# encoding: utf-8
require 'prawn' # http://cracklabs.com/prawnto # pdf

class HomeController < ApplicationController
  include InitHelper   # gerekli ortak şeyler
  include CleanHelper  # temizlik birimi
  include SchemaHelper # schema helper
  include PlanHelper   # plan helper
  include PdfHelper    # pdf birimi

  before_filter :clean_notice # temiz sayfa
  before_filter :clean_error, :only => [:index, :info, :help, :lecturerplan, :classplan] # temiz sayfa

  def departmentreview
    session[:department_id] = params[:department_id] if params[:department_id] # uniq veriyi oturuma gömelim
    session[:period_id] = params[:period_id] if params[:period_id] # uniq veriyi oturuma gömelim

    unless Department.find(:first, :conditions => { :id => session[:department_id] })
      return redirect_to "/home/lecturer"
    end
    unless Period.find(:first, :conditions => { :id => session[:period_id] })
      return redirect_to "/home/lecturer"
    end

    @lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] }, :order => 'first_name, last_name')
    if @lecturers.empty?
      session[:error] = Department.find(session[:department_id]).name + " bölümünde henüz öğretim görevlisi yok"
      return render '/home/lecturer'
    end
  end

  def lecturer
    session[:period_id] = params[:period_id] if params[:period_id]
    @auto_lecturers = Lecturer.all.collect do |lecturer|
      { lecturer.id => ["#{lecturer.first_name} #{lecturer.last_name}", lecturer.photo, lecturer.department.name] }
    end
  end

  def lecturershow
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    session[:period_id] = params[:period_id] if params[:period_id] # uniq veriyi oturuma gömelim

    unless Lecturer.find(:first, :conditions => { :id => session[:lecturer_id] })
      return redirect_to "/home/lecturer"
    end
    unless Period.find(:first, :conditions => { :id => session[:period_id] })
      return redirect_to "/home/lecturer"
    end

    session[:period_id] = params[:period_id]
    session[:lecturer_id] = params[:lecturer_id]
    @lecturer = Lecturer.find(params[:lecturer_id])
    session[:department_id] = @lecturer.department_id
  end

  def lecturerplan
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    session[:period_id] = params[:period_id] if params[:period_id] # uniq veriyi oturuma gömelim

    unless Lecturer.find(:first, :conditions => { :id => session[:lecturer_id] })
      return redirect_to "/home/lecturer"
    end
    unless Period.find(:first, :conditions => { :id => session[:period_id] })
      return redirect_to "/home/lecturer"
    end

    session[:course_ids], @assignments = lecturer_plan(session[:period_id], session[:lecturer_id])
    if session[:course_ids] == {}
      session[:error] = "#{Lecturer.find(session[:lecturer_id]).full_name} isimli öğretim görevlisinin " +
        "#{Period.find(session[:period_id]).full_name} dönemlik ders programı tablosu henüz hazır değil."
      return redirect_to '/home/lecturer'
    end
    @day, @header, @launch, @morning, @evening = lecturerplan_schema(session[:period_id], @assignments)
  end

  def lecturerplanpdf
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    session[:period_id] = params[:period_id] if params[:period_id] # uniq veriyi oturuma gömelim

    unless Lecturer.find(:first, :conditions => { :id => session[:lecturer_id] })
      return redirect_to "/home/lecturer"
    end
    unless Period.find(:first, :conditions => { :id => session[:period_id] })
      return redirect_to "/home/lecturer"
    end

    course_ids, assignments = lecturer_plan(session[:period_id], session[:lecturer_id])
    if course_ids == {}
      session[:error] = "#{Lecturer.find(session[:lecturer_id]).full_name} isimli öğretim görevlisinin " +
        "#{Period.find(session[:period_id]).full_name} dönemlik ders programı tablosu henüz hazır değil."
      return redirect_to '/home/lecturer'
    end
    day, header, launch, morning, evening = lecturerplan_schema(session[:period_id], assignments)

    lecturer = Lecturer.find(session[:lecturer_id])

    lecturer_name = lecturer.full_name
    lecturer_photo = lecturer.photo
    department_name = lecturer.department.name
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
    session[:classroom_id] = params[:classroom_id] if params[:classroom_id] # uniq veriyi oturuma gömelim
    session[:period_id] = params[:period_id] if params[:period_id] # uniq veriyi oturuma gömelim

    unless Classroom.find(:first, :conditions => {:id => session[:classroom_id] })
      return redirect_to "/home/class"
    end
    unless Period.find(:first, :conditions => {:id => session[:period_id] })
      return redirect_to "/home/class"
    end

    session[:course_ids], @assignments = class_plan(session[:period_id], session[:classroom_id])
    if session[:course_ids] == {}
      session[:error] = "#{Classroom.find(session[:classroom_id]).name} sınıfın, " +
        "#{Period.find(session[:period_id]).full_name} dönemlik ders " +
        "programı tablosu henüz hazır değil."
      return render '/home/class'
    end
    @day, @header, @launch, @morning, @evening = classplan_schema(session[:period_id], @assignments, session[:classroom_id])
  end

  def classplanpdf
    session[:classroom_id] = params[:classroom_id] if params[:classroom_id] # uniq veriyi oturuma gömelim
    session[:period_id] = params[:period_id] if params[:period_id] # uniq veriyi oturuma gömelim

    unless Classroom.find(:first, :conditions => {:id => session[:classroom_id] })
      return redirect_to "/home/class"
    end
    unless Period.find(:first, :conditions => {:id => session[:period_id] })
      return redirect_to "/home/class"
    end

    course_ids, assignments = class_plan(session[:period_id], session[:classroom_id])
    if course_ids == {}
      session[:error] = "#{Classroom.find(session[:classroom_id]).name} sınıfın, " +
        "#{Period.find(session[:period_id]).full_name} dönemlik ders " +
        "programı tablosu henüz hazır değil."
      return render '/home/class'
    end
    day, header, launch, morning, evening = classplan_schema(session[:period_id], assignments, session[:classroom_id])

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

  def departmentshow
    if session[:error] = control({
      (params[:section1] or params[:section2] or params[:section]) => "Bu 1. öğretim veya 2.öğretim",
    })
      #return render '/home/department'
    end
    session[:department_id] = params[:department_id] if params[:department_id] # uniq veriyi oturuma gömelim
    session[:period_id] = params[:period_id] if params[:period_id] # uniq veriyi oturuma gömelim

    unless Department.find(:first, :conditions => {:id => session[:department_id] })
      return redirect_to "/home/department"
    end
    unless Period.find(:first, :conditions => {:id => session[:period_id] })
      return redirect_to "/home/department"
    end

    if params[:section1] == "1" and params[:section2] == "1";
      session[:section] = 0
    elsif params[:section1] == "1"
      session[:section] = 1
    elsif params[:section2] == "1"
      session[:section] = 2
    elsif session[:section]
      ;# pass
    else
      return redirect_to "/home/department"
    end
  end

  def departmentplan
    session[:department_id] = params[:department_id] if params[:department_id] # uniq veriyi oturuma gömelim
    session[:period_id] = params[:period_id] if params[:period_id] # uniq veriyi oturuma gömelim
    session[:year] = params[:year]
    session[:section] = params[:section]

    unless Department.find(:first, :conditions => { :id => session[:department_id] })
      return redirect_to "/home/department"
    end
    unless Period.find(:first, :conditions => { :id => session[:period_id] })
      return redirect_to "/home/department"
    end
    unless ["0","1","2","3","4"].include?(session[:year])
      return redirect_to "/home/department"
    end
    unless ["0","1","2"].include?(session[:section])
      return redirect_to "/home/department"
    end
    @morning, @evening = [], []

    if session[:year] == "0"
      @year = (1..4)
      @day,@header,@launch,@morning[0],@evening[0] = departmentplan_schema(session[:period_id],session[:department_id],1,session[:section])
      @day,@header,@launch,@morning[1],@evening[1] = departmentplan_schema(session[:period_id],session[:department_id],2,session[:section])
      @day,@header,@launch,@morning[2],@evening[2] = departmentplan_schema(session[:period_id],session[:department_id],3,session[:section])
      @day,@header,@launch,@morning[3],@evening[3] = departmentplan_schema(session[:period_id],session[:department_id],4,session[:section])
    else
      @year = [session[:year]]
      @day,@header,@launch,@morning[0],@evening[0] = departmentplan_schema(session[:period_id],session[:department_id],session[:year].to_i,session[:section])
    end
  end

  def departmentplanpdf
    session[:department_id] = params[:department_id] if params[:department_id] # uniq veriyi oturuma gömelim
    session[:period_id] = params[:period_id] if params[:period_id] # uniq veriyi oturuma gömelim
    session[:section] = params[:section]

    unless Department.find(:first, :conditions => { :id => session[:department_id] })
      return redirect_to "/home/department"
    end
    unless Period.find(:first, :conditions => { :id => session[:period_id] })
      return redirect_to "/home/department"
    end
    unless ["0","1","2"].include?(session[:section])
      return redirect_to "/home/department"
    end

    day,header,launch,morning1,evening1 = departmentplan_schema(session[:period_id],session[:department_id],1,session[:section])
    day,header,launch,morning2,evening2 = departmentplan_schema(session[:period_id],session[:department_id],2,session[:section])
    day,header,launch,morning3,evening3 = departmentplan_schema(session[:period_id],session[:department_id],3,session[:section])
    day,header,launch,morning4,evening4 = departmentplan_schema(session[:period_id],session[:department_id],4,session[:section])

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
    session[:department_id] = params[:department_id] if params[:department_id] # uniq veriyi oturuma gömelim
    session[:period_id] = params[:period_id] if params[:period_id] # uniq veriyi oturuma gömelim
    session[:year] = params[:year]
    session[:section] = params[:section]

    unless Department.find(:first, :conditions => { :id => session[:department_id] })
      return redirect_to "/home/department"
    end
    unless Period.find(:first, :conditions => { :id => session[:period_id] })
      return redirect_to "/home/department"
    end
    unless ["0","1","2","3","4"].include?(session[:year])
      return redirect_to "/home/department"
    end
    unless ["0","1","2"].include?(session[:section])
      return redirect_to "/home/department"
    end

    day, header, launch, morning, evening = departmentplan_schema(session[:period_id],session[:department_id],params[:year].to_i,session[:section])

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
