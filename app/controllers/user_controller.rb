# encoding: utf-8
class UserController < ApplicationController
  include CleanHelper # temizlik birimi

  # gerekli yardımcı menümünüz
  include LecturerHelper
  include CourseHelper
  include AssignmentHelper
  include ScheduleHelper
  # --------------------------

  before_filter :period # rubysiz olmadığı gibi periodsuz da sahaya çıkmayız.
  before_filter :require_login, :except => [:login, :logout] # loginsiz asla!
  before_filter :clean_notice, :except => [:home, :lecturershow, :lecturerupdate,
                                                  :courseshow, :courseupdate,
                                                  :assignmentshow, :assignmentupdate,
                                                  :scheduleshow, :scheduleupdate
                                          ] # temiz sayfa
  before_filter :clean_error, :except => [:login, :lecturerfind, :lecturershow,
                                                  :coursefind, :courseshow,
                                                  :assignmentfind, :assignmentshow,
                                                  :schedulefind, :scheduleshow
                                        ] # temiz sayfa
  def login
    redirect_to '/user/home' if session[:user]

    unless session[:period_id]
      session[:error] = "Dikkat! aktif bir güz/bahar yılı yok. Bu problemin düzeltilmesi için asıl yönetici ile irtibata geçin"
    end
    if user = People.find(:first, :conditions => { :first_name => params[:first_name], :password => params[:password] })
      if user.department_id != 0 and user.status == 1
        session[:user] = true
        session[:department_id] = user.department_id
        session[:department] = user.department.name
        session[:username] = user.first_name
        session[:userpassword] = user.password
        return redirect_to '/user/home'
      end
    end
    if params[:first_name] or params[:password]
      session[:error] = "Oops! İsminiz veya şifreniz hatalı, belkide bunlardan sadece biri hatalıdır?"
    end
  end

  def logout
    reset_session if session[:user]
    redirect_to '/user/'
  end

  def require_login
    unless session[:user]
      session[:error] = "Lütfen hesabınıza girişi yapın!"
      redirect_to '/user/'
    end
  end

  private
  def period
    if period = Period.find( :first, :conditions => { :status => 1 })
      session[:period_id] = period.id
    end
  end
end
