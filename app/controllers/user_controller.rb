# encoding: utf-8
require 'unicode_utils' # http://unicode-utils.rubyforge.org/ turkish-char=utf8

class UserController < ApplicationController
  include InitHelper    # gerekli ortak şeyler
  include CleanHelper   # temizlik birimi
  include ReportHelper  # raporlama birimi

  # gerekli yardımcı menümünüz
  include AccountHelper # hesap güncelleme için
  include LecturerHelper
  include CourseHelper
  include AssignmentHelper
  include ScheduleHelper
  include NoticeHelper  # duyurular için
  # --------------------------

  before_filter :period # rubysiz olmadığı gibi periodsuz da sahaya çıkmayız.

  before_filter :require_login, :except => [:login, :logout] # loginsiz asla!
  before_filter :require_usersuper, :only => [:coursenew, :coursereview, :courseshow, :courseedit,
                                              :assignmentnew, :assignmentreview, :assignmentshow, :assignmentedit,
                                              :schedulenew, :schedulereview, :scheduleshow, :scheduleedit,
                                              ] # for usersuper
  before_filter :require_usernotice, :only => [
                                              :noticenew, :noticereview, :noticeshow, :noticeedit,
                                            ] # for notice : loginsiz asla!

  before_filter :clean_notice, :except => [:index, :lecturershow, :lecturerupdate, :lecturerreview,
                                                  :courseshow, :courseupdate, :coursereview,
                                                  :assignmentshow, :assignmentupdate, :assignmentreview,
                                                  :schedulenew, :scheduleshow, :scheduleupdate, :schedulereview
                                          ] # temiz sayfa

  before_filter :clean_error, :except => [:login, :noticenew,
                                                  :lecturernew, :coursenew, :lecturerfind, :lecturershow, :lecturerreview,
                                                  :coursefind, :courseshow, :coursereview,
                                                  :assignmentnew, :assignmentfind, :assignmentshow, :accountedit,
                                                  :schedulenew, :schedulefind, :scheduleshow
                                         ] # temiz sayfa

  def login
    return redirect_to '/user/index' if session[:user]

    if session[:period_id]
      if user = People.find(:first, :conditions => {
        :first_name => params[:first_name],
        :password => params[:password],
        :status => [1, 2, 3],
      })
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
        session[:error] = "Oops! İsminiz veya şifreniz hatalı, belkide bunlardan sadece biri hatalıdır?"
      end
    else
      session[:error] = "Dikkat! aktif bir güz/bahar dönemi yok. Bu problemin düzeltilmesi için asıl yönetici ile irtibata geçin"
    end
  end

  def logout
    reset_session if session[:user]
    redirect_to '/home'
  end

  def index
    assignments = Assignment.joins(:course).where(
      'courses.department_id' => session[:department_id],
      'assignments.period_id' => session[:period_id]
    ).select("assignments.course_id")
    @assignments = {}

    course_ids = assignments.collect { |assignment| assignment.course_id }.uniq

    course_ids.each do |course_id|
      assignments = Assignment.find(:all,
                                    :conditions => {
        :course_id => course_id,
        :period_id => session[:period_id]
      })
      lecturers = assignments.collect do |assignment|
        if !Classplan.find(:first, :conditions => {:assignment_id => assignment.id, :period_id => session[:period_id]})
          assignment.lecturer.full_name
        end
      end
      lecturers.compact! # nil'lerden kurtulsun
      unless lecturers == []
        lecturers = lecturers.join(';')
        @assignments[lecturers] = Course.find(course_id).full_name
      end
    end

    lecturer_count = Lecturer.where(:department_id => session[:department_id]).count
    assignments = Assignment.joins(:lecturer).where(
      'lecturers.department_id' => session[:department_id],
      'assignments.period_id' => session[:period_id]
    ).joins(:course).where(
    'courses.department_id' => session[:department_id],
    )
    lecturer_ids = assignments.collect { |assignment| assignment.lecturer_id }.uniq
    @lecturers = Lecturer.where('id not in (?)', lecturer_ids).where(:department_id => session[:department_id])
  end

  private

  def period
    if period = Period.find( :first, :conditions => { :status => true })
      session[:period_id] = period.id
    end
  end

  def require_login
    unless session[:user]
      session[:error] = "Lütfen hesabınıza girişi yapın!"
      redirect_to '/user/'
    end
  end

  def require_usersuper
    unless session[:usersuper]
      session[:error] = "Lütfen hesabınıza girişi yapın!"
      redirect_to '/user/'
    end
  end

  def require_usernotice
    unless session[:usernotice]
      session[:error] = "Lütfen hesabınıza girişi yapın!"
      redirect_to '/user/'
    end
  end

end
