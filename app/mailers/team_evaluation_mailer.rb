class TeamEvaluationMailer < ActionMailer::Base
  default from: "cs169-fa12-staff@lists.eecs.berkeley.edu"
  include SendGrid
  sendgrid_category :use_subject_lines

  def team_evaluation_feedback(gradee, anonymized_evaluations, iteration)
    @iteration_name = iteration.name
    @anonymized_evaluations = anonymized_evaluations
    @gradee = gradee
    subject = "Team Evaluation Feedback for #{@iteration_name}"
    mail(:to => gradee.email, :subject => subject)
  end
end
