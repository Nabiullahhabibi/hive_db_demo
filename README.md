# Hive Flutter Demo

A practical Flutter project for learning and implementing **Hive local database** with **Clean Architecture**.

This project starts with basic Hive CRUD operations and progressively moves toward a more realistic local database structure with **Users and Posts**, one-to-many relationships, Hive `TypeAdapter`s, reactive updates, and data consistency.

The goal is not only to learn how to use Hive, but to understand **how Hive can be integrated into a scalable Flutter application**.

---

## 📚 Project Goals

This project demonstrates:

* Hive local database
* Hive CE
* Flutter integration
* NoSQL key-value storage
* Boxes
* Keys and values
* CRUD operations
* Hive `TypeAdapter`
* Custom Hive models
* Multiple Hive boxes
* One-to-many relationships
* User → Posts relationship
* Reactive database updates
* `Box.watch()`
* Repository Pattern
* Data Source Pattern
* Clean Architecture
* Offline-first local persistence
* Cascade-style deletion
* Basic data consistency

---

# 🏗️ Architecture

The project follows a simplified **Clean Architecture** structure:

```text
Presentation
     ↓
Domain
     ↓
Data
     ↓
Hive
```

More specifically:

```text
UI
 │
 ▼
Repository
 │
 ▼
Local Data Source
 │
 ▼
Hive Box
```

Example:

```text
UsersPage
    ↓
UserRepository
    ↓
UserRepositoryImpl
    ↓
HiveUserLocalDataSource
    ↓
Hive users Box
```

And for posts:

```text
UserPostsPage
    ↓
PostRepository
    ↓
PostRepositoryImpl
    ↓
HivePostLocalDataSource
    ↓
Hive posts Box
```

---

# 🗂️ Project Structure

```text
hive_demo/
│
├── docs/
│   └── hive.md
│
├── lib/
│   │
│   ├── core/
│   │   └── storage/
│   │       ├── hive_boxes.dart
│   │       └── hive_service.dart
│   │
│   ├── data/
│   │   │
│   │   ├── local/
│   │   │   ├── hive_user_local_data_source.dart
│   │   │   └── hive_post_local_data_source.dart
│   │   │
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── user_model.g.dart
│   │   │   ├── post_model.dart
│   │   │   └── post_model.g.dart
│   │   │
│   │   └── repositories/
│   │       ├── user_repository_impl.dart
│   │       └── post_repository_impl.dart
│   │
│   ├── domain/
│   │   │
│   │   ├── entities/
│   │   │   ├── user.dart
│   │   │   └── post.dart
│   │   │
│   │   └── repositories/
│   │       ├── user_repository.dart
│   │       └── post_repository.dart
│   │
│   ├── presentation/
│   │   └── pages/
│   │       ├── users_page.dart
│   │       └── user_posts_page.dart
│   │
│   └── main.dart
│
├── docs/
│   └── hive.md
│
├── pubspec.yaml
└── README.md
```

---

# 🗄️ Hive Database Structure

The application uses two Hive boxes.

```text
users
posts
```

## Users Box

The users box stores:

```text
UserModel
```

Example:

```text
Key: user_001

Value:
    id: user_001
    name: Ahmad
    email: ahmad@example.com
    age: 25
```

---

## Posts Box

The posts box stores:

```text
PostModel
```

Example:

```text
Key: post_001

Value:
    id: post_001
    userId: user_001
    title: My First Post
    content: Hello Hive!
    createdAt: ...
```

---

# 🔗 User → Post Relationship

Hive is a **NoSQL database**, so it doesn't provide SQL-style joins and foreign keys.

Instead, the relationship is represented using:

```dart
Post.userId
```

For example:

```text
User
┌──────────────────┐
│ id = user_001    │
│ name = Ahmad     │
└──────────────────┘
          │
          │ userId
          ▼
Post
┌──────────────────┐
│ id = post_001    │
│ userId = user_001│
│ title = Hello    │
└──────────────────┘
```

When the user opens their posts page:

```dart
getPostsByUser(userId)
```

the application filters the posts using the user's ID.

---

# 👤 Users

The Users page provides complete CRUD functionality.

## Create

The user manually enters:

* Name
* Email
* Age

Then the application stores the user in Hive.

```text
Add User
   ↓
Create User
   ↓
UserRepository
   ↓
HiveUserLocalDataSource
   ↓
users Box
```

---

## Read

When the Users page loads:

```dart
getUsers()
```

retrieves all users from Hive.

The users are then displayed in the UI.

---

## Update

Selecting **Edit** opens the user form with the existing information.

The user can change:

```text
Name
Email
Age
```

The same user ID is preserved.

---

## Delete

A user can be deleted individually.

The application also removes all posts belonging to that user.

```text
Delete User
     ↓
Delete User
     ↓
Delete User's Posts
```

This provides cascade-style deletion at the application level.

---

## Delete All

The application can remove:

```text
All Users
+
All Posts
```

---

# 📝 Posts

When a user is selected:

```text
Users Page
    ↓
Tap User
    ↓
User Posts Page
```

The Posts page displays only posts belonging to that user.

---

## Create Post

A post contains:

```text
Title
Content
User ID
Created At
```

The `userId` is automatically taken from the selected user.

---

## Read Posts

The application loads:

```dart
getPostsByUser(userId)
```

Only posts belonging to the selected user are displayed.

---

## Update Post

The user can edit:

```text
Title
Content
```

The following values remain unchanged:

```text
id
userId
createdAt
```

---

## Delete Post

A post can be deleted individually.

---

# 📦 Hive Boxes

The project uses two boxes:

```dart
static const String users = 'users';

static const String posts = 'posts';
```

They represent two independent local collections.

```text
Hive
│
├── users
│     ├── UserModel
│     ├── UserModel
│     └── UserModel
│
└── posts
      ├── PostModel
      ├── PostModel
      └── PostModel
```

---

# 🧩 Hive TypeAdapters

Part 2 introduces Hive `TypeAdapter`s.

Instead of storing:

```text
Map<String, dynamic>
```

we store strongly typed objects:

```text
UserModel
PostModel
```

Example:

```dart
@HiveType(typeId: 0)
class UserModel extends HiveObject {
```

and:

```dart
@HiveType(typeId: 1)
class PostModel extends HiveObject {
```

The generated adapters are responsible for converting these objects into a format Hive can persist.

---

# ⚠️ Type ID Rules

Hive type IDs are part of your persisted database schema.

For example:

```dart
@HiveType(typeId: 0)
```

and:

```dart
@HiveType(typeId: 1)
```

Once these IDs are used in a real application, they should **not be casually changed**.

Similarly, existing `@HiveField()` indexes should remain stable.

Example:

```dart
@HiveField(0)
final String id;

@HiveField(1)
final String name;
```

Do not later reuse field `0` for a completely different property.

---

# ⚙️ Code Generation

The project uses:

```text
build_runner
hive_ce_generator
```

After creating or modifying Hive models, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:

```text
user_model.g.dart
post_model.g.dart
```

These generated files should not be manually edited.

---

# 📡 Reactive Updates

The project also demonstrates Hive's reactive capabilities.

The UI listens to:

```dart
_box.watch()
```

For example:

```text
Hive
 ↓
Box changes
 ↓
watch()
 ↓
Repository
 ↓
UI reloads
```

This means when a user or post is created, edited, or deleted, the corresponding page can automatically refresh.

---

# 🧱 Repository Pattern

The UI does not directly communicate with Hive.

Instead:

```text
Page
 ↓
Repository
 ↓
Data Source
 ↓
Hive
```

For users:

```dart
UserRepository
```

For posts:

```dart
PostRepository
```

This keeps Hive-specific implementation details outside the presentation layer.

---

# 💾 Local Persistence

Hive provides persistent storage.

For example:

```text
Create User
     ↓
Close Application
     ↓
Open Application
     ↓
User Still Exists
```

The same applies to posts.

This demonstrates the basic concept of **offline local persistence**.

---

# 📱 Application Flow

The complete application flow is:

```text
                    Users Page
                        │
          ┌─────────────┼─────────────┐
          │             │             │
       Create          Edit         Delete
          │             │             │
          └─────────────┴─────────────┘
                        │
                        ▼
                   Select User
                        │
                        ▼
                User Posts Page
                        │
             ┌──────────┼──────────┐
             │          │          │
          Create       Edit      Delete
             │          │          │
             └──────────┴──────────┘
```

---

# 🛠️ Technologies

| Technology         | Purpose                  |
| ------------------ | ------------------------ |
| Flutter            | Application framework    |
| Dart               | Programming language     |
| Hive CE            | Local NoSQL database     |
| Hive CE Flutter    | Flutter integration      |
| Hive CE Generator  | Hive adapter generation  |
| Build Runner       | Code generation          |
| Clean Architecture | Application architecture |
| Repository Pattern | Data abstraction         |

---

# 📦 Dependencies

Main dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter

  hive_ce: ^2.19.3
  hive_ce_flutter: ^2.3.4
```

Development dependencies:

```yaml
dev_dependencies:
  build_runner: ^2.4.15
  hive_ce_generator: ^1.9.3
```

---

# 🚀 Getting Started

## 1. Clone the repository

```bash
git clone <your-repository-url>
```

Then:

```bash
cd hive_demo
```

---

## 2. Install dependencies

```bash
flutter pub get
```

---

## 3. Generate Hive adapters

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Run the application

```bash
flutter run
```

---

# ⚠️ Important When Moving From Part 1 to Part 2

Part 1 stored users as:

```text
Map<String, dynamic>
```

Part 2 changes the users box to:

```text
UserModel
```

Therefore, old Part 1 Hive data can conflict with the new typed box.

During development, if you are moving from Part 1 to Part 2, you may need to:

* uninstall/reinstall the application, or
* clear the application's local data.

This is only a development transition issue.

A production application should instead use a proper migration strategy.

---

# 🧪 Testing the Application

A good manual test sequence is:

### Test 1 — Users

Create:

```text
Ahmad
Ali
Hamid
```

Verify that all three users remain after restarting the application.

### Test 2 — User Posts

Open Ahmad.

Create:

```text
My First Post
My Second Post
```

Open Ali.

Create:

```text
Ali's First Post
```

Verify that each user only sees their own posts.

### Test 3 — Update

Edit:

```text
User name
Post title
Post content
```

Restart the application and verify the changes remain.

### Test 4 — Delete Post

Delete one post.

Verify that only that post disappears.

### Test 5 — Delete User

Delete a user.

Verify:

```text
User deleted
+
User's posts deleted
```

### Test 6 — Persistence

Completely close the application.

Open it again.

Verify that the remaining users and posts are still available.

---

# 🧠 What I Learned From This Project

This project is designed to move from basic Hive usage to more realistic Flutter database architecture.

### Basic Hive

```text
Box
Key
Value
put()
get()
delete()
clear()
```

### Intermediate Hive

```text
Multiple Boxes
TypeAdapters
Typed Models
watch()
Relationships
Filtering
```

### Architecture

```text
Presentation
Domain
Data
Local Data Source
Repository
Hive
```

### Real-world database thinking

```text
Relationships
Data consistency
Cascade deletion
Persistence
Schema stability
Offline storage
```

---

# 🔮 Future Improvements

The next version of this project can demonstrate more advanced Hive concepts:

* Pagination
* Search
* Filtering
* Sorting
* LazyBox
* Efficient large-data queries
* Batch operations
* Atomic operations
* Transactions
* Error handling
* Database migrations
* Schema evolution
* Hive encryption
* Secure encryption-key storage
* Unit testing
* Repository testing
* Data-source testing
* Performance optimization
* Offline-first architecture
* Synchronization with a REST API
* Conflict resolution
* Background/isolate database operations

---

# 📚 Learning Documentation

Detailed Hive documentation for this project is available in:

```text
docs/hive.md
```

It covers:

1. Introduction
2. Why Hive exists
3. When to use Hive
4. When not to use Hive
5. Core concepts
6. Flutter implementation
7. Clean Architecture integration
8. Real-world examples
9. Common mistakes
10. Senior-level considerations
11. Demo implementation
12. Summary

---

# 🎯 Project Objective

The purpose of this project is **not simply to demonstrate CRUD**.

The main objective is to understand how a local database can be integrated into a Flutter application using good architecture.

The final concept is:

```text
                    Flutter UI
                       │
                       ▼
                 Repository
                       │
                       ▼
                Local Data Source
                       │
                       ▼
                    Hive
                       │
             ┌─────────┴─────────┐
             ▼                   ▼
          Users Box          Posts Box
             │                   │
             └───────┐   ┌───────┘
                     ▼   ▼
                  Relationship
                   userId
```

This provides a foundation for building larger **offline-first Flutter applications** with local persistence.

---

# 👨‍💻 Author

**Habibi**

Flutter Developer

---

# ⭐ If This Project Helps You

If this project is useful for learning Flutter local databases, feel free to:

* ⭐ Star the repository
* Fork the project
* Explore the code
* Improve the implementation
* Use the concepts in your own Flutter applications

---

## 📄 License

This project is created for educational and learning purposes.
