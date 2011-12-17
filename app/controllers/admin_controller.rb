# encoding: utf-8
class AdminController < ApplicationController
  include InitHelper
  include ImageHelper
  include CleanHelper # temizlik birimi
  before_filter :require_login, :except => [:login, :logout] # loginsiz asla!
  before_filter :clean_notice, :except => [:home, :show, :update, :review] # temiz sayfa
  before_filter :clean_error, :except => [:login, :find, :show] # temiz sayfa

  def login
    redirect_to '/admin/home' if session[:admin]

    if admin = People.find(:first, :conditions => {
                                                  :first_name => params[:first_name],
                                                  :password => params[:password],
                                                  :status => 0,
                                                  :department_id => 0,
                                                  }
      )
      session[:admin] = true
      session[:admindepartment] = admin.department_id
      session[:adminusername] = admin.first_name
      session[:adminpassword] = admin.password
      session[:TABLES] = {
                          "People" => 'id',
                          "Lecturer" => 'id',
                          "Classroom" => 'id',
                          "Assignment" => 'id',
                          "Classplan" => 'id',
                          "Course" => 'id',
                          "Department" => 'id',
                          "Period" => 'id',
                          "Notice" => 'id',
                          "Faculty" => 'id',
                          }
      session[:TABLE_INIT] = "People"
      session[:FIELDS] = {
                          '_id' => true,
                          'id' => true,
                          'name' => true,
                          'photo' => false,
                          'content' => false,
                          'code' => false,
      }
      unless session[:period_id] = Period.find( :first, :conditions => { :status => true })
        session[:error] = "Dikkat! aktif bir güz/bahar yılı yok. Bu problemin düzeltilmesi için asıl yönetici ile irtibata geçin"
      end

      return table # ilk tablo seçilsin, oyun başlasın!
    end
      if params[:first_name] or params[:password]
        session[:error] = "Oops! İsminiz veya şifreniz hatali, belkide bunlardan sadece biri hatalıdır?"
      end
  end

  def logout
    reset_session if session[:admin]
    redirect_to '/admin/'
  end

  def require_login
    unless session[:admin]
      session[:error] = "Lütfen hesabınıza girişi yapın!"
      redirect_to '/admin/'
    end
  end

  def table
    table = if params[:table]; params[:table] else session[:TABLE_INIT] end
    session[:success] = "#{table} tablosu başarıyla seçildi"
    session[:TABLE] = table
    session[:SAVE] = eval table.capitalize + ".count"
    session[:KEY] = session[:TABLES][table]

    redirect_to '/admin/home'
  end

  def new
    session[:_key] = nil
  end

  def add
    photo = params[:file] if params[:file]
    columns = table_columns
    params.select! { |k, v| columns.include?(k) }

    data = eval session[:TABLE].capitalize + ".new(params)"
    data.save
    session[:_key] = data[session[:KEY]]
    session[:SAVE] += 1

    # bir resim isteğimiz var mı ?
    if photo and response = Image.upload(session[:TABLE], session[:_key].to_s, photo, false) # üzerine yazma olmasın
      if response[0] # bu yanıt iyi mi kötü mü
        data[:photo] = response[1]
        data.save
      else
        session[:error] = response[1]
      end
    else
      data[:photo] = "/images/default.png"
      data.save
    end
    session[:success] = "#{session[:_key]} bilgisine sahip kişi #{session[:TABLE]} tablosuna başarıyla eklendi"

    redirect_to '/admin/show'# göster
  end

  def find
    session[:_key] = nil
  end

  def show # post ise oturma göm + verileri göster
    session[:_key] = params[:_key] if params[:_key] # uniq veriyi oturuma gömelim
    unless @data = eval(session[:TABLE].capitalize + ".find :first, :conditions => { session[:KEY] => session[:_key] }")
      session[:error] = "Böyle bir kayıt bulunmamaktadır"
      redirect_to '/admin/find'
    end
  end

  def review
    @data = eval session[:TABLE].capitalize + ".all"
  end

  def edit
    session[:_key] = params[:_key] if params[:_key] # post ise uniq veriyi oturuma gömelim
    @data = eval session[:TABLE].capitalize + ".find :first, :conditions => { session[:KEY] => session[:_key] }"
  end

  def del
    session[:_key] = params[:_key] if params[:_key] # post ise uniq veriyi oturuma gömelim
    eval session[:TABLE] + ".delete(session[:_key])"

    Image.delete session[:TABLE], "#{session[:_key]}.jpg"
    session[:SAVE] -= 1
    session[:success] = "#{session[:_key]} bilgisine sahip kişi #{session[:TABLE]} tablosundan başarıyla silindi"
    session[:_key] = nil # kişinin oturumunu öldürelim

    redirect_to '/admin/review'
  end

  def update
    photo = params[:file] if params[:file]
    columns = table_columns
    params.select! { |k, v| columns.include?(k) }

    eval session[:TABLE].capitalize + ".update(session[:_key], params)"
    data = eval session[:TABLE].capitalize + ".find :first, :conditions => { session[:KEY] => session[:_key] }"

    # bir resim isteğimiz var mı ?
    if photo and response = Image.upload(session[:TABLE], session[:_key].to_s, photo, true) # üzerine yazma olsun
      if response[0] # bu yanıt iyi mi kötü mü
        data[:photo] = response[1]
        data.save
      else
        session[:error] = response[1]
      end
    end
    session[:success] = "#{session[:_key]} bilgisine sahip kişi #{session[:TABLE]} tablosunda başariyla güncellendi"

    redirect_to '/admin/show'# göster
  end
  private
  def table_columns # tablo sütun isimleri
    return eval(session[:TABLE] + ".columns").collect {|c| c.name}
  end
end

