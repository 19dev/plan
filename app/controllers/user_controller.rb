# encoding: utf-8
class UserController < ApplicationController
  before_filter :period # rubysiz olmadığı gibi periodsuz da sahaya çıkmayız.
  before_filter :require_login,  :except => [:login, :logout] # loginsiz asla!

  # gerekli yardımcı menümünüz
  include ImageHelper # Image.upload & Image.delete
  include LecturerHelper
  include CourseHelper
  include AssignmentHelper
  include ScheduleHelper
  # --------------------------

  def login
    redirect_to '/admin/home' if session[:user]

    unless session[:period_id]
      session[:error] = "Dikkat! aktif bir güz/bahar yılı yok. Bu problemin düzeltilmesi için asıl yönetici ile irtibata geçin"
      return redirect_to '/user/giris'
    end
    if user = People.find(:first, :conditions => { :first_name => params[:first_name], :password => params[:password] })
      if user.department_id != 0 and user.status == 1
        session[:user] = true
        session[:department_id] = user.department_id
        session[:department] = user.department.name
        session[:username] = user.first_name
        session[:userpassword] = user.password
        session[:error] = nil
        return redirect_to '/user/home'
      end
    end
    if params[:first_name] or params[:password]
      session[:error] = "Oops! İsminiz veya şifreniz hatalı, belkide bunlardan sadece biri hatalıdır?"
    end
  end

  def logout
    reset_session if session[:user]
    redirect_to '/user/login'
  end

  def require_login
    unless session[:user]
      session[:error] = "Lütfen hesabınıza girişi yapın!"
      redirect_to '/user/login'
    end
  end

  private
  def period
    if period = Period.find( :first, :conditions => { :status => 1 })
      session[:period_id] = period.id
    end
  end
end
