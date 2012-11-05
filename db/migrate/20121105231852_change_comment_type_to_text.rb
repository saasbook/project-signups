class ChangeCommentTypeToText < ActiveRecord::Migration
  def self.up
    change_column :team_evaluations, :comment, :text
  end

  def self.down
    change_column :team_evaluations, :comment, :string
  end
end
