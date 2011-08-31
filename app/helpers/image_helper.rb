# encoding: utf-8
module ImageHelper
  class Image
    @dir = 'upload'
    @uploaddir = Rails.root.join 'public', @dir # <ana_dizin>
    @extension = '.jpg'

    # sesli hatalı çıkış için : [false,"bla bla"]
    # sesli başarılı çıkış için : [true, "bla bla"]
    # sessiz hatalı çıkış için : nil
    def self.upload directory, savename, uploaded, overwrite = false
      savename += @extension
      destination = @uploaddir.join directory # hedef dizin
      image = destination.join savename  # resmin tam yolu

      # <ana_dizin> yoksa oluşturalım
      unless File.exist? @uploaddir
        FileUtils.mkdir_p @uploaddir, :mode => 0777
        FileUtils.chmod_R 0777, @uploaddir
      end

      # hedef yoksa oluşturalım
      unless File.exist? destination
        FileUtils.mkdir_p destination, :mode => 0777
        FileUtils.chmod_R 0777, destination
      end

      # yüklenen dosya yok ise sessiz çık
      return nil unless File.exist? uploaded.path

      if uploaded.size > 550000;                 return [false, "Resim çok büyük"]
      elsif !(uploaded.content_type =~ /jpe?g/); return [false, "Resim jpg formatında olmalıdır"]
      elsif File.exist?(image) && !(overwrite);  return [false, "Resim zaten var"]
      elsif !FileUtils.mv(uploaded.path, image); return [false, "Dosya yükleme hatası"]
      else
        FileUtils.chmod 0777, image
        return [true, "/#{@dir}/#{directory}/#{savename}"] # resim yükleme başarısı
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
