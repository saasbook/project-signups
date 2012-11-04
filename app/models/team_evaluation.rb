class TeamEvaluation < ActiveRecord::Base
  belongs_to :grader, :class_name => "Student"
  belongs_to :gradee, :class_name => "Student"
  belongs_to :iteration
  belongs_to :group
  validates_presence_of :grader_id
  validates_presence_of :gradee_id
  validates_presence_of :score
  validates_presence_of :iteration_id
  validates_presence_of :comment
  validates_presence_of :group_id

  validate :cannot_evaluate_self
  validates :score, :inclusion => 0..10

  def cannot_evaluate_self
    errors[:base] << "You cannot evaluate yourself." if self.grader_id == self.gradee_id
  end


  def self.validate_evaluation(group, iteration, grader)
    if group.nil?
      return "Please select a valid group"
    end

    if iteration.nil?
      return "Please select a valid iteration"
    end

    if grader.nil?
      return "Please select your name"
    end

    if grader.group.id != group.id
      return "You do not belong in the group you are evaluating for"
    end

    return "success"
  end

  def self.parse_and_create_team_evaluations(group, iteration, grader, params)
    grader_id = grader.id
    group_id = group.id
    iteration_id = iteration.id
    other_student_ids = group.students.map(&:id) - [grader_id]

    other_student_ids.each do |student_id|
      # don't process or create any team eval entries if any required parameter is empty
      # or if any of scores are not within range
      return nil if params["student-#{student_id}-score"].blank? or params["student-#{student_id}-comment"].blank?
      return nil unless (0..10).include?(params["student-#{student_id}-score"].to_i)
    end

    # if we got here, everything's been filled out and valid. create team eval entries
    team_evaluations = []
    other_student_ids.each do |gradee_id|
      score = params["student-#{gradee_id}-score"]
      comment = params["student-#{gradee_id}-comment"]
      team_evaluation = self.create({:grader_id => grader_id, :gradee_id => gradee_id, :iteration_id => iteration_id, :score => score, :comment => comment, :group_id => group_id })
      team_evaluations << team_evaluation
    end

  end

  def self.grouped_team_evaluations(filters = {})
    conditions = ""
    if filters[:iteration_id].present?
      conditions += "iteration_id = #{filters[:iteration_id]}"
    end
    self.find(:all, 
      :order => "created_at desc, iteration_id desc, gradee_id asc",
      :include => [:grader, :gradee, :iteration],
      :conditions => conditions).group_by { |evaluation| [evaluation.grader_id, evaluation.iteration_id] }
  end


  def self.send_all_team_evaluations(iteration_id)
    # returns all group evaluations for each group and its group members evaluations of each other
    # can access hash of evaluations by group id
    # can further access each gradee's evaluation by gradee_id
    if Rails.env.development?
      # find a way to make this work on both environments..
      team_evaluations = self.find(:all, :conditions => ["iteration_id = ?", iteration_id], :order => "created_at desc", :group => [:grader_id, :gradee_id], :include => [:gradee])
    else
      team_evaluations = self.select("distinct on (grader_id, gradee_id) grader_id, gradee_id, id, created_at, group_id, score, comment").where("iteration_id = #{iteration_id}").order("grader_id desc, gradee_id desc, created_at desc").includes([:gradee])
    end

    iteration = Iteration.find_by_id(iteration_id)
    team_evaluations_for_group = team_evaluations.group_by { |evaluation| evaluation.group_id}
    team_evaluations_for_group.each_pair do |group_id, evaluations|
      team_evaluations_for_group[group_id] = evaluations.group_by { |evaluation| evaluation.gradee_id }
    end

    # send out emails for all groups and its members
    team_evaluations_for_group.each_pair do |group_id, team_evaluations_for_gradee_hash|
      team_evaluations_for_gradee_hash.each_pair do |gradee_id, gradee_evaluations|
        anonymized_evaluations = []
        gradee = nil
        gradee_evaluations.each do |evaluation|
          anonymized_evaluations.push( { :score => evaluation.score, :comment => evaluation.comment } )
          gradee = evaluation.gradee if gradee.nil?
        end
        TeamEvaluationMailer.team_evaluation_feedback(gradee, anonymized_evaluations, iteration).deliver
      end
    end
  end

end
