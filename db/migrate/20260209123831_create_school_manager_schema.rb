class CreateSchoolManagerSchema < ActiveRecord::Migration[8.1]
  def change
    # Persons
    unless table_exists?(:persons)
      create_table :persons do |t|
        t.string :avs_number, null: false
        t.string :last_name, null: false
        t.string :first_name, null: false
        t.string :phone_number
        t.string :email
        t.string :street
        t.integer :postal_code
        t.string :city
        t.integer :street_number
        t.date :birth_date

        t.timestamps
      end
    end
    add_index :persons, :avs_number, unique: true unless index_exists?(:persons, :avs_number)

    # Accounts
    unless table_exists?(:accounts)
      create_table :accounts do |t|
        t.string :email, null: false
        t.string :password_hash, null: false
        t.boolean :account_status, null: false

        t.timestamps
      end
    end
    add_index :accounts, :email, unique: true unless index_exists?(:accounts, :email)

    # Collaborator Roles
    unless table_exists?(:collaborator_roles)
      create_table :collaborator_roles do |t|
        t.string :name, null: false

        t.timestamps
      end
    end

    # Leaving Reasons
    unless table_exists?(:leaving_reasons)
      create_table :leaving_reasons do |t|
        t.string :title, null: false

        t.timestamps
      end
    end

    # Domains
    unless table_exists?(:domains)
      create_table :domains do |t|
        t.string :name, null: false

        t.timestamps
      end
    end

    # Training Plans
    unless table_exists?(:training_plans)
      create_table :training_plans do |t|
        t.string :name, null: false

        t.timestamps
      end
    end

    # Modules
    unless table_exists?(:modules)
      create_table :modules do |t|
        t.string :name, null: false

        t.timestamps
      end
    end

    # Units
    unless table_exists?(:units)
      create_table :units do |t|
        t.string :name, null: false
        t.references :module, null: false, foreign_key: { to_table: :modules }

        t.timestamps
      end
    end

    # Rooms
    unless table_exists?(:rooms)
      create_table :rooms do |t|
        t.string :name, null: false

        t.timestamps
      end
    end

    # Collaborators
    unless table_exists?(:collaborators)
      create_table :collaborators do |t|
        t.date :contract_start
        t.date :contract_end
        t.boolean :is_teacher
        t.references :person, null: false, foreign_key: { to_table: :persons }

        t.timestamps
      end
    end

    # Classes
    unless table_exists?(:classes)
      create_table :classes do |t|
        t.string :name, null: false
        t.references :domain, null: false, foreign_key: true
        t.references :training_plan, null: false, foreign_key: true
        t.references :responsible_collaborator, null: false,
                     foreign_key: { to_table: :collaborators }

        t.timestamps
      end
    end
    add_index :classes, :name, unique: true unless index_exists?(:classes, :name)

    # Students
    unless table_exists?(:students)
      create_table :students do |t|
        t.date :admission_date
        t.date :leaving_date
        t.boolean :repeat_year
        t.references :person, null: false, foreign_key: { to_table: :persons }
        t.references :leaving_reason, foreign_key: { to_table: :leaving_reasons }
        t.references :account, null: false, foreign_key: { to_table: :accounts }
        t.references :class, null: false, foreign_key: { to_table: :classes }

        t.timestamps
      end
    end
    add_index :students, :person_id, unique: true unless index_exists?(:students, :person_id)
    add_index :students, :account_id, unique: true unless index_exists?(:students, :account_id)

    # Schedules
    unless table_exists?(:schedules)
      create_table :schedules do |t|
        t.date :day, null: false
        t.time :start_time, null: false
        t.time :end_time, null: false
        t.references :class, foreign_key: { to_table: :classes }
        t.references :collaborator, null: false, foreign_key: true

        t.timestamps
      end
    end

    # Grades
    unless table_exists?(:grades)
      create_table :grades do |t|
        t.decimal :grade_value, precision: 2, scale: 1, null: false
        t.date :test_date, null: false
        t.references :student, null: false, foreign_key: true
        t.references :unit, null: false, foreign_key: true

        t.timestamps
      end
    end

    # Collaborators roles assignment (N-N)
    unless table_exists?(:collaborator_role_assignments)
      create_table :collaborator_role_assignments, id: false do |t|
        t.references :collaborator, null: false, foreign_key: true
        t.references :collaborator_role, null: false, foreign_key: true
      end
    end
    add_index :collaborator_role_assignments,
              %i[collaborator_id collaborator_role_id],
              unique: true,
              name: 'index_cra_on_collaborator_and_role' \
                unless index_exists?(:collaborator_role_assignments,
                                     %i[collaborator_id collaborator_role_id],
                                     name: 'index_cra_on_collaborator_and_role')

    # Training Plans - Modules (N-N)
    unless table_exists?(:training_plan_modules)
      create_table :training_plan_modules, id: false do |t|
        t.references :training_plan, null: false, foreign_key: true
        t.references :module, null: false, foreign_key: { to_table: :modules }
      end
    end
    add_index :training_plan_modules,
              %i[training_plan_id module_id],
              unique: true,
              name: 'index_tpm_on_training_plan_and_module' \
                unless index_exists?(:training_plan_modules,
                                     %i[training_plan_id module_id],
                                     name: 'index_tpm_on_training_plan_and_module')

    # Schedules - Units (N-N)
    unless table_exists?(:schedule_units)
      create_table :schedule_units, id: false do |t|
        t.references :schedule, null: false, foreign_key: true
        t.references :unit, null: false, foreign_key: true
      end
    end
    add_index :schedule_units,
              %i[schedule_id unit_id],
              unique: true,
              name: 'index_schedule_units_on_schedule_and_unit' \
                unless index_exists?(:schedule_units,
                                     %i[schedule_id unit_id],
                                     name: 'index_schedule_units_on_schedule_and_unit')

    # Schedules - Rooms (N-N)
    unless table_exists?(:schedule_rooms)
      create_table :schedule_rooms, id: false do |t|
        t.references :schedule, null: false, foreign_key: true
        t.references :room, null: false, foreign_key: true
      end
    end
    add_index :schedule_rooms,
              %i[schedule_id room_id],
              unique: true,
              name: 'index_schedule_rooms_on_schedule_and_room' \
                unless index_exists?(:schedule_rooms,
                                     %i[schedule_id room_id],
                                     name: 'index_schedule_rooms_on_schedule_and_room')
  end
end
