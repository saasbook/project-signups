class Group < ActiveRecord::Base
  has_many :students
  has_many :team_evaluations

  # This makes no sense
  # FIXME: In the future, completely rewrite it because it makes no sense
  has_many :self_projects
  has_many :private_projects, :through => :self_projects, :source => :project

  has_many :project_preferences, :dependent => :destroy
  # This is so confusing
  belongs_to :assigned_project, :class_name => "Project", :foreign_key => :assigned_project_id

  def student_names
    if students.empty?
      []
    else
      students.map{|x| x.full_name}
    end
  end

  # Literally the name you see in a dropdown menu
  def select_name
    "#{id}) #{students.map{|x| "#{x.first_name} #{x.last_name[0]}."}.join(", ")}"
  end

  def self.get_group_select_options
    groups = Group.all
    group_select_options = groups.map(&:id).zip(groups.map(&:id)).unshift([])
    return group_select_options
  end

  def get_all_students_select_options
    return nil if self.nil?
    all_students = self.students.find(:all, :select => "id, first_name, last_name, nick_name")
    all_students_select_options = all_students.map(&:full_name).zip(all_students.map(&:id)).unshift([])
    return all_students_select_options
  end

end
