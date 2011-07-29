class HomeController < ApplicationController
  def index
    session[:error], session[:notice] = nil, nil
  end

  def find
    session[:error], session[:notice] = nil, nil
  end

  def review
    session[:error], session[:notice] = nil, nil
    unless params[:department_id]
      session[:error] = "Bolum adi bos birakilamaz"
      return redirect_to '/home/find'
    end

    @lecturers = Lecturer.find(:all, :conditions => { :department_id => params[:department_id] })
    if @lecturers.empty?
      session[:error] = "Bu bolumde henuz hoca yok"
      return render '/home/find'
    end
  end

  def auto
    @lecturers = []
    Lecturer.all.each do |lecturer|
      @lecturers <<
        {
          lecturer.id => ["#{lecturer.first_name} #{lecturer.last_name}", lecturer.photo, lecturer.department.name]
        }
    end
  end

  def program

  end

  def show
    session[:error], session[:notice] = nil, nil
    # kontrollere rails'in genel bir önerisi olmalısı lazım'
    unless params[:lecturer_id]
      session[:error] = "Boyle bir hoca yok"
      return render '/home/auto'
    end

    @lecturer = Lecturer.find(:first, :conditions => { :id => params[:lecturer_id] })
  end
end
