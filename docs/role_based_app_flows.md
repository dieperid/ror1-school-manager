# Role-Based App Flows

## Overview

This document describes the main end-user flows of the application from a technical point of view.

It focuses on three roles:

- Student
- Collaborator
- Dean

The current access hierarchy is:

1. Admin
2. Dean
3. Other authenticated users

Technical note:

- `Admin` is driven by the `accounts.admin` flag.
- `Dean` is a standard account linked to a collaborator whose collaborator role title is `Dean`.
- Deans use the admin area like admins for most academic flows, but they are restricted from deleting or demoting admin accounts.

## Main Entry Points

### Student

- `/profile`
- `/schedule`

### Collaborator

- `/profile`
- `/schedule`
- `/units`
- `/units/:id`
- `/units/:unit_id/grades/new`

### Dean

- `/admin/people`
- `/admin/formation_plans`
- `/admin/school_classes`
- `/admin/learning_modules`
- `/admin/units`
- `/admin/people/:id/report_card`

## Student Flow

### Goal

A student signs in, reviews their profile, sees their schedule, and checks their grades.

### What the app does

- After sign-in, a non-admin, non-dean account lands on `/profile`.
- The profile page loads:
  - person details,
  - weekly schedule preview,
  - grade list if the person has a student record.
- The full calendar is available from `/schedule`.
- Student grades are read-only.

### Sequence Diagram

```mermaid
sequenceDiagram
    actor Student
    participant Browser
    participant App as Rails App
    participant ProfileCtrl as ProfilesController
    participant ScheduleCtrl as SchedulesController
    participant Person as Person/Student
    participant Lecture as Lecture/Unit
    participant Grade as Grade

    Student->>Browser: Sign in
    Browser->>App: POST /accounts/sign_in
    App-->>Browser: Redirect to /profile

    Student->>Browser: Open profile
    Browser->>ProfileCtrl: GET /profile
    ProfileCtrl->>Person: load current person and student
    ProfileCtrl->>Lecture: load weekly lectures for current student's formation plans
    ProfileCtrl->>Grade: load student grades ordered by awarded_on desc
    ProfileCtrl-->>Browser: render profile with personal data, weekly schedule, grades

    Student->>Browser: Open full calendar
    Browser->>ScheduleCtrl: GET /schedule
    ScheduleCtrl->>Lecture: load visible month lectures for current student
    ScheduleCtrl-->>Browser: render schedule calendar
```

### Relevant Files

- `app/controllers/profiles_controller.rb`
- `app/controllers/schedules_controller.rb`
- `app/models/student.rb`
- `app/views/profiles/show.html.erb`

## Collaborator Flow

### Goal

A collaborator signs in, reviews their schedule, opens the units they teach, and records grades for eligible students.

### What the app does

- A collaborator signs in and lands on `/profile`.
- The profile page shows:
  - collaborator role details,
  - weekly schedule preview.
- The collaborator can open `/schedule` for the monthly view.
- The collaborator can open `/units` and only sees units taught through their lectures.
- From a unit page, the collaborator can:
  - review visible grades,
  - create a new grade,
  - edit or delete grades for that unit.

Important access rules:

- A collaborator can only manage grades for units returned by `Unit.taught_by(current_collaborator)`.
- A collaborator can only grade students returned by `@unit.eligible_students`.
- If the student does not belong to a formation plan that includes the unit, the grade is rejected.

### Sequence Diagram

```mermaid
sequenceDiagram
    actor Collaborator
    participant Browser
    participant App as Rails App
    participant ProfileCtrl as ProfilesController
    participant UnitsCtrl as Admin::UnitsController
    participant GradesCtrl as Admin::GradesController
    participant Unit as Unit
    participant Student as Student
    participant Grade as Grade

    Collaborator->>Browser: Sign in
    Browser->>App: POST /accounts/sign_in
    App-->>Browser: Redirect to /profile

    Collaborator->>Browser: Open units
    Browser->>UnitsCtrl: GET /units
    UnitsCtrl->>Unit: load Unit.taught_by(current_collaborator)
    UnitsCtrl-->>Browser: render accessible units only

    Collaborator->>Browser: Open one unit
    Browser->>UnitsCtrl: GET /units/:id
    UnitsCtrl->>Unit: verify collaborator teaches the unit
    UnitsCtrl->>Grade: load visible grades for eligible students
    UnitsCtrl-->>Browser: render unit page with grade actions

    Collaborator->>Browser: Create grade
    Browser->>GradesCtrl: GET /units/:unit_id/grades/new
    GradesCtrl->>Student: load unit.eligible_students
    GradesCtrl-->>Browser: render grade form

    Collaborator->>Browser: Submit grade
    Browser->>GradesCtrl: POST /units/:unit_id/grades
    GradesCtrl->>Unit: verify current collaborator teaches the unit
    GradesCtrl->>Student: verify selected student is eligible
    GradesCtrl->>Grade: validate uniqueness and numeric value
    Grade-->>GradesCtrl: save
    GradesCtrl-->>Browser: redirect to /units/:id
```

### Relevant Files

- `app/controllers/profiles_controller.rb`
- `app/controllers/schedules_controller.rb`
- `app/controllers/admin/units_controller.rb`
- `app/controllers/admin/grades_controller.rb`
- `app/models/unit.rb`
- `app/views/admin/units/index.html.erb`
- `app/views/admin/units/show.html.erb`

## Dean Flow

### Goal

A Dean manages the academic structure and can generate report cards for students.

### What the app does

- A Dean signs in and is redirected to the management area.
- The Dean can use admin pages for:
  - people,
  - formation plans,
  - school classes,
  - learning modules,
  - units,
  - grades,
  - lectures,
  - report cards.

Typical academic setup flow:

1. Create a formation plan.
2. Create a school class and assign it to that formation plan.
3. Assign a responsible collaborator to the class.
4. Enroll students in the class.
5. Create or reuse units.
6. Create a learning module.
7. Link the learning module to the formation plan.
8. Link units to the learning module.
9. Create lectures for collaborators on those units.
10. Later, review student grades and generate report cards.

Important access rules:

- Deans share most admin pages through the same `admin/*` routes.
- Deans can generate student report cards from the admin person page.
- Deans cannot:
  - delete an admin account,
  - delete a person linked to an admin account,
  - disable or remove admin access from an admin account.

### Sequence Diagram

```mermaid
sequenceDiagram
    actor Dean
    participant Browser
    participant App as Rails App
    participant FP as Admin::FormationPlansController
    participant SC as Admin::SchoolClassesController
    participant LM as Admin::LearningModulesController
    participant U as Admin::UnitsController
    participant P as Admin::PeopleController
    participant Models as FormationPlan/SchoolClass/LearningModule/Unit/Grade

    Dean->>Browser: Sign in
    Browser->>App: POST /accounts/sign_in
    App-->>Browser: Redirect to /admin/people

    Dean->>Browser: Create formation plan
    Browser->>FP: POST /admin/formation_plans
    FP->>Models: save FormationPlan
    FP-->>Browser: redirect to formation plan page

    Dean->>Browser: Create school class for formation plan
    Browser->>SC: POST /admin/school_classes
    SC->>Models: save SchoolClass with formation_plan_id
    SC->>Models: save class enrollments for selected students
    SC-->>Browser: redirect to school class page

    Dean->>Browser: Create learning module
    Browser->>LM: POST /admin/learning_modules
    LM->>Models: save LearningModule
    LM->>Models: attach formation plans and units
    LM-->>Browser: redirect to learning module page

    Dean->>Browser: Review unit and grade data
    Browser->>U: GET /admin/units/:id
    U->>Models: load lectures, linked modules, grades
    U-->>Browser: render unit management page

    Dean->>Browser: Generate student report card
    Browser->>P: GET /admin/people/:id/report_card
    P->>Models: load student, grades, school classes, formation plans
    P-->>Browser: download report_card.txt
```

### Relevant Files

- `app/controllers/application_controller.rb`
- `app/controllers/admin/base_controller.rb`
- `app/controllers/admin/formation_plans_controller.rb`
- `app/controllers/admin/school_classes_controller.rb`
- `app/controllers/admin/learning_modules_controller.rb`
- `app/controllers/admin/units_controller.rb`
- `app/controllers/admin/people_controller.rb`
- `app/models/account.rb`
- `app/models/collaborator.rb`
- `app/views/admin/formation_plans/show.html.erb`
- `app/views/admin/school_classes/_form.html.erb`
- `app/views/admin/learning_modules/_form.html.erb`
- `app/views/admin/people/show.html.erb`

## Cross-Role Dependency Notes

These flows are connected by data dependencies:

- Students only see lectures that match the formation plans of their enrolled school classes.
- Collaborators only manage grades for units they teach through lectures.
- A unit becomes grade-relevant for a student only when:
  - the unit is linked to a learning module,
  - the learning module is linked to a formation plan,
  - the student belongs to a school class using that formation plan.
- Report cards depend on the grades already recorded for the student's units.

## Suggested Reading Order

If you want to understand the app progressively, this order works well:

1. `docs/authentication_and_invitation_flow.md`
2. `docs/grades_process.md`
3. this document
