# encoding: utf-8
require 'prawn' # http://cracklabs.com/prawnto

class HomeController < ApplicationController
  include InitHelper
  include CleanHelper # temizlik birimi
  include SchemaHelper   # pdf birimi
  include PdfHelper   # pdf birimi

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

  def find
    session[:period_id] = params[:period_id] if params[:period_id]
    @auto_lecturers = Lecturer.all.collect do |lecturer|
      { lecturer.id => ["#{lecturer.first_name} #{lecturer.last_name}", lecturer.photo, lecturer.department.name] }
    end
  end

  def lecturerplan
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    session[:course_ids] = {}
    @assignments = Assignment.find(:all,
                                  :conditions => {
                                    :lecturer_id => session[:lecturer_id],
                                    :period_id => session[:period_id]
                                  })
    @assignments.each do |assignment|
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

    @day, @header, @morning, @launch, @evening = table_schema # standart tablo şeması
    @assignments = @assignments.collect { |assignment| assignment.id }

    ["08","09","10","11"].each do |hour|
      column = [hour+'-15'+' / '+(hour.to_i+1).to_s+'-00']
      @day.each do |day_en, day_tr|
        classplan = Classplan.find(:first,
                                   :conditions => {
          :period_id => session[:period_id],
          :day => day_en,
          :begin_time => hour+'-15'
        })
        if classplan and @assignments.include?(classplan.assignment_id)
          column << classplan.assignment.course.code + "\n" +
                    classplan.assignment.course.name
          column << classplan.classroom.name
        else
          column << ""
          column << ""
        end
      end
      @morning << column
    end

    ["13","14","15","16","17","18","19","20","21","22"].each do |hour|
      column = [hour+'-00'+' / '+(hour.to_i+1).to_s+'-00']
      @day.each do |day_en, day_tr|
        classplan = Classplan.find(:first,
                                   :conditions => {
          :period_id => session[:period_id],
          :day => day_en,
          :begin_time => hour+'-00'
        })
        if classplan and @assignments.include?(classplan.assignment_id)
          column << classplan.assignment.course.code + "\n" +
                    classplan.assignment.course.name
          column << classplan.classroom.name
        else
          column << ""
          column << ""
        end
      end
      @evening << column
    end
    session[:tablo] = [@header, @morning, @launch, @evening] # for pdf
  end

  def lecturerplanpdf
    header, morning, launch, evening = session[:tablo]

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

    pdf = pdf_schema title, "#{lecturer_photo}", info, header, "Ders", "Sınıf", morning, launch, evening
    send_data(pdf.render(), :filename => period_name + "-" + lecturer_name + ".pdf")
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

    @day, @header, @morning, @launch, @evening = table_schema # standart tablo şeması

    ["08","09","10","11"].each do |hour|
      column = [hour + '-15' + ' / ' + (hour.to_i+1).to_s + '-00']
      @day.each do |day_en, day_tr|
        classplan = Classplan.find(:first,
                                   :conditions => {
          :classroom_id => session[:classroom_id],
          :period_id => session[:period_id],
          :day => day_en,
          :begin_time => hour+'-15'
        })
        if classplan and @assignments.include?(classplan.assignment_id)
          state = true
        else
          state = false
        end
        if state
          column << classplan.assignment.course.code + "\n" +
                    classplan.assignment.course.name + "\n" +
                    classplan.assignment.lecturer.full_name
          column << classplan.assignment.lecturer.department.code
        else
          column << ""
          column << ""
        end
      end
      @morning << column
    end

    ["13","14","15","16","17","18","19","20","21","22"].each do |hour|
      column = [hour + '-00' + ' / ' + (hour.to_i+1).to_s + '-00']
      @day.each do |day_en, day_tr|
        classplan = Classplan.find(:first,
                                   :conditions => {
                                                    :classroom_id => session[:classroom_id],
                                                    :period_id => session[:period_id],
                                                    :day => day_en,
                                                    :begin_time => hour+'-00'
		})
        if classplan and @assignments.include?(classplan.assignment_id)
          state = true
        else
          state = false
        end
        if state
          column << classplan.assignment.course.code + "\n" +
                    classplan.assignment.course.name + "\n" +
                    classplan.assignment.lecturer.full_name
          column << classplan.assignment.lecturer.department.code
        else
          column << ""
          column << ""
        end
      end
      @evening << column
    end
    session[:tablo] = [@header, @morning, @launch, @evening] # for pdf
  end

  def classplanpdf
    header, morning, launch, evening = session[:tablo]

    class_name = Classroom.find(session[:classroom_id]).name
    period_name = Period.find(session[:period_id]).full_name
    title = period_name + " / " + class_name

    info = [
            ["Sınıf", class_name],
            ["Dönem", period_name],
    ]

    pdf = pdf_schema title, nil, info, header, "Ders", "Bölüm", morning, launch, evening
    send_data(pdf.render(), :filename => period_name + "-" + class_name + ".pdf")
  end

  def departmentplan
    session[:period_id] = params[:period_id] if params[:period_id]
    session[:department_id] = params[:department_id] if params[:department_id]
    session[:section1] = if params[:section1]
                           params[:section1]
                         else
                           nil
                         end
    session[:section2] = if params[:section2]
                           params[:section2]
                         else
                           nil
                         end

    unless params[:period_id]
      session[:error] = "Period boş bırakılamaz"
      return render '/home/department'
    end
    unless params[:department_id]
      session[:error] = "Bu isme ait bir bölüm bulunamadı"
      return render '/home/department'
    end
    unless params[:section1] or params[:section2]
      session[:error] = "Bu 1. öğretim veya 2.öğretim seçilmelidir"
      return render '/home/department'
    end

    @day,@header,@morning1,@launch1,@evening1 = department_schema(session[:department_id],1,[session[:section1],session[:section2]])
    @day,@header,@morning2,@launch2,@evening2 = department_schema(session[:department_id],2,[session[:section1],session[:section2]])
    @day,@header,@morning3,@launch3,@evening3 = department_schema(session[:department_id],3,[session[:section1],session[:section2]])
    @day,@header,@morning4,@launch4,@evening4 = department_schema(session[:department_id],4,[session[:section1],session[:section2]])

  end
  def departmentplanpdf
    day,header,morning1,launch1,evening1 = department_schema(session[:department_id],1,[session[:section1],session[:section2]])
    day,header,morning2,launch2,evening2 = department_schema(session[:department_id],2,[session[:section1],session[:section2]])
    day,header,morning3,launch3,evening3 = department_schema(session[:department_id],3,[session[:section1],session[:section2]])
    day,header,morning4,launch4,evening4 = department_schema(session[:department_id],4,[session[:section1],session[:section2]])

    morning = [morning1, morning2, morning3, morning4]
    launch =  [launch1, launch2, launch3, launch4]
    evening = [evening1, evening2, evening3, evening4]

    department_name = Department.find(session[:department_id]).name
    period_name = Period.find(session[:period_id]).full_name
    title = period_name + " / " + department_name

    info = [
            ["Bölüm", department_name],
            ["Dönem", period_name],
    ]

    pdf = departmentpdf_schema title, nil, info, header, "Ders", "Bölüm", morning, launch, evening
    send_data(pdf.render(), :filename => period_name + "-" + department_name + ".pdf")
  end
  def departmentyearpdf
    day, header, morning, launch, evening = department_schema(
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

    pdf = pdf_schema title, nil, info, header, "Ders", "Sınıf", morning, launch, evening
    send_data(pdf.render(), :filename => period_name + "-" + department_name + "-" + params[:year] + ".pdf")
  end
end
