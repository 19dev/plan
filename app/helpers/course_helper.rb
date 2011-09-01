# encoding: utf-8
module CourseHelper
# Course --------------------------------------------------------------------
  def courseadd
    photo = params[:file]
    params.select! { |k, v| Course.columns.collect {|c| c.name}.include?(k) }
    params[:department_id] = session[:department_id]
    course = Course.new params
    course.save
    session[:course_id] = course.id

    session[:notice] = "#{course.code} - #{course.name} dersi başarıyla eklendi"
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
    Course.delete session[:course_id]
    # bu derse ait tüm atamaları da silelim
    Assignment.delete_all ({
                  :course_id => session[:course_id],
                  :period_id => session[:period_id]
                })
    session[:notice] = "#{session[:course_id]} dersi başarıyla silindi"
    session[:course_id] = nil # kişinin oturumunu öldürelim
    redirect_to '/user/coursereview'
  end
  def courseupdate
    params.select! { |k, v| Course.columns.collect {|c| c.name}.include?(k) }

    Course.update(session[:course_id], params)
    course = Course.find session[:course_id]
    session[:notice] = "#{course.code}-#{course.name} dersi başarıyla güncellendi"

    redirect_to '/user/courseshow'
   end
# end Course -------------------------------------------------------
end
