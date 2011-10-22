# encoding: utf-8
module ScheduleHelper
# Schedule -------------------------------------------------------
  def schedulenew
    lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] })
    @assignments = {}
    # tüm hocaların derslerini şu şekilde ekleyelim
    # courses = "1,BIL303-foo;2,BIL404-bar;#1"
    # courses = "1,BIL303-baz;2;#2"
    lecturers.select do |lecturer|
      if Assignment.find(:first, :conditions => { :lecturer_id => lecturer.id, :period_id => session[:period_id] })
        assignments = Assignment.find(:all,
                                      :conditions => {
                                        :lecturer_id => lecturer.id,
                                        :period_id => session[:period_id]
                                      })
        courses = assignments.collect do |assignment|
        unless Classplan.find(:first,:conditions => {:assignment_id => assignment.id,:period_id => session[:period_id]})
          assignment.course_id.to_s + ',' + assignment.course.full_name.to_s
        end
        end
        courses = courses.compact # nil'lerden kurtulsun
        unless courses == []
          courses = courses.join(';')
          courses += '#' + lecturer.id.to_s
          @assignments[courses] = lecturer
        end
      end
    end
    @class = Classroom.find(:all)

    # courses = Course.find(:all, :conditions => {:department_id => session[:department_id]})
    # @unschedule_courses = courses.select do |course|
    #   !Assignment.find(:first, :conditions => { :course_id => course.id, :period_id => session[:period_id] })
    # end
  end
  def scheduleadd
    @assignment = Assignment.find(:first,
                                  :conditions => {
                                      :lecturer_id => params[:lecturer_id],
                                      :course_id => params[:course_id],
                                      :period_id => session[:period_id]
                                  })
    @assignments = Assignment.find(:all,
                                  :conditions => {
                                      :lecturer_id => params[:lecturer_id],
                                      :period_id => session[:period_id]
                                  })
    @assignments = @assignments.collect { |assignment| assignment.id }
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
        sec = day_en + hour.to_s + "-15"
        part = params[sec]
        if part.length == 2 and part[1] == ""
            session[:error] = day_tr+hour.to_s+":15"+" bölümünde sınıf işaretlenmemiş"
            return redirect_to "/user/schedulenew"
        elsif part.length == 1 and part[0] != ""
            session[:error] = day_tr+hour.to_s+":15"+" bölümünde saat işaretlenmemiş"
            return redirect_to "/user/schedulenew"
        elsif part[0] != "" and part[1] != ""
            choice = {
                      'period_id' => session[:period_id],
                      'assignment_id' => @assignment.id,
                      'day' => day_en,
                      'begin_time' => part[0],
                      'classroom_id' => part[1],
                    }
            if classplan = Classplan.find(:first,
                                          :conditions => {
                                                'period_id' => session[:period_id],
                                                'day' => day_en,
                                                'begin_time' => part[0],
                                                'classroom_id' => part[1],
                                            })

              session[:error] = day_tr + " " + hour.to_s + ":15" + "de "+
                "#{classplan.classroom.name} sınıfında "+
                "#{classplan.assignment.lecturer.department.name} bölümünden "+
                "öğretim elamanı #{classplan.assignment.lecturer.full_name} tarafından "+
                "#{classplan.assignment.course.full_name} dersi verilmektedir. Bu "+
                "bilginin düzeltilmesini istiyorsanız; "+
                "#{classplan.assignment.lecturer.department.name} bölümünün yöneticileri ile irtibata geçin."
              return redirect_to "/user/schedulenew"
            elsif classplan = Classplan.find(:first,
                                          :conditions => {
                                                'period_id' => session[:period_id],
                                                'day' => day_en,
                                                'begin_time' => part[0],
                                            })
                if @assignments.include?(classplan.assignment_id)
                  session[:error] = day_tr + " " + hour.to_s + ":15 " + "de "+
                    "#{classplan.classroom.name} sınıfında kaydetmeye çalıştığınız "+
                    "#{classplan.assignment.lecturer.department.name} bölümünden "+
                    "#{classplan.assignment.lecturer.full_name} isimli öğretim elamanı "+
                    "#{classplan.assignment.course.full_name} dersini vermektedir. Bu "+
                    "bilginin düzeltilmesini istiyorsanız; "+
                    "bu verdiği dersin gününü veya saatini değiştiriniz."
                  return redirect_to "/user/schedulenew"
                end
            end

            schedule << choice
        end
      end
    end
    # akşam
    (13..22).each do |hour|
      days.each do |day_en, day_tr|
        sec = day_en + hour.to_s + "-00"
        part = params[sec]
        if part.length == 2 and part[1] == ""
            session[:error] = day_tr+hour.to_s+":00"+" bölümünde sınıf işaretlenmemiş"
            return redirect_to "/user/schedulenew"
        elsif part.length == 1 and part[0] != ""
            session[:error] = day_tr+hour.to_s+":00"+" bölümünde saat işaretlenmemiş"
            return redirect_to "/user/schedulenew"
        elsif part[0] != "" and part[1] != ""
            choice = {
                      'period_id' => session[:period_id],
                      'assignment_id' => @assignment.id,
                      'day' => day_en,
                      'begin_time' => part[0],
                      'classroom_id' => part[1],
                    }
            if classplan = Classplan.find(:first,
                                          :conditions => {
                                                'period_id' => session[:period_id],
                                                'day' => day_en,
                                                'begin_time' => part[0],
                                                'classroom_id' => part[1],
                                            })

              session[:error] = day_tr + " " + hour.to_s + ":00" + "de "+
                "#{classplan.classroom.name} sınıfında "+
                "#{classplan.assignment.lecturer.department.name} bölümünden "+
                "öğretim elamanı #{classplan.assignment.lecturer.full_name} tarafından "+
                "#{classplan.assignment.course.full_name} dersi verilmektedir. Bu "+
                "bilginin düzeltilmesini istiyorsanız; "+
                "#{classplan.assignment.lecturer.department.name} bölümünün yöneticileri ile irtibata geçin."
              return redirect_to "/user/schedulenew"
            elsif classplan = Classplan.find(:first,
                                          :conditions => {
                                                'period_id' => session[:period_id],
                                                'day' => day_en,
                                                'begin_time' => part[0],
                                            })
                if @assignments.include?(classplan.assignment_id)
                  session[:error] = day_tr + " " + hour.to_s + ":00 " + "de "+
                    "#{classplan.classroom.name} sınıfında kaydetmeye çalıştığınız "+
                    "#{classplan.assignment.lecturer.department.name} bölümünden "+
                    "#{classplan.assignment.lecturer.full_name} isimli öğretim elamanı "+
                    "#{classplan.assignment.course.full_name} dersini vermektedir. Bu "+
                    "bilginin düzeltilmesini istiyorsanız; "+
                    "bu verdiği dersin gününü veya saatini değiştiriniz."
                  return redirect_to "/user/schedulenew"
                end
            end

            schedule << choice
        end
      end
    end
    schedule.each do |s|
      choice = Classplan.new s
      choice.save
    end
    session[:lecturer_id] = params['lecturer_id']
    # kayıt buraya kadar tamam.
    # şimdi ekrana göstermek için veri toplayalım

    redirect_to '/user/scheduleshow'
  end
  def scheduleshow
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    session[:course_ids] = {}
    assignments = Assignment.find(:all,
                                  :conditions => {
                                    :lecturer_id => session[:lecturer_id],
                                    :period_id => session[:period_id]
                                  })
    assignments.each do |assignment|
      if Classplan.find(:first, :conditions => { :period_id => session[:period_id], :assignment_id => assignment.id })
        classplans = Classplan.find(:all,
                                    :conditions => {
                                      :assignment_id => assignment.id,
                                      :period_id => session[:period_id]
                                  })
        courses = classplans.collect { |classplan| classplan.day + classplan.begin_time }
        courses = courses.join(';')
        unless courses == ""
          courses += '#' + assignment.id.to_s
          session[:course_ids][courses] = assignment.course.full_name
        end
      end
    end
  end
  def schedulereview
    lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] })
    @classplans = {}
    lecturers.each do |lecturer|
      if Assignment.find(:first, :conditions => { :lecturer_id => lecturer.id, :period_id => session[:period_id] })
        assignments = Assignment.find(:all,
                                      :conditions => {
                                        :lecturer_id => lecturer.id,
                                        :period_id => session[:period_id]
                                      })
        courses = assignments.collect do |assignment|
         if Classplan.find(:first, :conditions => { :assignment_id => assignment.id,:period_id => session[:period_id] })
            assignment.course_id
          end
        end
        courses = courses.compact
        if courses != []
          @classplans[lecturer] = courses
        end
      end
    end
  end
  def scheduleedit
    assignment = Assignment.find(params[:assignment_id])
    Classplan.delete_all ({
                          :assignment_id => params[:assignment_id],
                          :period_id => session[:period_id]
                        })
    session[:success] = "#{assignment.lecturer.full_name} isimli öğretim elamanının ders programından " +
                      "#{assignment.course.full_name} ile ilgili olan tüm alanlar bu dönemlik silinmiştir. " +
                      "Bu öğretim elamanının bu dersi için şimdi tekrardan ders/sınıf seçebilirsiniz."
    redirect_to '/user/schedulenew'
  end
  def scheduledel
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    assignments = Assignment.find(:all,
                                  :conditions => {
                                    :lecturer_id => session[:lecturer_id],
                                    :period_id => session[:period_id]
                                  })
    assignments.each do |assignment|
      Classplan.delete_all({
                            :assignment_id => assignment.id,
                            :period_id => session[:period_id]
                          })
    end

    session[:success] = "#{Lecturer.find(session[:lecturer_id]).full_name} isimli öğretim elamanının " +
                       "dönemlik tüm dersleri silindi"
    redirect_to '/user/schedulereview'
  end
  def scheduleupdate
  end
# end Schedule -------------------------------------------------------
end
