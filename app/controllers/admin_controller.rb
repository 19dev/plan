class AdminController < ApplicationController

  def login
	@title = "Yonetici Paneli"
	session[:TABLES] = {
				"Admins" => 'id',
				"Lecturers" => 'id'
			}
	session[:TABLE_INIT] = "Admins"
	redirect_to '/admin/home' if session[:admin]
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
		session[:KEY] = nil
	end
	redirect_to '/admin/login'
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

	@admins = Admins.find :first, :conditions => { :first_name => params[:first_name], :password => params[:password] }

	session[:admin] = true
	session[:adminusername] = @admins.first_name
	session[:adminpassword] = @admins.password
	session[:adminsuper] = @admins.status

	table # ilk tablo seçilsin
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

	redirect_to '/admin/home'
  end

  def review
	@datas = eval session[:TABLE].capitalize + ".all"
  end
end
