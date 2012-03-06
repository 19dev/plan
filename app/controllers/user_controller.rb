# encoding: utf-8
require 'unicode_utils' # http://unicode-utils.rubyforge.org/ turkish-char=utf8

class UserController < ApplicationController
  include Init::InitHelper  # gerekli ortak şeyler
  include MainHelper        # raporlama birimi

  # Plan
  include Plan::PlanHelper         # plan helper
  include Plan::SchemaHelper       # schema helper
 # include Plan::PdfHelper          # pdf birimi

  # Account
  include Account::AccountHelper # hesap güncelleme için

  # User
  include User::LecturerHelper
  include User::CourseHelper
  include User::AssignmentHelper
  include User::ScheduleHelper
  include User::NoticeHelper  # duyurular için

  before_filter :period # rubysiz olmadığı gibi periodsuz da sahaya çıkmayız.

  before_filter :require_login, :except => [:login, :logout] # loginsiz asla!
  before_filter :require_usersuper, :only => [:coursenew, :coursereview, :courseshow, :courseedit,
                                              :assignmentnew, :assignmentreview, :assignmentshow, :assignmentedit,
                                              :schedulenew, :schedulereview, :scheduleshow, :scheduleedit,
                                              ] # for usersuper
  before_filter :require_usernotice, :only => [
                                              :noticenew, :noticereview, :noticeshow, :noticeedit,
                                            ] # for notice : loginsiz asla!

  def login
    return redirect_to '/user/index' if session[:user]

    if session[:period_id]
      if user = People.find_by_first_name_and_password_and_status(params[:first_name], params[:password], [1, 2, 3])
        session[:user] = true
        session[:user_id] = user.id # update for password
        session[:department_id] = user.department_id
        session[:department] = user.department.name
        session[:username] = user.first_name
        session[:userpassword] = user.password
        session[:period] = Period.find(session[:period_id]).full_name
        if user.status == 1
          session[:usersuper] = true
          return redirect_to '/user/index'
        elsif user.status == 2
          session[:usernotice] = true
          return redirect_to '/user/noticereview'
        elsif user.status == 3
          session[:userdig] = true
          return redirect_to '/user/lecturerreview'
        end
      end

      if params[:first_name] or params[:password]
        flash[:error] = "Oops! İsminiz veya şifreniz hatalı, belkide bunlardan sadece biri hatalıdır?"
      end
    else
      flash[:error] = "Dikkat! aktif bir güz/bahar dönemi yok. Bu problemin düzeltilmesi için asıl yönetici ile irtibata geçin"
    end
  end

  def logout
    reset_session if session[:user]
    redirect_to '/home'
  end

  private

  def period
    if period = Period.find( :first, :conditions => { :status => true })
      session[:period_id] = period.id
    end
  end

  def require_login
    unless session[:user]
      flash[:error] = "Lütfen hesabınıza girişi yapın!"
      redirect_to '/user/'
    end
  end

  def require_usersuper
    unless session[:usersuper]
      flash[:error] = "Lütfen hesabınıza girişi yapın!"
      redirect_to '/user/'
    end
  end

  def require_usernotice
    unless session[:usernotice]
      flash[:error] = "Lütfen hesabınıza girişi yapın!"
      redirect_to '/user/'
    end
  end

end
