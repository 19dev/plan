# encoding: utf-8
module ScheduleHelper
# Schedule -------------------------------------------------------
  def schedulenew
    lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] })
    @assignments = {}
    lecturers.select do |lecturer|
      if Assignment.find(:first, :conditions => { :period_id => session[:period_id], :lecturer_id => lecturer.id })
        ham_dersler = ""
        b = Assignment.find(:all, :conditions => { :period_id => session[:period_id], :lecturer_id => lecturer.id })
        b.each do |ass|
          ham_dersler += ";" if ham_dersler
          ham_dersler += ass.course_id.to_s + "," + ass.course.full_name.to_s
          #= ass.lecturer.full_name
        end
        ham_dersler += '#' + lecturer.id.to_s
        @assignments[ham_dersler] = lecturer
      end
    @class = Classroom.find(:all)
    end

    # courses = Course.find(:all, :conditions => {:department_id => session[:department_id]})
    # @unschedule_courses = courses.select do |course|
    #   !Assignment.find(:first, :conditions => { :course_id => course.id, :period_id => session[:period_id] })
    # end
  end
  def scheduleadd
    @a = params
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
