# encoding: utf-8
module PdfHelper
  def pdf_schema info, header, field1, field2, launch, morning, evening
    pdf = Prawn::Document.new(:page_size => 'A5', :layout => 'portrait') do
      font "#{Prawn::BASEDIR}/data/fonts/Dustismo_Roman.ttf", :size => 8

      move_up(30)
      text "Ondokuz Mayıs Üniversitesi", :size => 12,  :align => :center
      text "Mühendislik Fakültesi Eğitim Öğretim Planları", :size => 8,  :align => :center

      image "#{Rails.root}/app/assets/images/omu-logo.jpg", :width => 45, :height => 45, :position => 0, :vposition => -30
      image "#{Rails.root}/app/assets/images/mf-128x128.png", :width => 45, :height => 45, :position => 300, :vposition => -30

      move_up(90)
      table info,
        :position => 93,
        :column_widths => { 0 => 24, 1 => 137},
        :cell_style => { :size => 3.5, :text_color => "000000", :height => 13, :border_width => 0.1 }

      font "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf", :size => 4
      table header,
        :position => :center,
        :row_colors => ["cccccc"],
        :column_widths => { 0=>24,1=>63.7,2=>63.7,3=>63.7,4=>63.7,5=>63.7,6=>63.7},
        :cell_style => { :size => 3.3, :text_color => "000000", :height => 15, :border_width => 0.1 }
      table [["", field1, field2, field1, field2, field1, field2, field1, field2, field1, field2],],
        :position => :center,
        :row_colors => ["cccccc"],
        :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
        :cell_style => { :size => 3.3, :text_color => "000000", :height => 15, :border_width => 0.1 }
      if morning
        launch_time = nil
        morning.each_with_index do |row, index|
          if row[0].slice(0..1) == launch[0].slice(0..1)
            launch_time = index
            break
          end
        end
        table morning.slice(0..launch_time-1),
          :position => :center,
          :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
          :cell_style => { :size => 3, :text_color => "000000", :height => 25, :border_width => 0.1, :padding => 1 }

        table [launch],
          :position => :center,
          :row_colors => ["cccccc"],
          :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
          :cell_style => { :size => 3, :text_color => "000000", :height => 15, :border_width => 0.1, :padding => 1 }

        table morning.slice(launch_time+1..-1),
          :position => :center,
          :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
          :cell_style => { :size => 3, :text_color => "000000", :height => 25, :border_width => 0.1, :padding => 1 }
      end
      if evening
        table evening,
          :position => :center,
          :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
          :cell_style => { :size => 3, :text_color => "000000", :height => 25, :border_width => 0.1, :padding => 1 }
      end
    end
    pdf
  end
  def lecturerpdf_schema photo, info, header, field1, field2, launch, morning, evening
    pdf = Prawn::Document.new(:page_size => 'A4', :layout => 'portrait') do
      font "#{Prawn::BASEDIR}/data/fonts/Dustismo_Roman.ttf", :size => 8

      move_up(30)
      text "Ondokuz Mayıs Üniversitesi", :size => 16,  :align => :center
      text "Mühendislik Fakültesi Eğitim Öğretim Planları", :size => 12, :align => :center

      image "#{Rails.root}/app/assets/images/omu-logo.jpg", :width => 64, :height => 64, :position => 0, :vposition => -30
      image "#{Rails.root}/app/assets/images/mf-128x128.png", :width => 64, :height => 64, :position => 460, :vposition => -30

      move_up(125)
      table info,
        :position => 195,
        :column_widths => { 0 => 40,1 => 149},
        :cell_style => { :size => 6, :text_color => "000000", :height => 18, :border_width => 0.3 }
      if photo
        image "#{Rails.root}/public#{photo}", :width => 55, :height => 55, :position => 139, :vposition => 0
        move_up(54)
      end

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
        launch_time = nil
        morning.each_with_index do |row, index|
          if row[0].slice(0..1) == launch[0].slice(0..1)
            launch_time = index
            break
          end
        end
        table morning.slice(0..launch_time-1),
          :position => :center,
          :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
          :cell_style => { :size => 5, :text_color => "000000", :height => 30, :border_width => 0.3, :padding => 1 }

        table [launch],
          :position => :center,
          :row_colors => ["cccccc"],
          :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
          :cell_style => { :size => 5, :text_color => "000000", :height => 18, :border_width => 0.3 }

        table morning.slice(launch_time+1..-1),
          :position => :center,
          :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
          :cell_style => { :size => 5, :text_color => "000000", :height => 30, :border_width => 0.3, :padding => 1 }
      end
      if evening
        table evening,
          :position => :center,
          :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
          :cell_style => { :size => 5, :text_color => "000000", :height => 30, :border_width => 0.3, :padding => 1 }
      end
    end
    pdf
  end
  def departmentpdf_schema info, header, field1, field2, launch, morning, evening
    morning1, morning2, morning3, morning4 = morning
    evening1, evening2, evening3, evening4 = evening

    pdf = Prawn::Document.new(:page_size => 'A4', :layout => 'portrait') do
      font "#{Prawn::BASEDIR}/data/fonts/Dustismo_Roman.ttf", :size => 8

      move_up(30)
      text "Ondokuz Mayıs Üniversitesi", :size => 16,  :align => :center
      text "Mühendislik Fakültesi Eğitim Öğretim Planları", :size => 12,  :align => :center

      image "#{Rails.root}/app/assets/images/omu-logo.jpg", :width => 64, :height => 64, :position => 0, :vposition => -30
      image "#{Rails.root}/app/assets/images/mf-128x128.png", :width => 64, :height => 64, :position => 460, :vposition => -30

      move_up(125)
      table info,
        :position => 139,
        :column_widths => { 0 => 43.2, 1 => 202},
        :cell_style => { :size => 6, :text_color => "000000", :height => 18, :border_width => 0.3 }

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
          launch_time = nil
          eval("morning#{year}").each_with_index do |row, index|
            if row[0].slice(0..1) == launch[0].slice(0..1)
              launch_time = index
              break
            end
          end
          table eval("morning#{year}").slice(0..launch_time-1),
            :position => :center,
            :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
            :cell_style => { :size => 5, :text_color => "000000", :height => 35, :border_width => 0.3, :padding => 1 }

          table [launch],
            :position => :center,
            :row_colors => ["cccccc"],
            :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
            :cell_style => { :size => 5, :text_color => "000000", :height => 18, :border_width => 0.3 }

          table eval("morning#{year}").slice(launch_time+1..-1),
            :position => :center,
            :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
            :cell_style => { :size => 5, :text_color => "000000", :height => 35, :border_width => 0.3, :padding => 1 }
        end

        if eval("evening#{year}")
          table eval("evening#{year}"),
            :position => :center,
            :column_widths => { 0=>43.2,1=>73.3,2=>22.7,3=>73.3,4=>22.7,5=>73.3,6=>22.7,7=>73.3,8=>22.7,9=>73.3,10=>22.7},
            :cell_style => { :size => 5, :text_color => "000000", :height => 35, :border_width => 0.3, :padding => 1 }
        end
        if eval("morning#{year}") and eval("evening#{year}")
          move_down(260)
        elsif eval("morning#{year}")
          move_down(10)
        elsif eval("evening#{year}")
          move_down(130)
        end
      end
    end
    pdf
  end
end
