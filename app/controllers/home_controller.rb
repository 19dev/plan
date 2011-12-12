# encoding: utf-8
require 'prawn' # http://cracklabs.com/prawnto

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

    @lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] }, :order => 'first_name, last_name')
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
    @assignments = []
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
          @assignments << assignment.id
          courses += '#' + assignment.id.to_s
          session[:course_ids][courses] = assignment.course.full_name
        end
      end
    end
    session[:assignments] = @assignments
    if session[:course_ids] == {}
      session[:error] = "#{Classroom.find(session[:classroom_id]).name} sınıfın, " +
                        "#{Period.find(session[:period_id]).full_name} dönemlik ders " +
                        "programı tablosu henüz hazır değil."
      return render '/home/class'
    end
  end
  def classplanpdf
    @assignments = session[:assignments]

    days = {
      "Sunday" => "Pazartesi",
      "Tuesday" => "Salı",
      "Wednesday" => "Çarşamba",
      "Thursday" => "Perşembe",
      "Friday" => "Cuma"
    }
    class_name = Classroom.find(session[:classroom_id]).name
    period_name = Period.find(session[:period_id]).full_name

    header = [["Saat / Gün"] + days.values,]
    day = []
    launch = [["12:00 / 13:00", "", "", "", "", ""]]
    evening = []

    (8..11).each do |hour|
      column = [(hour).to_s+':15'+' / '+(hour+1).to_s+':00',]
      days.each do |day_en, day_tr|
        classplan = Classplan.find(:first,
                                   :conditions => {
          :classroom_id => session[:classroom_id],
          :period_id => session[:period_id],
          :day => day_en,
          :begin_time => hour.to_s+'-15'
        })
        if classplan and @assignments.include?(classplan.assignment_id)
          state = true
        else
          state = false
        end
        if state
          column << classplan.assignment.course.full_name + "\n" +
                    classplan.assignment.lecturer.full_name + "\n" +
                    classplan.assignment.lecturer.department.name
        else
          column << ""
        end
      end
      day << column
    end

    (13..22).each do |hour|
      column = [(hour).to_s+':00'+' / '+(hour+1).to_s+':00',]
      days.each do |day_en, day_tr|
        classplan = Classplan.find(:first,
                                   :conditions => {
          :classroom_id => session[:classroom_id],
          :period_id => session[:period_id],
          :day => day_en,
          :begin_time => hour.to_s+'-00'
        })
        if classplan and @assignments.include?(classplan.assignment_id)
          state = true
        else
          state = false
        end
        if state
          column << classplan.assignment.course.full_name + "\n" +
                    classplan.assignment.lecturer.full_name + "\n" +
                    classplan.assignment.lecturer.department.name
        else
          column << ""
        end
      end
      evening << column
    end

    pdf = Prawn::Document.new(:page_size => 'A4', :layout => 'portrait') do
      font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf", :size => 8
      text period_name + " / " + class_name, :size => 18,  :align => :center
      stroke do
        rectangle [0,740], 525, 0.025
      end
      move_down(20)

      table header,
        :position => :center,
        :row_colors => ["cccccc"],
        :column_widths => { 0 => 87, 1 => 87, 2 => 87, 3 => 87, 4 => 87 , 5 => 87 },
        :cell_style => { :size => 5, :text_color => "000000", :height => 18, :border_width => 0.5 }
      table day,
        :position => :center,
        :column_widths => { 0 => 87, 1 => 87, 2 => 87, 3 => 87, 4 => 87 , 5 => 87 },
        :cell_style => { :size => 5, :text_color => "000000", :height => 40, :border_width => 0.5 }
      table launch,
        :position => :center,
        :row_colors => ["cccccc"],
        :column_widths => { 0 => 87, 1 => 87, 2 => 87, 3 => 87, 4 => 87 , 5 => 87 },
        :cell_style => { :size => 5, :text_color => "000000", :height => 40, :border_width => 0.5 }
      table evening,
        :position => :center,
        :column_widths => { 0 => 87, 1 => 87, 2 => 87, 3 => 87, 4 => 87 , 5 => 87 },
        :cell_style => { :size => 5, :text_color => "000000", :height => 40, :border_width => 0.5 }
    end
    send_data(pdf.render(), :filename => class_name + ".pdf")

  end
  def foo
    # EXAMPLE PDF EXPORT
    pdf = Prawn::Document.new(:page_size => 'A4', :layout => 'portrait') do
      text "bölüm", :size => 21,  :align => :center
      stroke do
        rectangle [0,740], 525, 1
      end
      move_down(20)
      font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
      text "A Ruby On Rails Developer based in India", :size => 32
      text "Email: san2821@gmail.com", :size => 21
    end
    send_data(pdf.render(), :filename => 'pdfexport.pdf')
  end
end
