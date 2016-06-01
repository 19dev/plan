class CreateClassplans < ActiveRecord::Migration
  def change
    create_table :classplans do |t|
      t.integer :period_id
      t.integer :classroom_id
      t.integer :assignment_id
      t.string :day
      t.string :begin_time

      t.timestamps
    end
  end
end
