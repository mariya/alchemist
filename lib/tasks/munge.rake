require 'open-uri'
require 'json'
require 'cgi'

def geolocate(address)
  url = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=" + CGI::escape(address)
  result = JSON.parse(open(url).read)
  result = result['results'].first
  location = result['geometry']['location']
end

namespace :munge do
  desc "Parse CSV file mapping Industrial Processes to NACE codes and store in industrial_processes_nace table"
  task :map_industrial_processes_to_nace => :environment do
    csv_path = File.expand_path('../../data/industrial_processes_nace.csv', __FILE__)
    FasterCSV.foreach(csv_path) do |row|
      # Look up process by name
      process_name = row[3].strip
      process = IndustrialProcess.find_or_create_by_name(process_name)
      # First three fields are NACE codes
      for i in 0..2
        if row[i].to_i > 0
          nace = NaceCode.find_or_create_by_id(row[i])
          process.nace_codes << nace
          process.save
        end
      end
    end
  end

  desc "Parse SCB CSV file containing Swedish industrial presence data."
  task :swedish_industrial_presence, :csv_path, :needs => :environment do |t, args|
    csv_path = args['csv_path']
    FasterCSV.foreach(csv_path) do |row|
      # Municipality name is the third column
      municipality_name = row[2]
      unless municipality_name.blank?
        administrative_id = row[3].strip
        # If this is a valid name, look up or create the municipality
        if administrative_id.to_i > 0
          nace_code = row[4]
          # Proceed only of this is a valid NACE code
          if nace_code.to_i > 0
            municipality = Municipality.find_by_name(municipality_name.strip)
            if municipality.nil?
              # Grab coordinates using Google API
              location = geolocate("#{municipality_name.strip}, Sweden")
              municipality = Municipality.create(:name => municipality_name.strip, 
                                                 :country => "SE", 
		  			         :administrative_id => administrative_id, 
			  		         :latitude => location['lat'],
					         :longitude => location['lng'])
            end # End if municipality.nil?
            num_companies_with_employees = row[16]
            if num_companies_with_employees.to_i > 0
              industry_presence = IndustryPresence.find_or_create_by_municipality_id_and_nace_code_id(municipality.id, nace_code, :num_companies_with_employees => num_companies_with_employees)
            end
          end # End if administrative_id.to_i > 0
        end
      end
    end
  end

  desc "Parse list of EWC into Resource Categories"
  task :ewc, :needs => :environment do
    csv_path = File.expand_path('../../data/resource_categories.csv', __FILE__)
    last_supercat = nil
    FasterCSV.foreach(csv_path) do |row|
      # If the first column isn't blank, this is a super-category
      supercat_name = row[0].to_s.strip
      unless supercat_name.blank?
        supercat = ResourceCategory.find_or_create_by_ewc_name(supercat_name, :name => row[1].to_s.strip)
        last_supercat = supercat
      else # This is a child category of the last-defined supercat
        ewc = row[1].to_s.strip
        name = row[2].to_s.strip
        ResourceCategory.find_or_create_by_ewc_name(ewc, :name => name, :parent => last_supercat)
      end
    end
  end

  desc "Map EWC to resources"
  task :ewc_to_resources, :needs => :environment do
    csv_path = File.expand_path('../../data/resources_to_ewc.csv', __FILE__)    
    FasterCSV.foreach(csv_path) do |row|
      resource_name = row[0].strip
      resource_quantity = 0
      resource_quantity_s = row[2]
      resource_quantity = resource_quantity_s.strip.to_f if resource_quantity_s
      i_start = 5
      i_end = 16
      min_quantity = 0.02      
      if resource_quantity >= min_quantity
	for i in i_start..i_end do
	  val = row[i]
	  if val
	    ewc_name = val.strip
            resource_category = ResourceCategory.find_by_ewc_name(ewc_name)
            unless resource_category.nil?
              resource = Resource.find_or_create_by_name(resource_name)
              resource.resource_categories << resource_category unless resource.resource_categories.index(resource_category)
              resource.save
            end
	  end # End if val
	end # End for
      end # End if resource quantity significant
    end
  end

  desc "Map Industry Categories to Resource Categories, weighted with tons of non-hazardous waste produced in Sweden in 2008"
  task :outputs, :needs => :environment do
    csv_path = File.expand_path('../../data/outputs.csv', __FILE__)

    # Put the EWC codes in a lookup table
    ind_row_with_ewc_codes = 9
    csv = FasterCSV.read(csv_path)
    row_with_ewc_codes = csv[ind_row_with_ewc_codes]
    ewc_indexes = Array.new
    ind = 0
    row_with_ewc_codes.each do |val|
      unless val.nil?
        rc = ResourceCategory.find_by_ewc_name(val.strip)
        # If this is a valid EWC, put it in the lookup table
        ewc_indexes[ind] = rc.id if rc
      end
      ind += 1
    end

    # Parse the stats
    FasterCSV.foreach(csv_path) do |row|
      ind_group = row[0]
      # Does this row have a valid industrial grouping number?
      if !ind_group.blank? and ind_group.strip.to_i > 0
        industry_category_id = ind_group.strip.to_i
        industry_category_name = row[1].strip
        industry_category = IndustryCategory.find_or_create_by_id(industry_category_id, :name => industry_category_name)
        if industry_category
          # Loop through all values in this row. If one of them is an integer with the same index as an EWC code we're tracking, we want to capture the data
          ind = 0
          row.each do |val|
            ewc = ewc_indexes[ind]
            if ewc
              tons = val.strip.delete(",").to_i
              if tons > 0
                output = Output.find_or_create_by_industry_category_id_and_resource_category_id(industry_category.id, ewc, :tons_non_hazardous_waste_2008 => tons)
              end
            end
            ind += 1
          end
        end
      end
    end
  end

  desc "Map Industry Categories to NACE codes"
  task :industry_categories_to_nace, :needs => :environment do
    csv_path = File.expand_path('../../data/industry_categories_to_nace_codes.csv', __FILE__)
    FasterCSV.foreach(csv_path) do |row|
      ici = row[0]
      unless ici.nil?
        ici = ici.strip.to_i
        if ici > 0 and ic = IndustryCategory.find_by_id(ici)
          nace = row[1].strip.delete(".").to_i
          if nace > 0 and nc = NaceCode.find_by_id(nace)
            ic.nace_codes << nc unless ic.nace_codes.index(nc)
            ic.save
          end
        end
      end
    end
  end

  desc "Map industrial processes to resources"
  task :inputs, :needs => :environment do
    csv_path = File.expand_path('../../data/inputs.csv', __FILE__)
    FasterCSV.foreach(csv_path) do |row|
      industrial_process_name = row[0]
      resource_name = row[1]
      quantity = row[2]
      unless industrial_process_name.nil? or resource_name.nil? or quantity.to_f <= 0
        industrial_process_name = industrial_process_name.strip
        resource_name = resource_name.strip
        industrial_process = IndustrialProcess.find_by_name(industrial_process_name)
        resource = Resource.find_by_name(resource_name)
        if industrial_process and resource
          input = Input.find_or_create_by_industrial_process_id_and_resource_id(industrial_process.id, resource.id, :quantity => quantity)
        end
      end
    end
  end

  desc "Map nace codes to resource categories (outputs)"
  task :industry_categories_to_resource_categories, :needs => :environment do
    Output.find(:all).each do |output|
      ic = output.industry_category
      ic.nace_codes.each do |nc|
        nc.resource_categories << output.resource_category
        nc.save
      end
    end
  end

  desc "Map nace codes to resource categories (outputs)"
  task :industry_categories_to_resource_categories, :needs => :environment do
    Resource.find(:all).each do |resource|
      resource.industrial_processes.each do |ip|
        ip.nace_codes.each do |nc|
          nc.resources << resource
          nc.save
        end
      end
    end
  end
end