class CreateTeamEvaluations < ActiveRecord::Migration
  def change
    create_table :team_evaluations do |t|
      t.integer :grader_id
      t.integer :gradee_id
      t.integer :score
      t.integer :iteration_id
      t.string :comment

      t.timestamps
    end
  end
end
