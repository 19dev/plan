class AddContinuityToLecturer < ActiveRecord::Migration
  def change
    add_column :lecturers, :continuity, :boolean, :default => true
  end
end
