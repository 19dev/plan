class HomeController < ApplicationController
  def index
    @head = "ogretim uyesi ders takvimini arama motoru"
  end

  def find
    # kontrollere rails'in genel bir önerisi olmalısı lazım'
    if params[:id].empty?
      @error = "bolum adi bos birakilamaz"
      @departments = Departments.all # renderde /home/index'te tekrardan görmüyor
      return render '/home/index'
    end

    @lecturers = Lecturers.find :all, :conditions => { :department_id => params[:id] }
    @correct = "hoca bulundu"
  end
end
