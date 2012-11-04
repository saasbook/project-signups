class AddDeliveredtoTeamEvaluation < ActiveRecord::Migration
  def self.up
    add_column :team_evaluations, :delivered, :boolean, :default => false
  end

  def self.down
    remove_column :team_evaluations, :delivered
  end
end
