class Resource < ActiveRecord::Base
  has_and_belongs_to_many :resource_categories
end
