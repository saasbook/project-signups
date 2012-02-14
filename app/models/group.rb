class Group < ActiveRecord::Base
  has_many :students

  def student_names
    students.map{|x| x.full_name}
  end
end
