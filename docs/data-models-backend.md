# Data Models - Backend

## Database

- **Engine:** PostgreSQL 18
- **ORM:** SQLModel (SQLAlchemy + Pydantic)
- **Migrations:** Alembic

---

## User Model

### Table: `user`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT uuid4() | Unique identifier |
| `email` | VARCHAR | UNIQUE, NOT NULL, INDEX | User email address |
| `hashed_password` | VARCHAR | NOT NULL | Argon2/Bcrypt hashed password |
| `full_name` | VARCHAR | NULLABLE | User's full name |
| `is_active` | BOOLEAN | DEFAULT true | Account active status |
| `is_superuser` | BOOLEAN | DEFAULT false | Superuser privileges |
| `created_at` | TIMESTAMP WITH TZ | DEFAULT now() | Account creation time |

### Relationships

```
User 1 ──── * Item
  (owner_id FK with CASCADE DELETE)
```

### SQLModel Definition

```python
class User(SQLModel, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    email: str = Field(unique=True, index=True)
    hashed_password: str
    full_name: str | None = None
    is_active: bool = True
    is_superuser: bool = False
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    items: list["Item"] = Relationship(back_populates="owner", cascade_delete=True)
```

### Pydantic Schemas

```python
# Base (shared fields)
class UserBase(SQLModel):
    email: EmailStr
    full_name: str | None = None

# Create (input)
class UserCreate(UserBase):
    password: str

# Update (input, partial)
class UserUpdate(UserBase):
    password: str | None = None

# Public (output, no password)
class UserPublic(UserBase):
    id: uuid.UUID
    is_active: bool
    is_superuser: bool
    created_at: datetime

# Collection
class UsersPublic(SQLModel):
    data: list[UserPublic]
    count: int
```

---

## Item Model

### Table: `item`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY, DEFAULT uuid4() | Unique identifier |
| `title` | VARCHAR(255) | NOT NULL | Item title |
| `description` | VARCHAR(255) | NULLABLE | Item description |
| `owner_id` | UUID | FK → user.id, CASCADE DELETE | Owner reference |
| `created_at` | TIMESTAMP WITH TZ | DEFAULT now() | Creation time |

### Relationships

```
Item * ──── 1 User (owner)
```

### SQLModel Definition

```python
class Item(SQLModel, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    title: str = Field(max_length=255)
    description: str | None = Field(default=None, max_length=255)
    owner_id: uuid.UUID = Field(foreign_key="user", nullable=False)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    owner: User | None = Relationship(back_populates="items")
```

### Pydantic Schemas

```python
# Base (shared fields)
class ItemBase(SQLModel):
    title: str = Field(min_length=1, max_length=255)
    description: str | None = Field(default=None, max_length=255)

# Create (input)
class ItemCreate(ItemBase):
    pass

# Update (input, partial)
class ItemUpdate(ItemBase):
    title: str | None = Field(default=None, min_length=1, max_length=255)

# Public (output)
class ItemPublic(ItemBase):
    id: uuid.UUID
    owner_id: uuid.UUID
    created_at: datetime

# Collection
class ItemsPublic(SQLModel):
    data: list[ItemPublic]
    count: int
```

---

## Authentication Models

### Token

```python
class Token(SQLModel):
    access_token: str
    token_type: str = "bearer"
```

### Token Payload

```python
class TokenPayload(SQLModel):
    sub: str | None = None  # User ID (UUID string)
```

### New Password

```python
class NewPassword(SQLModel):
    token: str
    new_password: str
```

---

## Database Schema Diagram

```
┌─────────────────────────────────────────────────────────┐
│                        user                             │
├─────────────────────────────────────────────────────────┤
│  id              UUID        PK, DEFAULT uuid4()        │
│  email           VARCHAR     UNIQUE, NOT NULL, INDEX     │
│  hashed_password VARCHAR     NOT NULL                    │
│  full_name       VARCHAR     NULLABLE                    │
│  is_active       BOOLEAN     DEFAULT true                │
│  is_superuser    BOOLEAN     DEFAULT false               │
│  created_at      TIMESTAMPTZ DEFAULT now()               │
└─────────────────────────────────────────────────────────┘
                           │
                           │ 1:N (CASCADE DELETE)
                           ▼
┌─────────────────────────────────────────────────────────┐
│                        item                             │
├─────────────────────────────────────────────────────────┤
│  id              UUID        PK, DEFAULT uuid4()        │
│  title           VARCHAR(255) NOT NULL                   │
│  description     VARCHAR(255) NULLABLE                   │
│  owner_id        UUID        FK → user.id, NOT NULL      │
│  created_at      TIMESTAMPTZ DEFAULT now()               │
└─────────────────────────────────────────────────────────┘
```

---

## Migrations

| Migration | Description |
|-----------|-------------|
| `e2412789c190` | Initialize models (User, Item) |
| `d98dd8ec85a3` | Replace integer IDs with UUID |
| `fe56fa70289e` | Add created_at to User and Item |
| `1a31ce608336` | Add cascade delete relationships |
| `9c0a54914c78` | Add max_length for string columns |

### Creating New Migrations

```bash
cd backend
alembic revision --autogenerate -m "Description of changes"
alembic upgrade head
```

---

## CRUD Operations

### User CRUD

| Operation | Function | Notes |
|-----------|----------|-------|
| Create | `create_user()` | Hashes password with Argon2 |
| Read | `get_user_by_email()` | Case-insensitive lookup |
| Read | `get_user_by_id()` | UUID lookup |
| Update | `update_user()` | Partial update, optional password |
| Delete | `delete_user()` | Cascades to items |
| Authenticate | `authenticate()` | Timing-safe, auto hash upgrade |

### Item CRUD

| Operation | Function | Notes |
|-----------|----------|-------|
| Create | `create_item()` | Sets owner_id |
| Read | `get_items()` | Paginated, filtered by owner |
| Read | `get_item_by_id()` | UUID lookup |
| Update | Via SQLModel | Partial update |
| Delete | Via SQLModel | Owner check required |

---

## Links

- [API Contracts](./api-contracts-backend.md)
- [Architecture - Backend](./architecture-backend.md)
- [Development Guide](./development-guide-backend.md)
