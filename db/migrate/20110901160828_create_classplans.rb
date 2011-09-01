class CreateClassplans < ActiveRecord::Migration
  def self.up
    create_table :classplans do |t|
      t.integer :period_id
      t.integer :classroom_id
      t.integer :assignment_id
      t.string :day
      t.time :begin_time

      t.timestamps
    end
  end

  def self.down
    drop_table :classplans
  end
end
