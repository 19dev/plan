class UserController < ApplicationController
  def giris
    redirect_to '/user/home' if session[:user]
  end

  def login
    if admin = Admins.find(:first, :conditions => { :first_name => params[:first_name], :password => params[:password] })
        session[:user] = true
        session[:userdepartment_id] = admin.department_id
        session[:department] = Departments.find(:first, :conditions => { :id => admin.department_id }).name
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
  def upload savename, uploaded, overwrite = false
    destination = Rails.root.join 'public', 'images'
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

  def tutornew

  end

  def tutoradd
    session[:error] = nil

    photo = params[:file]
    params.select! { |k, v| Lecturers.columns.collect {|c| c.name}.include?(k) }
    params[:department_id] = session[:userdepartment_id]
    tutor = Lecturers.new params
    tutor.save
    session[:_key] = tutor.id

    # bir resim isteğimiz var mı ?
    if photo and upload("Lecturers/#{session[:_key]}", photo, false) # üzerine yazma olmasın
      tutor[:photo] = "Lecturers/#{session[:_key]}.jpg"
      tutor.save
    else
      tutor[:photo] = "default.png"
      tutor.save
    end
    session[:notice] = "#{tutor.first_name} #{tutor.last_name} kisi ogretim gorevlisi olarak basariyla eklendi"
    redirect_to '/user/tutorshow'
  end

  def tutorshow
    session[:_key] = params[:_key] if params[:_key] # uniq veriyi oturuma gömelim
    unless @tutor = Lecturers.find(:first, :conditions => { :id => session[:_key] })
      session[:error] = "Boyle bir kayit bulunmamaktadir"
  #      redirect_to '/user/find'
    end
  end

  def tutorreview
    session[:error], session[:notice] = nil, nil
    @data = Lecturers.find(:all, :conditions => { :department_id => session[:userdepartment_id] })
  end

end
