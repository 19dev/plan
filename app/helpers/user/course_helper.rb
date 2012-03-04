# encoding: utf-8
module User
  module CourseHelper
    def courseadd
      params.select! { |k, v| Course.columns.collect {|c| c.name}.include?(k) }
      if flash[:error] = control({
        params[:year] => "Ders yılı",
        params[:code] => "Ders kodu",
        params[:name] => "Ders adı",
        params[:theoretical] => "Ders teroik saati",
        params[:practice] => "Ders pratik saati",
        params[:lab] => "Ders lab saati",
        params[:credit] => "Ders kredisi",
      })
      return redirect_to '/user/coursenew'
      end
      params[:department_id] = session[:department_id]

      params[:code] = UnicodeUtils.upcase(params[:code])      # i => I (ör : BIL yazılıyor genelde)
      params[:name] = UnicodeUtils.upcase(params[:name], :tr) # i => İ (ör : BİLGİSAYAR GİRİŞ - I)

      course = Course.new params
      course.save
      session[:course_id] = course.id

      flash[:success] = "#{course.full_name} dersi başarıyla eklendi"
      redirect_to '/user/courseshow'
    end
    def courseshow
      session[:course_id] = params[:course_id] if params[:course_id] # uniq veriyi oturuma gömelim
      unless @course = Course.find(session[:course_id])
        flash[:error] = "Böyle bir kayıt bulunmamaktadır"
        redirect_to '/user/coursereview'
      end
    end
    def courseedit
      session[:course_id] = params[:course_id] if params[:course_id] # uniq veriyi oturuma gömelim
      @course = Course.find session[:course_id]
    end
    def coursedel
      session[:course_id] = params[:course_id] if params[:course_id] # uniq veriyi oturuma gömelim

      if Assignment.find_all_by_course_id(session[:course_id]) != []
        flash[:error] = "Bu ders, ders atamalarında kullanılıyor, bu yüzden silemezsiniz. " +
          "Eğer silmek istiyorsanız, ders atamalarını siliniz. Bu da tam çözüm vermez " +
          "ise; yönetici ile irtibata geçiniz "
      else
        flash[:success] = "#{Course.find(session[:course_id]).full_name} dersi başarıyla silindi"
        Course.delete session[:course_id]
        session[:course_id] = nil # dersin oturumunu öldürelim
      end
      redirect_to '/user/coursereview'
    end
    def courseupdate
      params.select! { |k, v| Course.columns.collect {|c| c.name}.include?(k) }

      if flash[:error] = control({
        params[:year] => "Ders yılı",
        params[:code] => "Ders kodu",
        params[:name] => "Ders adı",
        params[:theoretical] => "Ders teroik saati",
        params[:practice] => "Ders pratik saati",
        params[:lab] => "Ders lab saati",
        params[:credit] => "Ders kredisi",
      })
      return redirect_to '/user/courseshow'
      end

      params[:code] = UnicodeUtils.upcase(params[:code])      # i => I (ör : BIL yazılıyor genelde)
      params[:name] = UnicodeUtils.upcase(params[:name], :tr) # i => İ (ör : BİLGİSAYAR GİRİŞ - I)

      Course.update(session[:course_id], params)
      flash[:success] = "#{Course.find(session[:course_id]).full_name} dersi başarıyla güncellendi"

      redirect_to '/user/courseshow'
    end
  end
end
