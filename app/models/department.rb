class Department < ActiveRecord::Base
  has_many :course
  has_many :lecturer
  has_many :people
  belongs_to :faculty
end
