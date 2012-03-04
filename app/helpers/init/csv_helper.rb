# encoding: utf-8
module Init
  module CsvHelper
    def csv_export table, split_char = ",", columns
      _datas = eval table.capitalize + ".all"

      csvlib = CSV.const_defined?(:Reader) ? FasterCSV : CSV
      _csv_out = csvlib.generate(:col_sep => split_char) do |csv|
        csv << columns
        _datas.each do |row|
          csv << columns.collect { |column| row.attributes[column] }
        end
      end
      send_data(_csv_out, :type => 'text/csv', :charset => "utf-8",
                :filename => "#{table}-#{Time.now.strftime("%d-%m-%Y")}.csv")
      end
  end
end
