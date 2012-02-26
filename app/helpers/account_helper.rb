# encoding: utf-8
module AccountHelper
  include ImageHelper
  def accountedit
    unless @people = People.find(session[:user_id])
      session[:error] = "Kaydınız bulunmamaktadır"
      return redirect_to '/user/logout'
    end
  end
  def accountpassword
    @people = People.find(session[:user_id])
  end
  def accountupdate
    if params[:password]
      if session[:error] = control({
        (params[:last_password] or params[:new_password] or params[:new_password_repeat]) => "Parola Alanları",
      })
        return redirect_to '/user/accountshow'
      end
      unless params[:last_password] == People.find(session[:user_id]).password
        session[:error] = "Eski Parolayı Yanlış Girdiniz!"
        return redirect_to '/user/accountshow'
      end
      unless params[:new_password] == params[:new_password_repeat]
        session[:error] = "Yeni Parola ve Yeni Parola(Tekrar) Uyuşmuyor!"
        return redirect_to '/user/accountshow'
      end
      params[:password] = params[:new_password]
    end
    photo = params[:file] if params[:file]
    params.select! { |k, v| People.columns.collect {|c| c.name}.include?(k) }

    People.update(session[:user_id], params)
    people = People.find session[:user_id]
    if photo and response = Image.upload('People', "#{session[:user_id]}", photo, true) # üzerine yazma olsun
      if response[0] # bu yanıt iyi mi kötü mü
        people[:photo] = response[1]
        people.save
      else
        session[:error] = response[1]
      end
    end
    session[:success] = "#{people.first_name} kişisel bilgileriniz başarıyla güncellendi"
    return redirect_to '/user/accountshow'
  end
  def accountshow
    unless @people = People.find(session[:user_id])
      session[:error] = "Kaydınız bulunmamaktadır"
      return redirect_to '/user/logout'
    end
  end
end
