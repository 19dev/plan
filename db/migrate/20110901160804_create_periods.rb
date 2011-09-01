class CreatePeriods < ActiveRecord::Migration
  def self.up
    create_table :periods do |t|
      t.string :name
      t.integer :year
      t.boolean :status

      t.timestamps
    end
  end

  def self.down
    drop_table :periods
  end
end
