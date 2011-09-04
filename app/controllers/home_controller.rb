# encoding: utf-8
class HomeController < ApplicationController
  include CleanHelper # temizlik birimi
  before_filter :clean_notice # temiz sayfa
  before_filter :clean_error # temiz sayfa

  def review
    unless params[:department_id]
      session[:error] = "Bölüm adı boş bırakılamaz"
      return redirect_to '/home/find'
    end

    @lecturers = Lecturer.find(:all, :conditions => { :department_id => params[:department_id] })
    if @lecturers.empty?
      session[:error] = Department.find(params[:department_id]).name + " bölümünde henüz öğretim görevlisi yok"
      return render '/home/find'
    end
  end

  def auto
    @auto_lecturers = Lecturer.all.collect do |lecturer|
      { lecturer.id => ["#{lecturer.first_name} #{lecturer.last_name}", lecturer.photo, lecturer.department.name] }
    end
  end

  def schedule
    session[:period_id] = Period.find(:first, :conditions => { :status => 1 })
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

  def show
    unless params[:lecturer_id]
      session[:error] = "Bu isme ait bir öğretim görevlisi bulunamadı"
      return render '/home/auto'
    end

    @lecturer = Lecturer.find params[:lecturer_id]
  end
end
