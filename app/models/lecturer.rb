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
  def credits period_id
    evening_time = (17..22).collect { |h| "#{h}-00" } # doğrusu table_schmea'dan çekilmeli FIXME
    assignments = Lecturer.find(self.id).assignment.find_all_by_period_id(period_id)
    credits = assignments.inject({"morning" => 0, "evening" => 0}) do |credit, assignment|
      if classplans = Classplan.find_all_by_assignment_id_and_period_id(assignment.id, period_id)
        evening_classplans = Classplan.find_all_by_assignment_id_and_period_id_and_begin_time(assignment.id, period_id, evening_time)
        credit["morning"] += assignment.course.credit if classplans.count - evening_classplans.count > 0
        credit["evening"] += assignment.course.credit if evening_classplans.count > 0
      end
      credit
    end
    return credits
  end
end
