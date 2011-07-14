class AdminController < ApplicationController

  def giris
    @title = "Yonetici Paneli"
    session[:TABLES] = {
			"Admins" => 'id',
			"Lecturers" => 'id'
		}
    session[:TABLE_INIT] = "Admins"
    redirect_to '/admin/home' if session[:admin]
  end

  def login
    # kontrollere rails'in genel bir önerisi olması lazım'
    if params[:first_name].empty?
      @error = "ad bos birakilamaz"
      return render '/admin/giris' # direct olmaması lazım'
    end

    if params[:password].empty?
      @error = "sifre bos birakilamaz"
      return render '/admin/giris', # direct olmaması lazım
    end

    @admins = Admins.find :first, :conditions => { :first_name => params[:first_name], :password => params[:password] }

    session[:admin] = true
    session[:adminusername] = @admins.first_name
    session[:adminpassword] = @admins.password
    session[:adminsuper] = @admins.status

    table # ilk tablo seçilsin
  end

  def logout
    if session[:admin]
      session[:admin] = nil
      session[:adminusername] = nil
      session[:adminpassword] = nil
      session[:adminsuper] = nil
      session[:TABLE_INIT] = nil
      session[:TABLES] = nil
      session[:TABLE] = nil
      session[:KEY] = nil
    end
    redirect_to '/admin/giris'
  end

  def home
    @title="Yonetici Paneli"
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
    session[:KEY]  = session[:TABLES][table]

    render '/admin/home'
  end

  def find
    table = session[:TABLE]
    key = session[:KEY]
    _key = params[:_key]

    session[:_key] = _key # uniq veriyi oturuma gömelim
    @data = eval table.capitalize + ".find :first, :conditions => { key => _key }"
    render '/admin/ok'
  end

  def ok
    @title = "Inceleme Sonuclari"
  end

  def review
    @data = eval session[:TABLE].capitalize + ".all"
  end

  def edit
    table = session[:TABLE]
    key = session[:KEY]
    _key = session[:_key]

    @data = eval table.capitalize + ".find :first, :conditions => { key => _key }"
    render '/admin/edit'
  end

  def del

  end

  def update
    table = session[:TABLE]
    key = session[:KEY]
    _key = session[:_key]

    @data = eval table.capitalize + ".find :first, :conditions => { key => _key }"
    @data.update_attributes(params[:first_name])
  end
end
