# encoding: utf-8
class HomeController < ApplicationController
  include CleanHelper # temizlik birimi
  before_filter :clean_notice # temiz sayfa
  before_filter :clean_error, :except => [:review] # temiz sayfa

  def review
    session[:department_id] = params[:department_id] if params[:department_id]
    session[:period_id] = params[:period_id] if params[:period_id]
    unless session[:department_id]
      session[:error] = "Bölüm adı boş bırakılamaz"
      return redirect_to '/home/find'
    end
    unless session[:period_id]
      session[:error] = "Period boş bırakılamaz"
      return redirect_to '/home/find'
    end

    @lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] })
    if @lecturers.empty?
      session[:error] = Department.find(session[:department_id]).name + " bölümünde henüz öğretim görevlisi yok"
      return render '/home/find'
    end
  end

  def auto
    session[:period_id] = params[:period_id] if params[:period_id]
    @auto_lecturers = Lecturer.all.collect do |lecturer|
      { lecturer.id => ["#{lecturer.first_name} #{lecturer.last_name}", lecturer.photo, lecturer.department.name] }
    end
  end

  def schedule
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
    if session[:course_ids] == {}
      session[:error] = "#{Lecturer.find(session[:lecturer_id]).full_name} isimli öğretim görevlisinin " +
                        "bu dönemlik ders programı tablosu henüz hazır değil."
      redirect_to '/home/review'
    end
  end

  def show
    session[:period_id] = params[:period_id] if params[:period_id]
    unless params[:period_id]
      session[:error] = "Period boş bırakılamaz"
      return render '/home/auto'
    end
    unless params[:lecturer_id]
      session[:error] = "Bu isme ait bir öğretim görevlisi bulunamadı"
      return render '/home/auto'
    end

    @lecturer = Lecturer.find params[:lecturer_id]
  end

  def classplan
    session[:period_id] = params[:period_id] if params[:period_id]
    session[:classroom_id] = params[:classroom_id] if params[:classroom_id]
    unless params[:period_id]
      session[:error] = "Period boş bırakılamaz"
      return render '/home/class'
    end
    unless params[:classroom_id]
      session[:error] = "Sınıf boş bırakılamaz"
      return render '/home/class'
    end

    session[:course_ids] = {}
    assignments = Assignment.find(:all,
                                  :conditions => {
                                    :period_id => session[:period_id]
                                  })
    assignments.each do |assignment|
      if Classplan.find(:first, :conditions => { :period_id => session[:period_id], :assignment_id => assignment.id })
        classplans = Classplan.find(:all,
                                    :conditions => {
                                      :assignment_id => assignment.id,
                                      :classroom_id => session[:classroom_id],
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
    if session[:course_ids] == {}
      session[:error] = "#{Classroom.find(session[:classroom_id]).name} sınıfın, " +
                        "#{Period.find(session[:period_id]).full_name} dönemlik ders " +
                        "programı tablosu henüz hazır değil."
      return render '/home/class'
    end
  end
end
