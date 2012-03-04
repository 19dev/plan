class Classroom < ActiveRecord::Base
  has_many :classplan
  has_many :assignment, :through => :classplan
end
