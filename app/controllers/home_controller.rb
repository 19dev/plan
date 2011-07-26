class HomeController < ApplicationController
  def index
    session[:error], session[:notice] = nil, nil
  end

  def find
  end

  def review
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

  def auto
    lecturers = Lecturers.all
    @fields = []
    lecturers.each do |lecturer|
      @fields <<
        {
          lecturer.id => ["#{lecturer.first_name} #{lecturer.last_name}", lecturer.photo]
        }
    end
    @a = @fields
  end

  def program
    lecturer_id = params[:id]
  end
end
