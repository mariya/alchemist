class Input < ActiveRecord::Base
  belongs_to :industrial_process
  belongs_to :resource
end
