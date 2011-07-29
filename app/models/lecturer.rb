class Lecturer < ActiveRecord::Base
  belongs_to :department
  def full_name
    self.first_name + ' ' + self.last_name
  end
end
