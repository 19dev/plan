# encoding: utf-8
module Plan
  module PlanHelper
    def lecturer_plan period_id, lecturer_id

      course_ids = {}
      assignment_ids = []
      assignments = Lecturer.find(lecturer_id).assignment.find_all_by_period_id(period_id)
      assignments.each do |assignment|
        if classplans = Classplan.find_all_by_assignment_id_and_period_id(assignment.id, period_id)
          if (courses = classplans.collect { |classplan| classplan.day_begin_time }.join(';')) != ""
            assignment_ids << assignment.id
            courses += '#' + assignment.id.to_s
            course_ids[courses] = assignment.course.full_name
          end
        end
      end

      return [course_ids, assignment_ids]
    end

    def class_plan period_id, classroom_id

      course_ids = {}
      assignment_ids = []
      assignments = Classroom.find(classroom_id).assignment.find_all_by_period_id(period_id)
      assignments.each do |assignment|
        if classplans = Classplan.find_all_by_assignment_id_and_classroom_id_and_period_id(assignment.id, classroom_id, period_id)
          if (courses = classplans.collect { |classplan| classplan.day_begin_time }.join(';')) != ""
            unless course_ids.collect {|key, value| key.split("#")[0]}.include?(courses)
              assignment_ids << assignment.id
              courses += '#' + assignment.id.to_s
              course_ids[courses] = assignment.course.full_name
            end
          end
        end
      end

      return [course_ids, assignment_ids]
    end
  end
end
