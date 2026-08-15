# ApplyLog

> A production-oriented Flutter application for managing, tracking, and analyzing job applications from a single workspace.

ApplyLog is being built as a real-world Flutter portfolio project rather than a tutorial application.

The goal is to simulate the architecture, engineering practices, and product decisions expected in a professional Flutter development environment.

---

## 🚧 Project Status

**Current Progress: Day 4 / 6**

| Area | Status |
|---|---|
| Flutter architecture | ✅ |
| Firebase integration | ✅ |
| Firebase Authentication | ✅ |
| Firestore persistence | ✅ |
| Real-time application stream | ✅ |
| Add application | ✅ |
| Application status management | ✅ |
| Status filtering | ✅ |
| Local search | ✅ |
| Debounced search | ✅ |
| Delete application | ✅ |
| Delete confirmation | ✅ |
| Local notification infrastructure | ✅ |
| Follow-up reminder scheduling | ⚠️ Device testing |
| Application detail screen | ✅ |
| Dashboard | ⏳ |
| Dark mode | ⏳ |
| Navigation polish | ⏳ |
| Automated tests | ⏳ |
| Final documentation | ⏳ |

> **Note:** Scheduled notifications are implemented and successfully registered with Android. Testing on the development device indicates device-level background/alarm restrictions rather than an application scheduling failure.

---

# ✨ Features

## Authentication

- Firebase Authentication
- Login
- Signup
- Authentication state monitoring
- Automatic navigation based on authentication state
- Protected application routes

---

## Application Management

Track job applications with:

- Company name
- Role title
- Application status
- Application date
- Application source
- Notes
- Follow-up date

Supported application statuses:

```text
Applied
Screening
Interview
Offer
Rejected
Withdrawn


Real-Time Application Updates:
Applications are stored in Cloud Firestore and consumed through a real-time stream.
Firestore
    ↓
Repository
    ↓
Stream<Result<List<Application>>>
    ↓
Riverpod
    ↓
UI


Search:

ApplyLog provides local application searching with debouncing.

Instead of processing every keystroke:

F
Fl
Flu
Flut
Flutt
Flutter

the application waits briefly before updating the search query.

This reduces unnecessary processing and provides a smoother user experience.



Status Filtering:
Applications can be filtered locally by:

All
Applied
Screening
Interview
Offer
Rejected
Withdrawn

The current implementation performs filtering locally because the complete application stream is already available to the client.

For significantly larger datasets, server-side filtering and pagination can be introduced.



Status Updates:
Application status can be changed directly from the application list.

Example:

Applied
   ↓
Screening
   ↓
Interview
   ↓
Offer
The status is persisted in Firestore and automatically reflected through the real-time stream.

Application Details

The detail screen provides:

Company
Role
Current status
Application date
Days since application
Application source
Follow-up date
Notes
Delete action
Delete Confirmation

Applications cannot be deleted accidentally without confirmation.

The delete flow is designed around:

User requests deletion
        ↓
Confirmation dialog
        ↓
Repository operation
        ↓
Result handling
        ↓
UI feedback
🔔 Follow-Up Notifications

ApplyLog includes a local notification infrastructure for job follow-up reminders.

Technology:

flutter_local_notifications
timezone
Android exact alarms

The scheduling pipeline is:

Follow-up Date
      ↓
Notification Use Case
      ↓
Notification Repository
      ↓
Local Notification Service
      ↓
Android Alarm Manager
      ↓
Local Notification

The application correctly:

Initializes notification services
Requests notification permission
Requests exact-alarm permission
Creates a notification channel
Converts dates using the configured timezone
Schedules reminders
Cancels reminders

Scheduled notification testing is currently being validated on the physical Android device.

🏗️ Architecture

ApplyLog follows a feature-oriented Clean Architecture approach.

lib/
│
├── core/
│   ├── errors/
│   ├── notifications/
│   └── router/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── applications/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
🧱 Clean Architecture Layers
Presentation

Responsible for:

Screens
Widgets
Riverpod providers
UI state
User interactions
Presentation
     ↓
Domain
Domain

Contains business rules and contracts.

Examples:

Entities
Repository interfaces
Use cases

The domain layer does not depend directly on Firebase or Flutter infrastructure.

Data

Responsible for external data sources and implementations.

Examples:

Firestore repository
Firebase Authentication
Data models
Serialization/deserialization
Firestore
    ↓
Data Source / Repository Implementation
    ↓
Domain Entity
🔄 Result-Based Error Handling

The application uses a Result abstraction instead of exposing raw infrastructure exceptions throughout the application.

Conceptually:

Success<T>
Error<Failure>

This allows the presentation layer to handle successful and failed operations explicitly.

Example:

switch (result) {
  case Success():
    // success
  case Error(failure: final failure):
    // show failure
}
🧠 State Management

ApplyLog uses Riverpod for dependency injection and application state management.

Current examples include:

Authentication state
Firestore application stream
Search query
Selected status filter
Filtered applications
Notification dependencies

The project intentionally avoids putting business logic directly inside widgets where it can be moved into providers or domain services.

🧭 Navigation

Navigation is handled using go_router.

Current routes include:

/auth
/
 /add
/detail/:id

Authentication state controls access to protected routes.

🔥 Backend

ApplyLog uses Firebase services.

Firebase Authentication

Used for:

Account creation
Login
Authentication state
Cloud Firestore

Used for:

Application persistence
Real-time updates
Status changes
Application deletion

Data is scoped to the authenticated user:

users/
  {userId}/
    applications/
      {applicationId}

This prevents applications from different users being mixed together.

🛠️ Tech Stack
Technology	Purpose
Flutter	Cross-platform UI
Dart	Programming language
Riverpod	State management / DI
GoRouter	Navigation
Firebase Auth	Authentication
Cloud Firestore	Backend database
Flutter Local Notifications	Local reminders
Timezone	Timezone-aware scheduling
Git	Version control
📅 Development Roadmap
Day 1 — Architecture & Firebase
Completed
Project architecture
Feature-based folder structure
Firebase configuration
Application entity
Application model
Failure abstraction
Result abstraction
Authentication screens
Authentication state
Day 2 — Repository & Real-Time Applications
Completed
Firestore repository
Repository abstraction
Application stream
Riverpod stream provider
Application list
Empty state
Add application flow
Real-time Firestore updates
Day 3 — Application Pipeline
Completed
Status filter chips
Local search
Debounced search
Status update
Firestore status persistence
Delete application
Delete confirmation
UI feedback for failures
Day 4 — Notifications & Details
Completed
Notification repository
Local notification service
Notification initialization
Android notification channel
Notification permission
Exact alarm permission
Timezone configuration
Follow-up reminder scheduling
Reminder cancellation
Application detail screen
Detail navigation
Remaining
Finalize scheduled notification testing across devices
Connect follow-up dates from application data to notification scheduling
Complete production-level delete flow on detail screen
🚀 Day 5 — Dashboard & Product Polish

Planned:

Dashboard

Display:

Total applications
Applications by status
Interviews
Offers
Rejections
Response rate
Recent applications

Potential visualization:

Applications
│
├── Applied
├── Screening
├── Interview
├── Offer
├── Rejected
└── Withdrawn
UI Improvements
Dark mode
Theme configuration
Navigation polish
Responsive layouts
Improved empty states
Better loading states
Better error states
🧪 Day 6 — Testing & Release Preparation

Planned:

Unit tests
Repository tests
Provider tests
Widget tests
Error-state testing
Empty-state testing
README improvements
Architecture diagram
Screenshots
Git history cleanup
Final GitHub release
📊 Future Improvements

The project is intentionally designed so additional production features can be added without restructuring the entire application.

Potential future improvements:

Firestore pagination
Server-side search
Advanced filtering
Application timeline
Interview tracking
Multiple follow-up reminders
Notification deep linking
Resume attachment
Company contacts
Interview notes
Salary tracking
Job source tracking
Analytics
Export applications
Backup and restore
Offline-first synchronization
🎯 Engineering Goals

ApplyLog is being developed with the following principles:

Maintainability

Business logic should remain independent from UI and infrastructure.

Testability

Dependencies are abstracted through repositories and providers.

Scalability

The architecture should support additional features without turning the application into a monolithic codebase.

Reliability

Errors, loading states, empty states, and asynchronous operations are explicitly handled.

User Experience

The application should remain responsive and predictable even when network operations fail.

📈 Current Development Progress
Day 1  ████████████████████ 100%
Day 2  ████████████████████ 100%
Day 3  ████████████████████ 100%
Day 4  ███████████████████░  90%
Day 5  █████░░░░░░░░░░░░░░░  25%
Day 6  ░░░░░░░░░░░░░░░░░░░░   0%
Overall

Approximately 75% of the planned MVP is complete.

📱 Screens

Screens currently implemented:

Login
Signup
Application List
Add Application
Application Detail

More screenshots will be added after the final UI polish phase.

🔐 Security

Application data is scoped to the authenticated Firebase user.

The intended Firestore security model is:

Authenticated User
       ↓
users/{uid}
       ↓
users/{uid}/applications

Firestore security rules should ensure users can only access their own application records.

🧑‍💻 Development Philosophy

This project is intentionally being developed as a simulation of professional Flutter development.

The focus is not simply on making screens work.

The project emphasizes:

Clean Architecture
Separation of concerns
Repository pattern
Dependency injection
Reactive state management
Error handling
Maintainable code
Real-time data
Production-oriented feature design
Meaningful Git history
📌 Project Goals

The final version of ApplyLog aims to demonstrate that the developer understands more than Flutter UI development.

It demonstrates the ability to build a complete application involving:

UI
 ↓
State Management
 ↓
Business Logic
 ↓
Repository Abstraction
 ↓
Firebase
 ↓
Real-Time Data

alongside:

Local Notifications
Authentication
Navigation
Error Handling
Testing
Documentation
⭐ Why ApplyLog?

Job applications are often tracked using spreadsheets, notes, or scattered messages.

ApplyLog provides a dedicated workspace where developers can track:

What they applied for → where they are in the hiring pipeline → when to follow up → what happened next.

The project is designed to turn that simple idea into a realistic, maintainable Flutter application.

📄 License

This project is currently being developed as a personal portfolio project.

Built with Flutter & Dart.