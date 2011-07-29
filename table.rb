#/usr/bin/ruby

model = "rails g model"

tables = [
	"department " +
		"name:string",

	"lecturer " + # status : boolen olacak
		"department_id:integer first_name:string last_name:string email:string cell_phone:string work_phone:string status:integer photo:string",

	"course " +
		"department_id:integer code:string name:string theoretical:string practice:string lab:string credit:integer",

	"period " +
		"name:string year:date status:integer",

	"classroom " +
		"name:string floor:string capacity:integer type:string",

	"assignment " +
		"period_id:integer lecturer_id:integer course_id:integer",

	"classplan " +
		"period_id:integer classroom_id:integer assignment_id:integer day:string begin_time:time",

	"admin " + # status eklenecek
		"department_id:integer first_name:string last_name:string password:string"
]
tables.each do |table|
	system "#{model} #{table}"
end
