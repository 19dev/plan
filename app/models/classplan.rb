class Classplan < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :classroom
end
