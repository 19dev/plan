# encoding: utf-8
module Plan
  module PdfHelper
    def pdf_schema photo, info, header, field1, field2, meal_time, morning, evening, height
      pdf = Prawn::Document.new(:page_size => 'A4', :layout => 'portrait', :margin => 1) do
          font "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf", :size => 8

          text "Ondokuz Mayıs Üniversitesi", :size => 12, :align => :center
          text "Mühendislik Fakültesi Eğitim Öğretim Planları", :size => 8, :align => :center

          image "#{Rails.root}/app/assets/images/omu-logo.jpg", :width => 45, :height => 45, :position => :left, :vposition => 0
          image "#{Rails.root}/app/assets/images/mf-128x128.png", :width => 45, :height => 45, :position => :right, :vposition => 0

          move_up(90)
          if photo
            table info,
              :position => 254,
              :column_widths => { 0 => 35, 1 => 99 },
              :cell_style => { :size => 5, :text_color => "000000", :height => 16, :border_width => 0.1 }
            image "#{Rails.root}/public#{photo}", :width => 48, :height => 48, :position => 204.5, :vposition => 22
            move_up(48)
          else
            table info,
              :position => :center,
              :column_widths => { 0 => 24, 1 => 159 },
              :cell_style => { :size => 5, :text_color => "000000", :height => 16, :border_width => 0.1 }
          end
          move_down(1)

          column_widths = {
            0 => 29.5,
            1 => 62.5,
            2 => 18,
            3 => 62.5,
            4 => 18,
            5 => 62.5,
            6 => 18,
            7 => 62.5,
            8 => 18,
            9 => 62.5,
            10 => 18,
            11 => 62.5,
            12 => 18,
            13 => 62.5,
            14 => 18
          }

          header_column_widths = { 0 => column_widths[0] }
          1.upto((column_widths.length - 1) / 2) { |i| header_column_widths[i] = column_widths[1] + column_widths[2] }

          table header,
            :position => :center,
            :row_colors => ["cccccc"],
            :column_widths => header_column_widths,
            :cell_style => { :size => 4.5, :text_color => "000000", :height => 8, :border_width => 0.1, :padding => 1 }
          table [["", field1, field2, field1, field2, field1, field2, field1, field2, field1, field2, field1, field2, field1, field2],],
            :position => :center,
            :row_colors => ["cccccc"],
            :column_widths => column_widths,
            :cell_style => { :size => 4, :text_color => "000000", :height => 8, :border_width => 0.1, :padding => 1 }
          if morning
            lunch_time = nil
            morning.each_with_index do |row, index|
              if row[0].slice(0..1) == meal_time[0]
                lunch_time = index
                break
              end
            end
            table morning.slice(0..lunch_time-1),
              :position => :center,
              :column_widths => column_widths,
              :cell_style => { :size => 4.5, :text_color => "000000", :height => height, :border_width => 0.1, :padding => 1 }

            table morning.slice(lunch_time..lunch_time),
              :position => :center,
              :row_colors => ["cccccc"],
              :column_widths => column_widths,
              :cell_style => { :size => 4.5, :text_color => "000000", :height => height, :border_width => 0.1, :padding => 1 }

            table morning.slice(lunch_time+1..-1),
              :position => :center,
              :column_widths => column_widths,
              :cell_style => { :size => 4.5, :text_color => "000000", :height => height, :border_width => 0.1, :padding => 1 }
          end
          if morning and evening
            table [morning[0].collect { |column| "" }], # 2. öğretimi ayıran çizgi
              :position => :center,
              :row_colors => ["cccccc"],
              :column_widths => column_widths,
              :cell_style => { :size => 4.5, :text_color => "000000", :height => 6, :border_width => 0.1, :padding => 1 }
          end
          if evening
            table evening,
              :position => :center,
              :column_widths => column_widths,
              :cell_style => { :size => 4.5, :text_color => "000000", :height => height, :border_width => 0.1, :padding => 1 }
          end
          move_down(5)
          text "http://plan.mf.omu.edu.tr", :size => 5, :align => :center
          text "copyright © #{Time.now.strftime("%Y")} Mühendislik Fakültesi Eğitim Öğretim Planları", :size => 5.5, :align => :center
        end
      pdf
    end
    def departmentpdf_schema info, header, field1, field2, meal_time, morning, evening
      morning1, morning2, morning3, morning4 = morning
      evening1, evening2, evening3, evening4 = evening

      pdf = Prawn::Document.new(:page_size => 'A5', :layout => 'portrait') do
        font "#{Prawn::BASEDIR}/data/fonts/Dustismo_Roman.ttf", :size => 8

        move_up(30)
        text "Ondokuz Mayıs Üniversitesi", :size => 12, :align => :center
        text "Mühendislik Fakültesi Eğitim Öğretim Planları", :size => 8, :align => :center

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
            lunch_time = nil
            eval("morning#{year}").each_with_index do |row, index|
              if row[0].slice(0..1) == meal_time[0]
                lunch_time = index
                break
              end
            end
            table eval("morning#{year}").slice(0..lunch_time-1),
              :position => :center,
              :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
              :cell_style => { :size => 3, :text_color => "000000", :height => 28, :border_width => 0.1, :padding => 1 }

            table eval("morning#{year}").slice(lunch_time..lunch_time),
              :position => :center,
              :row_colors => ["cccccc"],
              :column_widths => { 0=>24,1=>45.7,2=>18,3=>45.7,4=>18,5=>45.7,6=>18,7=>45.7,8=>18,9=>45.7,10=>18},
              :cell_style => { :size => 3, :text_color => "000000", :height => 28, :border_width => 0.1, :padding => 1 }

            table eval("morning#{year}").slice(lunch_time+1..-1),
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
end
