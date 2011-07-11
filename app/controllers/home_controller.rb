class HomeController < ApplicationController
   def index
	@head = "ogretim uyesi ders takvimini arama motoru"
	@departments = Departments.all
  end

  def find
	# kontrollere rails'in genel bir önerisi olmalısı lazım'
	if params[:id].empty?
		@error = "bolum adi bos birakilamaz"
		@departments = Departments.all # renderde /home/index'te tekrardan görmüyor
		return render '/home/index'
	end
	if params[:name].empty?
		@error = "hoca adi bos birakilamaz"
		@departments = Departments.all # renderde /home/index'te tekrardan görmüyor
		return render '/home/index'
	end

	@lecturers = Lecturers.find :all, :conditions => { :first_name => params[:name], :department_id => params[:id] }
	@correct = "hoca bulundu"
  end
end
