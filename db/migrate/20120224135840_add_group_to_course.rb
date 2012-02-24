class AddGroupToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :group, :boolean, :default => false
  end
end
