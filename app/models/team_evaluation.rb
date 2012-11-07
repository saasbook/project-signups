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

  validates :score, :inclusion => -3..1

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
    student_ids = group.students.map(&:id)

    student_ids.each do |student_id|
      # don't process or create any team eval entries if any required parameter is empty
      # or if any of scores are not within range
      return nil if params["student-#{student_id}-score"].blank? or params["student-#{student_id}-comment"].blank?
      return nil unless (-3..1).include?(params["student-#{student_id}-score"].to_i)
    end

    # if we got here, everything's been filled out and valid
    # check if this grader has submitted any other evaluations for this iteration, 
    # if so, mark these previous evaluations' delivered to true to prevent delivery later
    previous_evaluations = TeamEvaluation.find(:all, :conditions => ["grader_id = ? and iteration_id = ? and delivered = ?", grader_id, iteration_id, false])
    previous_evaluations.each do |evaluation|
      evaluation.delivered = true
      evaluation.save
    end

    # create team eval entries
    team_evaluations = []
    student_ids.each do |gradee_id|
      score = params["student-#{gradee_id}-score"]
      comment = params["student-#{gradee_id}-comment"]
      team_evaluation = self.create({:grader_id => grader_id, :gradee_id => gradee_id, :iteration_id => iteration_id, :score => score, :comment => comment, :group_id => group_id })
      team_evaluations << team_evaluation
    end
    return team_evaluations
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


  def self.get_evaluations_delivered_for_group_hash(team_evaluations, students_for_group_hash)
    evaluations_count_for_group_hash = team_evaluations.group_by {|evaluation| evaluation.group_id}

    # if all evaluations have been delivered, number of evaluations for this group total
    # should = (group size) * (group size - 1)
    all_evaluations_received_for_group_hash = {}
    evaluations_count_for_group_hash.each_pair do |group_id, evaluations_arr|
      evaluations_count_for_group_hash[group_id] = evaluations_arr.size
      num_students_for_group = students_for_group_hash[group_id].size
      all_evaluations_received_for_group_hash[group_id] = (evaluations_count_for_group_hash[group_id] == num_students_for_group * (num_students_for_group - 1))
    end
    return all_evaluations_received_for_group_hash
  end


  def self.get_evaluations_for_gradee_hash(team_evaluations)
    # groups all evaluations by gradee first, then by iteration id
    evaluations_for_gradee_hash = team_evaluations.group_by {|evaluation| evaluation.gradee_id}
    evaluations_for_gradee_hash.each_pair do |gradee_id, evaluations_arr|
      gradee_evaluations_for_iteration_hash = evaluations_arr.group_by { |evaluation| evaluation.iteration_id }
      evaluations_for_gradee_hash[gradee_id] = gradee_evaluations_for_iteration_hash
    end
    return evaluations_for_gradee_hash
  end

  def self.get_recent_evaluations(include_assocs, iteration_id = nil, group_id = nil)
    distinct_clause = "grader_id, gradee_id"
    group_by_clause = [:grader_id, :gradee_id]
    order_by_clause = "grader_id desc, gradee_id desc, created_at desc"
    if group_id.present? and iteration_id.present?
      # we deliver to a specific group
      conditions = ["iteration_id = ? and group_id = ?", iteration_id, group_id]
    elsif iteration_id.present?
      # we deliver all evaluations for a specific iteration
      conditions = ["iteration_id = ? and delivered = ?", iteration_id, false]
    else
      # student index page, get all recent evaluations
      conditions = []
      distinct_clause = "grader_id, gradee_id, iteration_id"
      group_by_clause = [:grader_id, :gradee_id, :iteration_id]
      order_by_clause = "grader_id desc, gradee_id desc, iteration_id desc, created_at desc"
    end

    if Rails.env.development?
      # find a way to make this call work on both environments
      team_evaluations = self.find(:all, :conditions => conditions, :order => "created_at desc", :group => group_by_clause, :include => include_assocs)
    else
      team_evaluations = self.select("distinct on (#{distinct_clause}) grader_id, gradee_id, iteration_id, id, created_at, group_id, score, comment, delivered").where(conditions).order(order_by_clause).includes(include_assocs)
    end

    return team_evaluations
  end

  def self.send_group_team_evaluations(iteration_id, group_id)
    iteration = Iteration.find_by_id(iteration_id)
    group = Group.find_by_id(group_id)
    return nil if iteration.nil? || group.nil?

    team_evaluations = self.get_recent_evaluations([:gradee], iteration_id, group_id)

    # exploit our delivery method given an array of team evaluations. mmm, dry.
    self.deliver_evaluations_by_group_and_gradee(team_evaluations, iteration)
  end

  def self.send_all_team_evaluations(iteration_id)
    iteration = Iteration.find_by_id(iteration_id)
    if iteration.emails_delivered == true
      # dont send to everyone again (just in case)
      return false
    else
      # deliver what we have right now to each group, and mark iteration as delivered
      iteration.emails_delivered = true
      iteration.save

      # returns all recent group evaluations for each group and its group members'
      # evaluations of each other
      team_evaluations = self.get_recent_evaluations([:gradee], iteration_id)

      # exploit our delivery method given an array of team evaluations. mmm, dry.
      return self.deliver_evaluations_by_group_and_gradee(team_evaluations, iteration)
    end
  end

  def self.deliver_evaluations_by_group_and_gradee(team_evaluations, iteration)
    # takes an array of team evaluations and groups them by group_id, and then by gradee_id
    # so that we deliver evaluations group by group, gradee by gradee, yippee
    team_evaluations_for_group = team_evaluations.group_by { |evaluation| evaluation.group_id}
    team_evaluations_for_group.each_pair do |group_id, evaluations|
      team_evaluations_for_group[group_id] = evaluations.group_by { |evaluation| evaluation.gradee_id }
    end

    team_evaluations_for_group.each_pair do |group_id, team_evaluations_for_gradee_hash|
      team_evaluations_for_gradee_hash.each_pair do |gradee_id, gradee_evaluations|
        anonymized_evaluations = []
        gradee = nil
        gradee_evaluations.each do |evaluation|
          evaluation.delivered = true
          evaluation.save
          # find all other evaluations and mark as delivered
          anonymized_evaluations.push( { :score => evaluation.score, :comment => evaluation.comment } )
          gradee = evaluation.gradee if gradee.nil?
        end
        TeamEvaluationMailer.team_evaluation_feedback(gradee, anonymized_evaluations, iteration).deliver
      end
    end
    return true
  end

end
