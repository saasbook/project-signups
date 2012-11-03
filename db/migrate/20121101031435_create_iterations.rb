class CreateIterations < ActiveRecord::Migration
  def change
    create_table :iterations do |t|
      t.string :name
      t.datetime :due_date

      t.timestamps
    end
  end
end
