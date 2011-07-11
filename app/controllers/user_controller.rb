class UserController < ApplicationController
  def login
	@say = "login panel"
  end

  def find
	# kontrollere rails'in genel bir önerisi olmalısı lazım'
	if params[:name].empty?
		@error="ad bos birakilamaz"
		render '/admin/login' # direct olmaması lazım'
	end

	if params[:pass].empty?
		@error="sifre bos birakilamaz"
		render '/admin/login' # direct olmaması lazım
	end

	@users = Users.find :first, :conditions => { :first_name => params[:name], :password => params[:pass] }
	@correct = "giris yapildi" # türkçe karakter sıkıntısı var
  end

end
