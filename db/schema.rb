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
    t.string "email", default: "", null: false
    t.boolean "enabled", null: false
    t.string "encrypted_password", default: "", null: false
    t.bigint "person_id", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "idx_accounts_email_unique", unique: true
    t.index ["person_id"], name: "fk_accounts_person"
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
  end

  create_table "class_enrollments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "school_class_id", null: false
    t.bigint "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["school_class_id", "student_id"], name: "idx_class_student_unique", unique: true
    t.index ["student_id"], name: "idx_enrollments_student"
  end

  create_table "collaborator_assignments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "collaborator_id", null: false
    t.bigint "collaborator_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collaborator_id", "collaborator_role_id"], name: "idx_collaborator_role_unique", unique: true
    t.index ["collaborator_role_id"], name: "fk_assignment_role"
  end

  create_table "collaborator_roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "idx_collaborator_roles_title_unique", unique: true
  end

  create_table "collaborators", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "contract_begin"
    t.date "contract_end"
    t.datetime "created_at", null: false
    t.bigint "person_id", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "idx_collaborators_person_unique", unique: true
  end

  create_table "departure_reasons", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "idx_departure_reason_title_unique", unique: true
  end

  create_table "formation_plan_modules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "formation_plan_id", null: false
    t.bigint "learning_module_id", null: false
    t.datetime "updated_at", null: false
    t.index ["formation_plan_id", "learning_module_id"], name: "idx_plan_module_unique", unique: true
    t.index ["learning_module_id"], name: "fk_plan_modules_module"
  end

  create_table "formation_plans", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_formation_plan_name_unique", unique: true
  end

  create_table "grades", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "awarded_on"
    t.datetime "created_at", null: false
    t.bigint "student_id", null: false
    t.bigint "unit_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 3, scale: 1
    t.index ["student_id", "unit_id", "awarded_on"], name: "idx_grade_unique", unique: true
    t.index ["unit_id"], name: "fk_grades_unit"
  end

  create_table "learning_modules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_learning_module_name_unique", unique: true
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
    t.index ["collaborator_id"], name: "fk_lectures_collaborator"
    t.index ["room_id"], name: "fk_lectures_room"
    t.index ["unit_id"], name: "idx_lectures_unit"
  end

  create_table "module_units", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "learning_module_id", null: false
    t.bigint "unit_id", null: false
    t.datetime "updated_at", null: false
    t.index ["learning_module_id", "unit_id"], name: "idx_module_unit_unique", unique: true
    t.index ["unit_id"], name: "fk_module_units_unit"
  end

  create_table "people", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "avs_number", null: false
    t.date "birth_date"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number", limit: 50
    t.string "postal_code", limit: 20
    t.string "street"
    t.integer "street_number", limit: 1
    t.datetime "updated_at", null: false
    t.index ["avs_number"], name: "idx_people_avs_number_unique", unique: true
  end

  create_table "rooms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_room_name_unique", unique: true
  end

  create_table "school_classes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "formation_plan_id", null: false
    t.string "name", null: false
    t.bigint "responsible_collaborator_id", null: false
    t.datetime "updated_at", null: false
    t.index ["formation_plan_id"], name: "fk_classes_plan"
    t.index ["responsible_collaborator_id"], name: "fk_classes_responsible"
  end

  create_table "students", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "admission_date"
    t.datetime "created_at", null: false
    t.date "departure_date"
    t.bigint "departure_reason_id"
    t.bigint "person_id", null: false
    t.boolean "repeating_grade", null: false
    t.datetime "updated_at", null: false
    t.index ["departure_reason_id"], name: "fk_students_departure"
    t.index ["person_id"], name: "idx_student_person_unique", unique: true
    t.index ["person_id"], name: "idx_students_person"
  end

  create_table "units", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "idx_unit_name_unique", unique: true
  end

  add_foreign_key "accounts", "people", name: "fk_accounts_person"
  add_foreign_key "class_enrollments", "school_classes", name: "fk_enrollment_class"
  add_foreign_key "class_enrollments", "students", name: "fk_enrollment_student"
  add_foreign_key "collaborator_assignments", "collaborator_roles", name: "fk_assignment_role"
  add_foreign_key "collaborator_assignments", "collaborators", name: "fk_assignment_collaborator"
  add_foreign_key "collaborators", "people", name: "fk_collaborators_person"
  add_foreign_key "formation_plan_modules", "formation_plans", name: "fk_plan_modules_plan"
  add_foreign_key "formation_plan_modules", "learning_modules", name: "fk_plan_modules_module"
  add_foreign_key "grades", "students", name: "fk_grades_student"
  add_foreign_key "grades", "units", name: "fk_grades_unit"
  add_foreign_key "lectures", "collaborators", name: "fk_lectures_collaborator"
  add_foreign_key "lectures", "rooms", name: "fk_lectures_room"
  add_foreign_key "lectures", "units", name: "fk_lectures_unit"
  add_foreign_key "module_units", "learning_modules", name: "fk_module_units_module"
  add_foreign_key "module_units", "units", name: "fk_module_units_unit"
  add_foreign_key "school_classes", "collaborators", column: "responsible_collaborator_id", name: "fk_classes_responsible"
  add_foreign_key "school_classes", "formation_plans", name: "fk_classes_plan"
  add_foreign_key "students", "departure_reasons", name: "fk_students_departure"
  add_foreign_key "students", "people", name: "fk_students_person"
end
