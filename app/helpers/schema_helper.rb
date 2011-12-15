# encoding: utf-8
module SchemaHelper
  def table_schema
    @day = {
      "Sunday" => "Pazartesi",
      "Tuesday" => "Salı",
      "Wednesday" => "Çarşamba",
      "Thursday" => "Perşembe",
      "Friday" => "Cuma"
    }

    @header = [["Saat / Gün"] + @day.values]
    @morning = []
    @launch = [["12-00 / 13-00", "", "", "", "", "", "", "", "", "", ""]]
    @evening = []
    return [@day, @header, @morning, @launch, @evening]
  end

  def department_schema department_id, year, section

    @assignments = Assignment.joins(:lecturer).where('lecturers.department_id'=> department_id)
    @assignments = @assignments.collect { |assignment| assignment.id }

    @day, @header, @morning, @launch, @evening = table_schema # standart tablo şeması
    if section[0]
      ["08","09","10","11"].each do |hour|
        column = [hour + '-15' + ' / ' + (hour.to_i+1).to_s + '-00']
        @day.each do |day_en, day_tr|
          classplan = Classplan.find(:first,
                                    :conditions => {
            :period_id => session[:period_id],
            :day => day_en,
            :begin_time => hour+'-15'
          })
          if classplan and classplan.assignment.course.year == year and
            @assignments.include?(classplan.assignment_id)
            column << classplan.assignment.course.code + "\n" +
                      classplan.assignment.course.name + "\n" +
                      classplan.assignment.lecturer.full_name
            column << classplan.classroom.name
          else
            column << ""
            column << ""
          end
        end
          @morning << column
      end
    end
    if section[1]
      ["12","13","14","15","16","17","18","19","20","21","22"].each do |hour|
        column = [hour + '-00' + ' / ' + (hour.to_i+1).to_s + '-00']
        @day.each do |day_en, day_tr|
          classplan = Classplan.find(:first,
                                    :conditions => {
            :period_id => session[:period_id],
            :day => day_en,
            :begin_time => hour+'-00'
          })
          if classplan and classplan.assignment.course.year == year and
            @assignments.include?(classplan.assignment_id)
            column << classplan.assignment.course.code + "\n" +
                      classplan.assignment.course.name + "\n" +
                      classplan.assignment.lecturer.full_name
            column << classplan.classroom.name
          else
            column << ""
            column << ""
          end
        end
          @evening << column
      end
    end
    if section[0] and section[1]
      [@day, @header, @morning, @launch, @evening]
    elsif section[0]
      [@day, @header, @morning, nil, nil]
    elsif section[1]
      [@day, @header, nil, nil, @evening]
    end
  end
end
