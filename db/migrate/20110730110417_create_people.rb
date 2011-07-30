class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.integer :department_id
      t.string :first_name
      t.string :last_name
      t.string :password
      t.integer :status
      t.string :photo

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
