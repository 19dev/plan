class Course < ActiveRecord::Base
  has_one :assignment
  belongs_to :department
  def full_name
    self.department.code + self.code + ' - ' + self.name
  end
end
