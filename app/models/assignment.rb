class Assignment < ActiveRecord::Base
  belongs_to :lecturer
  belongs_to :course
end
