class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.integer :department_id
      t.string :code
      t.string :name
      t.string :theoretical
      t.string :practice
      t.string :lab
      t.integer :credit

      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
