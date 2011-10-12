# encoding: utf-8
module AccountHelper
  def accountedit
    unless @people = People.find(session[:user_id])
      session[:error] = "Kaydınız bulunmamaktadır"
      return redirect_to '/user/logout'
    end
  end
  def accountupdate
    params.select! { |k, v| People.columns.collect {|c| c.name}.include?(k) }
    People.update(session[:user_id], params)
    return redirect_to '/user/accountshow'
  end
  def accountshow
    unless @people = People.find(session[:user_id])
      session[:error] = "Kaydınız bulunmamaktadır"
      return redirect_to '/user/logout'
    end
  end
end
