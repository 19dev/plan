# encoding: utf-8
module ScheduleHelper
# Schedule -------------------------------------------------------
  def schedulenew
    lecturers = Lecturer.find(:all, :conditions => {:department_id => session[:department_id]})
    @lecturers = lecturers.select do |lecturer|
      Assignment.find(:first, :conditions => { :period_id => session[:period_id], :lecturer_id => lecturer.id })
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
