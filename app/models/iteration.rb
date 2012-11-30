class Iteration < ActiveRecord::Base
  has_many :team_evaluations
  validates_presence_of :name
  validates_presence_of :due_date

  def self.get_iteration_select_options
    iterations = Iteration.find(:all, :order => "due_date asc")

    iteration_names = iterations.map(&:name)
    iteration_due_dates = iterations.map(&:due_date)

    iteration_names.each_with_index {|name, index| iteration_names[index] = name + ' (due ' + iteration_due_dates[index].strftime('%m/%d') + ')' }
    iteration_select_options = iteration_names.zip(iterations.map(&:id)).unshift([])
    return iteration_select_options
  end
end
