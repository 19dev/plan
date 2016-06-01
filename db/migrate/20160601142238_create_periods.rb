class CreatePeriods < ActiveRecord::Migration
  def change
    create_table :periods do |t|
      t.string :name
      t.integer :year
      t.boolean :status

      t.timestamps
    end
  end
end
