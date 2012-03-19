class Lecturer < ActiveRecord::Base
  has_many :assignment
  belongs_to :department
  has_many :course, :through => :assignment
  has_many :period, :through => :assignment
  def full_name
    self.first_name + ' ' + self.last_name
  end
  def has_plan? period_id
    assignments = Lecturer.find(self.id).assignment.find_all_by_period_id(period_id)
    assignments.each { |assignment| return true if Classplan.find_all_by_assignment_id_and_period_id(assignment.id, period_id) }
    return false
  end
  def courses period_id
    assignments = Lecturer.find(self.id).assignment.find_all_by_period_id(period_id)
    course_ids = assignments.inject([]) do |course_id, assignment|
      course_id << assignment.course_id if Classplan.find_all_by_assignment_id_and_period_id(assignment.id, period_id)
      course_id
    end
    return Course.find(course_ids, :order => 'code')
  end
end
