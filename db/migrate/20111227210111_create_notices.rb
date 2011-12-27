class CreateNotices < ActiveRecord::Migration
  def change
    create_table :notices do |t|
      t.string :content

      t.timestamps
    end
  end
end
