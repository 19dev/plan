# encoding: utf-8
class UserController < ApplicationController
  include NoticeHelper  # duyurular için
  include AccountHelper # hesap güncelleme için
  include InitHelper    # temizlik birimi
  include CleanHelper   # temizlik birimi

  # gerekli yardımcı menümünüz
  include LecturerHelper
  include CourseHelper
  include AssignmentHelper
  include ScheduleHelper
  # --------------------------

  before_filter :period # rubysiz olmadığı gibi periodsuz da sahaya çıkmayız.
  before_filter :require_login, :except => [:login, :logout] # loginsiz asla!
  before_filter :clean_notice, :except => [:home, :lecturershow, :lecturerupdate, :lecturerreview,
                                                  :courseshow, :courseupdate, :coursereview,
                                                  :assignmentshow, :assignmentupdate, :assignmentreview,
                                                  :schedulenew, :scheduleshow, :scheduleupdate, :schedulereview
                                          ] # temiz sayfa
  before_filter :clean_error, :except => [:login, :noticenew,
                                                  :lecturernew, :coursenew, :lecturerfind, :lecturershow, :lecturerreview,
                                                  :coursefind, :courseshow, :coursereview,
                                                  :assignmentnew, :assignmentfind, :assignmentshow,
                                                  :schedulenew, :schedulefind, :scheduleshow
                                        ] # temiz sayfa
  def login
    return redirect_to '/user/home' if session[:user]

    if user = People.find(:first, :conditions => {
                                                  :first_name => params[:first_name],
                                                  :password => params[:password],
                                                  :status => 2
                                                  }
      )
        session[:user] = true
        session[:user_id] = user.id # update for password
        session[:username] = user.first_name
        session[:userpassword] = user.password
        return redirect_to '/user/noticereview'
    end

    if session[:period_id]
      if user = People.find(:first, :conditions => {
                                                    :first_name => params[:first_name],
                                                    :password => params[:password],
                                                    :status => 1
                                                    }
        )
        session[:user] = true
        session[:usersuper] = true
        session[:user_id] = user.id # update for password
        session[:department_id] = user.department_id
        session[:department] = user.department.name
        session[:departmentcode] = user.department.code
        session[:username] = user.first_name
        session[:userpassword] = user.password
        session[:period] = Period.find(session[:period_id]).full_name

        return redirect_to '/user/home'
      end
      if params[:first_name] or params[:password]
        session[:error] = "Oops! İsminiz veya şifreniz hatalı, belkide bunlardan sadece biri hatalıdır?"
      end
    else
      session[:error] = "Dikkat! aktif bir güz/bahar yılı yok. Bu problemin düzeltilmesi için asıl yönetici ile irtibata geçin"
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
    if period = Period.find( :first, :conditions => { :status => true })
      session[:period_id] = period.id
    end
  end
end
