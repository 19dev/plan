# encoding: utf-8
module PdfHelper
  def pdf_schema title, photo, info, header, field1, field2, morning, launch, evening
    pdf = Prawn::Document.new(:page_size => 'A4', :layout => 'portrait') do
      font "#{Prawn::BASEDIR}/data/fonts/Dustismo_Roman.ttf", :size => 8
      # font "#{Dir.pwd}/public/fonts/monaco.ttf", :size => 8
      # text title, :size => 18,  :align => :center
      text "Ondokuz Mayıs Üniversitesi", :size => 16,  :align => :center
      text "Mühendislik Fakültesi Program Arama Sistemi", :size => 12,  :align => :center

      image "#{Dir.pwd}/public/images/omu-logo.jpg", :width => 64, :height => 64, :position => 0, :vposition => 10
      image "#{Dir.pwd}/public/images/mf-128x128.png", :width => 64, :height => 64, :position => 460, :vposition => 10

      move_up(110)
      table info,
        :position => 130,
        :row_colors => ["00a0ff"],
        :column_widths => { 0 => 43.2,1 => 159},
        :cell_style => { :size => 6, :text_color => "000000", :height => 21, :border_width => 0.3 }
      move_down(5)
      if photo
        image "#{Dir.pwd}/public#{photo}", :width => 64, :height => 64, :position => 333, :vposition => 50
        move_up(50)
      end

      # stroke do
      #   rectangle [0,740], 525, 0.025
      # end


      font "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf", :size => 8
      table header,
        :position => :center,
        :row_colors => ["cccccc"],
        :column_widths => { 0 => 43.2,1 => 96,2 => 96,3 => 96,4 => 96,5 => 96 },
        :cell_style => { :size => 6, :text_color => "000000", :height => 18, :border_width => 0.3 }
      table [["", field1, field2, field1, field2, field1, field2, field1, field2, field1, field2],],
        :position => :center,
        :row_colors => ["cccccc"],
        :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
        :cell_style => { :size => 5, :text_color => "000000", :height => 18, :border_width => 0.3 }
      if morning
        table morning,
          :position => :center,
          :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
          :cell_style => { :size => 5, :text_color => "000000", :height => 40, :border_width => 0.3 }
      end
      if launch
        table launch,
          :position => :center,
          :row_colors => ["cccccc"],
          :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
          :cell_style => { :size => 5, :text_color => "000000", :height => 18, :border_width => 0.3 }
      end
      if evening
        table evening,
          :position => :center,
          :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
          :cell_style => { :size => 5, :text_color => "000000", :height => 40, :border_width => 0.3 }
      end
    end
    pdf
  end
  def departmentpdf_schema title, photo, info, header, field1, field2, morning, launch, evening
    morning1, morning2, morning3, morning4 = morning
    launch1, launch2, launch3, launch4 = launch
    evening1, evening2, evening3, evening4 = evening

    pdf = Prawn::Document.new(:page_size => 'A4', :layout => 'portrait') do
      font "#{Prawn::BASEDIR}/data/fonts/Dustismo_Roman.ttf", :size => 8
      # font "#{Dir.pwd}/public/fonts/monaco.ttf", :size => 8
      # text title, :size => 18,  :align => :center
      text "Ondokuz Mayıs Üniversitesi", :size => 16,  :align => :center
      text "Mühendislik Fakültesi Program Arama Sistemi", :size => 12,  :align => :center

      image "#{Dir.pwd}/public/images/omu-logo.jpg", :width => 64, :height => 64, :position => 0, :vposition => 10
      image "#{Dir.pwd}/public/images/mf-128x128.png", :width => 64, :height => 64, :position => 460, :vposition => 10

      move_up(110)
      table info,
        :position => 130,
        :row_colors => ["00a0ff"],
        :column_widths => { 0 => 43.2,1 => 159},
        :cell_style => { :size => 6, :text_color => "000000", :height => 21, :border_width => 0.3 }
      move_down(5)
      if photo
        image "#{Dir.pwd}/public#{photo}", :width => 64, :height => 64, :position => 333, :vposition => 50
        move_up(50)
      end

      # stroke do
      #   rectangle [0,740], 525, 0.025
      # end


      font "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf", :size => 8
      (1..4).each do |year|
        table [["#{year}.Sınıf"]],
          :position => :center,
          :row_colors => ["cccccc"],
          :column_widths => { 0 => 523,},
          :cell_style => { :size => 6, :text_color => "000000", :height => 18, :border_width => 0.3 }
        table header,
          :position => :center,
          :row_colors => ["cccccc"],
          :column_widths => { 0 => 43.2,1 => 96,2 => 96,3 => 96,4 => 96,5 => 96 },
          :cell_style => { :size => 6, :text_color => "000000", :height => 18, :border_width => 0.3 }
        table [["", field1, field2, field1, field2, field1, field2, field1, field2, field1, field2],],
          :position => :center,
          :row_colors => ["cccccc"],
          :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
          :cell_style => { :size => 5, :text_color => "000000", :height => 18, :border_width => 0.3 }
        if eval("morning#{year}")
          table eval("morning#{year}"),
            :position => :center,
            :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
            :cell_style => { :size => 5, :text_color => "000000", :height => 40, :border_width => 0.3 }
        end
        if eval("launch#{year}")
          table eval("launch#{year}"),
            :position => :center,
            :row_colors => ["cccccc"],
            :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
            :cell_style => { :size => 5, :text_color => "000000", :height => 18, :border_width => 0.3 }
        end
        if eval("evening#{year}")
          table eval("evening#{year}"),
            :position => :center,
            :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
            :cell_style => { :size => 5, :text_color => "000000", :height => 40, :border_width => 0.3 }
        end
        if eval("morning#{year}") and eval("evening#{year}")
          move_down(100)
        elsif eval("morning#{year}")
          move_down(7)
        elsif eval("evening#{year}")
          move_down(270)
        end
      end
    end
    pdf
  end
end
