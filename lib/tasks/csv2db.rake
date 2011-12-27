#!/usr/bin/ruby
# encoding: utf-8
require 'csv'
# SERVICE bir csv'yi kendi ismindeki tabloya doldurma eklentisi

TASKS_DIR = 'lib/tasks'
TEMP_FILE = TASKS_DIR + '/temp'
CSV_DIR = TASKS_DIR + '/csv'
CONSOLE = 'rails c' # rails console

task :push do
  Dir["#{CSV_DIR}/*"].each do |file|
    @kayitlar = []
    file = File.basename file
    if file =~ /.csv/
      table = file.split(".")[0].capitalize
      begin
        rows = CSV.open("#{CSV_DIR}/#{file}", 'r')
      rescue Exception => e
        puts "CSV dosya okuma veya yazmada hata: #{e}"
      end

      fields = rows.shift
      bunungibi = Hash[*fields.map { |alan| [alan, nil] }.flatten]

      rows.each do |row|
        kayit = bunungibi.clone
        fields.each { |alan| kayit[alan] = row.shift }
        @kayitlar << kayit
      end

      texts = []
      puts "#{table} tablosuna bilgiler yükleniyor..."
      @kayitlar.each do |kayit|
        texts << "yeni_kayit = #{table}.new"
        kayit.each { |field, value| texts << "yeni_kayit.#{field} = '#{value}'" }
        texts << "yeni_kayit.save"
      end
        fp = File.new(TEMP_FILE, "w")
        texts.each {|text| fp.write("#{text}\n") }
        fp.close
        system "cat #{TEMP_FILE} | #{CONSOLE}"
        FileUtils.rm_rf TEMP_FILE
    end
  end
end
