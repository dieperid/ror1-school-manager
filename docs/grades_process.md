# Grades Process

## Overview

Grades are attached to a `Unit` and a `Student`.

The application manages grades from the unit pages, not from a dedicated global grade list.

There are three practical perspectives in the current app:

1. Admins can review and manage all grades.
2. Deans can review and manage grades like admins, and can also generate student report cards.
3. Teaching collaborators can review and manage grades only for the units they teach, and only for eligible students.
4. Students can view only their own grades from their profile.

The intended hierarchy is:

- Admin
- Dean
- Other people

## Main Rules

- A grade belongs to exactly one `Student`.
- A grade belongs to exactly one `Unit`.
- A grade requires:
  - `student_id`
  - `unit_id`
  - `awarded_on`
  - `value`
- `value` must be numeric.
- `awarded_on` must be present.
- The combination of `student_id`, `unit_id`, and `awarded_on` must be unique.

This means the app does not allow two grades for the same student, same unit, and same date.

## Who Can Create Grades

### Admins

Admins can create grades for any unit and for any student.

Admin grade creation happens from:

- `/admin/units/:unit_id`
- `/admin/units/:unit_id/grades/new`

### Deans

Deans can create grades with the same scope as admins.

They use the same admin pages as admins.

### Teaching collaborators

Collaborators can create grades only if both conditions are true:

1. they teach the unit,
2. the selected student is eligible for that unit.

Collaborator grade creation happens from:

- `/units/:unit_id`
- `/units/:unit_id/grades/new`

### Students

Students cannot create grades.

### Guests and unauthorized accounts

Guests cannot access grade pages because authentication is required.

Collaborators who do not teach a unit cannot create grades for that unit.

## Who Can View Grades

### Admins

Admins can see:

- all grades listed on any admin unit page,
- any individual grade page,
- all grades recorded for a student from the admin person page.

The admin person page is read-oriented for grades: it shows the student's grades and links back to the relevant unit page for management.

### Deans

Deans can see the same grade data as admins.

They can also generate a report card for each student from the admin person page.

### Teaching collaborators

Teaching collaborators can see grades only for the units they teach.

Even inside a unit they teach, they only see grades for eligible students of that unit.

They can view:

- the unit page with its grade table,
- the individual grade page for visible grades.

They do not get the admin person links.

### Students

Students can see only their own grades on `/profile`.

They do not get grade management actions.

### Other collaborators

Collaborators who do not teach a given unit cannot view that unit's grades.

## Who Can Edit Grades

### Admins

Admins can edit any grade from the relevant admin unit page or grade page.

### Deans

Deans can edit grades with the same scope as admins.

### Teaching collaborators

Teaching collaborators can edit grades only when:

1. the grade belongs to a unit they teach,
2. the selected student is still eligible for that unit.

If a collaborator tries to assign a grade to a student outside the unit's eligible student set, the app rejects the change.

### Students

Students cannot edit grades.

## Who Can Delete Grades

### Admins

Admins can delete any grade.

### Deans

Deans can delete grades with the same scope as admins.

### Teaching collaborators

Teaching collaborators can delete grades only for units they teach and can access.

### Students

Students cannot delete grades.

## Eligibility Rules

Two internal rules decide grade access for collaborators.

### 1. What counts as a teaching collaborator for a unit

A collaborator is considered allowed on a unit when the unit has at least one lecture assigned to that collaborator.

In code, this is the `Unit.taught_by(collaborator)` scope.

### 2. What counts as an eligible student for a unit

A student is eligible for a unit when the student's school class belongs to a formation plan that includes a learning module containing that unit.

This is the rule used when collaborators:

- see the available student list,
- create a grade,
- update a grade,
- see grades on the unit page.

Admins and deans are not limited by this eligibility filter.

## Grade Lifecycle

### 1. Open a unit

The grade workflow starts from a unit page.

- Admins and deans use the admin unit pages.
- Teaching collaborators use the non-admin unit pages.

### 2. Create a grade

The user selects:

- the student,
- the awarded date,
- the numeric grade value.

If validation succeeds, the app redirects back to the unit page.

### 3. Review a grade

Each grade has a show page with:

- student,
- unit,
- awarded date,
- value.

From there, authorized users can edit or delete the grade.

### 4. Update a grade

The user can change:

- student,
- awarded date,
- value.

The same validation and eligibility rules still apply during update.

### 5. Delete a grade

Authorized users can delete a grade from the unit page or the grade detail page.

## Validation and Error Cases

The current implementation explicitly handles these cases:

- missing grade value: rejected
- non-numeric grade value: rejected
- missing awarded date: rejected
- duplicate grade for same student, unit, and date: rejected
- collaborator selecting a student outside the unit's eligible students: rejected
- collaborator trying to access a unit they do not teach: blocked and redirected away
- creating a grade when no eligible students are available for the unit: blocked and redirected back to the unit page

## Screens Involved

### Admin screens

- unit show page: review grades, create grade, open grade, edit grade, delete grade
- grade new page: create grade
- grade show page: review and delete grade
- grade edit page: update grade
- person show page: review a student's grades, jump to the relevant unit, and generate a report card

### Collaborator screens

- unit index: only units they teach
- unit show page: review visible grades and manage them
- grade new/show/edit pages for their accessible units

### Student screen

- profile page: read-only "My grades" section

## Relevant Files

Main implementation:

- `app/models/grade.rb`
- `app/models/unit.rb`
- `app/models/account.rb`
- `app/models/collaborator.rb`
- `app/controllers/admin/grades_controller.rb`
- `app/controllers/admin/people_controller.rb`
- `app/controllers/admin/units_controller.rb`
- `app/controllers/profiles_controller.rb`
- `app/views/admin/units/show.html.erb`
- `app/views/admin/grades/new.html.erb`
- `app/views/admin/grades/show.html.erb`
- `app/views/admin/grades/edit.html.erb`
- `app/views/admin/people/show.html.erb`
- `app/views/profiles/show.html.erb`
- `config/routes.rb`

Tests documenting the current behavior:

- `test/integration/admin_grades_flow_test.rb`
- `test/integration/dean_access_flow_test.rb`
- `test/integration/profile_flow_test.rb`
