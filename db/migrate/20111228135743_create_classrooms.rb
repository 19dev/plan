class CreateClassrooms < ActiveRecord::Migration
  def change
    create_table :classrooms do |t|
      t.string :name
      t.string :floor
      t.integer :capacity
      t.string :description

      t.timestamps
    end
  end
end
