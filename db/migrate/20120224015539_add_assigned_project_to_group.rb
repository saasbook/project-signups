class AddAssignedProjectToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :assigned_project_id, :integer
  end
end
