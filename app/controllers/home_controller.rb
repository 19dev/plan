class HomeController < ApplicationController
  def index
    @head = "ogretim uyesi ders takvimini arama motoru"
  end

  def find
    # kontrollere rails'in genel bir önerisi olmalısı lazım'
    if params[:id].empty?
      @error = "bolum adi bos birakilamaz"
      return render '/home/index'
    end

    if @lecturers = Lecturers.find(:all, :conditions => { :department_id => params[:id] })
      @correct = "Bolum basariyla secildi"
    else
      @error = "Bu bolumde henuz hoca yok"
      return render '/home/index'
    end
  end
end
