class Period < ActiveRecord::Base
  def full_name
    self.name + ' ' + self.year.to_s + '-' + (self.year + 1).to_s
  end
end
