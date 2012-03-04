class Assignment < ActiveRecord::Base
  belongs_to :period
  belongs_to :lecturer
  belongs_to :course
  has_many :classplan
  has_many :classroom, :through => :classplan
end
