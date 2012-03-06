class Lecturer < ActiveRecord::Base
  has_many :assignment
  belongs_to :department
  has_many :course, :through => :assignment
  def full_name
    self.first_name + ' ' + self.last_name
  end
  # def assignment period_id # main_helper böyle bir şey yapılabilir
  #   Assignment.find_all_by_lecturer_id_and_period_id(self.id, period_id)
  # end
end
