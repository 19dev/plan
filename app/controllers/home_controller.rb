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

  def program
    # TODO
  end

  def show
    unless params[:lecturer_id]
      session[:error] = "Bu isme ait bir öğretim görevlisi bulunamadı"
      return render '/home/auto'
    end

    @lecturer = Lecturer.find params[:lecturer_id]
  end
end
