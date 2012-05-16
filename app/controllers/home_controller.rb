# encoding: utf-8
require 'prawn' # http://cracklabs.com/prawnto # pdf

class HomeController < ApplicationController
  include Init::InitHelper   # gerekli ortak şeyler

  # Plan
  include Plan::PlanHelper         # plan helper
  include Plan::SchemaHelper       # schema helper
  include Plan::PdfHelper          # pdf birimi

  include MainHelper

  def departmentreview
    unless @department = Department.find(params[:department_id])
      return redirect_to "/home/lecturer"
    end
    unless @period = Period.find(params[:period_id])
      return redirect_to "/home/lecturer"
    end

    @lecturers = Lecturer.find(:all, :conditions => { :department_id => @department.id }, :order => 'first_name, last_name')
    if @lecturers.empty?
      flash[:error] = "#{@department.name} bölümünde henüz öğretim görevlisi yok"
      return render '/home/lecturer'
    end
  end

  def lecturer
    @auto_lecturers = Lecturer.all.collect do |lecturer|
      { lecturer.id => [lecturer.full_name, lecturer.photo, lecturer.department.name] }
    end
  end

  def lecturershow
    unless @lecturer = Lecturer.find(params[:lecturer_id])
      return redirect_to "/home/lecturer"
    end
    unless @period = Period.find(params[:period_id])
      return redirect_to "/home/lecturer"
    end
  end

  def lecturerplan
    unless @lecturer = Lecturer.find(params[:lecturer_id])
      return redirect_to "/home/lecturer"
    end
    unless @period = Period.find(params[:period_id])
      return redirect_to "/home/lecturer"
    end

    unless @lecturer.has_plan? @period.id
      flash[:error] = "#{@lecturer.full_name} isimli öğretim görevlisinin " +
        "#{@period.full_name} dönemlik ders programı tablosu henüz hazır değil."
      return redirect_to '/home/lecturer'
    end

    @course_ids, @assignments = lecturer_plan(@period.id, @lecturer.id)
    @day, @header, @morning, @evening, @meal_time = lecturerplan_schema(@period.id, @assignments)
  end

  def lecturerplanpdf
    unless lecturer = Lecturer.find(params[:lecturer_id])
      return redirect_to "/home/lecturer"
    end
    unless period = Period.find(params[:period_id])
      return redirect_to "/home/lecturer"
    end

    unless lecturer.has_plan? period.id
      flash[:error] = "#{lecturer.full_name} isimli öğretim görevlisinin " +
        "#{period.full_name} dönemlik ders programı tablosu henüz hazır değil."
      return redirect_to '/home/lecturer'
    end

    course_ids, assignments = lecturer_plan(period.id, lecturer.id)
    day, header, morning, evening, meal_time = lecturerplan_schema(period.id, assignments)

    description = {
      "Dönem" => period.full_name,
      "Bölüm" => lecturer.department.name,
      "Ad Soyad" => lecturer.full_name,
    }
    info = description.map {|k, v| [k, v]}

    pdf = pdf_schema lecturer.photo, info, header, "Ders", "Sınıf", meal_time, morning, evening, height=30
    send_data(pdf.render(), :filename => description.values.join("-") + ".pdf")
  end

  def classplan
    unless @classroom = Classroom.find(params[:classroom_id])
      return redirect_to "/home/class"
    end
    unless @period = Period.find(params[:period_id])
      return redirect_to "/home/class"
    end

    unless @classroom.has_plan? @period.id
      flash[:error] = "#{@classroom.name} sınıfın, " +
        "#{@period.full_name} dönemlik ders " +
        "programı tablosu henüz hazır değil."
      return redirect_to '/home/class'
    end

    @course_ids, @assignments = class_plan(@period.id, @classroom.id)
    @day, @header, @morning, @evening, @meal_time = classplan_schema(@period.id, @assignments, @classroom.id)
  end

  def classplanpdf
    unless classroom = Classroom.find(params[:classroom_id])
      return redirect_to "/home/class"
    end
    unless period = Period.find(params[:period_id])
      return redirect_to "/home/class"
    end

    unless classroom.has_plan? period.id
      flash[:error] = "#{classroom.name} sınıfın, " +
        "#{period.full_name} dönemlik ders " +
        "programı tablosu henüz hazır değil."
      return render '/home/class'
    end

    course_ids, assignments = class_plan(period.id, classroom.id)
    day, header, morning, evening, meal_time = classplan_schema(period.id, assignments, classroom.id)

    description = {
      "Dönem" => period.full_name,
      "Sınıf" => classroom.name,
    }
    info = description.map {|k, v| [k, v]}

    pdf = pdf_schema nil, info, header, "Ders", "Bölüm", meal_time, morning, evening, height=30
    send_data(pdf.render(), :filename => description.values.join("-") + ".pdf")
  end

  def departmentshow
    if flash[:error] = control({
      (params[:section1] or params[:section2] or params[:section]) => "Bu 1. öğretim veya 2.öğretim",
    })
      return render '/home/department'
    end

    unless @department = Department.find(params[:department_id])
      return redirect_to "/home/department"
    end
    unless @period = Period.find(params[:period_id])
      return redirect_to "/home/department"
    end

    if params[:section1] == "1" and params[:section2] == "1";
      @section = 0
    elsif params[:section1] == "1"
      @section = 1
    elsif params[:section2] == "1"
      @section = 2
    elsif session[:section]
      ;# pass
    else
      return redirect_to "/home/department"
    end
  end

  def departmentplan
    unless @department = Department.find(params[:department_id])
      return redirect_to "/home/department"
    end
    unless @period = Period.find(params[:period_id])
      return redirect_to "/home/department"
    end
    unless ["0","1","2","3","4"].include?(params[:year])
      return redirect_to "/home/department"
    end
    unless ["0","1","2"].include?(params[:section])
      return redirect_to "/home/department"
    end
    @section = params[:section]
    @morning, @evening = [], []

    if params[:year] == "0"
      @year = (1..4)
      @day, @header, @morning, @evening, @meal_time = departmentplan_schema(@period.id, @department.id, 0, @section.to_i)
    else
      @year = [params[:year]]
      @day, @header, @morning, @evening, @meal_time = departmentplan_schema(@period.id, @department.id, params[:year].to_i, @section.to_i)
    end
  end

  def departmentplanpdf
    unless department = Department.find(params[:department_id])
      return redirect_to "/home/department"
    end
    unless period = Period.find(params[:period_id])
      return redirect_to "/home/department"
    end
    unless ["0","1","2","3","4"].include?(params[:year])
      return redirect_to "/home/department"
    end
    unless ["0","1","2"].include?(params[:section])
      return redirect_to "/home/department"
    end
    section = params[:section]

    if params[:year] == "0"
      day, header, morning, evening, meal_time = departmentplan_schema(period.id, department.id, 0, section.to_i)
      description = {
        "Dönem" => period.full_name,
        "Bölüm" => department.name,
      }
      info = description.map {|k, v| [k, v]}

      pdf = departmentpdf_schema info, header, "Ders", "Sınıf", meal_time, morning, evening
      send_data(pdf.render(), :filename => description.values.join("-") + ".pdf")
    else
      day, header, morning, evening, meal_time = departmentplan_schema(period.id, department.id, params[:year].to_i, section.to_i)
      morning = morning[0]
      evening = evening[0]
      description = {
        "Dönem" => period.full_name,
        "Bölüm" => department.name + "-" + params[:year],
      }
      info = description.map {|k, v| [k, v]}

      pdf = pdf_schema nil, info, header, "Ders", "Sınıf", meal_time, morning, evening, height=28
      send_data(pdf.render(), :filename => description.values.join("-") + ".pdf")
    end
  end
end
