class AdminController < ApplicationController

  def login
	@title = "Yonetici Paneli"
	session[:TABLES] = {
				'admins' => 'first_name'
			}
	session[:TABLE_INIT] = 'admins'
	redirect_to '/admin/home' if session[:admin]
  end

  def find
	# kontrollere rails'in genel bir önerisi olması lazım'
	if params[:first_name].empty?
		@error = "ad bos birakilamaz"
		return render '/admin/login' # direct olmaması lazım'
	end

	if params[:password].empty?
		@error = "sifre bos birakilamaz"
		return render '/admin/login', # direct olmaması lazım
	end

	table # ilk tablo seçilsin

	@admins = Admins.find :first, :conditions => { :first_name => params[:first_name], :password => params[:password] }
	@correct = "giris yapildi" # türkçe karakter sıkıntısı var
	session[:admin] = true
	session[:adminusername] = @admins.first_name
	session[:adminpassword] = @admins.password
	session[:adminsuper] = @admins.status
	redirect_to '/admin/home'
  end

  def home
	@title="Yonetici Paneli"
  end

  def table
	if params[:table]
		@TABLE = params[:table]
	else
		@TABLE = session[:TABLE_INIT]
	end
	@correct = "#{@TABLE} tablosu basariyla secildi"
	session[:SAVE] = @TABLE
	session[:TABLE] = @TABLE
	session[:KEY] = session[:TABLES][@TABLE]

  end

  def logout
	if session[:admin]
		session[:admin] = nil
		session[:adminusername] = nil
		session[:adminpassword] = nil
		session[:adminsuper] = nil
		session[:TABLE] = nil
		session[:TABLE_INIT] = nil
		session[:TABLES] = nil
	end
	redirect_to '/admin/login'
  end
end
