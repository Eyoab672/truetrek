# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TrueTrek is a Rails 7.2 travel planning application where users can browse cities and places, create travel books (collections of places), and leave comments with photos. The app uses LLM-powered features to enhance place descriptions based on community feedback. Users can follow each other, send direct messages, and receive notifications.

## Common Commands

```bash
# Start development server
bin/rails server

# Database operations
bin/rails db:migrate
bin/rails db:seed
bin/rails db:reset

# Run tests
bin/rails test                              # unit/integration tests
bin/rails test:system                       # system tests (requires Chrome)
bin/rails test test/models/user_test.rb    # single test file
bin/rails test test/models/user_test.rb:10 # single test at line 10

# Code quality
bin/rubocop                    # linting (max line length: 120)
bin/brakeman                   # Ruby security scan
bin/importmap audit            # JS dependency security scan

# Rails console
bin/rails console

# Background job processing (Solid Queue)
bin/rails solid_queue:start
```

## Architecture

### Tech Stack
- Rails 7.2 with Hotwire (Turbo + Stimulus)
- PostgreSQL with pg_search for full-text search
- Devise authentication + Pundit authorization
- Bootstrap 5 + Font Awesome
- Cloudinary for image hosting (Active Storage)
- Geocoder with Nominatim for coordinates
- RubyLLM for AI-powered description enhancement
- Solid Queue for background jobs + Mission Control dashboard
- Progressive Web App (PWA) with offline comment support

### Data Model

```
User (Devise auth)
├── has_one TravelBook
├── has_many Comments, Votes, Reports
├── has_many Notifications
├── has_one_attached avatar
├── Follow relationships:
│   ├── has_many :follows (follower_id) → following
│   └── has_many :reverse_follows (followed_id) → followers
├── Conversations (DMs):
│   ├── has_many :sent_conversations (sender_id)
│   └── has_many :received_conversations (recipient_id)
├── attributes: username, city (required), admin, banned, tour_completed
└── methods: ban!(reason:), unban!, following?(user), follow(user), unfollow(user), find_or_create_conversation_with(user)

Follow (follow relationship)
├── belongs_to :follower (User)
├── belongs_to :followed (User)
├── validates uniqueness of follower_id scoped to followed_id
├── after_create: creates notification for followed user
└── before_destroy: cleans up related notifications

Notification
├── belongs_to :user (recipient)
├── belongs_to :actor (User who triggered it)
├── belongs_to :notifiable (polymorphic - Comment, Follow, etc.)
├── action: "new_comment", "new_follow"
├── scopes: unread, recent
└── auto-marked as read when viewing notifications page

Conversation (DM thread)
├── belongs_to :sender, :recipient (Users)
├── has_many Messages
├── accepted: boolean (message requests)
└── methods: mutual_follow?, can_send_message?(user), accept!

Message
├── belongs_to Conversation, User
├── belongs_to :replied_to_message (optional, for replies)
├── has_many_attached photos
└── can_unsend? (within 48 hours)

TravelBook
├── belongs_to User
└── has_many Places through TravelBookPlaces (join table)

TravelBookPlace (join table)
├── belongs_to :place, :travel_book
├── pinned: boolean (max 5 pinned places per travel book)
├── scopes: pinned, unpinned, ordered
└── methods: pin!, unpin!

City
├── has_many Places
└── img attribute (string URL)

Place
├── belongs_to City
├── has_many Comments, Reports
├── has_many_attached photo
├── geocoded_by :address
├── pg_search_scope on title, enhanced_description, comments
└── attributes: title, original_description, enhanced_description, address, lat/long

Comment
├── belongs_to Place, User
├── belongs_to :parent (self-referential for replies)
├── has_many :replies, Votes
├── has_many_attached photos
└── methods: vote_balance, weighted_score(local_bonus:), user_is_local?

Vote
├── belongs_to User, Comment
└── value: -1 or 1 (unique per user/comment)

Report
├── belongs_to User, Place
├── enum status: pending, reviewed, resolved, dismissed
└── validates reason: presence, user uniqueness per place
```

### Background Jobs
Jobs in `app/jobs/` processed by Solid Queue:
- `GeneratePlaceDescriptionJob` - creates initial place descriptions using LLM when a new place is added
- `UpdateEnhancedDescriptionJob` - regenerates place descriptions using positively-voted comments, prioritizing local resident insights
- `NotifyFollowersJob` - notifies a user's followers when they post a new comment

### LLM Integration
- `RubyLLM` gem with custom tools in `app/tools/`
- `WikipediaTool` fetches place summaries from Wikipedia API
- Descriptions are generated asynchronously via background jobs

### Real-time Updates (Turbo Streams)
- Place descriptions broadcast to `place_#{id}` channel when LLM generates/updates them
- Use `turbo_stream_from @place` in views to subscribe to updates
- Solid Cable handles WebSocket connections (no Redis required)

### Authorization with Pundit
- All controllers include `Pundit::Authorization` via `ApplicationController`
- `verify_authorized` runs after all actions except index (unless skipped)
- `verify_policy_scoped` runs after index actions
- Pundit is skipped for Devise controllers, pages controller, and mission_control
- Admin controllers (`Admin::BaseController`) use `require_admin` before_action and skip Pundit
- Policy files in `app/policies/`

### Routes Structure
- Root: `cities#index`
- Nested: `cities/:city_id/places` for places within a city
- Nested: `cities/:city_id/places/:place_id/comments` for comments
- Nested: `comments/:comment_id/replies` for threaded replies
- Nested: `comments/:comment_id/vote` for upvote/downvote
- Nested: `places/:place_id/reports` for user-submitted place reports
- `travel_book_places` for managing user's saved places
- `/camera` for photo capture feature (stores blob in session, redirects to comment form)
- `/users/search` for user autocomplete (@mentions)
- `/users/:id/follow` - follow/unfollow a user
- `/users/:id/followers`, `/users/:id/following` - view follower/following lists
- `/notifications` - user notifications with mark_read actions
- `/conversations` - direct messages with accept/decline for message requests
- `/conversations/:id/messages` - messages within a conversation
- `/tour/complete` - marks user's onboarding tour as completed
- `/jobs` Mission Control dashboard (admin only)
- `/admin` namespace for admin dashboard, reports management, place moderation, and user ban/unban
- `/places/autocomplete` for place name suggestions during place creation
- PWA routes: `/service-worker` and `/manifest` for Progressive Web App support

### Stimulus Controllers
Key JavaScript controllers in `app/javascript/controllers/`:
- `reply_toggle_controller.js`, `reply_form_controller.js`, `replies_expand_controller.js` - Reply handling
- `mention_autocomplete_controller.js` - @mention dropdown in comments
- `map_controller.js` - Map integration
- `place_selector_controller.js`, `place_name_autocomplete_controller.js` - Place selection/search
- `address_autocomplete_controller.js` - Address autocomplete
- `offline_controller.js`, `offline_comment_controller.js`, `sync_badge_controller.js` - PWA offline functionality
- `load_more_controller.js` - Pagination/infinite scroll
- `chat_controller.js`, `chat_scroll_controller.js`, `message_actions_controller.js` - DM messaging
- `tour_controller.js` - Onboarding tour for first-time users
- `lightbox_controller.js` - Image lightbox for photos
- `swipe_nav_controller.js` - Swipe navigation for mobile
- `tabs_controller.js` - Tab navigation UI
- `travel_book_select_controller.js` - Long-press multi-select for travel book places (pin/delete)

### Devise Configuration
Custom permitted parameters in `ApplicationController`:
- Sign up: `username`, `city`, `avatar`
- Account update: `username`, `city`, `avatar`
- Google OAuth: Users signing up via Google are redirected to complete their profile (city is required)

## Environment Variables

Uses `dotenv-rails`. Requires `.env` file with:
- Cloudinary credentials
- LLM API credentials (for RubyLLM)
- Google OAuth credentials (GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET)
