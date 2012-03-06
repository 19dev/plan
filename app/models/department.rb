class Department < ActiveRecord::Base
  has_many :course
  has_many :lecturer
  has_many :people
# has_many :faculty
  def assignment_percent period_id
    lecturer_count = Lecturer.where(:department_id => self.id).count
    done_lecturer_count = Assignment.joins(:lecturer).where(
      'lecturers.department_id' => self.id,
      'assignments.period_id' => period_id
    ).joins(:course).where(
    'courses.department_id' => self.id,
    ).group('assignments.lecturer_id').count.count
    (lecturer_count == 0) ? 0 : done_lecturer_count * 100 / lecturer_count
  end
  def schedule_percent period_id
    assignments = Assignment.joins(:course).where(
      'courses.department_id' => self.id,
      'assignments.period_id' => period_id
    ).select("assignments.id")
    assignment_count = 0
    done_assignment_count = 0
    assignments.each do |assignment|
      if Classplan.find(:first, :conditions => {
        :assignment_id => assignment.id,
        :period_id => period_id
      })
      done_assignment_count += 1
      end
      assignment_count += 1
    end
    (done_assignment_count == 0) ? 0 : done_assignment_count * 100 / assignment_count
  end
  def not_assignment_lecturer period_id
    lecturer_count = Lecturer.where(:department_id => self.id).count
    assignments = Assignment.joins(:lecturer).where(
      'lecturers.department_id' => self.id,
      'assignments.period_id' => period_id
    ).joins(:course).where(
    'courses.department_id' => self.id,
    ).group('assignments.lecturer_id')
    lecturer_ids = assignments.collect { |assignment| assignment.lecturer_id }
    (lecturer_ids == []) ? Lecturer.where(:department_id => self.id) : Lecturer.where('id not in (?)', lecturer_ids).where(:department_id => self.id)
  end
  def not_schedule_course period_id
    assignments = Assignment.joins(:course).where(
      'courses.department_id' => self.id,
      'assignments.period_id' => period_id
    ).select("assignments.course_id").group('assignments.course_id')

    _assignments = {}
    assignments.each do |assignment|
      assignments = Assignment.find(:all,
                                    :conditions => {
        :course_id => assignment.course_id,
        :period_id => period_id
      })
      lecturers = assignments.collect do |assignment|
        if !Classplan.find(:first, :conditions => {:assignment_id => assignment.id, :period_id => period_id})
          assignment.lecturer.full_name
        end
      end
      lecturers.compact! # nil'lerden kurtulsun
      unless lecturers == []
        lecturers = lecturers.join(';')
        _assignments[lecturers] = assignment.course.full_name
      end
    end
    _assignments
  end
end
