class Department < ActiveRecord::Base
  has_many :courses
  has_many :lecturer
end
