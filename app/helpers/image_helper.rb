# encoding: utf-8
module ImageHelper
  class Image

    @uploaddir = Rails.root.join 'public', 'images' # <ana> yükleme dizini

    # hata var ise oturuma göm; çıkmak isterse nil, doğru ise true dön
    def self.upload directory, savename, uploaded, overwrite = false
      destination = @uploaddir.join directory # hedef dizin
      image = destination.join savename # resmin tam yolu

      # hedef yoksa oluşturalım
      FileUtils.mkdir(destination) unless File.exist? destination

      # yüklenen dosya yok ise sessiz çık
      return nil unless File.exist? uploaded.path

      if uploaded.size > 550000;                          session[:error] = "Resim çok büyük"
      elsif !(uploaded.content_type =~ /jpe?g/);          session[:error] = "Resim jpg formatında olmalıdır"
      elsif File.exist?("#{image}.jpg") && !(overwrite);  session[:error] = "Resim zaten var"
      elsif !FileUtils.mv(uploaded.path, "#{image}.jpg"); session[:error] = "Dosya yükleme hatası"
      else return true end # resim yükleme başarısı

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
