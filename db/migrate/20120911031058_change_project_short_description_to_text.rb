class ChangeProjectShortDescriptionToText < ActiveRecord::Migration
  def change
    change_column :projects, :short_description, :text, :limit => nil
  end
end
