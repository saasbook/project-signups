class CreateProjectPreferences < ActiveRecord::Migration
  def change
    create_table :project_preferences do |t|
      t.integer :level
      t.integer :group_id
      t.integer :project_id

      t.timestamps
    end
  end
end
