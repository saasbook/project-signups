class Group < ActiveRecord::Base
  has_many :students
  has_many :self_projects
  has_many :private_projects, :through => :self_projects, :source => :project
  has_many :project_preferences

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
end
