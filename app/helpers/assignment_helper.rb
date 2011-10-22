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
    session[:success] = "#{Lecturer.find(params[:lecturer_id]).full_name} öğretim elamanının dersleri atandı"
    redirect_to '/user/assignmentshow'
  end
  def assignmentshow
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    unless @assignment = Assignment.find(:all,
                                         :conditions => {
                                            :lecturer_id => session[:lecturer_id],
                                            :period_id => session[:period_id]
                        })
      session[:error] = "Böyle bir kayıt bulunmamaktadır"
      redirect_to '/user/assignmentreview'
    end
    @lecturer = Lecturer.find(session[:lecturer_id])
  end
  def assignmentreview
    lecturers = Lecturer.find(:all, :conditions => {:department_id => session[:department_id]})
    @assignment_lecturers = lecturers.select do |lecturer|
      Assignment.find(:first, :conditions => { :lecturer_id => lecturer.id, :period_id => session[:period_id] })
    end
  end
  def assignmentedit
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    lecturer_assignment = Assignment.find(:all, :conditions => {:lecturer_id => session[:lecturer_id], :period_id => session[:period_id]})

    @lecturer_course_ids = lecturer_assignment.collect { |ass| ass.course_id }

    courses = Course.find(:all, :conditions => {:department_id => session[:department_id]})
    @unassignment_courses = courses.select do |course|
      !Assignment.find(:first, :conditions => { :course_id => course.id, :period_id => session[:period_id] }) or
      @lecturer_course_ids.include?(course.id)
    end
    @lecturer = Lecturer.find(session[:lecturer_id])
  end
  def assignmentdel
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    # o dönemki ataması olan hocanın atamalarını bul
    assignments = Assignment.find(:all,
                                 :conditions => {
                                    :lecturer_id => session[:lecturer_id],
                                    :period_id => session[:period_id]
                                  })
    # o dönemki bu atamaların dersleri saatleri belli ise onlarıda sil
    assignments.each do |assignment|
      Classplan.delete_all({
                  :assignment_id => assignment.id,
                  :period_id => session[:period_id]
                })
    end
    # o dönemki ataması olan hocanın atamalarını sil
    Assignment.delete_all({
                  :lecturer_id => session[:lecturer_id],
                  :period_id => session[:period_id]
                })
    session[:success] = "#{Lecturer.find(session[:lecturer_id]).full_name} öğretim elamanının dersleri silindi"
    session[:lecturer_id] = nil # kişinin oturumunu öldürelim
    redirect_to '/user/assignmentreview'
  end
  def assignmentupdate
    if params[:course_ids]
      # o dönemki öğretim elamanınin tüm atamalarını alalım
      assignments = Assignment.find(:all,
                      :conditions => {
                          :lecturer_id => session[:lecturer_id],
                          :period_id => session[:period_id]
                      })
      # öğretim elamanınin verdiği derslere erişmek için.
      assignments.each do |assignment|
        # yeni isteklerde, eski isteklerden biri yok ise
        # eski isteği sil(sınıf planınıda dahil).

        unless params[:course_ids].include?(assignment.course_id.to_s)
          Classplan.delete_all({
                      :assignment_id => assignment.id,
                      :period_id => session[:period_id]
                    })
          Assignment.delete(assignment.id)
        end
      end
      # yeni atamalarda değişmenyenler var ise ona ellemeden ekliyelim.
      params[:course_ids].each do |course_id|
        request = {
                :period_id => session[:period_id],
                :lecturer_id => session[:lecturer_id],
                :course_id => course_id
              }
        unless Assignment.find(:first, :conditions => request)
          assignment = Assignment.new(request)
          assignment.save
        end
      end
      session[:success] = "#{Lecturer.find(session[:lecturer_id]).full_name} öğretim elamanının dersleri güncellendi"

  else
      session[:error] = "#{Lecturer.find(session[:lecturer_id]).full_name} isimli öğretim elamanının dönemlik tüm derslerini ve " +
                        "tüm ders atamalarını silmeye çalışıyorsunuz. Bunu yapmak istediğinizden emin misiniz ? Eğer öyle ise " +
                        "İncele/Düzenle kısmından sil seçeneğini seçin "
  end

  redirect_to '/user/assignmentshow'
  end
# end Assignment  -------------------------------------------------------
end
