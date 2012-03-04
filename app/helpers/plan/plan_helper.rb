# encoding: utf-8
module Plan
  module PlanHelper
    def lecturer_plan period_id, lecturer_id
      #---v1.1
      course_ids = {}
      assignment_ids = []
      assignments = Lecturer.find(lecturer_id).assignment.find_all_by_period_id(1)
      assignments.each do |assignment|
        if classplans = Classplan.find_all_by_assignment_id_and_period_id(assignment.id, period_id)
          if (courses = classplans.collect { |classplan| classplan.day_begin_time }.join(';')) != ""
            assignment_ids << assignment.id
            courses += '#' + assignment.id.to_s
            course_ids[courses] = assignment.course.full_name
          end
        end
      end

      # #---v1
      # course_ids = {}
      # assignment_ids = []
      # assignments = Assignment.find(:all,
      #                                :conditions => {
      #   :lecturer_id => lecturer_id,
      #   :period_id => period_id
      # })
      # assignments.each do |assignment|
      #   if Classplan.find(:first, :conditions => { :period_id => period_id, :assignment_id => assignment.id })
      #     classplans = Classplan.find(:all,
      #                                 :conditions => {
      #       :assignment_id => assignment.id,
      #       :period_id => period_id
      #     })
      #     courses = classplans.collect { |classplan| classplan.day + classplan.begin_time }.join(';')
      #     unless courses == ""
      #       assignment_ids << assignment.id
      #       courses += '#' + assignment.id.to_s
      #       course_ids[courses] = assignment.course.full_name
      #     end
      #   end
      # end
      return [course_ids, assignment_ids]
    end
    def class_plan period_id, classroom_id

      #---v1.1
      course_ids = {}
      assignment_ids = []
      assignments = Classroom.find(classroom_id).assignment.find_all_by_period_id(1)
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

      # #---v1
      # course_ids = {}
      # assignment_ids = []
      # assignments = Assignment.find(:all,
      #                               :conditions => {
      #   :period_id => period_id
      # })
      # assignments.each do |assignment|
      #   if Classplan.find(:first, :conditions => { :period_id => period_id, :assignment_id => assignment.id })
      #     classplans = Classplan.find(:all,
      #                                 :conditions => {
      #       :assignment_id => assignment.id,
      #       :classroom_id => classroom_id,
      #       :period_id => period_id
      #     })
      #     courses = classplans.collect { |classplan| classplan.day_begin_time }.join(';')
      #     unless courses == ""
      #       assignment_ids << assignment.id
      #       keys = course_ids.collect {|key, value| key.split("#")[0]}
      #       unless keys.include?(courses)
      #         courses += '#' + assignment.id.to_s
      #         course_ids[courses] = assignment.course.full_name
      #       end
      #     end
      #   end
      # end

      # # hmm v1
      #
      # classplans = Classplan.find(:all, :conditions =>{
      #   'period_id' => period_id,
      #   'classroom_id' => classroom_id,},
      # :select => "assignment_id", :group => "assignment_id")
      # assignment_ids = classplans.collect {|classplan| classplan.assignment_id }
      #
      # # hmm v2
      #
      # assignments = Classroom.find(classroom_id).assignment.find_all_by_period_id(1)
      # assignment_ids = assignments.collect {|assignment| assignment.id }
      #
      # # hmm v3
      #
      # classplans = Classplan.find_all_by_classroom_id_and_period_id(classroom_id, period_id)
      # assignment_ids = classplans.collect {|classplan| classplan.assignment_id }.uniq
      #
      # # hmm v4
      #
      # classplans = Classplan.group("assignment_id").find_all_by_classroom_id_and_period_id(classroom_id, period_id)
      return [course_ids, assignment_ids]
    end
  end
end
