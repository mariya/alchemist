class IndustryPresence < ActiveRecord::Base
  belongs_to :municipality
  belongs_to :nace_code
end
