# API Contracts - Backend

## Base URL

- **Development:** `http://localhost:8000/api/v1`
- **Production:** `https://api.{DOMAIN}/api/v1`

## Authentication

All authenticated endpoints require JWT token in Authorization header:

```
Authorization: Bearer <access_token>
```

Token obtained from `POST /login/access-token`.

---

## Login Endpoints

### POST /login/access-token

OAuth2 password flow login.

**Auth Required:** No

**Request:**
```json
{
  "username": "user@example.com",
  "password": "secretpassword"
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

**Errors:**
- 400: Incorrect email or password

---

### POST /login/test-token

Validate current token.

**Auth Required:** Yes

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "is_active": true,
  "is_superuser": false,
  "full_name": "John Doe"
}
```

---

### POST /password-recovery/{email}

Request password reset email.

**Auth Required:** No

**Response (200):**
```json
{
  "message": "Password recovery email sent"
}
```

**Note:** Returns success even if email doesn't exist (security).

---

### POST /reset-password/

Reset password with token.

**Auth Required:** No

**Request:**
```json
{
  "token": "reset-token-here",
  "new_password": "newpassword123"
}
```

**Response (200):**
```json
{
  "message": "Password updated successfully"
}
```

---

## User Endpoints

### GET /users/

List all users (paginated).

**Auth Required:** Yes
**Superuser Only:** Yes

**Query Parameters:**
- `skip` (int, default: 0)
- `limit` (int, default: 100)

**Response (200):**
```json
{
  "count": 42,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "is_active": true,
      "is_superuser": false,
      "full_name": "John Doe",
      "created_at": "2026-03-27T10:00:00Z"
    }
  ]
}
```

---

### POST /users/

Create new user.

**Auth Required:** Yes
**Superuser Only:** Yes

**Request:**
```json
{
  "email": "newuser@example.com",
  "password": "secretpassword",
  "full_name": "Jane Doe",
  "is_active": true,
  "is_superuser": false
}
```

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "newuser@example.com",
  "is_active": true,
  "is_superuser": false,
  "full_name": "Jane Doe",
  "created_at": "2026-03-27T10:00:00Z"
}
```

**Errors:**
- 400: User with this email already exists

---

### GET /users/me

Get current user profile.

**Auth Required:** Yes

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "is_active": true,
  "is_superuser": false,
  "full_name": "John Doe",
  "created_at": "2026-03-27T10:00:00Z"
}
```

---

### PATCH /users/me

Update current user profile.

**Auth Required:** Yes

**Request:**
```json
{
  "full_name": "John Updated",
  "email": "john.updated@example.com"
}
```

**Response (200):** Updated user object

---

### PATCH /users/me/password

Change current user password.

**Auth Required:** Yes

**Request:**
```json
{
  "current_password": "oldpassword",
  "new_password": "newpassword123"
}
```

**Response (200):**
```json
{
  "message": "Password updated successfully"
}
```

**Errors:**
- 400: Incorrect password

---

### DELETE /users/me

Delete current user account.

**Auth Required:** Yes

**Response (200):**
```json
{
  "message": "User deleted successfully"
}
```

---

### POST /signup

Public user registration.

**Auth Required:** No

**Request:**
```json
{
  "email": "newuser@example.com",
  "password": "secretpassword",
  "full_name": "New User"
}
```

**Response (200):** Created user object

**Errors:**
- 400: User with this email already exists
- 403: Public registration is disabled

---

### GET /users/{user_id}

Get user by ID.

**Auth Required:** Yes
**Superuser Only:** Yes

**Response (200):** User object

---

### PATCH /users/{user_id}

Update user by ID.

**Auth Required:** Yes
**Superuser Only:** Yes

**Request:** Partial user object

**Response (200):** Updated user object

---

### DELETE /users/{user_id}

Delete user by ID.

**Auth Required:** Yes
**Superuser Only:** Yes

**Response (200):**
```json
{
  "message": "User deleted successfully"
}
```

---

## Item Endpoints

### GET /items/

List items (paginated).

**Auth Required:** Yes

**Query Parameters:**
- `skip` (int, default: 0)
- `limit` (int, default: 100)

**Response (200):**
```json
{
  "count": 15,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "My Item",
      "description": "Item description",
      "owner_id": "660e8400-e29b-41d4-a716-446655440000",
      "created_at": "2026-03-27T10:00:00Z"
    }
  ]
}
```

**Note:** Regular users see only their items. Superusers see all items.

---

### POST /items/

Create new item.

**Auth Required:** Yes

**Request:**
```json
{
  "title": "New Item",
  "description": "Optional description"
}
```

**Response (200):** Created item object

---

### GET /items/{id}

Get item by ID.

**Auth Required:** Yes

**Response (200):** Item object

**Errors:**
- 404: Item not found

---

### PUT /items/{id}

Update item by ID.

**Auth Required:** Yes

**Request:**
```json
{
  "title": "Updated Title",
  "description": "Updated description"
}
```

**Response (200):** Updated item object

**Errors:**
- 403: Not enough permissions (not owner)
- 404: Item not found

---

### DELETE /items/{id}

Delete item by ID.

**Auth Required:** Yes

**Response (200):**
```json
{
  "message": "Item deleted successfully"
}
```

**Errors:**
- 403: Not enough permissions (not owner)
- 404: Item not found

---

## Utils Endpoints

### POST /utils/test-email/

Send test email.

**Auth Required:** Yes
**Superuser Only:** Yes

**Query Parameters:**
- `email_to` (string, required)

**Response (200):**
```json
{
  "message": "Test email sent"
}
```

---

### GET /utils/health-check/

Health check endpoint.

**Auth Required:** No

**Response (200):**
```json
{
  "healthy": true
}
```

---

## Private Endpoints (Local Environment Only)

### POST /private/users/

Create user without auth (local development only).

**Auth Required:** No
**Environment:** local only

**Request:** UserCreate object

**Response (200):** Created user object

---

## Error Responses

All endpoints may return:

```json
{
  "detail": "Error message here"
}
```

| Status | Meaning |
|--------|---------|
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (missing/invalid token) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 422 | Validation Error (Pydantic) |
| 500 | Internal Server Error |
```
