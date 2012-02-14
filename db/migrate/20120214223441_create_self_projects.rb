class CreateSelfProjects < ActiveRecord::Migration
  def change
    create_table :self_projects do |t|
      t.references :group
      t.references :project
    end
  end
end
