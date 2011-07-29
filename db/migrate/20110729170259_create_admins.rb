class CreateAdmins < ActiveRecord::Migration
  def self.up
    create_table :admins do |t|
      t.integer :department_id
      t.string :first_name
      t.string :last_name
      t.string :password

      t.timestamps
    end
  end

  def self.down
    drop_table :admins
  end
end
