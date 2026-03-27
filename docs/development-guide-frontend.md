# Development Guide - Frontend

## Prerequisites

- **Runtime:** Bun (recommended) or Node.js 20+
- **Package Manager:** Bun (bundled)
- **Backend:** Running FastAPI server (for API calls)

## Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# From project root
docker compose watch
```

This starts all services with live reload:
- Frontend: http://localhost:5173
- Backend: http://localhost:8000

### Option 2: Local Development

```bash
cd frontend

# Install dependencies
bun install

# Start dev server
bun run dev
```

Frontend will be available at http://localhost:5173

## Project Structure

```
frontend/
├── src/
│   ├── main.tsx              # Entry point
│   ├── routeTree.gen.ts      # Auto-generated routes (DO NOT EDIT)
│   ├── index.css             # Tailwind CSS + theme
│   ├── lib/
│   │   └── utils.ts          # cn() utility
│   ├── components/
│   │   ├── ui/               # shadcn/ui primitives
│   │   ├── Common/           # Shared components
│   │   ├── Admin/            # Admin features
│   │   ├── Items/            # Items features
│   │   ├── UserSettings/     # User settings
│   │   ├── Pending/          # Pending approvals
│   │   └── Sidebar/          # Navigation
│   ├── routes/               # TanStack file-based routes
│   ├── hooks/                # Custom React hooks
│   └── client/               # Auto-generated API client (DO NOT EDIT)
├── tests/                    # Playwright E2E tests
├── package.json
├── biome.json                # Biome linter config
└── vite.config.ts            # Vite build config
```

## Common Tasks

### Add New Page/Route

1. **Create route file:**
```tsx
// src/routes/_layout/new-page.tsx
import { createFileRoute } from "@tanstack/react-router"

export const Route = createFileRoute("/_layout/new-page")({
  component: NewPage,
})

function NewPage() {
  return <div>New Page</div>
}
```

2. **Route auto-generates** to `routeTree.gen.ts`

3. **Add navigation link:**
```tsx
// In Sidebar/Main.tsx
<Link to="/new-page">New Page</Link>
```

### Add New Component

```tsx
// src/components/Feature/MyComponent.tsx
import { Button } from "@/components/ui/button"

interface MyComponentProps {
  title: string
}

export function MyComponent({ title }: MyComponentProps) {
  return (
    <div>
      <h1>{title}</h1>
      <Button>Click me</Button>
    </div>
  )
}
```

### Add New Hook

```tsx
// src/hooks/useMyHook.ts
import { useState, useEffect } from "react"

export function useMyHook(initialValue: string) {
  const [value, setValue] = useState(initialValue)

  useEffect(() => {
    // Side effect logic
  }, [value])

  return { value, setValue }
}
```

### Add UI Component (shadcn/ui)

```bash
npx shadcn@latest add dialog
npx shadcn@latest add dropdown-menu
npx shadcn@latest add table
```

### Update API Client

After backend changes:

```bash
bash ../scripts/generate-client.sh
```

**NEVER edit `src/client/` manually!**

## Data Fetching

### Query (Read)

```tsx
import { useQuery } from "@tanstack/react-query"
import { ItemsService } from "@/client"

function ItemsList() {
  const { data, isLoading, error } = useQuery({
    queryKey: ["items"],
    queryFn: () => ItemsService.readItems({ skip: 0, limit: 100 }),
  })

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error: {error.message}</div>

  return (
    <ul>
      {data?.data.map((item) => (
        <li key={item.id}>{item.title}</li>
      ))}
    </ul>
  )
}
```

### Mutation (Write)

```tsx
import { useMutation, useQueryClient } from "@tanstack/react-query"
import { ItemsService } from "@/client"

function AddItem() {
  const queryClient = useQueryClient()

  const mutation = useMutation({
    mutationFn: (data: { title: string }) =>
      ItemsService.createItem({ requestBody: data }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["items"] })
    },
  })

  return (
    <Button onClick={() => mutation.mutate({ title: "New Item" })}>
      Add Item
    </Button>
  )
}
```

## Forms

### React Hook Form + Zod

```tsx
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"

const schema = z.object({
  title: z.string().min(1, "Title is required").max(255),
  description: z.string().max(255).optional(),
})

type FormData = z.infer<typeof schema>

function MyForm() {
  const form = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { title: "", description: "" },
  })

  const onSubmit = (data: FormData) => {
    // Submit data
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField
          control={form.control}
          name="title"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Title</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Submit</Button>
      </form>
    </Form>
  )
}
```

## Styling

### Tailwind CSS

```tsx
// Use Tailwind classes
<div className="flex items-center gap-4 p-6 bg-background text-foreground">
  <h1 className="text-2xl font-bold">Title</h1>
</div>

// Conditional classes with cn()
import { cn } from "@/lib/utils"

<div className={cn(
  "base-class",
  isActive && "active-class",
  variant === "primary" ? "primary-class" : "secondary-class"
)} />
```

### CSS Variables (Theme)

Defined in `src/index.css`:

```css
@theme inline {
  --color-background: oklch(0.145 0 0);
  --color-foreground: oklch(0.985 0 0);
  --color-primary: oklch(0.7 0.15 250);
  /* ... */
}
```

Usage:

```tsx
<div className="bg-background text-foreground">
  <button className="bg-primary text-primary-foreground">
    Click me
  </button>
</div>
```

## Testing

### Run E2E Tests

```bash
# Start backend first
docker compose up -d --wait backend

# Run tests
bunx playwright test

# Run with UI
bunx playwright test --ui
```

### Write Tests

```typescript
// tests/my-feature.spec.ts
import { test, expect } from "@playwright/test"

test("should display items list", async ({ page }) => {
  await page.goto("/items")

  // Use data-testid for selection
  const itemsList = page.getByTestId("items-list")
  await expect(itemsList).toBeVisible()
})
```

### Test Utilities

```typescript
// tests/utils/random.ts
export function randomEmail() {
  return `test-${Date.now()}@example.com`
}

// tests/utils/user.ts
export async function getAuthToken(page, email, password) {
  // Login and return token
}
```

## Linting & Formatting

### Biome

```bash
# Check for issues
bun run lint

# Auto-fix issues
bun run lint --write
```

### Biome Config

```json
// biome.json
{
  "linter": { "enabled": true, "rules": { "recommended": true } },
  "formatter": { "indentStyle": "space" },
  "javascript": { "formatter": { "quoteStyle": "double" } }
}
```

## Build

### Development Build

```bash
bun run build
```

### Preview Build

```bash
bun run preview
```

### Production Build (Docker)

```bash
# From project root
docker compose -f compose.yml build frontend
```

## Environment Variables

### Frontend (.env)

```bash
VITE_API_URL=http://localhost:8000
MAILCATCHER_HOST=http://localhost:1080
```

### Access in Code

```typescript
const apiUrl = import.meta.env.VITE_API_URL
```

## Common Issues

### CORS Errors

Ensure backend CORS is configured for frontend origin:

```python
# backend/app/core/config.py
BACKEND_CORS_ORIGINS: list[str] = ["http://localhost:5173"]
```

### API Client Out of Date

```bash
# Regenerate client
bash ../scripts/generate-client.sh
```

### Type Errors

```bash
# Check TypeScript
npx tsc --noEmit

# Restart TS server in VS Code
Ctrl+Shift+P → "TypeScript: Restart TS Server"
```

### Build Errors

```bash
# Clear cache
rm -rf node_modules .vite
bun install
bun run dev
```

## Debugging

### React DevTools

Install browser extension: React Developer Tools

### TanStack Router DevTools

Enabled by default in development (bottom-left corner)

### TanStack Query DevTools

Enabled by default in development (bottom-right corner)

### Console Logging

```typescript
// Debug queries
const { data } = useQuery({
  queryKey: ["items"],
  queryFn: () => ItemsService.readItems(),
  onSuccess: (data) => console.log("Fetched:", data),
})
```

## Links

- [Architecture - Frontend](./architecture-frontend.md)
- [Component Inventory](./component-inventory-frontend.md)
- [Integration Architecture](./integration-architecture.md)
