class AdminController < ApplicationController
  def giris
    redirect_to '/admin/home' if session[:admin]
  end

  def login
    if admin = Admin.find(:first, :conditions => { :first_name => params[:first_name], :password => params[:password] })
      if admin.department_id == 0
        session[:admin] = true
        session[:admindepartment] = admin.department_id
        session[:adminusername] = admin.first_name
        session[:adminpassword] = admin.password
        session[:TABLES] = {
                            "Admin" => 'id',
                            "Lecturer" => 'id',
                            "Classroom" => 'id',
                            "Assignment" => 'id',
                            "Classplan" => 'id',
                            "Course" => 'id',
                            "Department" => 'id',
                            "Period" => 'id',
                            }
        session[:TABLE_INIT] = "Admin"
        session[:escape] = ["created_at", "updated_at"]
        # session[:escape] = ["id", "department_id", "period_id", "created_at", "updated_at", "status"]

        unless session[:period] = Period.find( :first, :conditions => { :status => 0 })
          session[:error] = "Dikkat! aktif bir guz/bahar yili yok. Bu problemin duzeltilmesi icin asil yonetici ile irtibata gecin"
        end

        return table # ilk tablo seçilsin, oyun başlasın!
      end
    end
      session[:error] = "Oops! Isminiz veya sifreniz hatali, belkide bunlardan sadece biri hatalidir?"
      redirect_to '/admin/giris'
  end

  def logout
    reset_session if session[:admin]
    redirect_to '/admin/giris'
  end

  def table
    table = if params[:table]; params[:table] else session[:TABLE_INIT] end
    session[:notice] = "#{table} tablosu basariyla secildi"
    session[:TABLE] = table
    session[:SAVE] = eval table.capitalize + ".count"
    session[:KEY] = session[:TABLES][table]

    render '/admin/home'
  end

  # hata var ise oturuma göm; çıkmak isterse nil, doğru ise true dön
  def upload directory, savename, uploaded, overwrite = false
    destination = Rails.root.join 'public', 'images', directory # hedef dizin
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

  def new
    session[:error], session[:notice], session[:_key] = nil, nil, nil
  end

  def home
    session[:error] = nil
  end

  def add
    session[:error] = nil

    photo = params[:file] if params[:file]
    params.select! { |k, v| eval(session[:TABLE] + ".columns").collect {|c| c.name}.include?(k) }

    data = eval session[:TABLE].capitalize + ".new(params)"
    data.save
    session[:_key] = data[session[:KEY]]
    session[:SAVE] += 1

    # bir resim isteğimiz var mı ?
    if photo and upload(session[:TABLE], session[:_key].to_s, photo, false) # üzerine yazma olmasın
      data[:photo] = "#{session[:TABLE]}/#{session[:_key]}.jpg"
      data.save
    else
      data[:photo] = "default.png"
      data.save
    end
    session[:notice] = "#{session[:_key]} bilgisine sahip kisi #{session[:TABLE]} tablosuna basariyla eklendi"

    redirect_to '/admin/show'# göster
  end

  def find
    session[:error], session[:notice], session[:_key] = nil, nil, nil
  end

  def show # post ise oturma göm + verileri göster
    session[:_key] = params[:_key] if params[:_key] # uniq veriyi oturuma gömelim
    unless @data = eval(session[:TABLE].capitalize + ".find :first, :conditions => { session[:KEY] => session[:_key] }")
      session[:error] = "Boyle bir kayit bulunmamaktadir"
      redirect_to '/admin/find'
    end
  end

  def review
    session[:error], session[:notice] = nil, nil
    @data = eval session[:TABLE].capitalize + ".all"
  end

  def edit
    session[:error], session[:notice] = nil, nil
    @data = eval session[:TABLE].capitalize + ".find :first, :conditions => { session[:KEY] => session[:_key] }"
  end

  def del
    session[:error], session[:notice] = nil, nil

    eval session[:TABLE] + ".delete(session[:_key])"

    image = Rails.root.join 'public', 'images', session[:TABLE], "#{session[:_key]}.jpg" # resmimizin tam yolu
    FileUtils.rm(image) if File.exist? image # resim var ise sil.
    session[:SAVE] -= 1
    session[:notice] = "#{session[:_key]} bilgisine sahip kisi #{session[:TABLE]} tablosundan basariyla silindi"
    session[:_key] = nil # kişinin oturumunu öldürelim

    render '/admin/find'
  end

  def update
    session[:error], session[:notice] = nil, nil

    photo = params[:file] if params[:file]
    params.select! { |k, v| eval(session[:TABLE] + ".columns").collect {|c| c.name}.include?(k) }

    eval session[:TABLE].capitalize + ".update(session[:_key], params)"
    data = eval session[:TABLE].capitalize + ".find :first, :conditions => { session[:KEY] => session[:_key] }"

    # bir resim isteğimiz var mı ?
    if photo and upload(session[:TABLE], session[:_key].to_s, photo, true) # üzerine yazma olsun
      data[:photo] = "#{session[:TABLE]}/#{session[:_key]}.jpg"
      data.save
    end
    session[:notice] = "#{session[:_key]} bilgisine sahip kisi #{session[:TABLE]} tablosunda basariyla guncellendi"

    redirect_to '/admin/show'# göster
  end
end
