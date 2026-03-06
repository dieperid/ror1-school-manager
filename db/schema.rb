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

ActiveRecord::Schema[8.1].define(version: 2026_03_02_110000) do
  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.boolean "enabled", default: true, null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.bigint "person_id", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["person_id"], name: "index_accounts_on_person_id", unique: true
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
  end

  create_table "class_enrollments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "school_class_id", null: false
    t.bigint "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["school_class_id", "student_id"], name: "idx_class_student_unique", unique: true
    t.index ["school_class_id"], name: "index_class_enrollments_on_school_class_id"
    t.index ["student_id"], name: "index_class_enrollments_on_student_id"
  end

  create_table "collaborator_assignments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "collaborator_id", null: false
    t.bigint "collaborator_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collaborator_id", "collaborator_role_id"], name: "idx_collaborator_role_unique", unique: true
    t.index ["collaborator_id"], name: "index_collaborator_assignments_on_collaborator_id"
    t.index ["collaborator_role_id"], name: "index_collaborator_assignments_on_collaborator_role_id"
  end

  create_table "collaborator_roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_collaborator_roles_on_title", unique: true
  end

  create_table "collaborators", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "contract_begin"
    t.date "contract_end"
    t.datetime "created_at", null: false
    t.bigint "person_id", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_collaborators_on_person_id"
  end

  create_table "departure_reasons", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_departure_reasons_on_title", unique: true
  end

  create_table "formation_plan_modules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "formation_plan_id", null: false
    t.bigint "learning_module_id", null: false
    t.datetime "updated_at", null: false
    t.index ["formation_plan_id", "learning_module_id"], name: "idx_plan_module_unique", unique: true
    t.index ["formation_plan_id"], name: "index_formation_plan_modules_on_formation_plan_id"
    t.index ["learning_module_id"], name: "index_formation_plan_modules_on_learning_module_id"
  end

  create_table "formation_plans", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_formation_plans_on_name", unique: true
  end

  create_table "grades", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "awarded_on"
    t.datetime "created_at", null: false
    t.bigint "student_id", null: false
    t.bigint "unit_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 3, scale: 1
    t.index ["student_id"], name: "index_grades_on_student_id"
    t.index ["unit_id"], name: "index_grades_on_unit_id"
  end

  create_table "learning_modules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_learning_modules_on_name", unique: true
  end

  create_table "lectures", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "collaborator_id", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.time "end_time", null: false
    t.bigint "room_id", null: false
    t.time "start_time", null: false
    t.bigint "unit_id", null: false
    t.datetime "updated_at", null: false
    t.index ["collaborator_id"], name: "index_lectures_on_collaborator_id"
    t.index ["room_id"], name: "index_lectures_on_room_id"
    t.index ["unit_id"], name: "index_lectures_on_unit_id"
  end

  create_table "module_units", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "learning_module_id", null: false
    t.bigint "unit_id", null: false
    t.datetime "updated_at", null: false
    t.index ["learning_module_id", "unit_id"], name: "idx_module_unit_unique", unique: true
    t.index ["learning_module_id"], name: "index_module_units_on_learning_module_id"
    t.index ["unit_id"], name: "index_module_units_on_unit_id"
  end

  create_table "people", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "avs_number", null: false
    t.date "birth_date"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number"
    t.string "postal_code"
    t.string "street"
    t.integer "street_number"
    t.datetime "updated_at", null: false
    t.index ["avs_number"], name: "index_people_on_avs_number", unique: true
  end

  create_table "rooms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_rooms_on_name", unique: true
  end

  create_table "school_classes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "formation_plan_id", null: false
    t.string "name", null: false
    t.bigint "responsible_collaborator_id", null: false
    t.datetime "updated_at", null: false
    t.index ["formation_plan_id"], name: "index_school_classes_on_formation_plan_id"
    t.index ["name"], name: "index_school_classes_on_name", unique: true
    t.index ["responsible_collaborator_id"], name: "index_school_classes_on_responsible_collaborator_id"
  end

  create_table "students", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "admission_date"
    t.datetime "created_at", null: false
    t.date "departure_date"
    t.bigint "departure_reason_id"
    t.bigint "person_id", null: false
    t.boolean "repeating_grade", null: false
    t.datetime "updated_at", null: false
    t.index ["departure_reason_id"], name: "index_students_on_departure_reason_id"
    t.index ["person_id"], name: "index_students_on_person_id"
  end

  create_table "units", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_units_on_name", unique: true
  end

  add_foreign_key "accounts", "people"
  add_foreign_key "class_enrollments", "school_classes"
  add_foreign_key "class_enrollments", "students"
  add_foreign_key "collaborator_assignments", "collaborator_roles"
  add_foreign_key "collaborator_assignments", "collaborators"
  add_foreign_key "collaborators", "people"
  add_foreign_key "formation_plan_modules", "formation_plans"
  add_foreign_key "formation_plan_modules", "learning_modules"
  add_foreign_key "grades", "students"
  add_foreign_key "grades", "units"
  add_foreign_key "lectures", "collaborators"
  add_foreign_key "lectures", "rooms"
  add_foreign_key "lectures", "units"
  add_foreign_key "module_units", "learning_modules"
  add_foreign_key "module_units", "units"
  add_foreign_key "school_classes", "collaborators", column: "responsible_collaborator_id"
  add_foreign_key "school_classes", "formation_plans"
  add_foreign_key "students", "departure_reasons"
  add_foreign_key "students", "people"
end
