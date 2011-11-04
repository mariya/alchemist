class IndustryCategory < ActiveRecord::Base
  has_and_belongs_to_many :nace_codes
end
