# Integration Architecture

## Overview

The Full Stack FastAPI Template uses a **REST API** integration pattern between the React frontend and FastAPI backend. Communication happens over HTTP/HTTPS with JSON payloads.

## Integration Points

```
┌─────────────────────────────────────────────────────────┐
│                   React Frontend                        │
│                   (localhost:5173)                      │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │           Generated API Client                  │   │
│  │           (src/client/sdk.gen.ts)               │   │
│  │                                                 │   │
│  │  - Auto-generated from OpenAPI schema          │   │
│  │  - TypeScript types for all endpoints          │   │
│  │  - Request/response validation                 │   │
│  └─────────────────────────────────────────────────┘   │
│                          │                              │
│                          │ HTTP/HTTPS                   │
│                          │ JSON payloads                │
│                          │ JWT Bearer token             │
│                          ▼                              │
└─────────────────────────────────────────────────────────┘
                           │
                           │
┌─────────────────────────────────────────────────────────┐
│                   FastAPI Backend                       │
│                   (localhost:8000)                      │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │              API Router                         │   │
│  │              (/api/v1)                          │   │
│  │                                                 │   │
│  │  - CORS configured for frontend origin         │   │
│  │  - JWT token validation                        │   │
│  │  - Request/response serialization              │   │
│  └─────────────────────────────────────────────────┘   │
│                          │                              │
│                          ▼                              │
│  ┌─────────────────────────────────────────────────┐   │
│  │              PostgreSQL Database                │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Communication Protocol

### Transport

- **Protocol:** HTTP/HTTPS
- **Format:** JSON (application/json)
- **Encoding:** UTF-8

### Authentication Flow

```
1. User submits credentials (email + password)
   Frontend → POST /api/v1/login/access-token
   Body: { username: email, password: password }

2. Backend validates credentials
   - Checks email exists
   - Verifies password hash (Argon2/Bcrypt)
   - Generates JWT token (HS256, 8-day expiry)

3. Backend returns JWT token
   Response: { access_token: "...", token_type: "bearer" }

4. Frontend stores token
   localStorage.setItem("access_token", token)

5. Subsequent requests include token
   Header: Authorization: Bearer <access_token>

6. Backend validates token on each request
   - Decodes JWT
   - Fetches user from DB
   - Checks is_active status
```

### CORS Configuration

```python
# backend/app/main.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.all_cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**Allowed Origins:**
- `http://localhost` (development)
- `http://localhost:5173` (Vite dev server)
- `http://localhost:1080` (Mailcatcher)
- Production domains from `BACKEND_CORS_ORIGINS` env var

## Data Flow Patterns

### Read Operations (GET)

```
Component
    │
    ▼
useQuery({
  queryKey: ["items"],
  queryFn: () => ItemsService.readItems()
})
    │
    ▼
SDK: GET /api/v1/items/
    Header: Authorization: Bearer <token>
    │
    ▼
Backend: Validate token → Query DB → Return JSON
    │
    ▼
Response: { data: [...], count: N }
    │
    ▼
TanStack Query Cache → Component Re-render
```

### Write Operations (POST/PUT/DELETE)

```
Component
    │
    ▼
useMutation({
  mutationFn: (data) => ItemsService.createItem({ requestBody: data }),
  onSuccess: () => queryClient.invalidateQueries(["items"])
})
    │
    ▼
SDK: POST /api/v1/items/
    Header: Authorization: Bearer <token>
    Body: { title: "...", description: "..." }
    │
    ▼
Backend: Validate token → Validate body → Create in DB → Return JSON
    │
    ▼
Response: { id: "...", title: "...", ... }
    │
    ▼
Query Cache Invalidation → Re-fetch → Component Re-render
```

## API Client Generation

### Process

```
1. Backend defines OpenAPI schema
   FastAPI auto-generates at /api/v1/openapi.json

2. Script downloads schema
   bash scripts/generate-client.sh

3. @hey-api/openapi-ts generates TypeScript client
   Output: frontend/src/client/

4. Generated files:
   - sdk.gen.ts: Service methods
   - types.gen.ts: TypeScript interfaces
   - schemas.gen.ts: Zod schemas
   - core/: Request/response handling
```

### Usage in Components

```typescript
// Import generated service
import { ItemsService } from "@/client"

// Use typed methods
const { data } = useQuery({
  queryKey: ["items"],
  queryFn: () => ItemsService.readItems({ skip: 0, limit: 100 })
})

// TypeScript knows the response type
// data.data: ItemPublic[]
// data.count: number
```

## Error Handling

### Global Error Handler

```typescript
// frontend/src/main.tsx
const queryClient = new QueryClient({
  queryCache: new QueryCache({
    onError: (error) => {
      if (error.status === 401 || error.status === 403) {
        // Clear token and redirect to login
        localStorage.removeItem("access_token")
        window.location.href = "/login"
      }
    },
  }),
})
```

### Error Response Format

```json
{
  "detail": "Error message here"
}
```

### HTTP Status Codes

| Code | Meaning | Frontend Action |
|------|---------|-----------------|
| 200 | Success | Process response |
| 400 | Validation Error | Show error message |
| 401 | Unauthorized | Clear token, redirect /login |
| 403 | Forbidden | Show permission error |
| 404 | Not Found | Show not found message |
| 422 | Validation Error | Show field errors |
| 500 | Server Error | Show generic error |

## Environment Configuration

### Development

```
Frontend: http://localhost:5173
Backend:  http://localhost:8000
API URL:  http://localhost:8000 (VITE_API_URL)
```

### Production

```
Frontend: https://dashboard.{DOMAIN}
Backend:  https://api.{DOMAIN}
API URL:  https://api.{DOMAIN} (built into Docker image)
```

## Docker Networking

### Development (compose.override.yml)

```
Services on same Docker network:
- frontend → backend: via service name "backend"
- backend → db: via service name "db"
- Traefik routes: localhost:8000 → backend, localhost:5173 → frontend
```

### Production (compose.yml)

```
Services on traefik-public network:
- Traefik routes:
  - api.{DOMAIN} → backend:8000
  - dashboard.{DOMAIN} → frontend:80
- Auto HTTPS via Let's Encrypt
```

## Security Considerations

### Token Storage

- **Location:** localStorage
- **Risk:** XSS vulnerability
- **Mitigation:** CSP headers, input sanitization

### CORS

- **Strict origin checking**
- **Credentials allowed** (for cookies if needed)
- **All methods/headers allowed** (can be restricted)

### HTTPS

- **Development:** Optional (HTTP)
- **Production:** Required (HTTPS via Traefik + Let's Encrypt)

---

## Links

- [API Contracts](./api-contracts-backend.md)
- [Architecture - Backend](./architecture-backend.md)
- [Architecture - Frontend](./architecture-frontend.md)
