# encoding: utf-8
module User
  module ScheduleHelper
    def schedulenew
      assignments = Assignment.joins(:course).where(
        'courses.department_id' => session[:department_id],
        'assignments.period_id' => session[:period_id]
      ).select("assignments.course_id").group('assignments.course_id')
      @assignments = {}

      assignments.each do |assignment|
        _assignments = Assignment.find_all_by_course_id_and_period_id(assignment.course_id, session[:period_id])
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
      @day, @header, @launch, @morning, @evening = departmentplan_schema(session[:period_id], session[:department_id], 0, 0)
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
              flash[:error] = day_tr+hour.gsub("-",":")+" bölümünde sınıf işaretlenmemiş"
              return redirect_to "/user/schedulenew"
            elsif part.length == 1 and part[0] != []
              flash[:error] = day_tr+hour.gsub("-",":")+" bölümünde saat işaretlenmemiş"
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
                }) and
                !(classplan.assignment.course.group and @assignment.course.group and classplan.assignment.course_id == @assignment.course_id) and
                !(classplan.assignment.course.common and @assignment.course.common and classplan.assignment.lecturer_id == @assignment.lecturer_id)

                  flash[:error] = day_tr + " " + hour.gsub("-",":") + " de "+
                    "#{classplan.classroom.name} sınıfında "+
                    "#{classplan.assignment.lecturer.department.name} bölümünden "+
                    "öğretim üyesi #{classplan.assignment.lecturer.full_name} tarafından "+
                    "#{classplan.assignment.course.full_name} dersi verilmektedir. Bu "+
                    "bilginin düzeltilmesini istiyorsanız; "+
                    "#{classplan.assignment.lecturer.department.name} bölümünün yöneticileri ile irtibata geçin."
                  return redirect_to "/user/schedulenew"
                elsif classplans = Classplan.find(:all,
                                                :conditions => {
                  'period_id' => session[:period_id],
                  'day' => day_en,
                  'begin_time' => part[0],
                })
                  assignment_id = ""
                  assignment_state = false
                  classplans.each do |classplan|
                    if @assignments.include?(classplan.assignment_id)
                      assignment_id = classplan.assignment_id
                      assignment_state = true
                      break
                    end
                  end
                  if assignment_state and classplan = Classplan.find(:first,
                                                :conditions => {
                      'period_id' => session[:period_id],
                      'assignment_id' => assignment_id,
                      'day' => day_en,
                      'begin_time' => part[0],
                    }) and
                    !(classplan.assignment.course.common and @assignment.course.common and classplan.assignment.lecturer_id == @assignment.lecturer_id)
                    flash[:error] = day_tr + " " + hour.gsub("-",":") + " de "+
                      "#{classplan.classroom.name} sınıfında kaydetmeye çalıştığınız "+
                      "#{classplan.assignment.lecturer.department.name} bölümünden "+
                      "#{classplan.assignment.lecturer.full_name} isimli öğretim üyesi "+
                      "#{classplan.assignment.course.full_name} dersini vermektedir. Bu "+
                      "bilginin düzeltilmesini istiyorsanız; "+
                      "bu verdiği dersin gününü veya saatini değiştiriniz."+@assignment.course.common.to_s
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
            flash[:error] = day_tr+hour.gsub("-",":")+" bölümünde sınıf işaretlenmemiş"
            return redirect_to "/user/schedulenew"
          elsif part.length == 1 and part[0] != []
            flash[:error] = day_tr+hour.gsub("-",":")+" bölümünde saat işaretlenmemiş"
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
                }) and
                !(classplan.assignment.course.group and @assignment.course.group and classplan.assignment.course_id == @assignment.course_id) and
                !(classplan.assignment.course.common and @assignment.course.common and classplan.assignment.lecturer_id == @assignment.lecturer_id)

                flash[:error] = day_tr + " " + hour.gsub("-",":") + " de "+
                  "#{classplan.classroom.name} sınıfında "+
                  "#{classplan.assignment.lecturer.department.name} bölümünden "+
                  "öğretim üyesi #{classplan.assignment.lecturer.full_name} tarafından "+
                  "#{classplan.assignment.course.full_name} dersi verilmektedir. Bu "+
                  "bilginin düzeltilmesini istiyorsanız; "+
                  "#{classplan.assignment.lecturer.department.name} bölümünün yöneticileri ile irtibata geçin."
                return redirect_to "/user/schedulenew"
              elsif classplans = Classplan.find(:all,
                                                :conditions => {
                'period_id' => session[:period_id],
                'day' => day_en,
                'begin_time' => part[0],
              })
                assignment_id = ""
                assignment_state = false
                classplans.each do |classplan|
                  if @assignments.include?(classplan.assignment_id)
                    assignment_id = classplan.assignment_id
                    assignment_state = true
                    break
                  end
                end
                if assignment_state and classplan = Classplan.find(:first,
                                                                   :conditions => {
                  'period_id' => session[:period_id],
                  'assignment_id' => assignment_id,
                  'day' => day_en,
                  'begin_time' => part[0],
                }) and
                !(classplan.assignment.course.common and @assignment.course.common and classplan.assignment.lecturer_id == @assignment.lecturer_id)
                  flash[:error] = day_tr + " " + hour.gsub("-",":") + " de "+
                    "#{classplan.classroom.name} sınıfında kaydetmeye çalıştığınız "+
                    "#{classplan.assignment.lecturer.department.name} bölümünden "+
                    "#{classplan.assignment.lecturer.full_name} isimli öğretim üyesi "+
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
      @course_ids, @assignments = lecturer_plan(session[:period_id], session[:lecturer_id])
      @day, @header, @launch, @morning, @evening = lecturerplan_schema(session[:period_id], @assignments)
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
      flash[:success] = "#{assignment.lecturer.full_name} isimli öğretim üyesinin ders programından " +
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

      flash[:success] = "#{Lecturer.find(session[:lecturer_id]).full_name} isimli öğretim üyesinin " +
        "bu dönemlik #{session[:department]} bölümüne verdiği tüm dersler silindi"
      redirect_to '/user/schedulereview'
    end
  end
end
