# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111213140009) do

  create_table "assignments", :force => true do |t|
    t.integer  "period_id"
    t.integer  "lecturer_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "classplans", :force => true do |t|
    t.integer  "period_id"
    t.integer  "classroom_id"
    t.integer  "assignment_id"
    t.string   "day"
    t.string   "begin_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "classrooms", :force => true do |t|
    t.string   "name"
    t.string   "floor"
    t.integer  "capacity"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", :force => true do |t|
    t.integer  "department_id"
    t.string   "code"
    t.string   "name"
    t.integer  "year"
    t.integer  "theoretical"
    t.integer  "practice"
    t.integer  "lab"
    t.integer  "credit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lecturers", :force => true do |t|
    t.integer  "department_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "cell_phone"
    t.string   "work_phone"
    t.boolean  "status"
    t.string   "photo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notices", :force => true do |t|
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.integer  "department_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password"
    t.integer  "status"
    t.string   "photo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "periods", :force => true do |t|
    t.string   "name"
    t.integer  "year"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
