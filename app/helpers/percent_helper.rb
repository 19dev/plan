# encoding: utf-8
module PercentHelper
  def assignment_percent department_id, period_id
    lecturer_count = Lecturer.where(:department_id => department_id).count
    done_lecturer_count = Assignment.joins(:lecturer).where(
      'lecturers.department_id' => department_id,
      'assignments.period_id' => period_id
    ).joins(:course).where(
    'courses.department_id' => department_id,
    ).group('assignments.lecturer_id').count.count
    assignment_percent = if lecturer_count != 0; done_lecturer_count * 100 / lecturer_count else 0 end
  end
  def schedule_percent department_id, period_id
    assignments = Assignment.joins(:course).where(
      'courses.department_id' => department_id,
      'assignments.period_id' => period_id
    ).select("assignments.id")
    all_assignment = 0
    done_assignment = 0
    assignments.each do |assignment|
      if Classplan.find(:first, :conditions => {
        :assignment_id => assignment.id,
        :period_id => period_id
      })
      done_assignment += 1
      end
      all_assignment += 1
    end
    schedule_percent = if all_assignment != 0; done_assignment * 100 / all_assignment else 0 end
  end
  def percent assignment_percent, schedule_percent
    state = if schedule_percent == 100 and assignment_percent == 100
      "up"
    elsif assignment_percent != 0
      "problem"
    else
      "down"
    end
  end
end
