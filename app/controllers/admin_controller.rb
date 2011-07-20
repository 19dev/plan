class AdminController < ApplicationController

  def giris
    session[:TABLES] = {
			"Admins" => 'id',
			"Lecturers" => 'id',
                        "Classplans" => 'id',
                        "Classrooms" => 'id',
                        "Courses" => 'id',
                        "Departments" => 'id',
                        "Periods" => 'id',
                        }
    session[:TABLE_INIT] = "Admins"
    session[:error], session[:correct] = nil, nil
    redirect_to '/admin/home' if session[:admin]
  end

  def login
    if admin = Admins.find(:first, :conditions => { :first_name => params[:first_name], :password => params[:password] })
      session[:admin] = true
      session[:adminusername] = admin.first_name
      session[:adminpassword] = admin.password
      session[:adminsuper] = true if admin.status == 1
      session[:error], session[:correct] = nil, nil

      table # ilk tablo seçilsin, oyun başlasın!
    else
      session[:error] = "isim veya sifre hatali"
      return render '/admin/giris'
    end
  end

  def logout
    reset_session if session[:admin]
    redirect_to '/admin/giris'
  end

  def table
    table = if params[:table]; params[:table] else session[:TABLE_INIT] end
    session[:correct] = "#{table} tablosu basariyla secildi"
    session[:TABLE] = table
    session[:SAVE] = eval table.capitalize + ".count"
    session[:KEY] = session[:TABLES][table]

    render '/admin/home'
  end

  def new
    session[:error], session[:correct], session[:_key] = nil, nil, nil
  end

  # hata var ise oturuma göm; çıkmak isterse nil, doğru ise true dön
  def upload savename, uploaded, overwrite = false
    destination = Rails.root.join 'public', 'images', session[:TABLE] # hedef dizin
    image = destination.join savename # resmin tam yolu

    # hedef yoksa oluşturalım
    FileUtils.mkdir(destination) unless File.exist? destination

    # yüklenen dosya yok ise sessiz çık
    return nil unless File.exist? uploaded.path

    if uploaded.size > 550000;                          session[:error] = "Resim cok buyuk"
    elsif !(uploaded.content_type =~ /jpe?g/);          session[:error] = "Resim jpg formatinda olmalidir"
    elsif File.exist?(image) && !(overwrite);           session[:error] = "Resim zaten var"
    elsif !FileUtils.mv(uploaded.path, "#{image}.jpg"); session[:error] = "Dosya yukleme hatasi"
    else return true end # resim yükleme başarısı

    return nil
  end

  def add
    session[:error] = nil

    photo = params[:file] if params[:file]
    params.select! { |k, v| eval(session[:TABLE] + ".columns").reduce([]) {|res, c| res << c.name; res}.include?(k) }

    data = eval session[:TABLE].capitalize + ".new(params)"
    data.save
    session[:_key] = data[session[:KEY]]
    session[:SAVE] += 1

    # bir resim isteğimiz var mı ?
    if photo and upload("#{session[:_key]}", photo, false) # üzerine yazma olmasın
      data[:photo] = "#{session[:TABLE]}/#{session[:_key]}.jpg"
      data.save
    else
      data[:photo] = "default.png"
      data.save
    end
    session[:correct] = "#{session[:_key]} bilgisine sahip kisi #{session[:TABLE]} tablosunu basariyla eklendi"
    show # göster
  end

  def find
    session[:error], session[:correct], session[:_key] = nil, nil, nil
  end

  def show # post ise oturma göm + verileri göster
    session[:_key] = params[:_key] if params[:_key] # uniq veriyi oturuma gömelim
    @data = eval session[:TABLE].capitalize + ".find :first, :conditions => { session[:KEY] => session[:_key] }"
    render '/admin/show'
  end

  def review
    session[:error], session[:correct] = nil, nil
    @data = eval session[:TABLE].capitalize + ".all"
  end

  def edit
    @data = eval session[:TABLE].capitalize + ".find :first, :conditions => { session[:KEY] => session[:_key] }"
  end

  def del
    session[:error], session[:correct] = nil, nil

    eval session[:TABLE] + ".delete(session[:_key])"

    image = Rails.root.join 'public', 'images', session[:TABLE], "#{session[:_key]}.jpg" # resmimizin tam yolu
    FileUtils.rm(image) if File.exist? image # resim var ise sil.
    session[:SAVE] -= 1
    session[:_key] = nil # kişinin oturumunu öldürelim

    render '/admin/find'
  end

  def update
    session[:error], session[:correct] = nil, nil

    photo = params[:file] if params[:file]
    params.select! { |k, v| eval(session[:TABLE] + ".columns").reduce([]) {|res, c| res << c.name; res}.include?(k) }

    eval session[:TABLE].capitalize + ".update(session[:_key], params)"
    data = eval session[:TABLE].capitalize + ".find :first, :conditions => { session[:KEY] => session[:_key] }"

    # bir resim isteğimiz var mı ?
    if photo and upload("#{session[:_key]}", photo, false) # üzerine yazma olmasın
      data[:photo] = "#{session[:TABLE]}/#{session[:_key]}.jpg"
      data.save
    end

    show # göster
  end
end
