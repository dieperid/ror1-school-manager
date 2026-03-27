# Application Architecture

## Overview

Ror1 School Manager is a server-rendered Rails application.

It uses:

- Rails controllers and ERB views for the web interface
- Devise for authentication
- Active Record for domain modeling and persistence
- MySQL as the main data store
- Hotwire for progressive enhancement

There is no separate frontend SPA and no separate API service in the current architecture.

## High-Level Architecture Diagram

```mermaid
flowchart TB
    Student([Student])
    Collaborator([Collaborator])
    Dean([Dean])
    Admin([Admin])

    Browser[Browser<br/>HTML + Turbo + Stimulus]

    subgraph RailsApp[Rails 8 Application]
        Router[Routes]

        subgraph WebLayer[Web Layer]
            Controllers[Controllers]
            Views[ERB Views]
            Helpers[Helpers]
        end

        subgraph AuthLayer[Access and Authentication]
            Devise[Devise Authentication]
            RoleChecks[Role and Access Rules<br/>Admin / Dean / Collaborator / Student]
        end

        subgraph DomainLayer[Domain Layer]
            PeopleDomain[People and Accounts<br/>Person / Account / Collaborator / Student / CollaboratorRole]
            AcademicDomain[Academic Structure<br/>FormationPlan / SchoolClass / LearningModule / Unit]
            TeachingDomain[Teaching Operations<br/>Lecture / Grade / Report Card]
        end

        subgraph Persistence[Persistence]
            ActiveRecord[Active Record Models]
        end
    end

    MySQL[(MySQL Database)]

    Docs[Docs and Seeds<br/>README / docs / db/seeds]

    Student --> Browser
    Collaborator --> Browser
    Dean --> Browser
    Admin --> Browser

    Browser --> Router
    Router --> Devise
    Router --> Controllers

    Controllers --> RoleChecks
    Controllers --> ActiveRecord
    Controllers --> Views
    Views --> Browser

    Devise --> RoleChecks
    RoleChecks --> Controllers

    ActiveRecord --> PeopleDomain
    ActiveRecord --> AcademicDomain
    ActiveRecord --> TeachingDomain
    ActiveRecord --> MySQL

    Docs --> RailsApp
```

## Main Layers

### 1. Users and browser

Users interact with the application through a browser.

The UI is rendered on the server with ERB templates and enhanced with:

- Turbo
- Stimulus
- Importmap-managed JavaScript

### 2. Routing and controllers

Rails routes dispatch requests to controllers.

Main controller areas:

- general authenticated pages
  - `ProfilesController`
  - `SchedulesController`
  - `DashboardController`
- management area
  - `Admin::*Controller`

The admin namespace is also used by Deans for most management flows.

### 3. Authentication and authorization

Authentication is handled by Devise through the `Account` model.

Authorization is currently a mix of:

- admin flag on `Account`
- dean detection through collaborator role title `Dean`
- collaborator-specific access rules
- student-specific self-service pages

Important access boundaries:

- Admins and Deans can access the management area
- Collaborators can access teaching-related non-admin flows
- Students can access self-service schedule and grade views

### 4. Domain model

The domain is organized around three main functional groups.

#### People and identity

- `Person`
- `Account`
- `Collaborator`
- `Student`
- `CollaboratorRole`
- `CollaboratorAssignment`

#### Academic structure

- `FormationPlan`
- `SchoolClass`
- `ClassEnrollment`
- `LearningModule`
- `FormationPlanModule`
- `Unit`
- `ModuleUnit`

#### Teaching and follow-up

- `Lecture`
- `Room`
- `Grade`

Report cards are currently generated from student data and grades through the people management flow.

## Domain Relationship Diagram

```mermaid
classDiagram
    class Person
    class Account
    class Collaborator
    class Student
    class CollaboratorRole
    class CollaboratorAssignment
    class FormationPlan
    class SchoolClass
    class ClassEnrollment
    class LearningModule
    class FormationPlanModule
    class Unit
    class ModuleUnit
    class Lecture
    class Room
    class Grade

    Person "1" --> "0..1" Account
    Person "1" --> "0..1" Collaborator
    Person "1" --> "0..1" Student

    Collaborator "1" --> "*" CollaboratorAssignment
    CollaboratorRole "1" --> "*" CollaboratorAssignment

    FormationPlan "1" --> "*" SchoolClass
    SchoolClass "1" --> "*" ClassEnrollment
    Student "1" --> "*" ClassEnrollment

    FormationPlan "1" --> "*" FormationPlanModule
    LearningModule "1" --> "*" FormationPlanModule

    LearningModule "1" --> "*" ModuleUnit
    Unit "1" --> "*" ModuleUnit

    Collaborator "1" --> "*" Lecture
    Unit "1" --> "*" Lecture
    Room "1" --> "*" Lecture

    Student "1" --> "*" Grade
    Unit "1" --> "*" Grade
```

## Typical Request Flow

```mermaid
sequenceDiagram
    actor User
    participant Browser
    participant Router
    participant Controller
    participant Auth as Devise + Access Rules
    participant Model as Active Record Models
    participant DB as MySQL
    participant View

    User->>Browser: Open page or submit form
    Browser->>Router: HTTP request
    Router->>Controller: Dispatch request
    Controller->>Auth: Authenticate and authorize
    Auth-->>Controller: Access granted or denied
    Controller->>Model: Query or persist domain data
    Model->>DB: SQL operations
    DB-->>Model: Records
    Model-->>Controller: Domain objects
    Controller->>View: Render page or file response
    View-->>Browser: HTML or download
```

## Persistence Model

The application stores its core business data in MySQL.

Main persisted areas:

- people and linked accounts
- collaborator and student role records
- formation plans and school classes
- learning modules and units
- lectures and rooms
- grades

Rails also includes Solid components in the stack:

- Solid Queue
- Solid Cache
- Solid Cable

## Runtime Characteristics

### Web application style

- monolithic Rails app
- server-rendered HTML
- no separate backend API service required for the normal UI

### Authentication model

- sign-in through Devise
- public sign-up disabled
- accounts are created by management users

### Authorization model

- account-level admin flag
- role-derived dean capability
- collaborator teaching scope for some grade flows
- student self-view only for grades and schedule

## Infrastructure Notes

The repository also contains deployment-oriented infrastructure:

- `Dockerfile` for production image builds
- `config/deploy.yml` for Kamal deployment

So the architecture can be viewed in two layers:

1. application architecture
2. deployment/runtime packaging

This document focuses on the application architecture.

## Relevant Files

- `app/controllers/application_controller.rb`
- `app/controllers/admin/base_controller.rb`
- `app/models/account.rb`
- `app/models/person.rb`
- `app/models/collaborator.rb`
- `app/models/student.rb`
- `app/models/unit.rb`
- `app/models/grade.rb`
- `config/routes.rb`
- `config/database.yml`
- `Dockerfile`
- `config/deploy.yml`
