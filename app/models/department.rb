class Department < ActiveRecord::Base
  has_many :courses
  has_many :lecturer
  has_many :people
end
