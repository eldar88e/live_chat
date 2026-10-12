# Codex Project Settings

## Project Context

- Stack: Ruby 3.4.11, Rails 8.1, PostgreSQL, Vite, Stimulus, Turbo, Slim, ViewComponent
- Main language for UI and content: Russian
- Default locale: `:ru`
- Timezone: `Europe/Moscow`

## Work Principles

- Keep changes minimal and aligned with the current architecture
- Do not rewrite unrelated code
- Preserve existing patterns in controllers, models, views, services, and components
- Before editing, inspect nearby code and follow local conventions

## Ruby and Rails Rules

- Follow RuboCop rules from the project
- Use single quotes unless interpolation is needed
- Do not add `# frozen_string_literal: true`
- Use `Time.current` and `Date.current`, never `Time.now` or `Date.today`
- Keep business logic out of controllers when it can live in services or models
- Use Rails 8 strong params style: `params.expect(...)`

## Controllers

- Public controllers inherit from `ApplicationController`
- Admin controllers inherit from `Admin::BaseController`
- API controllers inherit from `Api::V1::BaseController`
- Keep controllers thin
- Use `pagy` for pagination and `ransack` for admin search where appropriate

## Models

- Put validations near the top of the model
- Avoid callbacks unless they are clearly justified
- Prevent N+1 queries with `includes`, `preload`, or ActiveStorage preload helpers
- Use explicit scopes and class methods instead of controller-side query logic

## Views and Frontend

- Prefer existing Slim, Turbo, Stimulus, and ViewComponent patterns
- Do not hardcode user-facing strings; use I18n
- Keep admin UI compatible with Turbo Streams

## Background Jobs and Integrations

- Heavy or slow operations should go to solid_queue jobs
- External API calls should not block normal web requests unless necessary

## Data and Migrations

- Add indexes for frequently queried fields and foreign keys
- Add foreign keys for associations where applicable
- Avoid risky schema changes without checking compatibility

## Security

- Never commit secrets, tokens, or credentials
- Use ENV variables or Rails credentials for secrets
- Validate uploaded files and external input
- Respect existing authentication and authorization boundaries

## Testing and Validation

- If tests are added, prefer RSpec
- For code changes, run the smallest relevant validation available
- If you cannot run verification, state that explicitly

## Git

- Keep commits focused
- Do not revert user changes unless explicitly asked
- Use short English commit messages when committing

## SEO

- Use a Rails app without SSL because it runs behind a NGINX reverse proxy.
- Assume the project targets users in Russia (RU location only).
