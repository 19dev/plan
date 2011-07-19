class CreateClassplans < ActiveRecord::Migration
  def self.up
    create_table :classplans do |t|
      t.integer :period_id
      t.integer :classroom_id
      t.integer :course_id
      t.integer :lecturer_id
      t.datetime :begin_time
      t.datetime :end_time

      t.timestamps
    end
  end

  def self.down
    drop_table :classplans
  end
end
