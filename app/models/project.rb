class Project < ActiveRecord::Base
  has_one :self_project
  has_one :group, :through => :self_project
end
