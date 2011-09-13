# encoding: utf-8
module CourseHelper
# Course --------------------------------------------------------------------
  def courseadd
    params.select! { |k, v| Course.columns.collect {|c| c.name}.include?(k) }
    params[:department_id] = session[:department_id]
    course = Course.new params
    course.save
    session[:course_id] = course.id

    session[:notice] = "#{course.full_name} dersi başarıyla eklendi"
    redirect_to '/user/courseshow'
  end
  def courseshow
    session[:course_id] = params[:course_id] if params[:course_id] # uniq veriyi oturuma gömelim
    unless @course = Course.find(session[:course_id])
      session[:error] = "Böyle bir kayıt bulunmamaktadır"
      redirect_to '/user/coursereview'
    end
  end
  def coursereview
    @courses = Course.find :all, :conditions => { :department_id => session[:department_id] }
  end
  def courseedit
    session[:course_id] = params[:course_id] if params[:course_id] # uniq veriyi oturuma gömelim
    @course = Course.find session[:course_id]
  end
  def coursedel
    session[:course_id] = params[:course_id] if params[:course_id] # uniq veriyi oturuma gömelim
    session[:notice] = "#{Course.find(session[:course_id]).full_name} dersi başarıyla silindi"
    Course.delete session[:course_id]
    # bu derse ait tüm atamaları da silelim
    assignments = Assignment.find(:all,
                                  :conditions => {
                                    :course_id => session[:course_id],
                                  })
    assignments.each do |assignment|
      Classplan.delete_all({
                            :assignment_id => assignment.id,
                          })
    end
    Assignment.delete_all({
                            :course_id => session[:course_id],
                          })
    session[:course_id] = nil # dersin oturumunu öldürelim
    redirect_to '/user/coursereview'
  end
  def courseupdate
    params.select! { |k, v| Course.columns.collect {|c| c.name}.include?(k) }

    Course.update(session[:course_id], params)
    session[:notice] = "#{Course.find(session[:course_id]).full_name} dersi başarıyla güncellendi"

    redirect_to '/user/courseshow'
   end
# end Course -------------------------------------------------------
end
