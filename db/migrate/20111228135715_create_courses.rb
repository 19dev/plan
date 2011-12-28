class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.integer :department_id
      t.string :code
      t.string :name
      t.integer :year
      t.integer :theoretical
      t.integer :practice
      t.integer :lab
      t.integer :credit

      t.timestamps
    end
  end
end
