class Course < ActiveRecord::Base
#  belongs_to :department
  def full_name
    self.code + '-' + self.name
  end
end
