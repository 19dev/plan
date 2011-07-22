class HomeController < ApplicationController
  def index
    session[:error], session[:notice] = nil, nil
  end

  def find
    session[:error], session[:notice] = nil, nil
    # kontrollere rails'in genel bir önerisi olmalısı lazım'
    if params[:id].empty?
      @error = "bolum adi bos birakilamaz"
      return render '/home/index'
    end

    @lecturers = Lecturers.find(:all, :conditions => { :department_id => params[:id] })
    if @lecturers.empty?
      session[:error] = "Bu bolumde henuz hoca yok"
      return render '/home/index'
    end
  end
  def program
    lecturer_id = params[:id]
  end
end
