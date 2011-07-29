class UserController < ApplicationController
  def giris
    redirect_to '/user/home' if session[:user]
  end

  def login
    if admin = Admin.find(:first, :conditions => { :first_name => params[:first_name], :password => params[:password] })
      session[:user] = true
      session[:userdepartment_id] = admin.department_id
      session[:department] = Department.find(:first, :conditions => { :id => admin.department_id }).name
      session[:username] = admin.first_name
      session[:userpassword] = admin.password
      session[:error] = nil
      render '/user/home'
    else
      session[:error] = "Oops! Isminiz veya sifreniz hatali, belkide bunlardan sadece biri hatalidir?"
      redirect_to '/user/giris'
    end
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
    params[:department_id] = session[:userdepartment_id]
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
    unless @lecturer = Lecturer.find(:first, :conditions => { :id => session[:lecturer_id] })
      session[:error] = "Boyle bir kayit bulunmamaktadir"
      redirect_to '/user/lecturerreview'
    end
  end
  def lecturerreview
    session[:error] = nil
    @lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:userdepartment_id] })
  end
  def lectureredit
    session[:error], session[:notice] = nil, nil
    @lecturer = Lecturer.find(:first, :conditions => { :id => session[:lecturer_id] })
  end
  def lecturerdel
    Lecturer.delete(session[:lecturer_id])

    image = Rails.root.join 'public', 'images', 'Lecturer', "#{session[:lecturer_id]}.jpg" # resmimizin tam yolu
    FileUtils.rm(image) if File.exist? image # resim var ise sil.
    session[:notice] = "#{session[:lecturer_id]} bilgisine sahip ogretim gorevlisi basariyla silindi"
    session[:lecturer_id] = nil # kişinin oturumunu öldürelim

    redirect_to '/user/lecturerreview'
  end
  def lecturerupdate
    session[:error], session[:notice] = nil, nil

    photo = params[:file] if params[:file]
    params.select! { |k, v| Lecturer.columns.collect {|c| c.name}.include?(k) }

    Lecturer.update(session[:lecturer_id], params)
    lecturer = Lecturer.find :first, :conditions => { :id => session[:lecturer_id] }
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
    params[:department_id] = session[:userdepartment_id]
    course = Course.new params
    course.save
    session[:course_id] = course.id

    session[:notice] = "#{course.code} - #{course.name} dersi basariyla eklendi"
    redirect_to '/user/courseshow'
  end
  def courseshow
    session[:course_id] = params[:course_id] if params[:course_id] # uniq veriyi oturuma gömelim
    unless @course = Course.find(:first, :conditions => { :id => session[:course_id] })
      session[:error] = "Boyle bir kayit bulunmamaktadir"
      redirect_to '/user/coursereview'
    end
  end
  def coursereview
    session[:error] = nil
    @courses = Course.find :all, :conditions => { :department_id => session[:userdepartment_id] }
  end
  def courseedit
    session[:error], session[:notice] = nil, nil
    @course = Course.find :first, :conditions => { :id => session[:course_id] }
  end
  def coursedel
    Course.delete session[:course_id]
    session[:notice] = "#{session[:course_id]} dersi basariyla silindi"
    session[:course_id] = nil # kişinin oturumunu öldürelim
    redirect_to '/user/coursereview'
  end
  def courseupdate
    session[:error], session[:notice] = nil, nil

    params.select! { |k, v| Course.columns.collect {|c| c.name}.include?(k) }

    Course.update(session[:course_id], params)
    course = Course.find :first, :conditions => { :id => session[:course_id] }
    session[:notice] = "#{course.code}-#{course.name} dersi basariyla guncellendi"
    redirect_to '/user/courseshow'
   end
# end Course -------------------------------------------------------
end
