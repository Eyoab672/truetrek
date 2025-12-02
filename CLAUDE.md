# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TrueTrek is a Rails 7.2 travel planning application where users can browse cities and places, create travel books (collections of places), and leave comments with photos.

## Common Commands

```bash
# Start development server
bin/rails server

# Database operations
bin/rails db:migrate
bin/rails db:seed
bin/rails db:reset

# Run tests
bin/rails test
bin/rails test test/models/user_test.rb  # single test file

# Code quality
bin/rubocop                    # linting
bin/brakeman                   # security scan

# Rails console
bin/rails console
```

## Architecture

### Tech Stack
- Rails 7.2 with Hotwire (Turbo + Stimulus)
- PostgreSQL database
- Devise authentication
- Pundit authorization
- Bootstrap 5 + Font Awesome
- Cloudinary for image hosting (Active Storage)
- Geocoder with Nominatim lookup for place coordinates

### Data Model

```
User (Devise auth)
├── has_one TravelBook
└── has_many Comments

TravelBook
├── belongs_to User
└── has_many Places through TravelBookPlaces (join table)

City
├── has_many Places
└── img attribute (string URL)

Place
├── belongs_to City
├── has_many Comments
├── geocoded_by :address
└── attributes: title, wiki_description, latitude, longitude, address

Comment
├── belongs_to Place
├── belongs_to User
├── has_many_attached photos
└── validates description: presence, minimum 100 chars
```

### Authorization with Pundit
- All controllers include `Pundit::Authorization` via `ApplicationController`
- `verify_authorized` runs after all actions except index (unless skipped)
- `verify_policy_scoped` runs after index actions
- Pundit is skipped for Devise controllers and pages controller
- Policy files in `app/policies/` - each resource has its own policy

### Routes Structure
- Root: `cities#index`
- Nested: `cities/:city_id/places` for browsing places within a city
- Nested: `cities/:city_id/places/:place_id/comments` for creating comments
- `travel_book_places` for adding/removing places from a user's travel book
- Devise handles all `/users/*` authentication routes

### Devise Configuration
Custom permitted parameters configured in `ApplicationController` for:
- Sign up: `username`, `city`
- Account update: `username`, `city`

## Environment Variables

Uses `dotenv-rails` for environment variables. Requires `.env` file with Cloudinary credentials.
