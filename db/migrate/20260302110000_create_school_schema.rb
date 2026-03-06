class CreateSchoolSchema < ActiveRecord::Migration[8.1]
  def change
    # =====================================================
    # PEOPLE
    # =====================================================

    create_table :people do |t|
      t.string  :avs_number,  null: false
      t.string  :city
      t.date    :birth_date
      t.string  :first_name, null: false
      t.string  :last_name,  null: false
      t.string  :postal_code
      t.string  :street
      t.integer :street_number
      t.string  :phone_number

      t.timestamps
    end
    add_index :people, :avs_number, unique: true

    # =====================================================
    # ACCOUNTS
    # =====================================================

    create_table :accounts do |t|
      t.references :person, null: false, foreign_key: true, index: { unique: true }
      t.boolean :enabled, null: false, default: true

      # Authentication fields (Devise)
      t.string  :email, null: false, default: ""
      t.string  :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

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
    add_index :accounts, :email, unique: true
    add_index :accounts, :reset_password_token, unique: true
    # add_index :accounts, :confirmation_token,   unique: true
    # add_index :accounts, :unlock_token,         unique: true

    # =====================================================
    # COLLABORATORS
    # =====================================================

    create_table :collaborators do |t|
      t.references :person, null: false, foreign_key: true
      t.date   :contract_begin
      t.date   :contract_end

      t.timestamps
    end

    create_table :collaborator_roles do |t|
      t.string :title, null: false

      t.timestamps
    end
    add_index :collaborator_roles, :title, unique: true

    create_table :collaborator_assignments do |t|
      t.references :collaborator, null: false, foreign_key: true
      t.references :collaborator_role, null: false, foreign_key: true

      t.timestamps
    end
    add_index :collaborator_assignments, [ :collaborator_id, :collaborator_role_id ], unique: true, name: "idx_collaborator_role_unique"

    # =====================================================
    # STUDENTS
    # =====================================================

    create_table :departure_reasons do |t|
      t.string :title, null: false

      t.timestamps
    end
    add_index :departure_reasons, :title, unique: true

    create_table :students do |t|
      t.date   :admission_date
      t.date   :departure_date
      t.boolean :repeating_grade, null: false
      t.references :person, null: false, foreign_key: true
      t.references :departure_reason, foreign_key: true

      t.timestamps
    end

    # =====================================================
    # FORMATION PLANS & CLASSES
    # =====================================================

    create_table :formation_plans do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :formation_plans, :name, unique: true

    create_table :school_classes do |t|
      t.string :name, null: false
      t.references :formation_plan, null: false, foreign_key: true
      t.references :responsible_collaborator, null: false, foreign_key: { to_table: :collaborators }

      t.timestamps
    end
    add_index :school_classes, :name, unique: true

    create_table :class_enrollments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :school_class, null: false, foreign_key: true

      t.timestamps
    end
    add_index :class_enrollments, [ :school_class_id, :student_id ], unique: true, name: "idx_class_student_unique"

    # =====================================================
    # MODULES & UNITS
    # =====================================================

    create_table :learning_modules do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :learning_modules, :name, unique: true

    create_table :units do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :units, :name, unique: true

    create_table :module_units do |t|
      t.references :learning_module, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true

      t.timestamps
    end
    add_index :module_units, [ :learning_module_id, :unit_id ], unique: true, name: "idx_module_unit_unique"

    create_table :formation_plan_modules do |t|
      t.references :formation_plan, null: false, foreign_key: true
      t.references :learning_module, null: false, foreign_key: true

      t.timestamps
    end
    add_index :formation_plan_modules, [ :formation_plan_id, :learning_module_id ], unique: true, name: "idx_plan_module_unique"

    # =====================================================
    # ROOMS & LECTURES
    # =====================================================

    create_table :rooms do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :rooms, :name, unique: true

    create_table :lectures do |t|
      t.date :date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.references :room, null: false, foreign_key: true
      t.references :collaborator, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true

      t.timestamps
    end

    # =====================================================
    # GRADES
    # =====================================================

    create_table :grades do |t|
      t.decimal :value, precision: 3, scale: 1
      t.date :awarded_on
      t.references :student, null: false, foreign_key: true
      t.references :unit, null: false, foreign_key: true

      t.timestamps
    end
  end
end
