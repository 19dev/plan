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
        :cell_style => { :size => 3.3, :text_color => "000000", :height => 8, :border_width => 0.1, :padding => 2 }
      table [["", field1, field2, field1, field2, field1, field2, field1, field2, field1, field2],],
        :position => :center,
        :row_colors => ["cccccc"],
        :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
        :cell_style => { :size => 3, :text_color => "000000", :height => 8, :border_width => 0.1, :padding => 2 }
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
          :cell_style => { :size => 3, :text_color => "000000", :height => 28, :border_width => 0.1, :padding => 1 }

        table [launch],
          :position => :center,
          :row_colors => ["cccccc"],
          :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
          :cell_style => { :size => 3, :text_color => "000000", :height => 6, :border_width => 0.1, :padding => 1 }

        table morning.slice(launch_time+1..-1),
          :position => :center,
          :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
          :cell_style => { :size => 3, :text_color => "000000", :height => 28, :border_width => 0.1, :padding => 1 }
      end
      if evening
        table evening,
          :position => :center,
          :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
          :cell_style => { :size => 3, :text_color => "000000", :height => 28, :border_width => 0.1, :padding => 1 }
      end
    end
    pdf
  end
  def lecturerpdf_schema photo, info, header, field1, field2, launch, morning, evening
    pdf = Prawn::Document.new(:page_size => 'A5', :layout => 'portrait') do
      font "#{Prawn::BASEDIR}/data/fonts/Dustismo_Roman.ttf", :size => 8

      move_up(30)
      text "Ondokuz Mayıs Üniversitesi", :size => 12,  :align => :center
      text "Mühendislik Fakültesi Eğitim Öğretim Planları", :size => 8,  :align => :center

      image "#{Rails.root}/app/assets/images/omu-logo.jpg", :width => 45, :height => 45, :position => 0, :vposition => -30
      image "#{Rails.root}/app/assets/images/mf-128x128.png", :width => 45, :height => 45, :position => 300, :vposition => -30

      move_up(90)
      table info,
        :position => 133,
        :column_widths => { 0 => 24, 1 => 98},
        :cell_style => { :size => 3.5, :text_color => "000000", :height => 13, :border_width => 0.1 }
      if photo
        image "#{Rails.root}/public#{photo}", :width => 39, :height => 39, :position => 93, :vposition => -10
        move_up(38)
      end

      font "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf", :size => 8
      table header,
        :position => :center,
        :row_colors => ["cccccc"],
        :column_widths => { 0=>24,1=>63.7,2=>63.7,3=>63.7,4=>63.7,5=>63.7,6=>63.7},
        :cell_style => { :size => 3.3, :text_color => "000000", :height => 8, :border_width => 0.1, :padding => 2 }
      table [["", field1, field2, field1, field2, field1, field2, field1, field2, field1, field2],],
        :position => :center,
        :row_colors => ["cccccc"],
        :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
        :cell_style => { :size => 3, :text_color => "000000", :height => 8, :border_width => 0.1, :padding => 2 }
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
          :cell_style => { :size => 3, :text_color => "000000", :height => 6, :border_width => 0.1, :padding => 1 }

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
  def departmentpdf_schema info, header, field1, field2, launch, morning, evening
    morning1, morning2, morning3, morning4 = morning
    evening1, evening2, evening3, evening4 = evening

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

      font "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf", :size => 8
      (1..4).each do |year|
        table [["#{year}.Sınıf"]],
          :position => :center,
          :row_colors => ["cccccc"],
          :column_widths => { 0 => 342.5,},
          :cell_style => { :size => 3.3, :text_color => "000000", :height => 8, :border_width => 0.1, :padding => 2 }
        table header,
          :position => :center,
          :row_colors => ["cccccc"],
          :column_widths => { 0=>24,1=>63.7,2=>63.7,3=>63.7,4=>63.7,5=>63.7,6=>63.7},
          :cell_style => { :size => 3.3, :text_color => "000000", :height => 8, :border_width => 0.1, :padding => 2 }
        table [["", field1, field2, field1, field2, field1, field2, field1, field2, field1, field2],],
          :position => :center,
          :row_colors => ["cccccc"],
          :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
          :cell_style => { :size => 3, :text_color => "000000", :height => 8, :border_width => 0.1, :padding => 2 }
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
            :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
            :cell_style => { :size => 3, :text_color => "000000", :height => 28, :border_width => 0.1, :padding => 1 }

          table [launch],
            :position => :center,
            :row_colors => ["cccccc"],
            :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
            :cell_style => { :size => 3, :text_color => "000000", :height => 6, :border_width => 0.1, :padding => 1 }

          table eval("morning#{year}").slice(launch_time+1..-1),
            :position => :center,
            :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
            :cell_style => { :size => 3, :text_color => "000000", :height => 28, :border_width => 0.1, :padding => 1 }
        end

        if eval("evening#{year}")
          table eval("evening#{year}"),
            :position => :center,
            :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
            :cell_style => { :size => 3, :text_color => "000000", :height => 28, :border_width => 0.1, :padding => 1 }
        end
        if eval("morning#{year}") and eval("evening#{year}")
          move_down(260)
        elsif eval("morning#{year}")
          move_down(265)
        elsif eval("evening#{year}")
          move_down(330)
        end
      end
    end
    pdf
  end
end
