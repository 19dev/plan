class Classroom < ActiveRecord::Base
  has_many :classplan
  has_many :assignment, :through => :classplan
  def has_plan? period_id
    assignments = Classroom.find(self.id).assignment.find_all_by_period_id(period_id)
    assignments.each { |assignment| return true if Classplan.find_all_by_assignment_id_and_classroom_id_and_period_id(assignment.id, self.id, period_id) }
    return false
  end
end
