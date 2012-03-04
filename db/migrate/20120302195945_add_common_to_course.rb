class AddCommonToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :common, :boolean, :default => false
  end
end
