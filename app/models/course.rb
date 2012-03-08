class Course < ActiveRecord::Base
  has_many :assignment
  belongs_to :department
  has_many :lecturer, :through => :assignment
  def full_name
    self.code + ' - ' + self.name
  end
  def to_code
    require 'unicode'
    Unicode::upcase(self.code)
  end
end
