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
    return false
  end
  def substr?(text, text_length)
    if text.length > text_length
      text = text.slice(0..text_length) + "..."
    end
    return text
  end
  def control(hash)
    hash.each do |key, value|
      if key == "" or key == nil
        return "#{value} boş bırakılamaz"
      end
    end
    return nil
  end
end
