class AddEmailsDeliveredToIteration < ActiveRecord::Migration
  def self.up
    add_column :iterations, :emails_delivered, :boolean, :default => false
  end

  def self.down
    remove_column :iterations, :emails_delivered
  end
end
