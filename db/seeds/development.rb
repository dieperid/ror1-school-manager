puts "Seeding development sample data..."

departure_reason_titles = [
  "Graduation",
  "Internship",
  "Transfer",
  "Apprenticeship",
  "Exchange Program",
  "Medical Leave",
  "Career Change",
  "Personal Leave",
  "Employment Opportunity",
  "Relocation"
]

departure_reasons = departure_reason_titles.index_with do |title|
  DepartureReason.find_or_create_by!(title: title)
end

collaborator_role_titles = [
  "Dean",
  "Teacher",
  "Mentor",
  "Coordinator",
  "Accountant",
  "Coach",
  "Supervisor",
  "Advisor",
  "Program Lead"
]

collaborator_roles = collaborator_role_titles.index_with do |title|
  CollaboratorRole.find_or_create_by!(title: title)
end

module_unit_names = {
  "Web Fundamentals" => [ "HTML & CSS", "Frontend Layouts" ],
  "Programming Foundations" => [ "Ruby Basics", "Databases" ],
  "Finance Core" => [ "Accounting Basics", "Spreadsheets" ],
  "Data Literacy" => [ "Statistics Basics", "Data Visualization" ],
  "Project Delivery" => [ "Agile Methods", "Project Planning" ],
  "Communication Skills" => [ "Professional Writing", "Presentation Skills" ],
  "Networks & Security" => [ "Networking Basics", "Cybersecurity Basics" ],
  "UX Foundations" => [ "User Research", "Interface Design" ],
  "Business Law" => [ "Contract Law", "Compliance Basics" ],
  "Office Automation" => [ "Excel Automation", "Document Templates" ],
  "Systems Analysis" => [ "Requirements Gathering", "Process Modeling" ],
  "Customer Relations" => [ "Client Communication", "Service Excellence" ]
}

plan_definitions = [
  {
    name: "Informatics",
    code: "INF",
    modules: [ "Web Fundamentals", "Programming Foundations", "Data Literacy", "Networks & Security", "Systems Analysis" ]
  },
  {
    name: "Business Administration",
    code: "BUS",
    modules: [ "Finance Core", "Office Automation", "Business Law", "Communication Skills", "Project Delivery" ]
  },
  {
    name: "Digital Media",
    code: "MED",
    modules: [ "Web Fundamentals", "UX Foundations", "Communication Skills", "Project Delivery" ]
  },
  {
    name: "Healthcare Administration",
    code: "HEA",
    modules: [ "Office Automation", "Customer Relations", "Business Law", "Data Literacy" ]
  },
  {
    name: "Hospitality Operations",
    code: "HOS",
    modules: [ "Customer Relations", "Communication Skills", "Office Automation", "Project Delivery" ]
  },
  {
    name: "Engineering Prep",
    code: "ENG",
    modules: [ "Programming Foundations", "Data Literacy", "Project Delivery", "Systems Analysis" ]
  }
]

formation_plans = plan_definitions.to_h do |definition|
  [ definition[:name], FormationPlan.find_or_create_by!(name: definition[:name]) ]
end

learning_modules = module_unit_names.keys.index_with do |name|
  LearningModule.find_or_create_by!(name: name)
end

units = module_unit_names.values.flatten.uniq.index_with do |name|
  Unit.find_or_create_by!(name: name)
end

module_unit_names.each do |module_name, unit_names|
  learning_module = learning_modules.fetch(module_name)
  unit_names.each do |unit_name|
    ModuleUnit.find_or_create_by!(learning_module: learning_module, unit: units.fetch(unit_name))
  end
end

plan_definitions.each do |definition|
  formation_plan = formation_plans.fetch(definition[:name])
  definition[:modules].each do |module_name|
    FormationPlanModule.find_or_create_by!(
      formation_plan: formation_plan,
      learning_module: learning_modules.fetch(module_name)
    )
  end
end

room_names = [
  "Lab A",
  "Lab B",
  "Room B12",
  "Room C21",
  "Finance Room",
  "Innovation Hub",
  "Design Studio",
  "Library 2",
  "Workshop East",
  "Workshop West",
  "Seminar 3",
  "Seminar 4"
]

rooms = room_names.index_with do |name|
  Room.find_or_create_by!(name: name)
end

city_profiles = [
  { city: "Lausanne", postal_code: "1004", street: "Rue du Lac" },
  { city: "Geneva", postal_code: "1201", street: "Avenue Centrale" },
  { city: "Neuchatel", postal_code: "2000", street: "Rue Haute" },
  { city: "Renens", postal_code: "1020", street: "Chemin des Ecoles" },
  { city: "Morges", postal_code: "1110", street: "Route du Campus" },
  { city: "Vevey", postal_code: "1800", street: "Rue du Port" },
  { city: "Fribourg", postal_code: "1700", street: "Route de la Gare" },
  { city: "Yverdon", postal_code: "1400", street: "Avenue des Sciences" },
  { city: "Sion", postal_code: "1950", street: "Rue des Alpes" },
  { city: "Biel", postal_code: "2502", street: "Rue du College" }
]

build_person_attributes = lambda do |avs_number:, first_name:, last_name:, birth_date:, profile_index:, phone_prefix:|
  location = city_profiles.fetch(profile_index % city_profiles.length)

  {
    avs_number: avs_number,
    first_name: first_name,
    last_name: last_name,
    birth_date: birth_date,
    city: location.fetch(:city),
    postal_code: location.fetch(:postal_code),
    street: location.fetch(:street),
    street_number: (profile_index % 60) + 1,
    phone_number: format("%s%07d", phone_prefix, profile_index + 1)
  }
end

manual_collaborators_by_plan = {
  "Informatics" => [
    {
      key: "dana_dean",
      avs_number: "756.1000.0000.08",
      first_name: "Dana",
      last_name: "Dean",
      birth_date: Date.new(1984, 1, 15),
      contract_begin: Date.new(2018, 8, 1),
      roles: [ "Dean", "Program Lead" ],
      email: "dean@example.com"
    },
    {
      key: "alice_mentor",
      avs_number: "756.1000.0000.01",
      first_name: "Alice",
      last_name: "Mentor",
      birth_date: Date.new(1987, 3, 12),
      contract_begin: Date.new(2020, 8, 1),
      roles: [ "Teacher", "Mentor" ],
      email: "teacher@example.com"
    },
    {
      key: "claire_coordination",
      avs_number: "756.1000.0000.03",
      first_name: "Claire",
      last_name: "Coordination",
      birth_date: Date.new(1991, 6, 21),
      contract_begin: Date.new(2021, 8, 1),
      roles: [ "Teacher", "Coordinator" ],
      email: "claire.coordination@example.com"
    }
  ],
  "Business Administration" => [
    {
      key: "bruno_finance",
      avs_number: "756.1000.0000.02",
      first_name: "Bruno",
      last_name: "Finance",
      birth_date: Date.new(1983, 11, 8),
      contract_begin: Date.new(2019, 8, 1),
      roles: [ "Teacher", "Accountant" ],
      email: "bruno.finance@example.com"
    }
  ]
}

generated_collaborator_names = [
  [ "Daniel", "Perrin" ],
  [ "Emma", "Keller" ],
  [ "Felix", "Martin" ],
  [ "Giulia", "Rossi" ],
  [ "Hugo", "Favre" ],
  [ "Iris", "Weber" ],
  [ "Jonas", "Muller" ],
  [ "Kelly", "Schmid" ],
  [ "Liam", "Rey" ],
  [ "Manon", "Piguet" ],
  [ "Noe", "Berger" ],
  [ "Olivia", "Aubert" ],
  [ "Paolo", "Bianchi" ],
  [ "Quentin", "Morel" ],
  [ "Romy", "Chevalier" ],
  [ "Sofia", "Bonnet" ],
  [ "Theo", "Suter" ],
  [ "Ugo", "Girard" ],
  [ "Valeria", "Mercier" ],
  [ "Yann", "Dubois" ],
  [ "Zoe", "Lombard" ]
]

secondary_role_titles = collaborator_role_titles - [ "Teacher" ]
plan_unit_names = plan_definitions.to_h do |definition|
  [ definition[:name], definition[:modules].flat_map { |module_name| module_unit_names.fetch(module_name) }.uniq ]
end

collaborator_blueprints = []

plan_definitions.each_with_index do |definition, plan_index|
  plan_collaborators = Array(manual_collaborators_by_plan[definition[:name]]).map(&:dup)

  while plan_collaborators.length < 4
    first_name, last_name = generated_collaborator_names.shift
    position = plan_collaborators.length

    plan_collaborators << {
      key: "#{definition[:code].downcase}_collaborator_#{position + 1}",
      first_name: first_name,
      last_name: last_name,
      birth_date: Date.new(1980 + ((plan_index + position) % 12), ((position * 3) % 12) + 1, ((plan_index + position) % 27) + 1),
      contract_begin: Date.new(2017 + ((plan_index + position) % 7), 8, 1),
      roles: [ "Teacher", secondary_role_titles[(plan_index + position) % secondary_role_titles.length] ],
      email: "#{first_name.downcase}.#{last_name.downcase}.#{definition[:code].downcase}@example.com"
    }
  end

  plan_collaborators.each_with_index do |blueprint, position|
    profile_index = plan_index * 10 + position

    collaborator_blueprints << blueprint.merge(
      plan_name: definition[:name],
      unit_names: plan_unit_names.fetch(definition[:name]).rotate(position * 2).take(4),
      person_attributes: build_person_attributes.call(
        avs_number: blueprint[:avs_number] || format("756.3000.0000.%02d", collaborator_blueprints.length + 1),
        first_name: blueprint[:first_name],
        last_name: blueprint[:last_name],
        birth_date: blueprint[:birth_date],
        profile_index: profile_index,
        phone_prefix: "079"
      )
    )
  end
end

manual_students_by_plan = {
  "Informatics" => [
    {
      key: "sam_student",
      avs_number: "756.1000.0000.04",
      first_name: "Sam",
      last_name: "Student",
      birth_date: Date.new(2006, 2, 14),
      admission_date: Date.new(2024, 8, 1),
      repeating_grade: false,
      email: "student@example.com"
    },
    {
      key: "tina_trainee",
      avs_number: "756.1000.0000.05",
      first_name: "Tina",
      last_name: "Trainee",
      birth_date: Date.new(2005, 9, 1),
      admission_date: Date.new(2024, 8, 1),
      repeating_grade: false,
      email: "tina.trainee@example.com"
    }
  ],
  "Business Administration" => [
    {
      key: "marc_moved",
      avs_number: "756.1000.0000.06",
      first_name: "Marc",
      last_name: "Moved",
      birth_date: Date.new(2004, 5, 30),
      admission_date: Date.new(2023, 8, 1),
      departure_date: Date.new(2025, 6, 30),
      departure_reason_title: "Transfer",
      repeating_grade: true,
      email: "marc.moved@example.com"
    }
  ]
}

generated_student_names = [
  [ "Amina", "Lopez" ],
  [ "Bastien", "Favre" ],
  [ "Chloe", "Martin" ],
  [ "Diego", "Perez" ],
  [ "Elena", "Garcia" ],
  [ "Farah", "Dubois" ],
  [ "Gabriel", "Rochat" ],
  [ "Hana", "Meyer" ],
  [ "Ilan", "Caruso" ],
  [ "Jade", "Perrin" ],
  [ "Karim", "Aubry" ],
  [ "Lina", "Keller" ],
  [ "Mehdi", "Rossi" ],
  [ "Nina", "Moret" ],
  [ "Omar", "Costa" ],
  [ "Pauline", "Blanc" ],
  [ "Quentin", "Monnier" ],
  [ "Rania", "Suter" ],
  [ "Sasha", "Brunner" ],
  [ "Theo", "Girard" ],
  [ "Uma", "Weber" ],
  [ "Victor", "Simon" ],
  [ "Wafa", "Bernard" ],
  [ "Xavier", "Meyer" ],
  [ "Yasmine", "Costa" ],
  [ "Zakaria", "Pahud" ],
  [ "Lea", "Caron" ]
]

student_blueprints = []

plan_definitions.each_with_index do |definition, plan_index|
  plan_students = Array(manual_students_by_plan[definition[:name]]).map(&:dup)

  while plan_students.length < 5
    first_name, last_name = generated_student_names.shift
    position = plan_students.length
    departed = position == 4 && plan_index.odd?

    plan_students << {
      key: "#{definition[:code].downcase}_student_#{position + 1}",
      first_name: first_name,
      last_name: last_name,
      birth_date: Date.new(2004 + ((plan_index + position) % 4), ((position * 2) % 12) + 1, ((plan_index + position * 2) % 27) + 1),
      admission_date: Date.new(2022 + (position % 3), 8, 1),
      departure_date: departed ? Date.new(2025, 6, 30) - plan_index.weeks : nil,
      departure_reason_title: departed ? departure_reason_titles.rotate(plan_index).first : nil,
      repeating_grade: position % 4 == 0,
      email: "#{first_name.downcase}.#{last_name.downcase}.#{definition[:code].downcase}@example.com"
    }
  end

  plan_students.each_with_index do |blueprint, position|
    profile_index = 100 + plan_index * 10 + position

    student_blueprints << blueprint.merge(
      plan_name: definition[:name],
      person_attributes: build_person_attributes.call(
        avs_number: blueprint[:avs_number] || format("756.4000.0000.%02d", student_blueprints.length + 1),
        first_name: blueprint[:first_name],
        last_name: blueprint[:last_name],
        birth_date: blueprint[:birth_date],
        profile_index: profile_index,
        phone_prefix: "078"
      )
    )
  end
end

unlinked_people_blueprints = [
  {
    key: "nora_unlinked",
    avs_number: "756.1000.0000.07",
    first_name: "Nora",
    last_name: "Unlinked",
    birth_date: Date.new(1998, 12, 10)
  },
  {
    key: "unlinked_2",
    first_name: "Oscar",
    last_name: "Villard",
    birth_date: Date.new(1994, 4, 3)
  },
  {
    key: "unlinked_3",
    first_name: "Maya",
    last_name: "Robert",
    birth_date: Date.new(1992, 7, 18)
  },
  {
    key: "unlinked_4",
    first_name: "Cedric",
    last_name: "Maillard",
    birth_date: Date.new(1990, 1, 24)
  },
  {
    key: "unlinked_5",
    first_name: "Ines",
    last_name: "Pasquier",
    birth_date: Date.new(1997, 9, 9)
  },
  {
    key: "unlinked_6",
    first_name: "Loris",
    last_name: "Ruffieux",
    birth_date: Date.new(1989, 6, 15)
  },
  {
    key: "unlinked_7",
    first_name: "Salome",
    last_name: "Jacot",
    birth_date: Date.new(1995, 10, 6)
  },
  {
    key: "unlinked_8",
    first_name: "Nicolas",
    last_name: "Perret",
    birth_date: Date.new(1993, 2, 27)
  }
].each_with_index.map do |blueprint, index|
  blueprint.merge(
    person_attributes: build_person_attributes.call(
      avs_number: blueprint[:avs_number] || format("756.5000.0000.%02d", index + 1),
      first_name: blueprint[:first_name],
      last_name: blueprint[:last_name],
      birth_date: blueprint[:birth_date],
      profile_index: 200 + index,
      phone_prefix: "077"
    )
  )
end

people_blueprints = collaborator_blueprints + student_blueprints + unlinked_people_blueprints

seed_people = people_blueprints.to_h do |blueprint|
  [ blueprint[:key], Seeds.upsert_person(**blueprint[:person_attributes]) ]
end

collaborator_blueprints_by_key = collaborator_blueprints.index_by { |blueprint| blueprint[:key] }
student_blueprints_by_key = student_blueprints.index_by { |blueprint| blueprint[:key] }

collaborators = collaborator_blueprints.to_h do |blueprint|
  collaborator = Seeds.upsert_collaborator(
    person: seed_people.fetch(blueprint[:key]),
    contract_begin: blueprint[:contract_begin]
  )
  collaborator.collaborator_roles = blueprint[:roles].map { |title| collaborator_roles.fetch(title) }
  collaborator.save!

  Seeds.upsert_account(
    person: seed_people.fetch(blueprint[:key]),
    email: blueprint[:email],
    admin: false,
    enabled: true,
    password: Seeds::DEV_PASSWORD,
    reset_password: true
  )

  [ blueprint[:key], collaborator ]
end

students = student_blueprints.to_h do |blueprint|
  student = Seeds.upsert_student(
    person: seed_people.fetch(blueprint[:key]),
    admission_date: blueprint[:admission_date],
    repeating_grade: blueprint[:repeating_grade],
    departure_date: blueprint[:departure_date],
    departure_reason: blueprint[:departure_reason_title] ? departure_reasons.fetch(blueprint[:departure_reason_title]) : nil
  )

  Seeds.upsert_account(
    person: seed_people.fetch(blueprint[:key]),
    email: blueprint[:email],
    admin: false,
    enabled: true,
    password: Seeds::DEV_PASSWORD,
    reset_password: true
  )

  [ blueprint[:key], student ]
end

collaborator_keys_by_plan = collaborator_blueprints.group_by { |blueprint| blueprint[:plan_name] }.transform_values do |plan_blueprints|
  plan_blueprints.map { |blueprint| blueprint[:key] }
end

plan_codes = plan_definitions.to_h do |definition|
  [ definition[:name], definition[:code] ]
end

school_class_blueprints = plan_definitions.flat_map do |definition|
  responsible_keys = collaborator_keys_by_plan.fetch(definition[:name])

  [
    {
      name: "#{definition[:code]}-24A",
      plan_name: definition[:name],
      responsible_key: responsible_keys[0]
    },
    {
      name: "#{definition[:code]}-25B",
      plan_name: definition[:name],
      responsible_key: responsible_keys[1]
    }
  ]
end

school_classes = school_class_blueprints.to_h do |blueprint|
  school_class = SchoolClass.find_or_initialize_by(name: blueprint[:name])
  school_class.assign_attributes(
    formation_plan: formation_plans.fetch(blueprint[:plan_name]),
    responsible_collaborator: collaborators.fetch(blueprint[:responsible_key])
  )
  school_class.save!

  [ blueprint[:name], school_class ]
end

student_positions_by_plan = Hash.new(0)

student_blueprints.each do |blueprint|
  position = student_positions_by_plan[blueprint[:plan_name]]
  student_positions_by_plan[blueprint[:plan_name]] += 1

  class_suffix = position.even? ? "24A" : "25B"
  class_name = "#{plan_codes.fetch(blueprint[:plan_name])}-#{class_suffix}"

  ClassEnrollment.find_or_create_by!(
    school_class: school_classes.fetch(class_name),
    student: students.fetch(blueprint[:key])
  )
end

time_slots = [
  [ "08:15", "10:00" ],
  [ "10:15", "12:00" ],
  [ "13:15", "15:00" ],
  [ "15:15", "17:00" ]
]

room_values = rooms.values
lecture_anchor = Date.current.beginning_of_month - 14.days
used_lecture_slots = {}
lecture_records = []

collaborator_blueprints.each_with_index do |blueprint, collaborator_index|
  6.times do |lecture_index|
    date = lecture_anchor + (lecture_index * 7).days + (collaborator_index % 6).days + (collaborator_index / 6).days
    start_time, end_time = time_slots[(collaborator_index + lecture_index) % time_slots.length]
    room_index = (collaborator_index * 3 + lecture_index) % room_values.length
    room = room_values.fetch(room_index)
    original_room_index = room_index

    loop do
      slot_key = [ date, start_time, room.id ]
      break unless used_lecture_slots.key?(slot_key)

      room_index = (room_index + 1) % room_values.length
      room = room_values.fetch(room_index)

      next unless room_index == original_room_index

      date += 1.day
    end

    used_lecture_slots[[ date, start_time, room.id ]] = true

    lecture_records << Seeds.upsert_lecture(
      date: date,
      start_time: start_time,
      end_time: end_time,
      room: room,
      collaborator: collaborators.fetch(blueprint[:key]),
      unit: units.fetch(blueprint[:unit_names][lecture_index % blueprint[:unit_names].length])
    )
  end
end

lectures_by_unit_name = lecture_records.group_by { |lecture| lecture.unit.name }

student_blueprints.each_with_index do |blueprint, student_index|
  grade_unit_names = plan_unit_names.fetch(blueprint[:plan_name]).rotate(student_index).take(4)

  grade_unit_names.each_with_index do |unit_name, grade_index|
    lecture_pool = lectures_by_unit_name.fetch(unit_name)
    lecture = lecture_pool.fetch((student_index + grade_index) % lecture_pool.length)
    awarded_on = lecture.date + (grade_index % 2).days

    if blueprint[:departure_date].present? && awarded_on > blueprint[:departure_date]
      awarded_on = blueprint[:departure_date] - (grade_index * 7).days
    end

    value = (3.8 + ((student_index * 4 + grade_index) % 20) * 0.1).round(1)

    Seeds.upsert_grade(
      student: students.fetch(blueprint[:key]),
      unit: units.fetch(unit_name),
      awarded_on: awarded_on,
      value: value
    )
  end
end

puts "Development sample data ready."
puts "Created #{collaborator_blueprints.size} collaborators, #{student_blueprints.size} students, #{school_class_blueprints.size} classes, #{lecture_records.size} lectures, and #{student_blueprints.size * 4} grades."
puts "Default development password: #{Seeds::DEV_PASSWORD}"
