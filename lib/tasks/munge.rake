# If a NACE code is less than five chars, pad it with leading zeros
def pad_nace(nace)
  nace = nace.to_s
  while nace.length < 5
    nace = "0" + nace
  end
  nace
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
end