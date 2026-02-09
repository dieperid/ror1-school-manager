# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_09_123831) do
  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "account_status", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_hash", null: false
    t.bigint "person_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["person_id"], name: "index_accounts_on_person_id", unique: true
  end

  create_table "school_classes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "domain_id", null: false
    t.string "name", null: false
    t.bigint "responsible_collaborator_id", null: false
    t.bigint "training_plan_id", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_id"], name: "index_school_classes_on_domain_id"
    t.index ["name"], name: "index_school_classes_on_name", unique: true
    t.index ["responsible_collaborator_id"], name: "index_school_classes_on_responsible_collaborator_id"
    t.index ["training_plan_id"], name: "index_school_classes_on_training_plan_id"
  end

  create_table "collaborator_role_assignments", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "collaborator_id", null: false
    t.bigint "collaborator_role_id", null: false
    t.index ["collaborator_id", "collaborator_role_id"], name: "index_cra_on_collaborator_and_role", unique: true
    t.index ["collaborator_id"], name: "index_collaborator_role_assignments_on_collaborator_id"
    t.index ["collaborator_role_id"], name: "index_collaborator_role_assignments_on_collaborator_role_id"
  end

  create_table "collaborator_roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collaborators", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "contract_end"
    t.date "contract_start"
    t.datetime "created_at", null: false
    t.boolean "is_teacher"
    t.bigint "person_id", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_collaborators_on_person_id"
  end

  create_table "domains", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grades", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "grade_value", precision: 2, scale: 1, null: false
    t.bigint "student_id", null: false
    t.date "test_date", null: false
    t.bigint "unit_id", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_grades_on_student_id"
    t.index ["unit_id"], name: "index_grades_on_unit_id"
  end

  create_table "leaving_reasons", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "school_modules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "persons", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "avs_number", null: false
    t.date "birth_date"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number"
    t.integer "postal_code"
    t.string "street"
    t.integer "street_number"
    t.datetime "updated_at", null: false
    t.index ["avs_number"], name: "index_persons_on_avs_number", unique: true
  end

  create_table "rooms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "schedule_rooms", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "schedule_id", null: false
    t.index ["room_id"], name: "index_schedule_rooms_on_room_id"
    t.index ["schedule_id", "room_id"], name: "index_schedule_rooms_on_schedule_and_room", unique: true
    t.index ["schedule_id"], name: "index_schedule_rooms_on_schedule_id"
  end

  create_table "schedule_units", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "schedule_id", null: false
    t.bigint "unit_id", null: false
    t.index ["schedule_id", "unit_id"], name: "index_schedule_units_on_schedule_and_unit", unique: true
    t.index ["schedule_id"], name: "index_schedule_units_on_schedule_id"
    t.index ["unit_id"], name: "index_schedule_units_on_unit_id"
  end

  create_table "schedules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "school_class_id"
    t.bigint "collaborator_id", null: false
    t.datetime "created_at", null: false
    t.date "day", null: false
    t.time "end_time", null: false
    t.time "start_time", null: false
    t.datetime "updated_at", null: false
    t.index ["school_class_id"], name: "index_schedules_on_school_class_id"
    t.index ["collaborator_id"], name: "index_schedules_on_collaborator_id"
  end

  create_table "students", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "admission_date"
    t.bigint "school_class_id", null: false
    t.datetime "created_at", null: false
    t.date "leaving_date"
    t.bigint "leaving_reason_id"
    t.bigint "person_id", null: false
    t.boolean "repeat_year"
    t.datetime "updated_at", null: false
    t.index ["school_class_id"], name: "index_students_on_school_class_id"
    t.index ["leaving_reason_id"], name: "index_students_on_leaving_reason_id"
    t.index ["person_id"], name: "index_students_on_person_id", unique: true
  end

  create_table "training_plan_modules", id: false, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "school_module_id", null: false
    t.bigint "training_plan_id", null: false
    t.index ["school_module_id"], name: "index_training_plan_modules_on_school_module_id"
    t.index ["training_plan_id", "school_module_id"], name: "index_tpm_on_training_plan_and_school_module", unique: true
    t.index ["training_plan_id"], name: "index_training_plan_modules_on_training_plan_id"
  end

  create_table "training_plans", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "units", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "school_module_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["school_module_id"], name: "index_units_on_school_module_id"
  end

  add_foreign_key "accounts", "persons"
  add_foreign_key "school_classes", "collaborators", column: "responsible_collaborator_id"
  add_foreign_key "school_classes", "domains"
  add_foreign_key "school_classes", "training_plans"
  add_foreign_key "collaborator_role_assignments", "collaborator_roles"
  add_foreign_key "collaborator_role_assignments", "collaborators"
  add_foreign_key "collaborators", "persons"
  add_foreign_key "grades", "students"
  add_foreign_key "grades", "units"
  add_foreign_key "schedule_rooms", "rooms"
  add_foreign_key "schedule_rooms", "schedules"
  add_foreign_key "schedule_units", "schedules"
  add_foreign_key "schedule_units", "units"
  add_foreign_key "schedules", "school_classes"
  add_foreign_key "schedules", "collaborators"
  add_foreign_key "students", "school_classes"
  add_foreign_key "students", "leaving_reasons"
  add_foreign_key "students", "persons"
  add_foreign_key "training_plan_modules", "school_modules"
  add_foreign_key "training_plan_modules", "training_plans"
  add_foreign_key "units", "school_modules"
end
