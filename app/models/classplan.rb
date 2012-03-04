class Classplan < ActiveRecord::Base
  belongs_to :period
  belongs_to :assignment
  belongs_to :classroom
  def day_begin_time
    self.day + self.begin_time
  end
end
