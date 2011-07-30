class CreateAssignments < ActiveRecord::Migration
  def self.up
    create_table :assignments do |t|
      t.integer :period_id
      t.integer :lecturer_id
      t.integer :course_id

      t.timestamps
    end
  end

  def self.down
    drop_table :assignments
  end
end
