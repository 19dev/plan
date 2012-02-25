# encoding: utf-8
module AssignmentHelper
  def assignmentnew
    @auto_lecturers = Lecturer.all.collect do |lecturer|
      { lecturer.id => ["#{lecturer.first_name} #{lecturer.last_name}", lecturer.photo, lecturer.department.name] }
    end
    lecturers = Lecturer.find(:all, :conditions => {:department_id => session[:department_id]})
    @unassignment_lecturers = lecturers.select do |lecturer|
      !Assignment.find(:first, :conditions => { :lecturer_id => lecturer.id, :period_id => session[:period_id] })
    end
    @unassignment_courses = Course.find(:all, :conditions => {:department_id => session[:department_id]}, :order => 'code') # yeni
  end
  def assignmentadd
    if session[:error] = control({ params[:course_ids] => "Atanacak ders", params[:lecturer_id] => "Dersi atanacak hoca",})
      return redirect_to '/user/assignmentnew'
    end
    params[:course_ids].each do |course_id|
      unless Assignment.find(:first,
                             :conditions => {
        :lecturer_id => params[:lecturer_id],
        :period_id => session[:period_id],
        :course_id => course_id
      })
      assignment = Assignment.new ({
        :period_id => session[:period_id],
        :lecturer_id => params[:lecturer_id],
        :course_id => course_id
      })
      assignment.save
      end
    end
    session[:lecturer_id] = params[:lecturer_id]
    session[:success] = "#{Lecturer.find(params[:lecturer_id]).full_name} öğretim üyesinin dersleri atandı"
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
    assignments = Assignment.joins(:course).where(
      'courses.department_id' => session[:department_id],
      'assignments.period_id' => session[:period_id]
    ).select('assignments.lecturer_id').group('assignments.lecturer_id')
    lecturer_ids = assignments.collect { |assignment| assignment.lecturer_id }
    @assignment_lecturers = Lecturer.joins(:assignment).where(
      'assignments.period_id' => session[:period_id],
      'assignments.lecturer_id' => lecturer_ids
    ).group('assignments.lecturer_id')
  end
  def assignmentedit
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    lecturer_assignment = Assignment.find(:all, :conditions => {:lecturer_id => session[:lecturer_id], :period_id => session[:period_id]}, :select => 'course_id')

    @lecturer_course_ids = lecturer_assignment.collect { |assignment| assignment.course_id }
    @lecturer = Lecturer.find(session[:lecturer_id])
    @unassignment_courses = Course.find(:all, :conditions => {:department_id => session[:department_id]}, :order => 'code') # yeni
  end
  def assignmentdel
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    # o dönemki ataması olan hocanın atamalarını bul
    assignments = Assignment.joins(:lecturer).where(
      'lecturers.id' => session[:lecturer_id],
      'assignments.period_id' => session[:period_id]
    ).joins(:course).where(
      'courses.department_id' => session[:department_id],
    )
    # o dönemki bu atamaların dersleri saatleri belli ise onlarıda sil
    # o dönemki ataması olan hocanın atamalarını sil
    assignments.each do |assignment|
      Classplan.delete_all({
        :assignment_id => assignment.id,
        :period_id => session[:period_id]
      })
      Assignment.delete_all({
        :id => assignment.id,
        :period_id => session[:period_id]
      })
    end

    session[:success] = "#{Lecturer.find(session[:lecturer_id]).full_name} öğretim üyesinin dersleri silindi"
    session[:lecturer_id] = nil # kişinin oturumunu öldürelim
    redirect_to '/user/assignmentreview'
  end
  def assignmentupdate
    if params[:course_ids]
      # o dönemki öğretim üyesinin tüm atamalarını alalım
      assignments = Assignment.find(:all,
                      :conditions => {
                          :lecturer_id => session[:lecturer_id],
                          :period_id => session[:period_id]
                      })
      # öğretim üyesinin verdiği derslere erişmek için.
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
      session[:success] = "#{Lecturer.find(session[:lecturer_id]).full_name} öğretim üyesinin dersleri güncellendi"

  else
      session[:error] = "#{Lecturer.find(session[:lecturer_id]).full_name} isimli öğretim üyesinin dönemlik tüm derslerini ve " +
                        "tüm ders atamalarını silmeye çalışıyorsunuz. Bunu yapmak istediğinizden emin misiniz ? Eğer öyle ise " +
                        "İncele/Düzenle kısmından sil seçeneğini seçin "
  end

  redirect_to '/user/assignmentshow'
  end
end
