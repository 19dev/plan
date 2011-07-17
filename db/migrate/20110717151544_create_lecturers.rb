class CreateLecturers < ActiveRecord::Migration
  def self.up
    create_table :lecturers do |t|
      t.integer :department_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :cell_phone
      t.string :work_phone

      t.timestamps
    end
  end

  def self.down
    drop_table :lecturers
  end
end
