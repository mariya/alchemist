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
end