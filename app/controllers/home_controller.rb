# encoding: utf-8
require 'prawn' # http://cracklabs.com/prawnto # pdf

class HomeController < ApplicationController
  include InitHelper   # gerekli ortak şeyler
  include CleanHelper  # temizlik birimi
  include SchemaHelper # schema helper
  include PlanHelper   # plan helper
  include PdfHelper    # pdf birimi
  include ReportHelper # raporlama birimi
  include PercentHelper # raporlama birimi

  before_filter :clean_notice # temiz sayfa
  before_filter :clean_error, :only => [:index, :info, :help, :lecturerplan, :classplan] # temiz sayfa

  def index
    assignments = Assignment.joins(:course).where(
      'courses.department_id' => session[:department_id],
      'assignments.period_id' => session[:period_id]
    ).select("assignments.course_id")
    @assignments = {}

    course_ids = assignments.collect { |assignment| assignment.course_id }.uniq

    course_ids.each do |course_id|
      assignments = Assignment.find(:all,
                                    :conditions => {
        :course_id => course_id,
        :period_id => session[:period_id]
      })
      lecturers = assignments.collect do |assignment|
        if !Classplan.find(:first, :conditions => {:assignment_id => assignment.id, :period_id => session[:period_id]})
          assignment.lecturer.full_name
        end
      end
      lecturers.compact! # nil'lerden kurtulsun
      unless lecturers == []
        lecturers = lecturers.join(';')
        @assignments[lecturers] = Course.find(course_id).full_name
      end
    end

    lecturer_count = Lecturer.where(:department_id => session[:department_id]).count
    assignments = Assignment.joins(:lecturer).where(
      'lecturers.department_id' => session[:department_id],
      'assignments.period_id' => session[:period_id]
    ).joins(:course).where(
    'courses.department_id' => session[:department_id],
    )
    lecturer_ids = assignments.collect { |assignment| assignment.lecturer_id }.uniq
    @lecturers = Lecturer.where('id not in (?)', lecturer_ids).where(:department_id => session[:department_id])
  end

  def departmentreview
    unless @department = Department.find(:first, :conditions => { :id => params[:department_id] })
      return redirect_to "/home/lecturer"
    end
    unless @period = Period.find(:first, :conditions => { :id => params[:period_id] })
      return redirect_to "/home/lecturer"
    end

    @lecturers = Lecturer.find(:all, :conditions => { :department_id => @department.id }, :order => 'first_name, last_name')
    if @lecturers.empty?
      session[:error] = "#{@department.name} bölümünde henüz öğretim görevlisi yok"
      return render '/home/lecturer'
    end
  end

  def lecturer
    @auto_lecturers = Lecturer.all.collect do |lecturer|
      { lecturer.id => ["#{lecturer.first_name} #{lecturer.last_name}", lecturer.photo, lecturer.department.name] }
    end
  end

  def lecturershow
    unless @lecturer = Lecturer.find(:first, :conditions => { :id => params[:lecturer_id] })
      return redirect_to "/home/lecturer"
    end
    unless @period = Period.find(:first, :conditions => { :id => params[:period_id] })
      return redirect_to "/home/lecturer"
    end
  end

  def lecturerplan
    unless @lecturer = Lecturer.find(:first, :conditions => { :id => params[:lecturer_id] })
      return redirect_to "/home/lecturer"
    end
    unless @period = Period.find(:first, :conditions => { :id => params[:period_id] })
      return redirect_to "/home/lecturer"
    end

    @course_ids, @assignments = lecturer_plan(@period.id, @lecturer.id)
    if @course_ids == {}
      session[:error] = "#{@lecturer.full_name} isimli öğretim görevlisinin " +
        "#{@period.full_name} dönemlik ders programı tablosu henüz hazır değil."
      return redirect_to '/home/lecturer'
    end
    @day, @header, @launch, @morning, @evening = lecturerplan_schema(@period.id, @assignments)
  end

  def lecturerplanpdf
    unless lecturer = Lecturer.find(:first, :conditions => { :id => params[:lecturer_id] })
      return redirect_to "/home/lecturer"
    end
    unless period = Period.find(:first, :conditions => { :id => params[:period_id] })
      return redirect_to "/home/lecturer"
    end

    course_ids, assignments = lecturer_plan(period.id, lecturer.id)
    if course_ids == {}
      session[:error] = "#{lecturer.full_name} isimli öğretim görevlisinin " +
        "#{period.full_name} dönemlik ders programı tablosu henüz hazır değil."
      return redirect_to '/home/lecturer'
    end
    day, header, launch, morning, evening = lecturerplan_schema(period.id, assignments)

    description = {
      "Dönem" => period.full_name,
      "Bölüm" => lecturer.department.name,
      "Ad Soyad" => lecturer.full_name,
    }
    info = description.map {|k, v| [k, v]}

    pdf = lecturerpdf_schema "#{lecturer.photo}", info, header, "Ders", "Sınıf", launch, morning, evening
    send_data(pdf.render(), :filename => description.values.join("-") + ".pdf")
  end

  def classplan
    unless @classroom = Classroom.find(:first, :conditions => {:id => params[:classroom_id] })
      return redirect_to "/home/class"
    end
    unless @period = Period.find(:first, :conditions => {:id => params[:period_id] })
      return redirect_to "/home/class"
    end

    @course_ids, @assignments = class_plan(@period.id, @classroom.id)
    if @course_ids == {}
      session[:error] = "#{@classroom.name} sınıfın, " +
        "#{@period.full_name} dönemlik ders " +
        "programı tablosu henüz hazır değil."
      return render '/home/class'
    end
    @day, @header, @launch, @morning, @evening = classplan_schema(@period.id, @assignments, @classroom.id)
  end

  def classplanpdf
    unless classroom = Classroom.find(:first, :conditions => {:id => params[:classroom_id] })
      return redirect_to "/home/class"
    end
    unless period = Period.find(:first, :conditions => {:id => params[:period_id] })
      return redirect_to "/home/class"
    end

    course_ids, assignments = class_plan(period.id, classroom.id)
    if course_ids == {}
      session[:error] = "#{classroom.name} sınıfın, " +
        "#{period.full_name} dönemlik ders " +
        "programı tablosu henüz hazır değil."
      return render '/home/class'
    end
    day, header, launch, morning, evening = classplan_schema(period.id, assignments, classroom.id)

    description = {
      "Dönem" => period.full_name,
      "Sınıf" => classroom.name,
    }
    info = description.map {|k, v| [k, v]}

    pdf = pdf_schema info, header, "Ders", "Bölüm", launch, morning, evening
    send_data(pdf.render(), :filename => description.values.join("-") + ".pdf")
  end

  def departmentshow
    if session[:error] = control({
      (params[:section1] or params[:section2] or params[:section]) => "Bu 1. öğretim veya 2.öğretim",
    })
      return render '/home/department'
    end

    unless @department = Department.find(:first, :conditions => {:id => params[:department_id] })
      return redirect_to "/home/department"
    end
    unless @period = Period.find(:first, :conditions => {:id => params[:period_id] })
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
    unless @department = Department.find(:first, :conditions => { :id => params[:department_id] })
      return redirect_to "/home/department"
    end
    unless @period = Period.find(:first, :conditions => { :id => params[:period_id] })
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
      @day, @header, @launch, @morning[0], @evening[0] = departmentplan_schema(@period.id, @department.id, 1, @section)
      @day, @header, @launch, @morning[1], @evening[1] = departmentplan_schema(@period.id, @department.id, 2, @section)
      @day, @header, @launch, @morning[2], @evening[2] = departmentplan_schema(@period.id, @department.id, 3, @section)
      @day, @header, @launch, @morning[3], @evening[3] = departmentplan_schema(@period.id, @department.id, 4, @section)
    else
      @year = [params[:year]]
      @day, @header, @launch, @morning[0], @evening[0] = departmentplan_schema(@period.id, @department.id, params[:year].to_i, @section)
    end
  end

  def departmentplanpdf
    unless department = Department.find(:first, :conditions => { :id => params[:department_id] })
      return redirect_to "/home/department"
    end
    unless period = Period.find(:first, :conditions => { :id => params[:period_id] })
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
      day, header, launch, morning1, evening1 = departmentplan_schema(period.id, department.id, 1, section)
      day, header, launch, morning2, evening2 = departmentplan_schema(period.id, department.id, 2, section)
      day, header, launch, morning3, evening3 = departmentplan_schema(period.id, department.id, 3, section)
      day, header, launch, morning4, evening4 = departmentplan_schema(period.id, department.id, 4, section)
      morning = [morning1, morning2, morning3, morning4]
      evening = [evening1, evening2, evening3, evening4]

      description = {
        "Dönem" => period.full_name,
        "Bölüm" => department.name,
      }
      info = description.map {|k, v| [k, v]}

      pdf = departmentpdf_schema info, header, "Ders", "Sınıf", launch, morning, evening
      send_data(pdf.render(), :filename => description.values.join("-") + ".pdf")
    else
      day, header, launch, morning, evening = departmentplan_schema(period.id, department.id, params[:year].to_i, params[:section])

      description = {
        "Dönem" => period.full_name,
        "Bölüm" => department.name,
        "Sınıf" => params[:year],
      }
      info = description.map {|k, v| [k, v]}

      pdf = pdf_schema info, header, "Ders", "Sınıf", launch, morning, evening
      send_data(pdf.render(), :filename => description.values.join("-") + ".pdf")
    end
  end
end
