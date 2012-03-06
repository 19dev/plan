# encoding: utf-8
module MainHelper
  def percent assignment_percent, schedule_percent
    state = if schedule_percent == 100 and assignment_percent == 100
              "up"
            elsif assignment_percent != 0
              "problem"
            else
              "down"
            end
  end
end
