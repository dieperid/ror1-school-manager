module Seeds
  module_function

  DEV_PASSWORD = ENV.fetch("DEV_ACCOUNT_PASSWORD", "pa$$w0rd")

  def upsert_person(avs_number:, **attributes)
    person = Person.find_or_initialize_by(avs_number: avs_number)
    person.assign_attributes(attributes)
    person.save!
    person
  end

  def upsert_account(person:, email:, admin:, enabled:, password:, reset_password: false)
    account = person.account || person.build_account
    account.assign_attributes(email: email, admin: admin, enabled: enabled)

    if account.new_record? || reset_password
      account.password = password
      account.password_confirmation = password
    end

    account.save!
    account
  end

  def upsert_collaborator(person:, contract_begin:, contract_end: nil)
    collaborator = person.collaborator || person.build_collaborator
    collaborator.assign_attributes(contract_begin: contract_begin, contract_end: contract_end)
    collaborator.save!
    collaborator
  end

  def upsert_student(person:, admission_date:, repeating_grade:, departure_reason: nil, departure_date: nil)
    student = person.student || person.build_student
    student.assign_attributes(
      admission_date: admission_date,
      departure_date: departure_date,
      departure_reason: departure_reason,
      repeating_grade: repeating_grade
    )
    student.save!
    student
  end

  def upsert_lecture(date:, start_time:, end_time:, room:, collaborator:, unit:)
    lecture = Lecture.find_or_initialize_by(date: date, start_time: start_time, room: room)
    lecture.assign_attributes(end_time: end_time, collaborator: collaborator, unit: unit)
    lecture.save!
    lecture
  end

  def upsert_grade(student:, unit:, awarded_on:, value:)
    grade = Grade.find_or_initialize_by(student: student, unit: unit, awarded_on: awarded_on)
    grade.assign_attributes(value: value)
    grade.save!
    grade
  end
end
