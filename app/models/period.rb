class Period < ActiveRecord::Base
  def full_name
    self.year.to_s + '-' + (self.year + 1).to_s + ' / ' + self.name
  end
end
