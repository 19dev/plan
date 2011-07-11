class CreateClassPlans < ActiveRecord::Migration
  def self.up
    create_table :class_plans do |t|
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
    drop_table :class_plans
  end
end
