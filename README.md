# Ror1 School Manager

Ror1 School Manager is a Rails application for managing school structure, people, schedules, and grades.

It supports several user perspectives:

- Admins
- Deans
- Collaborators
- Students

From the app, you can manage:

- people and linked accounts
- collaborator roles
- formation plans
- school classes and student enrollments
- learning modules and units
- lectures and schedules
- grades and student report cards

## Tech Stack

- Ruby `4.0.1`
- Rails `8.1.2`
- MySQL with `mysql2`
- Hotwire:
  - Turbo
  - Stimulus
- Importmap for JavaScript
- Propshaft for assets
- Devise for authentication
- Simple Calendar for calendar views
- Solid Queue, Solid Cache, and Solid Cable

## Requirements

Before starting, make sure you have:

- Ruby `4.0.1`
- Bundler
- MySQL running locally
- build tools required for native gems such as `mysql2`

The default local database connection is:

- host: `127.0.0.1`
- port: `3306`
- username: `root`

You can override this through environment variables.

## Environment Variables

An example environment file is available at [`.env.example`](.env.example).

Useful variables for local development:

```bash
PORT=3000
RAILS_MAX_THREADS=5
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=
DB_NAME_DEVELOPMENT=ror1_school_manager_development
DB_NAME_TEST=ror1_school_manager_test
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=ChangeMe123!
```

Typical setup:

```bash
cp .env.example .env
```

## Local Setup

### 1. Install dependencies

```bash
bundle install
```

### 2. Prepare the database

```bash
bin/rails db:prepare
```

This creates the database if needed and loads the schema.

### 3. Seed data

```bash
bin/rails db:seed
```

In development, this will:

- create or update the bootstrap admin account
- seed sample school data
- seed sample collaborators, students, plans, modules, units, rooms, and lectures

### 4. Start the app

```bash
bin/dev
```

`bin/dev` currently starts the Rails server directly.

The app will usually be available at:

- `http://localhost:3000`

## One-Command Setup

You can also use the built-in setup script:

```bash
bin/setup --skip-server
```

Or, to set up and immediately start the server:

```bash
bin/setup
```

If you want a clean reset of the local database:

```bash
bin/setup --reset --skip-server
```

## Database Workflow

Run migrations:

```bash
bin/rails db:migrate
```

Reset and reseed the database:

```bash
bin/rails db:reset
bin/rails db:seed
```

Prepare the test database:

```bash
RAILS_ENV=test bin/rails db:prepare
```

## Authentication Bootstrap

The app seeds an initial admin account.

Default non-production credentials:

- email: `admin@example.com`
- password: `ChangeMe123!`

These can be changed with:

- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`
- `ADMIN_AVS_NUMBER`
- `ADMIN_FIRST_NAME`
- `ADMIN_LAST_NAME`
- `ADMIN_BIRTH_DATE`
- `ADMIN_CITY`
- `ADMIN_POSTAL_CODE`
- `ADMIN_STREET`
- `ADMIN_STREET_NUMBER`
- `ADMIN_PHONE_NUMBER`

## Running Tests

Run the full test suite:

```bash
bin/rails test
```

Run a single test file:

```bash
bin/rails test test/integration/admin_grades_flow_test.rb
```

Run a single test by line number:

```bash
bin/rails test test/integration/admin_grades_flow_test.rb:4
```

Important:

- the test suite uses MySQL too
- the test database must exist and MySQL must be reachable on the configured host

## Code Quality And Security Checks

Run RuboCop:

```bash
bin/rubocop
```

Run Brakeman:

```bash
bin/brakeman
```

Run bundler-audit:

```bash
bin/bundler-audit
```

## Project Structure

Key directories:

- `app/controllers` for request handling
- `app/models` for domain logic and Active Record models
- `app/views` for server-rendered UI
- `config/routes.rb` for routing
- `db/migrate` for schema changes
- `db/seeds*` for bootstrap and sample data
- `test` for integration and model tests
- `docs` for technical documentation

## Main Functional Areas

### People and accounts

- person creation and editing
- linked accounts with invitation download
- collaborator and student role management
- collaborator-role management

### Academic structure

- formation plans
- school classes
- learning modules
- units

### Teaching operations

- lectures
- schedules for collaborators and students
- grade management
- student report cards

## Role Model

The current hierarchy is:

1. Admin
2. Dean
3. Other users

Notes:

- `Admin` is controlled by the `accounts.admin` boolean
- `Dean` is recognized through a collaborator role titled `Dean`
- Deans can use most management screens like admins
- Deans cannot delete or demote admin accounts

## Documentation

Additional documentation is available here:

- [Authentication and invitation flow](docs/authentication_and_invitation_flow.md)
- [Grades process](docs/grades_process.md)
- [Role-based app flows](docs/role_based_app_flows.md)

## Deployment Notes

The repository includes:

- a production-oriented [Dockerfile](Dockerfile)
- a Kamal config in [config/deploy.yml](config/deploy.yml)

The Docker setup is intended for production, not day-to-day local development.

## Useful Commands

```bash
bin/setup --skip-server
bin/dev
bin/rails db:migrate
bin/rails db:seed
bin/rails test
bin/rubocop
bin/brakeman
bin/bundler-audit
```
