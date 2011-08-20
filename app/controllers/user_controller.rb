class UserController < ApplicationController
  before_filter :period # rubysiz olmadığı gibi periodsuz da sahaya çıkmayız.

  def giris
    redirect_to '/user/home' if session[:user]
  end

  def login
    unless session[:period_id]
      session[:error] = "Dikkat! aktif bir guz/bahar yili yok. Bu problemin duzeltilmesi icin asil yonetici ile irtibata gecin"
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
        return render '/user/home'
      end
    end
    session[:error] = "Oops! Isminiz veya sifreniz hatali, belkide bunlardan sadece biri hatalidir?"
    redirect_to '/user/giris'
  end

  def logout
    reset_session if session[:user]
    redirect_to '/user/giris'
  end

  # hata var ise oturuma göm; çıkmak isterse nil, doğru ise true dön
  def upload directory, savename, uploaded, overwrite = false
    destination = Rails.root.join 'public', 'images', directory
    # hedef dizin
    image = destination.join savename # resmin tam yolu

    # hedef yoksa oluşturalım
    FileUtils.mkdir(destination) unless File.exist? destination

    # yüklenen dosya yok ise sessiz çık
    return nil unless File.exist? uploaded.path

    if uploaded.size > 550000;                          session[:error] = "Resim cok buyuk"
    elsif !(uploaded.content_type =~ /jpe?g/);          session[:error] = "Resim jpg formatinda olmalidir"
    elsif File.exist?("#{image}.jpg") && !(overwrite);  session[:error] = "Resim zaten var"
    elsif !FileUtils.mv(uploaded.path, "#{image}.jpg"); session[:error] = "Dosya yukleme hatasi"
    else return true end # resim yükleme başarısı

    return nil
  end

# Lecturer --------------------------------------------------------------------
  def lectureradd
    session[:error] = nil

    photo = params[:file]
    params.select! { |k, v| Lecturer.columns.collect {|c| c.name}.include?(k) }
    params[:department_id] = session[:department_id]
    lecturer = Lecturer.new params
    lecturer.save
    session[:lecturer_id] = lecturer.id

    if photo and upload('Lecturer', "#{session[:lecturer_id]}", photo, false) # üzerine yazma olmasın
      lecturer[:photo] = "Lecturer/#{session[:lecturer_id]}.jpg"
      lecturer.save
    else
      lecturer[:photo] = "default.png"
      lecturer.save
    end
    session[:notice] = "#{lecturer.first_name} #{lecturer.last_name} kisi ogretim gorevlisi olarak basariyla eklendi"
    redirect_to '/user/lecturershow'
  end
  def lecturershow
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    unless @lecturer = Lecturer.find(session[:lecturer_id])
      session[:error] = "Boyle bir kayit bulunmamaktadir"
      redirect_to '/user/lecturerreview'
    end
  end
  def lecturerreview
    session[:error] = nil
    @lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] })
  end
  def lectureredit
    session[:error], session[:notice] = nil, nil
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    @lecturer = Lecturer.find session[:lecturer_id]
  end
  def lecturerdel
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    Lecturer.delete session[:lecturer_id]
    # bu hocaya ait tüm dersleri silelim
    Assignment.delete_all ({
                  :lecturer_id => session[:lecturer_id],
                  :period_id => session[:period_id]
                })
    image = Rails.root.join 'public', 'images', 'Lecturer', "#{session[:lecturer_id]}.jpg" # resmimizin tam yolu
    FileUtils.rm(image) if File.exist? image # resim var ise sil.
    session[:notice] = "ogretim gorevlisi basariyla silindi"
    session[:lecturer_id] = nil # kişinin oturumunu öldürelim

    redirect_to '/user/lecturerreview'
  end
  def lecturerupdate
    session[:error], session[:notice] = nil, nil

    photo = params[:file] if params[:file]
    params.select! { |k, v| Lecturer.columns.collect {|c| c.name}.include?(k) }

    Lecturer.update(session[:lecturer_id], params)
    lecturer = Lecturer.find session[:lecturer_id]
    if photo and upload('Lecturer', "#{session[:lecturer_id]}", photo, true) # üzerine yazma olsun
      lecturer[:photo] = "Lecturer/#{session[:lecturer_id]}.jpg"
      lecturer.save
    end
    session[:notice] = "#{session[:lecturer_id]} bilgisine sahip kisi asd tablosunda basariyla guncellendi"
    redirect_to '/user/lecturershow'
   end
# end Lecturer -------------------------------------------------------
# Course --------------------------------------------------------------------
  def courseadd
    session[:error] = nil

    photo = params[:file]
    params.select! { |k, v| Course.columns.collect {|c| c.name}.include?(k) }
    params[:department_id] = session[:department_id]
    course = Course.new params
    course.save
    session[:course_id] = course.id

    session[:notice] = "#{course.code} - #{course.name} dersi basariyla eklendi"
    redirect_to '/user/courseshow'
  end
  def courseshow
    session[:course_id] = params[:course_id] if params[:course_id] # uniq veriyi oturuma gömelim
    unless @course = Course.find(session[:course_id])
      session[:error] = "Boyle bir kayit bulunmamaktadir"
      redirect_to '/user/coursereview'
    end
  end
  def coursereview
    session[:error] = nil
    @courses = Course.find :all, :conditions => { :department_id => session[:department_id] }
  end
  def courseedit
    session[:error], session[:notice] = nil, nil
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
    session[:notice] = "#{session[:course_id]} dersi basariyla silindi"
    session[:course_id] = nil # kişinin oturumunu öldürelim
    redirect_to '/user/coursereview'
  end
  def courseupdate
    session[:error], session[:notice] = nil, nil

    params.select! { |k, v| Course.columns.collect {|c| c.name}.include?(k) }

    Course.update(session[:course_id], params)
    course = Course.find session[:course_id]
    session[:notice] = "#{course.code}-#{course.name} dersi basariyla guncellendi"
    redirect_to '/user/courseshow'
   end
# end Course -------------------------------------------------------
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
      session[:error] = "Dersi atanmamis hoca kalmamis!"
      return redirect_to '/user/assignmentnew'
    end
    unless params[:course_ids]
      session[:error] = "Atanacak hic ders kalmamis!"
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
    session[:notice] = "#{Lecturer.find(params[:lecturer_id]).full_name} ogretim gorevlisinin dersleri basariyla atandi"
    redirect_to '/user/assignmentshow'
  end
  def assignmentshow
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    unless @assignment = Assignment.find(:all, :conditions => { :lecturer_id => session[:lecturer_id] })
      session[:error] = "Boyle bir kayit bulunmamaktadir"
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
    session[:notice] = "#{Lecturer.find(session[:lecturer_id]).full_name} ogretim gorevlisinin dersleri basariyla silindi"
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
    session[:notice] = "#{Lecturer.find(session[:lecturer_id]).full_name} ogretim gorevlisinin dersleri basariyla guncellendi"
    redirect_to '/user/assignmentshow'
  end
# end Assignment  -------------------------------------------------------
# Schedule -------------------------------------------------------
  def schedulenew
    lecturers = Lecturer.find(:all, :conditions => {:department_id => session[:department_id]})
    @lecturers = lecturers.select do |lecturer|
      Assignment.find(:first, :conditions => { :period_id => session[:period_id], :lecturer_id => lecturer.id })
    end
    # courses = Course.find(:all, :conditions => {:department_id => session[:department_id]})
    # @unschedule_courses = courses.select do |course|
    #   !Assignment.find(:first, :conditions => { :course_id => course.id, :period_id => session[:period_id] })
    # end
  end
  def scheduleadd
  end
  def scheduleshow
  end
  def schedulereview
  end
  def scheduleedit
  end
  def scheduledel
  end
  def scheduleupdate
  end
# end Schedule -------------------------------------------------------

  private
  def period
    if period = Period.find( :first, :conditions => { :status => 1 })
      session[:period_id] = period.id
    end
  end
end
