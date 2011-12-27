class Assignment < ActiveRecord::Base
  belongs_to :lecturer
  belongs_to :course
  has_many :assignment
  has_many :classplan
end
