# encoding: utf-8
module PlanHelper
  def lecturer_plan period_id, lecturer_id

    course_ids = {}
    assignments = Assignment.find(:all,
                                   :conditions => {
      :lecturer_id => lecturer_id,
      :period_id => period_id
    })
    assignments.each do |assignment|
      if Classplan.find(:first, :conditions => { :period_id => period_id, :assignment_id => assignment.id })
        classplans = Classplan.find(:all,
                                    :conditions => {
          :assignment_id => assignment.id,
          :period_id => period_id
        })
        courses = classplans.collect { |classplan| classplan.day + classplan.begin_time }
        courses = courses.join(';')
        unless courses == ""
          courses += '#' + assignment.id.to_s
          course_ids[courses] = assignment.course.full_name
        end
      end
    end

    return [course_ids, assignments.collect { |assignment| assignment.id }]
  end
  def class_plan period_id, classroom_id
    course_ids = {}
    assignments = Assignment.find(:all,
                                  :conditions => {
      :period_id => period_id
    })
    assignment_ids = []
    assignments.each do |assignment|
      if Classplan.find(:first, :conditions => { :period_id => period_id, :assignment_id => assignment.id })
        classplans = Classplan.find(:all,
                                    :conditions => {
          :assignment_id => assignment.id,
          :classroom_id => classroom_id,
          :period_id => period_id
        })
        courses = classplans.collect { |classplan| classplan.day + classplan.begin_time }
        courses = courses.join(';')
        unless courses == ""
          assignment_ids << assignment.id
          courses += '#' + assignment.id.to_s
          course_ids[courses] = assignment.course.full_name
        end
      end
    end
    return [course_ids, assignment_ids]
    end
end
