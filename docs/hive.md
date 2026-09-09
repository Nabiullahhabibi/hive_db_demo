# Hive Database in Flutter

A complete guide and practical Flutter implementation of Hive CE, from basic CRUD to production-level local database concepts.

---

# Table of Contents

1. Introduction
2. Why Hive Exists
3. When to Use Hive
4. When NOT to Use Hive
5. Core Concepts
6. Flutter Implementation
7. Clean Architecture Integration
8. Real-World Example
9. Common Mistakes
10. Senior-Level Considerations
11. Demo Implementation
12. Short Summary

---

# 1. Introduction

## What is Hive?

Hive is a lightweight NoSQL key-value database written in Dart.

It is designed for local data persistence in Dart and Flutter applications.

Unlike SQLite, Hive does not primarily work with:

- Tables
- Rows
- Columns
- SQL
- JOINs
- Foreign keys

Instead, Hive stores data inside containers called **boxes**.

A box can conceptually be understood as:

```text
Box
│
├── key_1 → value_1
├── key_2 → value_2
└── key_3 → value_3
```

For example:

```dart
await box.put('name', 'Habibi');
```

Then:

```dart
final name = box.get('name');
```

returns:

```text
Habibi
```

---

## Hive CE

This project uses:

```yaml
hive_ce:
hive_ce_flutter:
```

Hive CE is the community continuation of Hive v2.

It provides:

- NoSQL local storage
- Key-value storage
- Cross-platform support
- Encryption
- Type adapters
- Lazy boxes
- Reactive box listeners
- Isolate support
- Flutter integration

---

## Hive in a Flutter application

A simplified architecture is:

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
Hive Box
    │
    ▼
Device Storage
```

When using Clean Architecture:

```text
Presentation
     │
     ▼
Domain
     │
     ▼
Data
     │
     ▼
Hive
```

Hive should normally remain inside the data/infrastructure side of the application.

---

# 2. Why Hive Exists

Applications often need to persist data locally.

For example:

- User preferences
- Cached API responses
- Offline data
- Drafts
- Products
- Posts
- Recently viewed items
- Local application state
- Temporary data
- User sessions

Without local storage, data can disappear when:

- The application closes
- The device restarts
- The network disappears
- The API becomes unavailable

Hive provides a simple local persistence layer without requiring SQL.

---

## Why not just use SharedPreferences?

SharedPreferences is mainly designed for simple preference values.

Examples:

```text
theme = dark
language = en
isFirstLaunch = false
```

Hive is more appropriate for structured local data.

Examples:

```text
Users
Posts
Products
Cached API responses
Offline records
```

---

## Why not always use SQLite?

SQLite is a relational database.

Hive is a NoSQL/key-value database.

SQLite is better when you need:

```text
Tables
Relationships
JOINs
Complex queries
Aggregations
Constraints
Indexes
Relational transactions
```

Hive is better when you need:

```text
Simple local persistence
Key-value access
Object storage
Caching
Offline storage
Simple CRUD
```

---

# 3. When to Use Hive

Hive is a good choice when the application needs local persistence without complex relational queries.

---

## 3.1 Caching

A common architecture is:

```text
              Repository
              /        \
             /          \
        Remote API     Hive
             \          /
              \        /
                  UI
```

When online:

```text
API
 ↓
Repository
 ↓
Hive
 ↓
UI
```

When offline:

```text
Hive
 ↓
Repository
 ↓
UI
```

---

## 3.2 Offline-first applications

Hive is useful for applications that must continue working without internet access.

Example:

```text
User creates record
       │
       ▼
Save locally
       │
       ▼
Internet unavailable
       │
       ▼
Record remains available
```

When the internet returns:

```text
Local data
    │
    ▼
Synchronization
    │
    ▼
Server
```

---

## 3.3 Local cache

For example:

```text
GET /users
```

The application can:

```text
1. Request API
2. Save users to Hive
3. Display users
4. Use Hive if API is unavailable
```

---

## 3.4 Small and medium datasets

Hive works well for many local application datasets such as:

```text
Users
Posts
Products
Categories
Notes
Drafts
Cached API responses
```

---

## 3.5 Object storage

Hive can store custom Dart objects using TypeAdapters.

This will be implemented in Step 2.

Example concept:

```dart
await box.put(
  user.id,
  user,
);
```

---

# 4. When NOT to Use Hive

Hive is not the best database for every application.

---

## 4.1 Complex relational queries

Avoid Hive when you frequently need SQL-style queries such as:

```sql
SELECT *
FROM users
WHERE age > 20;
```

or:

```sql
SELECT users.name, posts.title
FROM users
JOIN posts
ON users.id = posts.user_id;
```

---

## 4.2 Heavy relational applications

If the application contains:

```text
Users
Orders
Products
Payments
OrderItems
Invoices
Categories
Transactions
```

and those entities have many relationships and complex queries, SQLite/Drift may be more appropriate.

---

## 4.3 Advanced aggregation

For requirements such as:

```text
COUNT
SUM
AVG
GROUP BY
HAVING
Complex JOINs
```

a relational database is usually a better fit.

---

## Hive vs SQLite

### Hive

```text
NoSQL
Key-value
Simple local access
Object-oriented storage
Good for caching
Good for offline data
```

### SQLite

```text
Relational
SQL
Tables
JOINs
Indexes
Constraints
Complex queries
```

---

# 5. Core Concepts

Understanding these concepts is the foundation of Hive.

---

# 5.1 Hive

`Hive` is the main database interface.

Initialization:

```dart
await Hive.initFlutter();
```

---

# 5.2 Box

A box is a storage container.

Example:

```dart
final box = await Hive.openBox('users');
```

Conceptually:

```text
users box
│
├── 1 → User
├── 2 → User
└── 3 → User
```

---

# 5.3 Key

A key identifies a stored value.

Example:

```dart
await box.put(
  'user_1',
  'Habibi',
);
```

Here:

```text
Key   = user_1
Value = Habibi
```

---

# 5.4 Value

The value is the data stored against the key.

Example:

```dart
await box.put(
  'name',
  'Habibi',
);
```

The value is:

```text
Habibi
```

---

# 5.5 put()

`put()` creates or updates data.

```dart
await box.put(
  'name',
  'Habibi',
);
```

If the key doesn't exist:

```text
CREATE
```

If the key already exists:

```text
UPDATE
```

Therefore:

```dart
box.put(key, value);
```

can represent both create and update.

---

# 5.6 putAll()

Store multiple key/value pairs:

```dart
await box.putAll({
  'name': 'Habibi',
  'country': 'Afghanistan',
});
```

---

# 5.7 get()

Retrieve data:

```dart
final name = box.get('name');
```

If the key doesn't exist:

```text
null
```

You can also specify a default value:

```dart
final name = box.get(
  'name',
  defaultValue: 'Unknown',
);
```

---

# 5.8 containsKey()

Check whether a key exists:

```dart
final exists = box.containsKey('name');
```

---

# 5.9 delete()

Delete one value:

```dart
await box.delete('name');
```

---

# 5.10 deleteAll()

Delete multiple values:

```dart
await box.deleteAll([
  'user_1',
  'user_2',
]);
```

---

# 5.11 clear()

Remove all values:

```dart
await box.clear();
```

Be careful.

This is a destructive operation.

---

# 5.12 keys

Get all keys:

```dart
final keys = box.keys;
```

---

# 5.13 values

Get all values:

```dart
final values = box.values;
```

---

# 5.14 length

Get the number of stored values:

```dart
final count = box.length;
```

---

# 5.15 getAt()

Read a value by index:

```dart
final value = box.getAt(0);
```

Difference:

```dart
box.get('user_1');
```

uses a key.

While:

```dart
box.getAt(0);
```

uses an index.

---

# 5.16 putAt()

Update a value using its index:

```dart
await box.putAt(
  0,
  newValue,
);
```

---

# 5.17 deleteAt()

Delete a value using its index:

```dart
await box.deleteAt(0);
```

---

# 5.18 add()

Hive can automatically generate an integer key.

Example:

```dart
await box.add(value);
```

This is useful when you don't need to control the key yourself.

---

# 5.19 addAll()

Add multiple values:

```dart
await box.addAll([
  value1,
  value2,
  value3,
]);
```

---

# 5.20 watch()

Hive can notify the application when data changes.

Example:

```dart
box.watch().listen((event) {
  print(event);
});
```

This is useful for reactive applications.

---

# 5.21 listenable()

Hive CE also provides Flutter integration for listening to box changes.

Example:

```dart
ValueListenableBuilder(
  valueListenable: box.listenable(),
  builder: (context, box, child) {
    return Text(
      box.length.toString(),
    );
  },
);
```

This is useful when building a UI directly around a Hive box.

However, in a Clean Architecture project, it is usually better to expose changes through the repository/data layer rather than making widgets depend directly on Hive.

---

# 6. Flutter Implementation

## 6.1 Add Hive dependencies

Add:

```yaml
dependencies:
  flutter:
    sdk: flutter

  hive_ce: ^2.19.3
  hive_ce_flutter: ^2.3.4
```

---

# 6.2 Initialize Flutter

Hive must be initialized before opening boxes.

Use:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  runApp(
    const MyApp(),
  );
}
```

---

# 6.3 Open a box

```dart
final box = await Hive.openBox('users');
```

After the box has already been opened:

```dart
final box = Hive.box('users');
```

---

# 6.4 Store data

```dart
await box.put(
  'name',
  'Habibi',
);
```

---

# 6.5 Read data

```dart
final name = box.get('name');
```

---

# 6.6 Update data

```dart
await box.put(
  'name',
  'Nabiullah',
);
```

Because the key is the same, the previous value is replaced.

---

# 6.7 Delete data

```dart
await box.delete('name');
```

---

# 6.8 Close a box

When a box is no longer needed:

```dart
await box.close();
```

In a normal application, you generally do not close a shared application-wide box every time a screen disappears.

Manage box lifetime at the storage layer.

---

# 7. Clean Architecture Integration

The UI should not directly depend on Hive.

Avoid:

```dart
class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box('users');

    // ...
  }
}
```

This couples the UI to Hive.

---

## Recommended architecture

```text
Presentation
     │
     ▼
Domain Repository
     │
     ▼
Repository Implementation
     │
     ▼
Local Data Source
     │
     ▼
Hive
```

---

# 7.1 Domain

The domain layer defines the repository contract.

Example:

```dart
abstract class UserRepository {
  Future<List<User>> getUsers();

  Future<void> saveUser(User user);

  Future<void> updateUser(User user);

  Future<void> deleteUser(String id);
}
```

The domain layer doesn't know that Hive exists.

---

# 7.2 Data

The data layer implements the repository.

```text
UserRepositoryImpl
       │
       ▼
HiveUserLocalDataSource
       │
       ▼
Hive
```

---

# 7.3 Presentation

The UI communicates with the repository.

```text
Page
 ↓
Repository
 ↓
Hive
```

---

# 7.4 Why this matters

If you later replace Hive with:

```text
SQLite
Drift
Isar
API
Another database
```

the presentation layer does not need to know about that change.

---

# 8. Real-World Example

Imagine an offline-first application.

The application manages:

```text
Users
Posts
```

Remote:

```text
REST API
```

Local:

```text
Hive
```

Architecture:

```text
                 Flutter
                    │
                    ▼
               Repository
               /         \
              /           \
        Remote API       Hive
              \           /
               \         /
                   Data
                    │
                    ▼
                    UI
```

---

# 8.1 Online flow

```text
User requests users
        │
        ▼
Repository
        │
        ▼
API
        │
        ▼
Save result to Hive
        │
        ▼
Return users
        │
        ▼
UI
```

---

# 8.2 Offline flow

```text
User requests users
        │
        ▼
Repository
        │
        ▼
Hive
        │
        ▼
Cached users
        │
        ▼
UI
```

---

# 8.3 Synchronization

When internet returns:

```text
Hive
  │
  ▼
Pending local changes
  │
  ▼
API
  │
  ▼
Server
```

The synchronization system should handle:

```text
Create
Update
Delete
Conflict
Retry
Failure
```

---

# 8.4 Users and Posts

Step 2 will contain:

```text
Users Box
│
├── User 1
├── User 2
└── User 3

Posts Box
│
├── Post 1 → userId = 1
├── Post 2 → userId = 1
└── Post 3 → userId = 2
```

Hive does not behave like a relational SQL database with automatic foreign keys and JOINs.

Relationships are usually represented using IDs and resolved in application code.

---

# 9. Common Mistakes

## Mistake 1 — Using Hive directly inside widgets

Bad:

```dart
final box = Hive.box('users');
```

inside every widget.

Better:

```text
Widget
  ↓
Repository
  ↓
Local Data Source
  ↓
Hive
```

---

# Mistake 2 — Treating Hive like SQL

Don't expect:

```sql
SELECT *
FROM users
WHERE age > 20;
```

Hive is not a SQL database.

---

# Mistake 3 — Random box names

Avoid:

```dart
Hive.openBox('box1');
Hive.openBox('data');
Hive.openBox('users2');
```

Centralize box names:

```dart
class HiveBoxes {
  static const users = 'users';
  static const posts = 'posts';
}
```

---

# Mistake 4 — One giant box for everything

Avoid:

```text
app_data
```

containing unrelated information.

Prefer:

```text
users
posts
settings
cache
```

when the data has different responsibilities.

---

# Mistake 5 — Ignoring schema compatibility

When using TypeAdapters, do not randomly change:

```dart
@HiveType(typeId: 0)
```

or:

```dart
@HiveField(0)
```

after data has already been stored.

These identifiers are part of the persisted data format.

---

# Mistake 6 — Reusing deleted field indexes

Suppose you have:

```dart
@HiveField(0)
String name;
```

Then you remove `name`.

Do not immediately use field `0` for an unrelated field.

Instead, preserve the old index and add a new field number.

Example:

```dart
@HiveField(1)
String email;
```

---

# Mistake 7 — Assuming local storage cannot fail

Local databases can still experience:

```text
Corruption
Invalid adapters
Encryption errors
Migration problems
Disk errors
Unexpected data
```

Important storage operations should be handled appropriately.

---

# Mistake 8 — Loading huge datasets unnecessarily

Avoid blindly doing:

```dart
box.values.toList();
```

when the box contains a very large dataset.

For larger datasets, consider:

```text
LazyBox
Pagination
Chunking
Indexes
Server-side pagination
```

depending on the application.

---

# Mistake 9 — Closing boxes incorrectly

Don't open and close a global application box every time a screen appears/disappears.

For example, avoid:

```text
Page opened
 ↓
open box

Page closed
 ↓
close box

Page opened
 ↓
open box
```

unless there is a specific reason.

Centralize storage lifecycle management.

---

# 10. Senior-Level Considerations

---

# 10.1 Schema Evolution

Data models change.

Version 1:

```text
User
- id
- name
```

Version 2:

```text
User
- id
- name
- email
```

Existing users must remain readable.

This means database schema evolution must be planned.

---

# 10.2 TypeAdapter Stability

Example:

```dart
@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;
}
```

The following values should be considered stable:

```text
typeId
field indexes
```

Do not casually change them after users already have persisted data.

---

# 10.3 Encryption

Hive CE supports encrypted boxes.

Conceptually:

```dart
final key = Hive.generateSecureKey();

final cipher = HiveAesCipher(key);

final box = await Hive.openBox(
  'users',
  encryptionCipher: cipher,
);
```

However, the encryption key itself should be protected.

Do not do:

```dart
final key = 'my-secret-key';
```

and hard-code it in the application.

A production application should securely manage encryption keys.

For example:

```text
Hive encrypted box
       ▲
       │
Encryption key
       ▲
       │
Secure platform storage
```

A package such as `flutter_secure_storage` can be used for the key-management side.

---

# 10.4 Performance

Hive is designed for fast local operations.

However, performance still depends on how the application uses it.

Consider:

```text
Dataset size
Number of operations
Serialization
Object size
Memory usage
Box structure
Reactive listeners
Pagination
Lazy loading
```

Don't assume:

```text
Local database = unlimited performance
```

---

# 10.5 LazyBox

For larger datasets, a lazy box can be useful.

Normal boxes keep values available in memory.

A LazyBox loads values when they are requested.

Conceptually:

```text
Normal Box

Disk
 ↓
Memory
 ↓
Application
```

Lazy box:

```text
Disk
 ↓
Requested value
 ↓
Application
```

This can reduce memory usage for certain workloads.

---

# 10.6 Pagination

Hive does not provide SQL-style pagination.

You need to implement an application-level strategy.

Possible strategies include:

```text
Index-based pagination
Key-based pagination
Chunking
Lazy boxes
Local cache + server pagination
```

For example:

```text
Page 1
0 - 9

Page 2
10 - 19

Page 3
20 - 29
```

---

# 10.7 Searching

Hive does not automatically give you the same query capabilities as SQL.

For example:

```text
Search users by name
```

may require retrieving records and filtering them in Dart.

For large datasets, this should be carefully designed.

---

# 10.8 Sorting

Sorting may also be done in Dart:

```dart
final users = box.values.toList();

users.sort(
  (a, b) => a.name.compareTo(b.name),
);
```

For very large datasets, repeatedly loading and sorting everything can become inefficient.

---

# 10.9 Relationships

Hive does not automatically provide SQL foreign-key relationships.

Instead:

```text
Post
│
├── id
├── title
└── userId
```

Then:

```text
post.userId
     │
     ▼
users box
     │
     ▼
User
```

Relationships must be managed by application code.

---

# 10.10 Transactions and Consistency

Hive should not be treated as a relational transaction engine.

For multi-step operations:

```text
Create user
Create first post
Update metadata
```

think about:

```text
Ordering
Failure
Partial completion
Recovery
Consistency
```

Step 2 will demonstrate a practical multi-operation workflow.

---

# 10.11 Offline-first architecture

A strong offline-first architecture separates:

```text
Remote data source
Local data source
Repository
```

Example:

```text
              Repository
              /        \
             /          \
        Remote          Local
          API           Hive
             \          /
              \        /
                 Data
                  │
                  ▼
                 UI
```

The repository decides:

```text
When to use API
When to use Hive
When to synchronize
When to retry
```

---

# 10.12 Testing

Hive storage should be tested.

Tests should cover:

```text
Create
Read
Update
Delete
Clear
Batch operations
Relationships
Pagination
Search
Sorting
Repository behavior
Failure handling
```

---

# 11. Demo Implementation

This project is divided into two steps.

---

# Step 1 — Basic CRUD

Step 1 focuses on understanding Hive itself.

We use a simple User entity:

```text
User
│
├── id
├── name
├── email
└── age
```

We implement:

```text
Create
Read
Update
Delete
```

And additionally demonstrate:

```text
put
putAll
get
containsKey
delete
deleteAll
clear
getAt
putAt
deleteAt
add
addAll
keys
values
length
watch
```

---

# Step 1 Architecture

```text
Presentation
     │
     ▼
UserRepository
     │
     ▼
UserRepositoryImpl
     │
     ▼
HiveUserLocalDataSource
     │
     ▼
HiveService
     │
     ▼
Hive Box
```

---

# Step 1 Storage

We use:

```text
users box
```

Each user is stored as a `Map<String, dynamic>`.

Example:

```text
Key:
user_id

Value:
{
  id: user_id,
  name: Habibi,
  email: habibi@example.com,
  age: 25
}
```

Step 2 will replace these maps with real Hive `TypeAdapter` models.

---

# Step 2 — Real Hive Database

Step 2 introduces:

```text
User
Post
```

and real Hive object persistence.

---

# Step 2 Features

## Models

```text
UserModel
PostModel
```

---

## TypeAdapters

```text
HiveType
HiveField
TypeAdapter
```

---

## Multiple boxes

```text
users
posts
```

---

## Relationships

```text
User
 │
 └── Posts
```

using:

```text
userId
```

---

## CRUD

Users:

```text
Create
Read
Update
Delete
```

Posts:

```text
Create
Read
Update
Delete
```

---

## Searching

```text
Search users
Search posts
```

---

## Filtering

```text
Posts by user
Users by condition
```

---

## Sorting

```text
Name ASC
Name DESC
Newest
Oldest
```

---

## Pagination

```text
Page 1
Page 2
Page 3
```

---

## Reactive updates

```text
Hive
 ↓
Watch
 ↓
Repository
 ↓
State management
 ↓
UI
```

---

## Batch operations

```text
Create many users
Create many posts
Delete many records
```

---

## Encryption

```text
Generate key
     ↓
Secure key storage
     ↓
Encrypted Hive box
```

---

## Offline-first

```text
API
 │
 ▼
Repository
 │
 ├── Remote
 │
 └── Hive
      │
      ▼
     Cache
```

---

## Testing

```text
Local data source tests
Repository tests
CRUD tests
Relationship tests
Pagination tests
```

---

# 12. Short Summary

Hive is a lightweight NoSQL/key-value database for Dart and Flutter.

The most important concept is:

```text
Hive
 │
 └── Box
      │
      ├── Key
      └── Value
```

Basic CRUD:

```dart
await box.put(key, value);

final value = box.get(key);

await box.put(key, newValue);

await box.delete(key);
```

Hive is useful for:

```text
Local persistence
Caching
Offline-first applications
Simple CRUD
Object storage
Small/medium local datasets
```

Hive is less appropriate for:

```text
Complex SQL
Heavy relational queries
JOIN-heavy applications
Advanced aggregation
Strict relational constraints
```

Clean Architecture:

```text
Presentation
     ↓
Domain
     ↓
Repository
     ↓
Local Data Source
     ↓
Hive
```

The goal of this project is not only to learn:

```dart
box.put();
box.get();
```

The goal is to understand:

```text
How Hive works
How to structure Hive
How to integrate Hive with Clean Architecture
How to model data
How to handle relationships
How to paginate
How to cache
How to encrypt
How to handle offline data
How to think about Hive at a senior level
```

---

# Project Roadmap

```text
STEP 1
│
├── Hive initialization
├── Box management
├── Keys
├── Values
├── Create
├── Read
├── Update
├── Delete
├── Batch operations
├── Index operations
├── Clear
├── Watch
└── Clean Architecture
        │
        ▼
STEP 2
│
├── User model
├── Post model
├── TypeAdapters
├── Multiple boxes
├── Relationships
├── Search
├── Filter
├── Sort
├── Pagination
├── Watch
├── Batch operations
├── Encryption
├── Offline-first
├── Synchronization concepts
└── Testing
```