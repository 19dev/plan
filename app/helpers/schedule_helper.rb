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
    @assignment = Assignment.find(:first, :conditions => { :period_id => session[:period_id],
                                             :lecturer_id => params['lecturer_id'],
                                             :course_id => params['course_id']
                                              })
    # @assignment.id
    schedule = []
    days = {"Sunday" => "Pazartesi",
            "Tuesday" => "Salı",
            "Wednesday" => "Çarşamba",
            "Thursday" => "Perşembe",
            "Friday" => "Cuma"}

    # sabah
    (8..11).each do |hour|
      days.each do |day_en, day_tr|
        sec = day_en + hour.to_s + ":15"
        part = params[sec]
        if part.length == 2 and part[1] == ""
            session[:error] = day_tr+hour.to_s+":15"+"  bölümünde sınıf işaretlenmemiş"
            return redirect_to "/user/schedulenew"
        elsif part.length == 1 and part[0] != ""
            session[:error] = day_tr+hour.to_s+":15"+"  bölümünde saat işaretlenmemiş"
            return redirect_to "/user/schedulenew"
        elsif part[0] != "" and part[1] != ""
            schedule << {
                      'period_id' => session[:period_id],
                      'assignment_id' => @assignment.id,
                      'day' => day_en,
                      'begin_time' => part[0],
                      'classroom_id' => part[1],
                    }
        end
      end
    end
    # akşam
    (13..22).each do |hour|
      days.each do |day_en, day_tr|
        sec = day_en + hour.to_s + ":00"
        part = params[sec]
        if part.length == 2 and part[1] == ""
            session[:error] = day_tr+hour.to_s+":00"+"  bölümünde sınıf işaretlenmemiş"
            return redirect_to "/user/schedulenew"
        elsif part.length == 1 and part[0] != ""
            session[:error] = day_tr+hour.to_s+":00"+"  bölümünde saat işaretlenmemiş"
            return redirect_to "/user/schedulenew"
        elsif part[0] != "" and part[1] != ""
            schedule << {
                      'period_id' => session[:period_id],
                      'assignment_id' => @assignment.id,
                      'day' => day_en,
                      'begin_time' => part[0],
                      'classroom_id' => part[1],
                    }
        end
      end
    end
    schedule.each do |s|
      choice = Classplan.new s
      choice.save
    end

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
