class Period < ActiveRecord::Base
  has_many :assignment
  has_many :classplan
  def full_name
    self.year.to_s + '-' + (self.year + 1).to_s + ' / ' + self.name
  end
end
