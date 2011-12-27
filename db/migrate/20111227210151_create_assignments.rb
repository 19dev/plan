class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :period_id
      t.integer :lecturer_id
      t.integer :course_id

      t.timestamps
    end
  end
end
