#/usr/bin/ruby

model = "rails g model"

tables = [
	"departments " +
	"name:string chairman:string",

	"lecturers " +
	"department_id:integer first_name:string last_name:string email:string cell_phone:string work_phone:string photo:string",

	"courses " +
	"department_id:integer period_id:integer code:string name:string theoretical:string practice:string lab:string credit:integer",

	"periods " +
	"name:string year:date status:integer",

	"classrooms " +
	"name:string floor:string capacity:integer type:string",

	"classplans " +
	"period_id:integer classroom_id:integer course_id:integer lecturer_id:integer begin_time:datetime end_time:datetime",

	"admins " +
	"department_id:integer first_name:string last_name:string password:string status:integer"
]
tables.each do |table|
	system "#{model} #{table}"
end

