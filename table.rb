#/usr/bin/ruby

model = "rails g model"

tables = [
	"departments " +
		"name:string",

	"lecturers " + # status : boolen olacak
		"department_id:integer first_name:string last_name:string email:string cell_phone:string work_phone:string status:integer photo:string",

	"courses " +
		"department_id:integer code:string name:string theoretical:string practice:string lab:string credit:integer",

	"periods " +
		"name:string year:date status:integer",

	"classrooms " +
		"name:string floor:string capacity:integer type:string",

	"assignments " +
		"period_id:integer lecturer_id:integer course_id:integer",

	"classplans " +
		"period_id:integer classroom_id:integer assignment_id:integer day:string begin_time:time",

	"admins " + # status eklenecek
		"department_id:integer first_name:string last_name:string password:string"
]
tables.each do |table|
	system "#{model} #{table}"
end
