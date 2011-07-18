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
    @title = "Yonetici Paneli"
    redirect_to '/admin/home' if session[:admin]
  end

  def login
    if admin = Admins.find(:first, :conditions => { :first_name => params[:first_name], :password => params[:password] })
      session[:admin] = true
      session[:adminusername] = admin.first_name
      session[:adminpassword] = admin.password
      session[:adminsuper] = true if admin.status == 1

      table # ilk tablo seçilsin, oyun başlasın!
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
    table = if params[:table]; params[:table] else session[:TABLE_INIT] end
    @correct = "#{table} tablosu basariyla secildi"
    session[:TABLE] = table
    session[:SAVE] = eval table.capitalize + ".count"
    session[:KEY] = session[:TABLES][table]

    @title = "Yonetici Panelix"
    render '/admin/home'
  end

  def new
    session[:_key] = nil
  end

  def add
    table = session[:TABLE]

    _post = {}
    eval(table + ".columns").map { |c| _post[c.name] = params[c.name] }

    data = eval table.capitalize + ".new(_post)"
    data.save
    session[:_key] = data[session[:KEY]]
    session[:SAVE] += 1

    show # göster
  end

  def show # post ise oturma göm + verileri göster
    session[:_key] = params[:_key] if params[:_key] # uniq veriyi oturuma gömelim
    @data = eval session[:TABLE].capitalize + ".find :first, :conditions => { session[:KEY] => session[:_key] }"
    render '/admin/show'
  end

  def review
    @data = eval session[:TABLE].capitalize + ".all"
  end

  def edit
    @data = eval session[:TABLE].capitalize + ".find :first, :conditions => { session[:KEY] => session[:_key] }"
  end

  def del
    table = session[:TABLE]
    _key = session[:_key]

    eval table + ".delete(_key)"
    session[:SAVE] -= 1
    session[:_key] = nil # kişinin oturumunu öldürelim
    @data = eval table.capitalize + ".find :first, :conditions => { session[:KEY] => _key }"
    render '/admin/find'
  end

  def update
    table = session[:TABLE]

    _post = {}
    eval(table + ".columns").map { |c| _post[c.name] = params[c.name] }
    eval table.capitalize + ".update(session[:_key], _post)"

    show # göster
  end

end
