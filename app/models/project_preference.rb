class ProjectPreference < ActiveRecord::Base
  belongs_to :group
  belongs_to :project

  MAX_PREFERENCE = 8

  validates :level, 
    :uniqueness => { :scope => :group_id, :message => "Only one preference per preference level per group" }, 
    :inclusion => { :in => 1..MAX_PREFERENCE }
  validates :project_id, :uniqueness => { :scope => :group_id, :message => "Each preference level must have a different project" }
end
