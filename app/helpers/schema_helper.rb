# encoding: utf-8
module SchemaHelper
  def table_schema
    day = {
      "Sunday" => "Pazartesi",
      "Tuesday" => "Salı",
      "Wednesday" => "Çarşamba",
      "Thursday" => "Perşembe",
      "Friday" => "Cuma"
    }

    header = [["Saat / Gün"] + day.values]
    morning = []
    launch = ["12", "", "", "", "", "", "", "", "", "", ""]
    evening = []
    morning_time = ["08", "09", "10", "11", "12", "13", "14", "15", "16"]
    evening_time = ["17", "18", "19", "20", "21", "22"]
    return [day, header, launch, morning, evening, morning_time, evening_time]
  end

  def departmentplan_schema period_id, department_id, year, section
    assignments = Assignment.joins(:course).where(
      'courses.department_id' => department_id,
      'assignments.period_id' => period_id
    )
    assignments = assignments.collect { |assignment| assignment.id }

    day, header, launch, morning, evening, morning_time, evening_time = table_schema # standart tablo şeması
    if section == "0" or section == "1"
      morning_time.each do |hour|
        if hour.to_i < 13
          column = [hour + '-15' + '/' + (hour.to_i+1).to_s + '-00']
          hour = hour + '-15'
        else
          column = [hour + '-00' + '/' + (hour.to_i+1).to_s + '-00']
          hour = hour + '-00'
        end
        if hour.slice(0..1) == launch[0]
          launch.slice(1..-1).each {|l| column << l }
          launch = column
          morning << column
        else
          day.each do |day_en, day_tr|
            classplan = Classplan.find(:first,
                                       :conditions => {
              :period_id => period_id,
              :day => day_en,
              :begin_time => hour
            })
            if classplan and classplan.assignment.course.year == year and
              assignments.include?(classplan.assignment_id)
              column << classplan.assignment.course.code + "\n" +
                classplan.assignment.course.name + "\n" +
                classplan.assignment.lecturer.full_name
              column << classplan.classroom.name
            else
              column << ""
              column << ""
            end
          end
          morning << column
        end
      end
    end
    if section == "0" or section == "2"
      evening_time.each do |hour|
        column = [hour + '-00' + '/' + (hour.to_i+1).to_s + '-00']
        day.each do |day_en, day_tr|
          classplan = Classplan.find(:first,
                                     :conditions => {
            :period_id => period_id,
            :day => day_en,
            :begin_time => hour+'-00'
          })
          if classplan and classplan.assignment.course.year == year and
            assignments.include?(classplan.assignment_id)
            column << classplan.assignment.course.code + "\n" +
              classplan.assignment.course.name + "\n" +
              classplan.assignment.lecturer.full_name
            column << classplan.classroom.name
          else
            column << ""
            column << ""
          end
        end
        evening << column
      end
    end
    if section == "0"
      [day, header, launch, morning, evening]
    elsif section == "1"
      [day, header, launch, morning, nil]
    elsif section == "2"
      [day, header, nil, nil, evening]
    end
  end

  def classplan_schema period_id, assignments, classroom_id

    day, header, launch, morning, evening, morning_time, evening_time = table_schema # standart tablo şeması
    morning_time.each do |hour|
      if hour.to_i < 13
        column = [hour + '-15' + '/' + (hour.to_i+1).to_s + '-00']
        hour = hour + '-15'
      else
        column = [hour + '-00' + '/' + (hour.to_i+1).to_s + '-00']
        hour = hour + '-00'
      end
      if hour.slice(0..1) == launch[0]
        launch.slice(1..-1).each {|l| column << l }
        launch = column
        morning << column
      else
        day.each do |day_en, day_tr|
          classplan = Classplan.find(:first,
                                     :conditions => {
            :classroom_id => classroom_id,
            :period_id => period_id,
            :day => day_en,
            :begin_time => hour
          })
          if classplan and assignments.include?(classplan.assignment_id)
            column << classplan.assignment.course.code + "\n" +
              classplan.assignment.course.name + "\n" +
              classplan.assignment.lecturer.full_name
            column << classplan.assignment.course.department.code
          else
            column << ""
            column << ""
          end
        end
        morning << column
      end
    end

    evening_time.each do |hour|
      column = [hour + '-00' + '/' + (hour.to_i+1).to_s + '-00']
      hour = hour + '-00'
      day.each do |day_en, day_tr|
        classplan = Classplan.find(:first,
                                   :conditions => {
          :classroom_id => classroom_id,
          :period_id => period_id,
          :day => day_en,
          :begin_time => hour
        })
        if classplan and assignments.include?(classplan.assignment_id)
          column << classplan.assignment.course.code + "\n" +
            classplan.assignment.course.name + "\n" +
            classplan.assignment.lecturer.full_name
          column << classplan.assignment.course.department.code
        else
          column << ""
          column << ""
        end
      end
      evening << column
    end
    [day, header, launch, morning, evening]
  end
  def lecturerplan_schema period_id, assignments

    day, header, launch, morning, evening, morning_time, evening_time = table_schema # standart tablo şeması
    morning_time.each do |hour|
      if hour.to_i < 13
        column = [hour + '-15' + '/' + (hour.to_i+1).to_s + '-00']
        hour = hour + '-15'
      else
        column = [hour + '-00' + '/' + (hour.to_i+1).to_s + '-00']
        hour = hour + '-00'
      end
      if hour.slice(0..1) == launch[0]
        launch.slice(1..-1).each {|l| column << l }
        launch = column
        morning << column
      else
        day.each do |day_en, day_tr|
          classplan = Classplan.find(:first,
                                     :conditions => {
            :period_id => period_id,
            :day => day_en,
            :begin_time => hour
          })
          if classplan and assignments.include?(classplan.assignment_id)
            column << classplan.assignment.course.code + "\n" +
              classplan.assignment.course.name
            column << classplan.classroom.name
          else
            column << ""
            column << ""
          end
        end
        morning << column
      end
    end

    evening_time.each do |hour|
      column = [hour + '-00' + '/' + (hour.to_i+1).to_s + '-00']
      hour = hour + '-00'
      day.each do |day_en, day_tr|
        classplan = Classplan.find(:first,
                                   :conditions => {
          :period_id => period_id,
          :day => day_en,
          :begin_time => hour
        })
        if classplan and assignments.include?(classplan.assignment_id)
          column << classplan.assignment.course.code + "\n" +
            classplan.assignment.course.name
          column << classplan.classroom.name
        else
          column << ""
          column << ""
        end
      end
      evening << column
    end
    [day, header, launch, morning, evening]
  end
end
