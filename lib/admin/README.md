# Admin Web Module

This directory contains the dedicated Flutter web admin interface for Sevakam. It is intentionally separated from the main mobile route tree and uses its own entrypoint, application shell, and admin-specific data flow.

## Purpose

The admin web app is responsible for:

- platform overview and operational monitoring
- user and provider administration
- order and post moderation
- service and category management
- support ticket review
- admin broadcasts and promotions

## Module Structure

```text
lib/admin/
├── main.dart           Admin web entrypoint
├── app/                App shell, routes, and admin bootstrap
├── data/               API clients, data sources, and repository implementations
├── domain/             Entities and repository contracts
└── presentation/       Pages, widgets, and state management
```

## Entrypoint

- `lib/admin/main.dart`

This entrypoint is separate from the main app entrypoint:

- mobile / shared app: `lib/main.dart`
- admin web app: `lib/admin/main.dart`

## Running the Admin App

Start the backend first:

```bash
cd lib/backend
npm run dev
```

Then run the admin web application:

```bash
flutter run -d chrome -t lib/admin/main.dart --web-port=8099
```

## Backend Dependency

The admin UI depends on backend admin endpoints such as:

- `/api/admin/overview`
- `/api/admin/users`
- `/api/admin/orders`
- `/api/admin/posts`
- `/api/admin/tickets`
- `/api/admin/services`

Most list endpoints are paginated and intended for dashboard-style management views rather than bulk export workflows.

## Development Notes

- The admin module does not reuse the mobile app route tree.
- Authentication and authorization are enforced through the backend admin APIs.
- Keep admin-only presentation, routing, and state inside `lib/admin/` to avoid coupling with the customer app.
