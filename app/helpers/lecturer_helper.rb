# encoding: utf-8
module LecturerHelper
  include ImageHelper
# Lecturer --------------------------------------------------------------------
  def lectureradd
    session[:error] = nil

    photo = params[:file]
    params.select! { |k, v| Lecturer.columns.collect {|c| c.name}.include?(k) }
    params[:department_id] = session[:department_id]
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
    session[:notice] = "#{lecturer.first_name} #{lecturer.last_name} kisi öğretim görevlisi olarak eklendi"
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
    session[:error] = nil
    @lecturers = Lecturer.find(:all, :conditions => { :department_id => session[:department_id] })
  end
  def lectureredit
    session[:error], session[:notice] = nil, nil
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    @lecturer = Lecturer.find session[:lecturer_id]
  end
  def lecturerdel
    session[:lecturer_id] = params[:lecturer_id] if params[:lecturer_id] # uniq veriyi oturuma gömelim
    Lecturer.delete session[:lecturer_id]
    # bu hocaya ait tüm dersleri silelim
    Assignment.delete_all ({
                  :lecturer_id => session[:lecturer_id],
                  :period_id => session[:period_id]
                })
    Image.delete 'Lecturer', "#{session[:lecturer_id]}.jpg"
    session[:notice] = "Öğretim görevlisi başarıyla silindi"
    session[:lecturer_id] = nil # kişinin oturumunu öldürelim

    redirect_to '/user/lecturerreview'
  end
  def lecturerupdate
    session[:error], session[:notice] = nil, nil

    photo = params[:file] if params[:file]
    params.select! { |k, v| Lecturer.columns.collect {|c| c.name}.include?(k) }

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
    session[:notice] = "#{session[:lecturer_id]} bilgisine sahip kişi başarıyla güncellendi"
    redirect_to '/user/lecturershow'
   end
# end Lecturer -------------------------------------------------------
end
