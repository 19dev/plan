# encoding: utf-8
module ScheduleHelper
# Schedule -------------------------------------------------------
  def schedulenew
    lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] })
    @assignments = {}
    lecturers.select do |lecturer|
      if Assignment.find(:first, :conditions => { :period_id => session[:period_id], :lecturer_id => lecturer.id })
        c = ""
        d = Assignment.find(:all, :conditions => { :period_id => session[:period_id], :lecturer_id => lecturer.id })
        d.each do |ass|
          if c
            c = c + ";"
          end
          c = c + ass.course_id.to_s+","+ass.course.full_name.to_s
          #= ass.lecturer.full_name
        end
        @assignments[c] = lecturer.full_name
      end
    end

    # courses = Course.find(:all, :conditions => {:department_id => session[:department_id]})
    # @unschedule_courses = courses.select do |course|
    #   !Assignment.find(:first, :conditions => { :course_id => course.id, :period_id => session[:period_id] })
    # end
  end
  def scheduleadd
  end
  def scheduleshow
  end
  def schedulereview
  end
  def scheduleedit
  end
  def scheduledel
  end
  def scheduleupdate
  end
# end Schedule -------------------------------------------------------
end
