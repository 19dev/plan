class Courses < ActiveRecord::Base
  def full_name
    self.code + '-' + self.name
  end
end
