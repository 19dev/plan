class Period < ActiveRecord::Base
  has_many :assignment
  has_many :classplan
  has_many :lecturer, :through => :assignment
  has_many :course, :through => :assignment
  def full_name
    self.year.to_s + '-' + (self.year + 1).to_s + ' / ' + self.name
  end
end
