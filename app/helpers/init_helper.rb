# encoding: utf-8
module InitHelper
  def in?(item, fields)
    fields.each do |field, type|
      if type
	return true if item =~/#{field}/
      else
	return true if field == item
      end
    end
    false
  end
  def substr?(text, text_length)
    return text.slice(0..text_length) + "..." if text.length > text_length
    text
  end
  def control(hash)
    error_message = "boş bırakılamaz"
    hash.each { |key, value| return "#{value} #{error_message}" if key == "" or key == nil }
    nil
  end
end
