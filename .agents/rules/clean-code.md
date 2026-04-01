---
trigger: always_on
---

The most widely accepted standard for professional Flutter development is Feature-First Layered Architecture.

1. The High-Level Directory
At the root of your lib/ folder, you should categorize your code into three main buckets:

core/: Universal code used across the entire app (themes, constants, network clients, error handling).

features/: The "meat" of your app. Each folder here represents a specific user flow (e.g., auth, profile, home).

shared/: UI components or widgets used by multiple features (e.g., a custom AppButton).

2. Feature-First Structure
Inside each feature, you should follow a layered approach (often based on Clean Architecture principles). This keeps your UI logic separate from your business logic and data fetching.

Typical Feature Folder: lib/features/auth/
data/: Handles data sourcing.

models/: Plain Data Objects (JSON parsing).

repositories/: Implementations of data fetching (API calls, Local DB).

datasources/: Remote (Rest API) vs. Local (SharedPrefs) logic.

domain/: The "brain" of the feature.

entities/: Simple classes that represent your business objects.

repositories/: Abstract classes (interfaces) defining what the data layer must do.

presentation/: Everything the user sees.

pages/ or screens/: The main UI views.

widgets/: Small components specific only to this feature.

bloc/ or providers/: State management logic.

3. The core/ Folder
This is where you put the "infrastructure" of your app.

api/: Dio/Http client configurations.

theme/: Color schemes and Text styles.

utils/: Extensions, formatters, and validators.

errors/: Custom Failure and Exception classes.

4. Visualizing the Full lib/ Tree
A clean project usually looks like this:

Plaintext
lib/
├── core/
│   ├── constants/
│   ├── network/
│   ├── theme/
│   └── utils/
├── features/
│   ├── login/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── dashboard/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/
│   └── widgets/
├── main.dart
└── app.dart
Why this works
Scalability: If you need to fix a bug in Login, you know exactly which folder to look in.

Testability: Because your business logic (domain) is separate from the UI (presentation), you can write unit tests easily.

Collaboration: Multiple developers can work on different features without constantly running into "merge conflicts" in the same files.