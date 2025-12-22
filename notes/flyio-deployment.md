# Fly.io Deployment - Machine Requirements

## Fly.io Machines Required

| Process | Purpose | Machines |
|---------|---------|----------|
| **web** | Puma server (HTTP + Action Cable via Solid Cable) | 1-2+ |
| **worker** | Solid Queue job processing | 1 |
| **Postgres** | Database (also stores Solid Queue + Solid Cable data) | 1-3 |

## Maximum typical deployment: 5-6 machines

- **2 web machines** - for redundancy/load balancing
- **1 worker machine** - for background jobs (GeneratePlaceDescriptionJob, NotifyFollowersJob, etc.)
- **2-3 Postgres machines** - if using Fly Postgres with HA (primary + replica(s))

## Minimum deployment: 2-3 machines

- **1 web machine** (could even run worker inline with `solid_queue` in-process)
- **1 Postgres machine** (single node, no HA)

## Key advantages of TrueTrek's stack

The app uses **Solid Queue** and **Solid Cable** which both use PostgreSQL as their backend - no Redis needed. This simplifies deployment significantly since you don't need a separate cache/message broker machine.

You could even run Solid Queue in-process with Puma (avoiding a separate worker machine) by setting:

```ruby
# config/environments/production.rb
config.solid_queue.connects_to = { database: { writing: :queue } }
config.active_job.queue_adapter = :solid_queue
```

And running the supervisor within the web process. But for production with LLM calls, a separate worker is recommended.

## Current Procfile Configuration

```
web: bundle exec puma -C config/puma.rb
worker: bin/jobs
```

## Solid Queue Configuration

- 3 threads per worker
- Processes controlled by `JOB_CONCURRENCY` env var (default: 1)
- Polling interval: 0.1 seconds

## Solid Cable Configuration

- Polling interval: 0.1 seconds
- Message retention: 1 day (production)
