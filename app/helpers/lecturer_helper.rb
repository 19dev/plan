# encoding: utf-8
module LecturerHelper
  include ImageHelper
# Lecturer --------------------------------------------------------------------
  def lectureradd
    photo = params[:file]
    params.select! { |k, v| Lecturer.columns.collect {|c| c.name}.include?(k) }
    if hata = control({
                      params[:first_name]=>"Öğretim elamanı adı",
                      params[:last_name]=>"Öğretim elamanı soyadı",
                      params[:email]=>"Öğretim elamanı email"
                      }
    )
      session[:error] = hata
      return redirect_to '/user/lecturernew'
    end

    params[:first_name] = UnicodeUtils.titlecase(params[:first_name], :tr)
    params[:last_name] = UnicodeUtils.titlecase(params[:last_name], :tr)

    # params[:department_id] = session[:department_id] # doğrusu böyle olmalı
    params[:department_id] = params[:department_id] # şimdilik diğer bölümlere ekleyecek şekilde yapıyoruz.

    lecturer = Lecturer.new params
    lecturer.save
    session[:lecturer_id] = lecturer.id

    if photo and response = Image.upload('Lecturer', "#{session[:lecturer_id]}", photo, false) # üzerine yazma olmasın
      if response[0] # bu yanıt iyi mi kötü mü
        lecturer[:photo] = response[1]
        lecturer.save
      else
        session[:error] = response[1]
      end
    else
      lecturer[:photo] = "/images/default.png"
      lecturer.save
    end
    session[:success] = "#{lecturer.full_name} isimli kişi öğretim elamanı olarak eklendi"
    redirect_to '/user/lecturershow'
  end
  def lecturershow
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    unless @lecturer = Lecturer.find(session[:lecturer_id])
      session[:error] = "Böyle bir kayıt bulunmamaktadır"
      redirect_to '/user/lecturerreview'
    end
  end
  def lecturerreview
    @lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] })
  end
  def lectureredit
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    @lecturer = Lecturer.find session[:lecturer_id]
  end
  def lecturerdel
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim

    assignments = Assignment.find(:all,
                                  :conditions => {
                                     :lecturer_id => session[:lecturer_id],
                                   })
    if assignments != []
      session[:error] = "Bu öğretim elamanının ders ataması vardır, bu yüzden silemezsiniz. " +
                        "Eğer silmek istiyorsanız, ders atamalarını siliniz. Bu da tam çözüm vermez " +
                        "ise; yönetici ile irtibata geçiniz "
      return redirect_to '/user/lecturerreview'
    end
    Lecturer.delete session[:lecturer_id]
    # # bu hocaya ait tüm dönemlik bilgileri silelim
    # assignments = Assignment.find(:all,
    #                               :conditions => {
    #                                 :lecturer_id => session[:lecturer_id],
    #                               })
    # assignments.each do |assignment|
    #   Classplan.delete_all({
    #                         :assignment_id => assignment.id,
    #                       })
    # end
    # Assignment.delete_all({
    #                         :lecturer_id => session[:lecturer_id],
    #                       })
    Image.delete 'Lecturer', "#{session[:lecturer_id]}.jpg"
    session[:success] = "Öğretim elamanı başarıyla silindi"
    session[:lecturer_id] = nil # kişinin oturumunu öldürelim

    redirect_to '/user/lecturerreview'
  end
  def lecturerupdate
    photo = params[:file] if params[:file]
    params.select! { |k, v| Lecturer.columns.collect {|c| c.name}.include?(k) }

    if hata = control({
                      params[:first_name]=>"Öğretim elamanı adı",
                      params[:last_name]=>"Öğretim elamanı soyadı",
                      params[:email]=>"Öğretim elamanı email"
                      }
    )
      session[:error] = hata
      return redirect_to '/user/lecturershow'
    end

    params[:first_name] = UnicodeUtils.titlecase(params[:first_name], :tr)
    params[:last_name] = UnicodeUtils.titlecase(params[:last_name], :tr)

    Lecturer.update(session[:lecturer_id], params)
    lecturer = Lecturer.find session[:lecturer_id]
    if photo and response = Image.upload('Lecturer', "#{session[:lecturer_id]}", photo, true) # üzerine yazma olsun
      if response[0] # bu yanıt iyi mi kötü mü
        lecturer[:photo] = response[1]
        lecturer.save
      else
        session[:error] = response[1]
      end
    end
    session[:success] = "#{Lecturer.find(session[:lecturer_id]).full_name} isimli öğretim elamanı başarıyla güncellendi"
    redirect_to '/user/lecturershow'
   end
# end Lecturer -------------------------------------------------------
end
