# encoding: utf-8
require 'prawn' # http://cracklabs.com/prawnto # pdf

class HomeController < ApplicationController
  include InitHelper   # gerekli ortak şeyler
  include CleanHelper  # temizlik birimi
  include SchemaHelper # schema helper
  include PdfHelper    # pdf birimi

  before_filter :clean_notice # temiz sayfa
  before_filter :clean_error, :except => [:review] # temiz sayfa

  def review
    if session[:error] = control({
      params[:department_id] => "Bölüm adı",
      params[:period_id] => "Period",
    })
      return redirect_to '/home/find'
    end
    session[:department_id] = params[:department_id]
    session[:period_id] = params[:period_id]

    @lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] }, :order => 'first_name, last_name')
    if @lecturers.empty?
      session[:error] = Department.find(session[:department_id]).name + " bölümünde henüz öğretim görevlisi yok"
      return render '/home/find'
    end
  end

  def find
    session[:period_id] = params[:period_id] if params[:period_id]
    @auto_lecturers = Lecturer.joins(:department).where('departments.faculty_id' => 1).collect do |lecturer|
      { lecturer.id => ["#{lecturer.first_name} #{lecturer.last_name}", lecturer.photo, lecturer.department.name] }
    end
  end

  def show
    if session[:error] = control({
      params[:lecturer_id] => "Öğretim elamanı",
      params[:period_id] => "Period",
    })
      return render '/home/find'
    end
    session[:period_id] = params[:period_id]

    @lecturer = Lecturer.find params[:lecturer_id]
  end

  def lecturerplan
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

    @day, @header, @launch, @morning, @evening, morning_time, evening_time = table_schema # standart tablo şeması
    @assignments = assignments.collect { |assignment| assignment.id }

    session[:lecturerplan] = @assignments
    @day, @header, @launch, @morning, @evening = lecturerplan_schema(session[:lecturerplan])
  end

  def lecturerplanpdf
    day, header, launch, morning, evening = lecturerplan_schema(session[:lecturerplan])

    lecturer_name = Lecturer.find(session[:lecturer_id]).full_name
    lecturer_photo = Lecturer.find(session[:lecturer_id]).photo
    department_name = Lecturer.find(session[:lecturer_id]).department.name
    period_name = Period.find(session[:period_id]).full_name

    title = period_name + " / " + department_name + " / " + lecturer_name
    info = [
      ["Ad Soyad", lecturer_name],
      ["Bölüm",    department_name],
      ["Dönem",    period_name],
    ]

    pdf = lecturerpdf_schema title, "#{lecturer_photo}", info, header, "Ders", "Sınıf", launch, morning, evening
    send_data(pdf.render(), :filename => period_name + "-" + lecturer_name + ".pdf")
  end

  def classplan
    if session[:error] = control({
      params[:classroom_id] => "Sınıf",
      params[:period_id] => "Period",
    })
      return redirect_to '/home/class'
    end
    session[:period_id] = params[:period_id]
    session[:classroom_id] = params[:classroom_id]

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
    #session[:assignments] = @assignments
    if session[:course_ids] == {}
      session[:error] = "#{Classroom.find(session[:classroom_id]).name} sınıfın, " +
        "#{Period.find(session[:period_id]).full_name} dönemlik ders " +
        "programı tablosu henüz hazır değil."
      return render '/home/class'
    end
    session[:classplan] = @assignments
    @day, @header, @launch, @morning, @evening = classplan_schema(session[:classplan], session[:classroom_id])
  end

  def classplanpdf
    day, header, launch, morning, evening = classplan_schema(session[:classplan], session[:classroom_id])

    class_name = Classroom.find(session[:classroom_id]).name
    period_name = Period.find(session[:period_id]).full_name
    title = period_name + " / " + class_name

    info = [
      ["Sınıf", class_name],
      ["Dönem", period_name],
    ]

    pdf = pdf_schema title, info, header, "Ders", "Bölüm", launch, morning, evening
    send_data(pdf.render(), :filename => period_name + "-" + class_name + ".pdf")
  end

  def departmentplan
    if session[:error] = control({
      params[:department_id] => "Bölüm adı",
      params[:period_id] => "Period",
      (params[:section1] or params[:section2]) => "Bu 1. öğretim veya 2.öğretim",
    })
      return render '/home/department'
    end
    session[:period_id] = params[:period_id]
    session[:department_id] = params[:department_id]
    session[:section1] = params[:section1]
    session[:section2] = params[:section2]

    @day,@header,@launch,@morning1,@evening1 = departmentplan_schema(session[:department_id],1,[session[:section1],session[:section2]])
    @day,@header,@launch,@morning2,@evening2 = departmentplan_schema(session[:department_id],2,[session[:section1],session[:section2]])
    @day,@header,@launch,@morning3,@evening3 = departmentplan_schema(session[:department_id],3,[session[:section1],session[:section2]])
    @day,@header,@launch,@morning4,@evening4 = departmentplan_schema(session[:department_id],4,[session[:section1],session[:section2]])
  end

  def departmentplanpdf
    day,header,launch,morning1,evening1 = departmentplan_schema(session[:department_id],1,[session[:section1],session[:section2]])
    day,header,launch,morning2,evening2 = departmentplan_schema(session[:department_id],2,[session[:section1],session[:section2]])
    day,header,launch,morning3,evening3 = departmentplan_schema(session[:department_id],3,[session[:section1],session[:section2]])
    day,header,launch,morning4,evening4 = departmentplan_schema(session[:department_id],4,[session[:section1],session[:section2]])

    morning = [morning1, morning2, morning3, morning4]
    evening = [evening1, evening2, evening3, evening4]

    department_name = Department.find(session[:department_id]).name
    period_name = Period.find(session[:period_id]).full_name
    title = period_name + " / " + department_name

    info = [
      ["Bölüm", department_name],
      ["Dönem", period_name],
    ]

    pdf = departmentpdf_schema title, info, header, "Ders", "Bölüm", launch, morning, evening
    send_data(pdf.render(), :filename => period_name + "-" + department_name + ".pdf")
  end

  def departmentyearpdf
    day, header, launch, morning, evening = departmentplan_schema(
      session[:department_id],
      params[:year].to_i,
      [session[:section1], session[:section2]]
    )

    department_name = Department.find(session[:department_id]).name
    period_name = Period.find(session[:period_id]).full_name
    title = period_name + " / " + department_name

    info = [
      ["Bölüm", department_name],
      ["Sınıf", params[:year]],
      ["Dönem", period_name],
    ]

    pdf = pdf_schema title, info, header, "Ders", "Sınıf", launch, morning, evening
    send_data(pdf.render(), :filename => period_name + "-" + department_name + "-" + params[:year] + ".pdf")
  end
end
