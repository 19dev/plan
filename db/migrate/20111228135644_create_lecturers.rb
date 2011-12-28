class CreateLecturers < ActiveRecord::Migration
  def change
    create_table :lecturers do |t|
      t.integer :department_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :cell_phone
      t.string :work_phone
      t.boolean :status
      t.string :photo

      t.timestamps
    end
  end
end
