# encoding: utf-8
include SchemaHelper # schema helper
module ScheduleHelper
  def schedulenew
    # lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] })
    # @assignments = {}
    # # tüm hocaların derslerini şu şekilde ekleyelim
    # # courses = "1,BIL303-foo;2,BIL404-bar;#1"
    # # courses = "1,BIL303-baz;2;#2"
    # lecturers.select do |lecturer|
    #   if Assignment.find(:first, :conditions => { :lecturer_id => lecturer.id, :period_id => session[:period_id] })
    #     assignments = Assignment.find(:all,
    #                                   :conditions => {
    #       :lecturer_id => lecturer.id,
    #       :period_id => session[:period_id]
    #     })
    #     courses = assignments.collect do |assignment|
    #       unless Classplan.find(:first,:conditions => {:assignment_id => assignment.id,:period_id => session[:period_id]})
    #         assignment.course_id.to_s + ',' + assignment.course.full_name.to_s
    #       end
    #     end
    #     courses = courses.compact # nil'lerden kurtulsun
    #     unless courses == []
    #       courses = courses.join(';')
    #       courses += '#' + lecturer.id.to_s
    #       @assignments[courses] = lecturer
    #     end
    #   end
    # end
    # lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] })

    assignments = Assignment.joins(:course).where(
      'courses.department_id' => session[:department_id],
      'assignments.period_id' => session[:period_id]
    )
    @assignments = {}
    # tüm hocaların derslerini şu şekilde ekleyelim
    # courses = "1,BIL303-foo;2,BIL404-bar;#1"
    # courses = "1,BIL303-baz;2;#2"
    lecturer_ids = assignments.collect { |assignment| assignment.lecturer_id }

    lecturer_ids.uniq!

    lecturer_ids.each do |lecturer_id|
      assignments = Assignment.find(:all,
                                    :conditions => {
        :lecturer_id => lecturer_id,
        :period_id => session[:period_id]
      })
      courses = assignments.collect do |assignment|
        if !Classplan.find(:first, :conditions => {:assignment_id => assignment.id, :period_id => session[:period_id]}) and
            assignment.course.department_id == session[:department_id]
          assignment.course_id.to_s + ',' + assignment.course.full_name.to_s
        end
      end
      courses = courses.compact # nil'lerden kurtulsun
      unless courses == []
        courses = courses.join(';')
        courses += '#' + lecturer_id.to_s
        @assignments[courses] = Lecturer.find(lecturer_id)
      end
    end

    @class = Classroom.find(:all, :order => 'name')

    # courses = Course.find(:all, :conditions => {:department_id => session[:department_id]})
    # @unschedule_courses = courses.select do |course|
    #   !Assignment.find(:first, :conditions => { :course_id => course.id, :period_id => session[:period_id] })
    # end

    @day, @header, @launch, @morning, @evening, morning_time, evening_time = table_schema # standart tablo şeması
    morning_time.each do |hour|
      if hour.to_i < 13
        column = [hour + '-15' + ' / ' + (hour.to_i+1).to_s + '-00']
        hour = hour + '-15'
      else
        column = [hour + '-00' + ' / ' + (hour.to_i+1).to_s + '-00']
        hour = hour + '-00'
      end
      @day.each do |day_en, day_tr|
        classplan = Classplan.find(:first,
                                   :conditions => {
          :classroom_id => session[:classroom_id],
          :period_id => session[:period_id],
          :day => day_en,
          :begin_time => hour
        })
        if classplan and @assignments.include?(classplan.assignment_id)
          column << classplan.assignment.course.full_name + "\n" +
            classplan.assignment.lecturer.full_name + "\n" +
            classplan.assignment.lecturer.department.name
        else
          column << ""
        end
      end
      @morning << column
    end

    evening_time.each do |hour|
      column = [hour + '-00' + ' / ' + (hour.to_i+1).to_s + '-00']
      hour = hour + '-00'
      @day.each do |day_en, day_tr|
        classplan = Classplan.find(:first,
                                   :conditions => {
          :classroom_id => session[:classroom_id],
          :period_id => session[:period_id],
          :day => day_en,
          :begin_time => hour
        })
        if classplan and @assignments.include?(classplan.assignment_id)
          column << classplan.assignment.course.full_name + "\n" +
            classplan.assignment.lecturer.full_name + "\n" +
            classplan.assignment.lecturer.department.name
        else
          column << ""
        end
      end
      @evening << column
    end
  end
  def scheduleadd
    @assignment = Assignment.find(:first,
                                  :conditions => {
      :lecturer_id => params[:lecturer_id],
      :course_id => params[:course_id],
      :period_id => session[:period_id]
    })
    assignments = Assignment.find(:all,
                                  :conditions => {
      :lecturer_id => params[:lecturer_id],
      :period_id => session[:period_id]
    })
    @assignments = assignments.collect { |assignment| assignment.id }
    # @assignment.id
    schedule = []

    @day, @header, @launch, @morning, @evening, morning_time, evening_time = table_schema # standart tablo şeması
    # sabah
    morning_time.each do |hour|
      unless hour == @launch[0]
        if hour.to_i < 13
          hour = hour + "-15"
        else
          hour = hour + "-00"
        end
        @day.each do |day_en, day_tr|
          part = params[day_en + hour]
          if part.length == 2 and part[1] == ""
            session[:error] = day_tr+hour+" bölümünde sınıf işaretlenmemiş"
            return redirect_to "/user/schedulenew"
          elsif part.length == 1 and part[0] != ""
            session[:error] = day_tr+hour+" bölümünde saat işaretlenmemiş"
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

              session[:error] = day_tr + " " + hour + "de "+
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
                session[:error] = day_tr + " " + hour + " de "+
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
    end
    # akşam
    evening_time.each do |hour|
      hour = hour + "-00"
      @day.each do |day_en, day_tr|
        part = params[day_en + hour]
        if part.length == 2 and part[1] == ""
          session[:error] = day_tr+hour+" bölümünde sınıf işaretlenmemiş"
          return redirect_to "/user/schedulenew"
        elsif part.length == 1 and part[0] != ""
          session[:error] = day_tr+hour+" bölümünde saat işaretlenmemiş"
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

            session[:error] = day_tr + " " + hour + " de "+
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
              session[:error] = day_tr + " " + hour + " de "+
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
    @assignments = assignments.collect {|assignment| assignment.id }

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

    @day, @header, @launch, @morning, @evening, morning_time, evening_time = table_schema # standart tablo şeması

    morning_time.each do |hour|
      if hour.to_i < 13
        column = [hour + '-15' + ' / ' + (hour.to_i+1).to_s + '-00']
        hour = hour + '-15'
      else
        column = [hour + '-00' + ' / ' + (hour.to_i+1).to_s + '-00']
        hour = hour + '-00'
      end
      if hour.slice(0..1) == @launch[0]
        @launch.slice(1..-1).each {|l| column << l }
        @launch = column
        @morning << column
      else
        @day.each do |day_en, day_tr|
          classplan = Classplan.find(:first,
                                     :conditions => {
            :period_id => session[:period_id],
            :day => day_en,
            :begin_time => hour
          })
          if classplan and @assignments.include?(classplan.assignment_id)
            column << classplan.assignment.course.full_name
            column << classplan.classroom.name
          else
            column << ""
            column << ""
          end
        end
        @morning << column
      end
    end

    evening_time.each do |hour|
      column = [hour + '-00' + ' / ' + (hour.to_i+1).to_s + '-00']
      hour = hour + '-00'
      @day.each do |day_en, day_tr|
        classplan = Classplan.find(:first,
                                   :conditions => {
          :period_id => session[:period_id],
          :day => day_en,
          :begin_time => hour
        })
        if classplan and @assignments.include?(classplan.assignment_id)
          column << classplan.assignment.course.full_name
          column << classplan.classroom.name
        else
          column << ""
          column << ""
        end
      end
      @morning << column
    end

  end
  def schedulereview
    assignments = Assignment.joins(:course).where(
      'courses.department_id' => session[:department_id],
      'assignments.period_id' => session[:period_id]
    )
    lecturer_ids = assignments.collect { |assignment| assignment.lecturer_id }
    lecturer_ids.uniq!

    @classplans = {}
    lecturer_ids.each do |lecturer_id|
      if Assignment.find(:first, :conditions => { :lecturer_id => lecturer_id, :period_id => session[:period_id] })
        assignments = Assignment.find(:all,
                                      :conditions => {
          :lecturer_id => lecturer_id,
          :period_id => session[:period_id]
        })
        courses = assignments.collect do |assignment|
          if Classplan.find(:first, :conditions => { :assignment_id => assignment.id,:period_id => session[:period_id] })
            assignment.course_id
          end
        end
        courses = courses.compact
        if courses != []
          @classplans[Lecturer.find(lecturer_id)] = courses
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
end
