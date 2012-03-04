class Lecturer < ActiveRecord::Base
  has_many :assignment
  belongs_to :department
  has_many :course, :through => :assignment
  def full_name
    self.first_name + ' ' + self.last_name
  end
end
