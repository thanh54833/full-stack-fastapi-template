# Component Inventory - Frontend

## UI Components (shadcn/ui)

These are base primitives from shadcn/ui (Radix UI + Tailwind). Located in `src/components/ui/`.

| Component | File | Purpose |
|-----------|------|---------|
| Alert | `alert.tsx` | Alert messages with variants |
| Avatar | `avatar.tsx` | User avatar display |
| Badge | `badge.tsx` | Status badges |
| Button | `button.tsx` | Buttons with variants (default, destructive, outline, secondary, ghost, link) |
| Button Group | `button-group.tsx` | Grouped button layouts |
| Card | `card.tsx` | Card containers |
| Checkbox | `checkbox.tsx` | Checkbox inputs |
| Dialog | `dialog.tsx` | Modal dialogs |
| Dropdown Menu | `dropdown-menu.tsx` | Dropdown menus |
| Form | `form.tsx` | React Hook Form integration |
| Input | `input.tsx` | Text inputs |
| Label | `label.tsx` | Form labels |
| Loading Button | `loading-button.tsx` | Button with loading state |
| Pagination | `pagination.tsx` | Pagination controls |
| Password Input | `password-input.tsx` | Password input with visibility toggle |
| Select | `select.tsx` | Dropdown selects |
| Separator | `separator.tsx` | Visual separators |
| Sheet | `sheet.tsx` | Slide-out panels |
| Sidebar | `sidebar.tsx` | Collapsible sidebar |
| Skeleton | `skeleton.tsx` | Loading placeholders |
| Sonner | `sonner.tsx` | Toast notifications |
| Table | `table.tsx` | Data table structure |
| Tabs | `tabs.tsx` | Tab navigation |
| Theme Provider | `theme-provider.tsx` | Dark/light theme context |
| Tooltip | `tooltip.tsx` | Tooltip overlays |

---

## Common Components

Shared components used across features. Located in `src/components/Common/`.

| Component | File | Purpose |
|-----------|------|---------|
| Appearance | `Appearance.tsx` | Theme toggle (dark/light) |
| AuthLayout | `AuthLayout.tsx` | Layout wrapper for auth pages |
| DataTable | `DataTable.tsx` | Reusable data table with TanStack Table |
| ErrorComponent | `ErrorComponent.tsx` | Error boundary display |
| Footer | `Footer.tsx` | Page footer |
| Logo | `Logo.tsx` | Application logo |
| NotFound | `NotFound.tsx` | 404 page component |

---

## Sidebar Components

Navigation sidebar. Located in `src/components/Sidebar/`.

| Component | File | Purpose |
|-----------|------|---------|
| AppSidebar | `AppSidebar.tsx` | Main sidebar container with navigation |
| Main | `Main.tsx` | Navigation menu items |
| User | `User.tsx` | User info display in sidebar footer |

---

## Items Components

Items CRUD feature. Located in `src/components/Items/`.

| Component | File | Purpose |
|-----------|------|---------|
| AddItem | `AddItem.tsx` | Item creation form (dialog) |
| EditItem | `EditItem.tsx` | Item edit form (dialog) |
| DeleteItem | `DeleteItem.tsx` | Item deletion confirmation |
| ItemActionsMenu | `ItemActionsMenu.tsx` | Row actions dropdown (edit/delete) |
| columns | `columns.tsx` | TanStack Table column definitions |

---

## Admin Components

Admin panel for user management. Located in `src/components/Admin/`.

| Component | File | Purpose |
|-----------|------|---------|
| AddUser | `AddUser.tsx` | User creation form (dialog) |
| EditUser | `EditUser.tsx` | User edit form (dialog) |
| DeleteUser | `DeleteUser.tsx` | User deletion confirmation |
| UserActionsMenu | `UserActionsMenu.tsx` | Row actions dropdown (edit/delete) |
| columns | `columns.tsx` | TanStack Table column definitions |

---

## User Settings Components

User profile and settings. Located in `src/components/UserSettings/`.

| Component | File | Purpose |
|-----------|------|---------|
| UserInformation | `UserInformation.tsx` | User profile display/edit |
| ChangePassword | `ChangePassword.tsx` | Password change form |
| DeleteAccount | `DeleteAccount.tsx` | Account deletion trigger |
| DeleteConfirmation | `DeleteConfirmation.tsx` | Deletion confirmation dialog |

---

## Pending Components

Pending approval items. Located in `src/components/Pending/`.

| Component | File | Purpose |
|-----------|------|---------|
| PendingUsers | `PendingUsers.tsx` | List of pending user registrations |
| PendingItems | `PendingItems.tsx` | List of pending item approvals |

---

## Custom Hooks

Located in `src/hooks/`.

| Hook | File | Purpose |
|------|------|---------|
| useAuth | `useAuth.ts` | Auth state: login, logout, signup, currentUser |
| useCustomToast | `useCustomToast.ts` | Toast notification helpers (success, error) |
| useMobile | `useMobile.ts` | Mobile device detection (media query) |
| useCopyToClipboard | `useCopyToClipboard.ts` | Clipboard copy with timeout |

---

## Routes (Pages)

Located in `src/routes/`. TanStack file-based routing.

| Route | File | Auth | Description |
|-------|------|------|-------------|
| `/` | `_layout/index.tsx` | Yes | Dashboard home |
| `/items` | `_layout/items.tsx` | Yes | Items management |
| `/settings` | `_layout/settings.tsx` | Yes | User settings |
| `/admin` | `_layout/admin.tsx` | Yes (superuser) | Admin panel |
| `/login` | `login.tsx` | No | Login page |
| `/signup` | `signup.tsx` | No | Registration page |
| `/reset-password` | `reset-password.tsx` | No | Reset password form |
| `/recover-password` | `recover-password.tsx` | No | Password recovery request |

---

## Component Patterns

### Data Table Pattern

```tsx
// columns.tsx - Define columns
export const columns: ColumnDef<Item>[] = [
  { accessorKey: "title", header: "Title" },
  { accessorKey: "description", header: "Description" },
  { id: "actions", cell: ({ row }) => <ItemActionsMenu item={row.original} /> }
]

// items.tsx - Use DataTable
<DataTable columns={columns} data={items.data} />
```

### Form Pattern (React Hook Form + Zod)

```tsx
// Define schema
const formSchema = z.object({
  title: z.string().min(1).max(255),
  description: z.string().max(255).optional(),
})

// Use in component
const form = useForm<z.infer<typeof formSchema>>({
  resolver: zodResolver(formSchema),
})

// Submit handler
const mutation = useMutation({
  mutationFn: (data) => ItemsService.createItem({ requestBody: data }),
})
```

### Dialog Pattern

```tsx
<Dialog open={open} onOpenChange={setOpen}>
  <DialogTrigger asChild>
    <Button>Add Item</Button>
  </DialogTrigger>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Add New Item</DialogTitle>
    </DialogHeader>
    <AddItem onSuccess={() => setOpen(false)} />
  </DialogContent>
</Dialog>
```

---

## Design System

### Colors

- **Primary:** OKLCH-based with CSS variables
- **Dark Mode:** Default theme
- **Variables:** Defined in `src/index.css`

### Typography

- **Font:** System default (no custom font)
- **Sizes:** Tailwind defaults (text-sm, text-base, text-lg, etc.)

### Spacing

- **Gap:** Tailwind defaults (gap-2, gap-4, gap-6)
- **Padding:** Tailwind defaults (p-2, p-4, p-6)

---

## Links

- [Architecture - Frontend](./architecture-frontend.md)
- [Development Guide](./development-guide-frontend.md)
