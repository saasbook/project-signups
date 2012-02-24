class SelfProject < ActiveRecord::Base
  # This means internal project
  belongs_to :group
  belongs_to :project
end
