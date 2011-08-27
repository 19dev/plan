# encoding: utf-8
module AssignmentHelper
# Assignment -------------------------------------------------------
  def assignmentnew
    lecturers = Lecturer.find(:all, :conditions => {:department_id => session[:department_id]})
    @unassignment_lecturers = lecturers.select do |lecturer|
      !Assignment.find(:first, :conditions => { :lecturer_id => lecturer.id, :period_id => session[:period_id] })
    end
    courses = Course.find(:all, :conditions => {:department_id => session[:department_id]})
    @unassignment_courses = courses.select do |course|
      !Assignment.find(:first, :conditions => { :course_id => course.id, :period_id => session[:period_id] })
    end
  end
  def assignmentadd
    unless params[:lecturer_id]
      session[:error] = "Dersi atanmamış hoca kalmamis!"
      return redirect_to '/user/assignmentnew'
    end
    unless params[:course_ids]
      session[:error] = "Atanacak hic ders kalmamış!"
      return redirect_to '/user/assignmentnew'
    end
    params[:course_ids].each do |course_id|
      assignment = Assignment.new ({
                                    :period_id => session[:period_id],
                                    :lecturer_id => params[:lecturer_id],
                                    :course_id => course_id
                                  })
      assignment.save
    end
    session[:lecturer_id] = params[:lecturer_id]
    session[:notice] = "#{Lecturer.find(params[:lecturer_id]).full_name} öğretim görevlisinin dersleri atandı"
    redirect_to '/user/assignmentshow'
  end
  def assignmentshow
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    unless @assignment = Assignment.find(:all, :conditions => { :lecturer_id => session[:lecturer_id] })
      session[:error] = "Böyle bir kayıt bulunmamaktadır"
      redirect_to '/user/assignmentreview'
    end
  end
  def assignmentreview
    session[:error] = nil
    lecturers = Lecturer.find(:all, :conditions => {:department_id => session[:department_id]})
    @assignment_lecturers = lecturers.select do |lecturer|
      Assignment.find(:first, :conditions => { :lecturer_id => lecturer.id, :period_id => session[:period_id] })
    end
  end
  def assignmentedit
    session[:error], session[:notice] = nil, nil
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    lecturer_assignment = Assignment.find(:all, :conditions => {:lecturer_id => session[:lecturer_id], :period_id => session[:period_id]})

    @lecturer_course_ids = lecturer_assignment.collect { |ass| ass.course_id }

    courses = Course.find(:all, :conditions => {:department_id => session[:department_id]})
    @unassignment_courses = courses.select do |course|
      !Assignment.find(:first, :conditions => { :course_id => course.id, :period_id => session[:period_id] }) or
      @lecturer_course_ids.include?(course.id)
    end
  end
  def assignmentdel
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    Assignment.delete_all ({
                  :lecturer_id => session[:lecturer_id],
                  :period_id => session[:period_id]
                })
    session[:notice] = "#{Lecturer.find(session[:lecturer_id]).full_name} öğretim görevlisinin dersleri silindi"
    session[:lecturer_id] = nil # kişinin oturumunu öldürelim
    redirect_to '/user/assignmentreview'
  end
  def assignmentupdate
    session[:error], session[:notice] = nil, nil
    # tum atamalarını silelim
    Assignment.delete_all ({
                  :lecturer_id => session[:lecturer_id],
                  :period_id => session[:period_id]
                })
    # yeni atamalarını ekliyelim
    params[:course_ids].each do |course_id|
      assignment = Assignment.new ({
                                    :period_id => session[:period_id],
                                    :lecturer_id => session[:lecturer_id],
                                    :course_id => course_id
                                  })
      assignment.save
    end
    session[:notice] = "#{Lecturer.find(session[:lecturer_id]).full_name} öğretim görevlisinin dersleri güncellendi"
    redirect_to '/user/assignmentshow'
  end
# end Assignment  -------------------------------------------------------
end
