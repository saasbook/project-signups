class Student < ActiveRecord::Base
  belongs_to :group
  has_many :given_team_evaluations, :foreign_key => "grader_id", :class_name => "TeamEvaluation"
  has_many :received_team_evaluations, :foreign_key => "gradee_id", :class_name => "TeamEvaluation"

  def full_name
    first = nick_name.blank? ? first_name : nick_name
    "#{first} #{last_name}"
  end
end
