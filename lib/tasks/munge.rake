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
      resource_name = row[1].strip
      i_start = 2
      i_end = 13
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
        end
      end
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
        ewc_indexes[ind] = rc.ewc_name if rc
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
      end
    end
  end
end