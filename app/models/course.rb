class Course < ActiveRecord::Base
  has_one :assignment
  belongs_to :department
  def full_name
    self.code + ' - ' + self.name
  end
  def to_code
    require 'unicode'
    Unicode::upcase(self.code)
  end
end
