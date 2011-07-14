class AdminController < ApplicationController

  def giris
    session[:TABLES] = {
			"Admins" => 'id',
			"Lecturers" => 'id'
                        }
    session[:TABLE_INIT] = "Admins"
    @title = "Yonetici Paneli"
    redirect_to '/admin/home' if session[:admin]
  end

  def login
    if admin = Admins.find(:first, :conditions => { :first_name => params[:first_name], :password => params[:password] })
      session[:admin] = true
      session[:adminusername] = admin.first_name
      session[:adminpassword] = admin.password
      session[:adminsuper] = admin.status

      table # ilk tablo seçilsin, oyun başlasın
    else
      @error = "isim veya sifre hatali"
      return render '/admin/giris'
    end
  end

  def logout
    if session[:admin]
      reset_session
#      session[:admin] = nil
#      session[:adminusername] = nil
#      session[:adminpassword] = nil
#      session[:adminsuper] = nil
#      session[:TABLE_INIT] = nil
#      session[:TABLES] = nil
#      session[:TABLE] = nil
#      session[:KEY] = nil
    end
    redirect_to '/admin/giris'
  end

  def table
    if params[:table]
      table = params[:table]
    else
      table = session[:TABLE_INIT]
    end
    @correct = "#{table} tablosu basariyla secildi"
    session[:SAVE] = eval table.capitalize + ".count"
    session[:TABLE] = table
    session[:KEY] = session[:TABLES][table]

    @title = "Yonetici Paneli"
    render '/admin/home'
  end

  def new
    session[:_key] = nil
  end

  def add
    table = session[:TABLE]
    key = session[:KEY]

    _post = {}
    eval(table + ".columns").map do |c|
      _post[c.name] = params[c.name]
    end
    eval table.capitalize + ".new(_post)"
    session[:_key] = _post[key]

  end

  def look
    @title = "Kayit Inceleniyor"
    table = session[:TABLE]
    key = session[:KEY]
    _key = params[:_key]

    session[:_key] = _key # uniq veriyi oturuma gömelim
    @data = eval table.capitalize + ".find :first, :conditions => { key => _key }"
  end

  def review
    @data = eval session[:TABLE].capitalize + ".all"
  end

  def edit
    table = session[:TABLE]
    key = session[:KEY]
    _key = session[:_key]

    @data = eval table.capitalize + ".find :first, :conditions => { key => _key }"
  end

  def del
    table = session[:TABLE]
    _key = session[:_key]
    eval table + ".delete(_key)"
  end

  def update
    table = session[:TABLE]
    key = session[:KEY]
    _key = session[:_key]

    _post = {}
    eval(table + ".columns").map do |c|
      _post[c.name] = params[c.name]
    end

    eval table.capitalize + ".update(_key, _post)"
    @data = eval table.capitalize + ".find :first, :conditions => { key => _key }"
    render '/admin/look'
  end
end
