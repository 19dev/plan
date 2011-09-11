class Period < ActiveRecord::Base
  def full_name
    self.name + ' ' + self.year
  end
end
