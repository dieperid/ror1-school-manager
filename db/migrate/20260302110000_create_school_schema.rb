class CreateSchoolSchema < ActiveRecord::Migration[8.1]
  def change
    # =====================================================
    # PEOPLE
    # =====================================================

    create_table :people, id: :bigint do |t|
      t.string  :avs_number,  null: false, limit: 255
      t.string  :city,                   limit: 255
      t.date    :birth_date
      t.string  :first_name, null: false, limit: 255
      t.string  :last_name,  null: false, limit: 255
      t.string  :postal_code,           limit: 20
      t.string  :street,                limit: 255
      t.integer :street_number, limit: 1
      t.string  :phone_number,          limit: 50

      t.timestamps
    end

    add_index :people, :avs_number, unique: true, name: "idx_people_avs_number_unique"

    # =====================================================
    # ACCOUNTS
    # =====================================================

    create_table :accounts, id: :bigint do |t|
      t.string  :email,              null: false, default: "", limit: 255
      t.string  :encrypted_password, null: false, default: "", limit: 255
      t.boolean :enabled,            null: false
      t.bigint  :person_id,          null: false

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.timestamps
    end

    add_index :accounts, :email, unique: true, name: "idx_accounts_email_unique"
    add_index :accounts, :reset_password_token, unique: true
    # add_index :accounts, :confirmation_token,   unique: true
    # add_index :accounts, :unlock_token,         unique: true
    add_foreign_key :accounts, :people, column: :person_id, name: "fk_accounts_person"

    # =====================================================
    # COLLABORATORS
    # =====================================================

    create_table :collaborators, id: :bigint do |t|
      t.date   :contract_begin
      t.date   :contract_end
      t.bigint :person_id, null: false

      t.timestamps
    end

    add_index :collaborators, :person_id, unique: true, name: "idx_collaborators_person_unique"
    add_foreign_key :collaborators, :people, column: :person_id, name: "fk_collaborators_person"

    create_table :collaborator_roles, id: :bigint do |t|
      t.string :title, null: false, limit: 255

      t.timestamps
    end

    add_index :collaborator_roles, :title,
              unique: true,
              name: "idx_collaborator_roles_title_unique"

    create_table :collaborator_assignments, id: :bigint do |t|
      t.bigint :collaborator_id,      null: false
      t.bigint :collaborator_role_id, null: false

      t.timestamps
    end

    add_index :collaborator_assignments,
              [ :collaborator_id, :collaborator_role_id ],
              unique: true,
              name: "idx_collaborator_role_unique"

    add_foreign_key :collaborator_assignments, :collaborators,
                    column: :collaborator_id,
                    name: "fk_assignment_collaborator"
    add_foreign_key :collaborator_assignments, :collaborator_roles,
                    column: :collaborator_role_id,
                    name: "fk_assignment_role"

    # =====================================================
    # STUDENTS
    # =====================================================

    create_table :departure_reasons, id: :bigint do |t|
      t.string :title, null: false, limit: 255

      t.timestamps
    end

    add_index :departure_reasons, :title,
              unique: true,
              name: "idx_departure_reason_title_unique"

    create_table :students, id: :bigint do |t|
      t.date   :admission_date
      t.date   :departure_date
      t.bigint :departure_reason_id
      t.bigint :person_id,        null: false
      t.boolean :repeating_grade, null: false

      t.timestamps
    end

    add_index :students, :person_id, unique: true, name: "idx_student_person_unique"
    add_foreign_key :students, :people, column: :person_id, name: "fk_students_person"
    add_foreign_key :students, :departure_reasons,
                    column: :departure_reason_id,
                    name: "fk_students_departure"

    add_index :students, :person_id, name: "idx_students_person"

    # =====================================================
    # FORMATION PLANS & CLASSES
    # =====================================================

    create_table :formation_plans, id: :bigint do |t|
      t.string :name, null: false, limit: 255

      t.timestamps
    end

    add_index :formation_plans, :name,
              unique: true,
              name: "idx_formation_plan_name_unique"

    create_table :school_classes, id: :bigint do |t|
      t.bigint :formation_plan_id,        null: false
      t.string :name,                     null: false, limit: 255
      t.bigint :responsible_collaborator_id, null: false

      t.timestamps
    end

    add_foreign_key :school_classes, :formation_plans,
                    column: :formation_plan_id,
                    name: "fk_classes_plan"
    add_foreign_key :school_classes, :collaborators,
                    column: :responsible_collaborator_id,
                    name: "fk_classes_responsible"

    create_table :class_enrollments, id: :bigint do |t|
      t.bigint :school_class_id, null: false
      t.bigint :student_id,      null: false

      t.timestamps
    end

    add_index :class_enrollments,
              [ :school_class_id, :student_id ],
              unique: true,
              name: "idx_class_student_unique"

    add_index :class_enrollments, :student_id, name: "idx_enrollments_student"

    add_foreign_key :class_enrollments, :school_classes,
                    column: :school_class_id,
                    name: "fk_enrollment_class"
    add_foreign_key :class_enrollments, :students,
                    column: :student_id,
                    name: "fk_enrollment_student"

    # =====================================================
    # MODULES & UNITS
    # =====================================================

    create_table :learning_modules, id: :bigint do |t|
      t.string :name, null: false, limit: 255

      t.timestamps
    end

    add_index :learning_modules, :name,
              unique: true,
              name: "idx_learning_module_name_unique"

    create_table :units, id: :bigint do |t|
      t.string :name, null: false, limit: 255

      t.timestamps
    end

    add_index :units, :name,
              unique: true,
              name: "idx_unit_name_unique"

    create_table :module_units, id: :bigint do |t|
      t.bigint :learning_module_id, null: false
      t.bigint :unit_id,            null: false

      t.timestamps
    end

    add_index :module_units,
              [ :learning_module_id, :unit_id ],
              unique: true,
              name: "idx_module_unit_unique"

    add_foreign_key :module_units, :learning_modules,
                    column: :learning_module_id,
                    name: "fk_module_units_module"
    add_foreign_key :module_units, :units,
                    column: :unit_id,
                    name: "fk_module_units_unit"

    create_table :formation_plan_modules, id: :bigint do |t|
      t.bigint :formation_plan_id,  null: false
      t.bigint :learning_module_id, null: false

      t.timestamps
    end

    add_index :formation_plan_modules,
              [ :formation_plan_id, :learning_module_id ],
              unique: true,
              name: "idx_plan_module_unique"

    add_foreign_key :formation_plan_modules, :formation_plans,
                    column: :formation_plan_id,
                    name: "fk_plan_modules_plan"
    add_foreign_key :formation_plan_modules, :learning_modules,
                    column: :learning_module_id,
                    name: "fk_plan_modules_module"

    # =====================================================
    # ROOMS & LECTURES
    # =====================================================

    create_table :rooms, id: :bigint do |t|
      t.string :name, null: false, limit: 255

      t.timestamps
    end

    add_index :rooms, :name, unique: true, name: "idx_room_name_unique"

    create_table :lectures, id: :bigint do |t|
      t.bigint :collaborator_id, null: false
      t.date   :date,            null: false
      t.time   :end_time,        null: false
      t.bigint :room_id,         null: false
      t.time   :start_time,      null: false
      t.bigint :unit_id,         null: false

      t.timestamps
    end

    add_index :lectures, :unit_id, name: "idx_lectures_unit"

    add_foreign_key :lectures, :collaborators,
                    column: :collaborator_id,
                    name: "fk_lectures_collaborator"
    add_foreign_key :lectures, :rooms,
                    column: :room_id,
                    name: "fk_lectures_room"
    add_foreign_key :lectures, :units,
                    column: :unit_id,
                    name: "fk_lectures_unit"

    # =====================================================
    # GRADES
    # =====================================================

    create_table :grades, id: :bigint do |t|
      t.date   :awarded_on
      t.bigint :student_id, null: false
      t.bigint :unit_id,    null: false
      t.decimal :value, precision: 3, scale: 1

      t.timestamps
    end

    add_index :grades,
              [ :student_id, :unit_id, :awarded_on ],
              unique: true,
              name: "idx_grade_unique"

    add_foreign_key :grades, :students,
                    column: :student_id,
                    name: "fk_grades_student"
    add_foreign_key :grades, :units,
                    column: :unit_id,
                    name: "fk_grades_unit"
  end
end
