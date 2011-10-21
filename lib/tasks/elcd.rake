namespace :elcd do
  desc "Get list of inputs from ELCD XML files"
  task :list_inputs do
    elcd_path = File.expand_path('../../ELCD', __FILE__)
    files = Dir::entries(elcd_path)
    inputs = []
    # Loop through all files in ELCD dir
    files.each do |fname|
      path = File.expand_path(fname, elcd_path)
      if path.index("xml")
        f = File.open(path)
        doc = Nokogiri::XML(f)
        # Search for all inputs in this file
        nodes = doc.css("exchange referenceToFlowDataSet")
        nodes.each do |n|
          input_name = n.children[1].content
          ind = inputs.index(input_name)
          if ind.nil?
            inputs << input_name
          end
        end
        f.close
      end
    end
    inputs.sort
    inputs.each do |input|
      puts input + "\n"
    end
  end
end