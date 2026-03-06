# Authentication And Invitation Flow

## Overview

This application uses Devise for authentication, but public self-registration is disabled.

The onboarding flow is now:

1. An administrator logs in.
2. The administrator creates a `Person`.
3. The administrator optionally creates a linked `Account`.
4. If an account is created, the application generates a text file containing the username and password setup link.
5. The administrator shares that file or its contents with the user.
6. The invited user sets their password through the Devise reset-password screen and can then sign in.

## Core Rules

- `Account` belongs to one `Person`.
- `Person` has one `Account`.
- Public sign-up is disabled.
- Only admin accounts can access the people management screens.
- Invitation links reuse Devise's reset-password mechanism.

## Data Model

### `Person`

`Person` stores identity and contact data:

- `avs_number`
- `first_name`
- `last_name`
- `birth_date`
- `street`
- `street_number`
- `postal_code`
- `city`
- `phone_number`

### `Account`

`Account` stores authentication and access data:

- `email`
- `encrypted_password`
- `enabled`
- `admin`
- `invited_at`
- `person_id`

Important flags:

- `enabled`: if `false`, the user cannot authenticate.
- `admin`: grants access to the admin area.
- `invited_at`: timestamp set when the invitation file is generated.

## What Changed Compared To Default Devise

### Public registration is disabled

- The app does not expose Devise registration routes.
- `/accounts/sign_up` is not available.
- The sign-up link was removed from shared Devise views.

### Invitation file is based on password reset

Instead of adding `devise_invitable`, the application generates the standard Devise reset-password token when an admin creates an account.

For a first-time account:

- a temporary password is generated internally,
- the account is created,
- `invited_at` is filled,
- the application creates a text file with the username and reset link,
- the user chooses their real password from that link.

This keeps the flow simple and avoids adding another gem.

## First Admin Bootstrap

The first admin account is created through `db/seeds.rb`.

### Required commands

```bash
bin/rails db:migrate
bin/rails db:seed
```

### Development and test defaults

In non-production environments, the seed uses these defaults if no environment variables are provided:

- `ADMIN_EMAIL=admin@example.com`
- `ADMIN_PASSWORD=ChangeMe123!`

### Production setup

In production, set at least:

```bash
ADMIN_EMAIL=admin@your-domain.tld
ADMIN_PASSWORD=your-secure-password
bin/rails db:seed
```

Optional seed variables:

- `ADMIN_AVS_NUMBER`
- `ADMIN_FIRST_NAME`
- `ADMIN_LAST_NAME`
- `ADMIN_CITY`
- `ADMIN_POSTAL_CODE`
- `ADMIN_STREET`
- `ADMIN_STREET_NUMBER`
- `ADMIN_PHONE_NUMBER`

### Seed behavior

- If the admin person/account already exists, the seed updates the existing admin account metadata.
- If no admin account exists yet, a password is required to create it.
- Re-running the seed does not require resetting the password of an existing admin account.

## Admin Workflow

### 1. Log in as admin

Use the seeded admin account on the normal login page:

- `/accounts/sign_in`

After login:

- admins are redirected to the dashboard,
- the dashboard links to the people management page.

### 2. Open the people management page

Admin pages:

- `/admin/people`
- `/admin/people/new`

Only accounts with `admin: true` can access these routes.

### 3. Create a person

The admin fills in the person form with:

- identity data,
- address data,
- contact data.

At this point there are two valid options:

- create only the `Person`,
- create the `Person` and a linked `Account` in the same action.

### 4. Optionally create the linked account

In the "Optional account" section of the form:

- enter the user's email address,
- optionally check "Grant admin access".

If the email field is empty:

- only the `Person` record is created,
- no account is created,
- no invitation file is generated.

If the email field is filled:

- a linked `Account` is created,
- the account is enabled by default,
- an invitation text file is downloaded immediately.

## Invitation Flow

When an admin creates an account:

1. The application creates the `Person`.
2. The application creates the `Account`.
3. A temporary password is generated internally.
4. `invited_at` is set.
5. A reset-password token is generated.
6. The application downloads a `.txt` file containing the username and the password setup link.

The application can also regenerate that text file later from the admin people list.

## Recipient Workflow

The invited user:

1. receives the text file or copied link from the administrator,
2. clicks "Set my password",
3. chooses a password,
4. submits the Devise password reset form,
5. is then able to sign in normally.

After that point, later password resets still use the standard Devise reset token flow.

## Access Control

### Standard account

A standard account can:

- sign in,
- access non-admin authenticated pages.

A standard account cannot:

- access `/admin/people`,
- create people,
- create accounts for others.

### Admin account

An admin account can:

- sign in,
- access the admin area,
- create `Person` records,
- create linked `Account` records,
- generate invitation files through account creation.

## Disabled Accounts

Authentication checks respect the `enabled` flag.

If `enabled` is `false`:

- the account cannot sign in,
- Devise returns a disabled-account message.

## Link Generation

The invitation file contains a full reset-password URL generated from the current application request.

That means the downloaded link is based on the host and port the admin used to access the app.

## Relevant Files

Main implementation files:

- `app/models/account.rb`
- `app/models/person.rb`
- `app/controllers/admin/people_controller.rb`
- `app/controllers/admin/base_controller.rb`
- `app/views/admin/people/new.html.erb`
- `app/views/admin/people/index.html.erb`
- `config/routes.rb`
- `db/seeds.rb`
- `db/migrate/20260306150000_add_admin_and_invited_at_to_accounts.rb`

Tests:

- `test/models/account_test.rb`
- `test/integration/admin_people_flow_test.rb`

## Typical Local Setup

```bash
bin/rails db:migrate
bin/rails db:seed
bin/rails server
```

Then:

1. log in with the seeded admin account,
2. open `/admin/people`,
3. create a person,
4. provide an email if you want to generate an invite immediately.

## Troubleshooting

### The downloaded link points to the wrong host

Check:

- the URL used by the admin to access the app
- reverse proxy or host configuration in front of Rails

### Admin routes return access denied

Check that the current account has:

- `admin: true`

### A user cannot sign in

Check:

- the account exists,
- the password was set through the invite link,
- `enabled` is still `true`.
