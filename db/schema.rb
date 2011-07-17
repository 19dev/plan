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

ActiveRecord::Schema.define(:version => 20110717151559) do

  create_table "admins", :force => true do |t|
    t.integer  "department_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "password"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "classplans", :force => true do |t|
    t.integer  "period_id"
    t.integer  "classroom_id"
    t.integer  "course_id"
    t.integer  "lecturer_id"
    t.datetime "begin_time"
    t.datetime "end_time"
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
    t.integer  "period_id"
    t.string   "code"
    t.string   "name"
    t.string   "theoretical"
    t.string   "practice"
    t.string   "lab"
    t.integer  "credit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.string   "chairman"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "periods", :force => true do |t|
    t.string   "name"
    t.date     "year"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
