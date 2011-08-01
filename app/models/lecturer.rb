class Lecturer < ActiveRecord::Base
  has_many :assignment
  belongs_to :department
  def full_name
    self.first_name + ' ' + self.last_name
  end
  def image_with_full_name
    "<%= image_tag " + self.photo + "%>" + self.first_name + ' ' + self.last_name
  end
end
