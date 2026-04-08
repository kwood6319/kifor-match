# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kifor Match is an MVP matching platform connecting donors and charities. Donors offer goods/services, charities post requests for items they need, and donors submit offers against those requests. Built with the Le Wagon Rails template.

## Tech Stack

- Ruby 3.3.5, Rails 8.1.2, PostgreSQL
- Authentication: Devise
- Frontend: Bootstrap 5.3, Stimulus, Turbo, Simple Form, ERB views
- Assets: Importmap (no Node.js/Webpack)

## Common Commands

```bash
# Setup
bundle install
bin/rails db:create db:migrate db:seed

# Dev server
bin/rails server

# Tests (Minitest)
bin/rails test                        # all tests
bin/rails test test/models/user_test.rb  # single file
bin/rails test test/models/user_test.rb:10  # single test by line
bin/rails test:system                 # system tests (Capybara/Selenium)

# Linting & Security
bin/rubocop                           # RuboCop (omakase config)
bin/rubocop -a                        # auto-fix
bin/brakeman                          # security scan
bundle exec bundler-audit check       # gem vulnerabilities
```

## Architecture

### Domain Model

```
User (Devise auth)
├── has_many :charities
│   └── has_many :requests
│       └── has_many :offers
└── has_many :donors
    └── has_many :offers
```

- **Request**: A charity's need (title, category, quantity_needed/remaining, condition, urgency, status)
- **Offer**: A donor's response to a request (quantity_offered, condition, status, can_ship_by, tracking_number)
- Both requests and offers have activate/deactivate lifecycle actions
- Offers also have accept and mark_sent actions

### Routing

Offers are nested under requests for creation (`/requests/:id/offers/new`) but top-level for show/edit (`/offers/:id`). Charities and donors are index-only with activate/deactivate member routes.

### Authorization

All routes require authentication (`authenticate_user!` in ApplicationController). Policy objects are being added under `app/policies/`.

### Key Conventions

- Model attributes are normalized to lowercase before save
- Fields have null constraints at the database level
- RuboCop max line length: 120 characters
- RuboCop excludes `bin/`, `db/`, `config/`, `test/` directories

## CI Pipeline

GitHub Actions on PRs and pushes to master: Brakeman scan, bundler-audit, importmap audit, RuboCop lint, Minitest, system tests (with PostgreSQL service).
