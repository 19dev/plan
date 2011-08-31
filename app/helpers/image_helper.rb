# encoding: utf-8
module ImageHelper
  class Image

    # @uploaddir = Rails.root.join 'public', 'images' # <ana> yükleme dizini
    @uploaddir = Rails.root.join 'public' # <ana> yükleme dizini

    # hata var ise oturuma göm; çıkmak isterse nil, doğru ise resmin ismini dön
    def self.upload directory, savename, uploaded, overwrite = false
      destination = @uploaddir.join directory # hedef dizin
      image = destination.join savename+'.jpg' # resmin tam yolu

      # hedef yoksa oluşturalım
      unless File.exist? destination
        FileUtils.mkdir_p destination, :mode => 0777
        FileUtils.chmod_R 0777, destination
      end

      # yüklenen dosya yok ise sessiz çık
      return nil unless File.exist? uploaded.path

      if uploaded.size > 550000;                 session[:error] = "Resim çok büyük"
      elsif !(uploaded.content_type =~ /jpe?g/); session[:error] = "Resim jpg formatında olmalıdır"
      elsif File.exist?(image) && !(overwrite);  session[:error] = "Resim zaten var"
      elsif !FileUtils.mv(uploaded.path, image); session[:error] = "Dosya yükleme hatası"
      else
        FileUtils.chmod 0777, image
        return directory.join image # resim yükleme başarısı
      end

      return nil
    end

    # resim var ise sil çık
    def self.delete directory, savename
      destination = @uploaddir.join  directory # hedef dizin
      image = destination.join savename # resmin tam yolu
      FileUtils.rm(image) if File.exist? image # resim var ise sil.
    end
  end
end
