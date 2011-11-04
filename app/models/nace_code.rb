class NaceCode < ActiveRecord::Base
  has_and_belongs_to_many :industrial_processes
  has_and_belongs_to_many :industry_categories
end
