class Output < ActiveRecord::Base
  belongs_to :industry_category
  belongs_to :resource_category
end
