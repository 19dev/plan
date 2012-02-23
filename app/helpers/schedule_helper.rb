# encoding: utf-8
include SchemaHelper # schema helper
module ScheduleHelper
  def schedulenew


    # assignments = Assignment.joins(:course).where(
    #   'courses.department_id' => session[:department_id],
    #   'assignments.period_id' => session[:period_id]
    # ).select("assignments.course_id").group('assignments.course_id')
    # @assignments = {}

    # assignments.each do |assignment|
    #   _assignments = Assignment.find(:all,
    #                                 :conditions => {
    #     :course_id => assignment.course_id,
    #     :period_id => session[:period_id]
    #   })
    #   _assignments = Assignment.joins(:classplan).where(
    #     'assignments.course_id' => assignment.course_id,
    #     'assignments.period_id' => session[:period_id],
    #     'classplans.period_id' => session[:period_id],
    #   )
    #   lecturers = _assignments.each do |_assignment|
    #     _assignment.lecturer_id.to_s + ',' + _assignment.lecturer.full_name.to_s
    #   end
    #   lecturers.compact! # nil'lerden kurtulsun
    #   unless lecturers == []
    #     lecturers = lecturers.join(';') + '#' + assignment.course_id.to_s
    #     @assignments[lecturers] = assignment.course.full_name
    #   end
    # end


    assignments = Assignment.joins(:course).where(
      'courses.department_id' => session[:department_id],
      'assignments.period_id' => session[:period_id]
    ).select("assignments.course_id").group('assignments.course_id')
    @assignments = {}

    assignments.each do |assignment|
      _assignments = Assignment.find(:all,
                                    :conditions => {
        :course_id => assignment.course_id,
        :period_id => session[:period_id]
      })
      lecturers = _assignments.collect do |_assignment|
        if !Classplan.find(:first, :conditions => {:assignment_id => _assignment.id, :period_id => session[:period_id]})
          _assignment.lecturer_id.to_s + ',' + _assignment.lecturer.full_name.to_s
        end
      end
      lecturers.compact! # nil'lerden kurtulsun
      unless lecturers == []
        lecturers = lecturers.join(';') + '#' + assignment.course_id.to_s
        @assignments[lecturers] = assignment.course.full_name
      end
    end

    @class = Classroom.find(:all, :order => 'name')

    unless Department.find(:first, :conditions => { :id => session[:department_id] })
      return redirect_to "/user/index"
    end
    unless Period.find(:first, :conditions => { :id => session[:period_id] })
      return redirect_to "/user/index"
    end
  end
  def scheduleselect
    unless Department.find(:first, :conditions => { :id => session[:department_id] })
      return redirect_to "/user/index"
    end
    unless Course.find(:first, :conditions => { :id => params[:course_id] })
      return redirect_to "/user/index"
    end
    unless Lecturer.find(:first, :conditions => { :id => params[:lecturer_id] })
      return redirect_to "/user/index"
    end
    unless Period.find(:first, :conditions => { :id => session[:period_id] })
      return redirect_to "/user/index"
    end

    @lecturer = Lecturer.find(params[:lecturer_id])
    @course = Course.find(params[:course_id])
    @class = Classroom.find(:all, :order => 'name')

    @year = (1..4)
    @day, @header, @launch, @morning, @evening = departmentplan_schema(session[:period_id],session[:department_id], 0, 0)
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
    }, :select => "id")
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
          next unless part
          part[1] = part.slice(1..-1)
          if part.length > 1 and part[1] == []
            session[:error] = day_tr+hour.gsub("-",":")+" bölümünde sınıf işaretlenmemiş"
            return redirect_to "/user/schedulenew"
          elsif part.length == 1 and part[0] != []
            session[:error] = day_tr+hour.gsub("-",":")+" bölümünde saat işaretlenmemiş"
            return redirect_to "/user/schedulenew"
          elsif part[0] != nil and part[1] != []
            part[1].each do |classroom_id|
              choice = {
                'period_id' => session[:period_id],
                'assignment_id' => @assignment.id,
                'day' => day_en,
                'begin_time' => part[0],
                'classroom_id' => classroom_id,
              }
              if classplan = Classplan.find(:first,
                                            :conditions => {
                'period_id' => session[:period_id],
                'day' => day_en,
                'begin_time' => part[0],
                'classroom_id' => classroom_id,
              })

                session[:error] = day_tr + " " + hour.gsub("-",":") + " de "+
                  "#{classplan.classroom.name} sınıfında "+
                  "#{classplan.assignment.lecturer.department.name} bölümünden "+
                  "öğretim üyesini #{classplan.assignment.lecturer.full_name} tarafından "+
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
                  session[:error] = day_tr + " " + hour.gsub("-",":") + " de "+
                    "#{classplan.classroom.name} sınıfında kaydetmeye çalıştığınız "+
                    "#{classplan.assignment.lecturer.department.name} bölümünden "+
                    "#{classplan.assignment.lecturer.full_name} isimli öğretim üyesini "+
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
    end
    # akşam
    evening_time.each do |hour|
      hour = hour + "-00"

      @day.each do |day_en, day_tr|
        part = params[day_en + hour]
        next unless part
        part[1] = part.slice(1..-1)
        if part.length > 1 and part[1] == []
          session[:error] = day_tr+hour.gsub("-",":")+" bölümünde sınıf işaretlenmemiş"
          return redirect_to "/user/schedulenew"
        elsif part.length == 1 and part[0] != []
          session[:error] = day_tr+hour.gsub("-",":")+" bölümünde saat işaretlenmemiş"
          return redirect_to "/user/schedulenew"
        elsif part[0] != nil and part[1] != []
          part[1].each do |classroom_id|
            choice = {
              'period_id' => session[:period_id],
              'assignment_id' => @assignment.id,
              'day' => day_en,
              'begin_time' => part[0],
              'classroom_id' => classroom_id,
            }
            if classplan = Classplan.find(:first,
                                          :conditions => {
              'period_id' => session[:period_id],
              'day' => day_en,
              'begin_time' => part[0],
              'classroom_id' => classroom_id,
            })

              session[:error] = day_tr + " " + hour.gsub("-",":") + " de "+
                "#{classplan.classroom.name} sınıfında "+
                "#{classplan.assignment.lecturer.department.name} bölümünden "+
                "öğretim üyesini #{classplan.assignment.lecturer.full_name} tarafından "+
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
                session[:error] = day_tr + " " + hour.gsub("-",":") + " de "+
                  "#{classplan.classroom.name} sınıfında kaydetmeye çalıştığınız "+
                  "#{classplan.assignment.lecturer.department.name} bölümünden "+
                  "#{classplan.assignment.lecturer.full_name} isimli öğretim üyesini "+
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
    @lecturer = Lecturer.find(session[:lecturer_id])
    @course_ids = {}

    assignments = Assignment.find(:all,
                                  :conditions => {
      :lecturer_id => session[:lecturer_id],
      :period_id => session[:period_id]
    }, :select => "id")

    @assignments = assignments.collect {|assignment| assignment.id }

    assignments = Assignment.joins(:lecturer).where(
      'lecturers.id' => session[:lecturer_id],
      'assignments.period_id' => session[:period_id]
    ).joins(:course).where(
    'courses.department_id' => session[:department_id],
    )

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
          @course_ids[courses] = assignment.course.full_name
        end
      end
    end

    @day, @header, @launch, @morning, @evening, morning_time, evening_time = table_schema # standart tablo şeması

    morning_time.each do |hour|
      if hour.to_i < 13
        column = [hour + '-15' + '/' + (hour.to_i+1).to_s + '-00']
        hour = hour + '-15'
      else
        column = [hour + '-00' + '/' + hour + '-45']
        hour = hour + '-00'
      end
      if hour.slice(0..1) == @launch[0]
        @launch.slice(1..-1).each {|l| column << l }
        @launch = column
        @morning << column
      else
        @day.each do |day_en, day_tr|
          classplans = Classplan.find(:all,
                                      :conditions => {
            :period_id => session[:period_id],
            :day => day_en,
            :begin_time => hour
          }, :select => "assignment_id")
          assignment_ids = classplans.collect { |classplan| classplan.assignment_id }
          assignment_state = false
          _assignment_id = ""
          assignment_ids.each do |assignment_id|
            if @assignments.include?(assignment_id)
              _assignment_id = assignment_id
              assignment_state = true
              break
            end
          end
          if assignment_state
            classplan = Classplan.find(:all,
                                      :conditions => {
              :assignment_id => _assignment_id,
              :period_id => session[:period_id],
              :day => day_en,
              :begin_time => hour
            }, :select => "assignment_id, classroom_id")
            classroom_name = ""
            classplan.each {|cp| classroom_name += cp.classroom.name + "\n"}
            column << classplan[0].assignment.course.code + "\n" +
              classplan[0].assignment.course.name
            column << classroom_name
          else
            column << ""
            column << ""
          end
        end
        @morning << column
      end
    end

    evening_time.each do |hour|
      column = [hour + '-00' + '/' + hour + '-45']
      hour = hour + '-00'
      @day.each do |day_en, day_tr|
        classplans = Classplan.find(:all,
                                   :conditions => {
          :period_id => session[:period_id],
          :day => day_en,
          :begin_time => hour
          }, :select => "assignment_id")

        assignment_ids = classplans.collect { |classplan| classplan.assignment_id }
        assignment_state = false
        _assignment_id = ""
        assignment_ids.each do |assignment_id|
          if @assignments.include?(assignment_id)
            _assignment_id = assignment_id
            assignment_state = true
            break
          end
        end
        if assignment_state
          classplan = Classplan.find(:all,
                                     :conditions => {
            :assignment_id => _assignment_id,
            :period_id => session[:period_id],
            :day => day_en,
            :begin_time => hour
          }, :select => "assignment_id, classroom_id")
          classroom_name = ""
          classplan.each {|cp| classroom_name += cp.classroom.name + "\n"}
          column << classplan[0].assignment.course.code + "\n" +
            classplan[0].assignment.course.name
          column << classroom_name
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
    ).select("assignments.id, assignments.lecturer_id")

    lecturer_ids = []
    assignments.each do |assignment|
      if Classplan.find(:first, :conditions => { 'assignment_id' => assignment.id })
        lecturer_ids << assignment.lecturer_id
      end
    end
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
    session[:success] = "#{assignment.lecturer.full_name} isimli öğretim üyesinin ders programından " +
      "#{assignment.course.full_name} ile ilgili olan tüm alanlar bu dönemlik silinmiştir. " +
      "Bu öğretim üyesinin bu dersi için şimdi tekrardan ders/sınıf seçebilirsiniz."
    redirect_to '/user/schedulenew'
  end
  def scheduledel
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim

    assignments = Assignment.joins(:lecturer).where(
      'lecturers.id' => session[:lecturer_id],
      'assignments.period_id' => session[:period_id]
    ).joins(:course).where(
    'courses.department_id' => session[:department_id],
    ).select("assignments.id")

    assignments.each do |assignment|
      Classplan.delete_all({
        :assignment_id => assignment.id,
        :period_id => session[:period_id]
      })
    end

    session[:success] = "#{Lecturer.find(session[:lecturer_id]).full_name} isimli öğretim üyesinin " +
      "bu dönemlik #{session[:department]} bölümüne verdiği tüm dersler silindi"
    redirect_to '/user/schedulereview'
  end
end
