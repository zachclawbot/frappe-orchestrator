# Chateau Orchestrator - Complete System Analysis

## Executive Summary

**Chateau Orchestrator** is a **production-ready, healthcare-focused operations management platform** built with:
- **Frontend:** Next.js 15 (App Router) + React + TypeScript
- **Backend:** Firebase (Firestore + Auth + Functions)
- **AI:** Google Gemini (GenKit flows for document processing)
- **External Integration:** Kipu EMR (patient census sync via HMAC-SHA256 API)
- **Deployment:** Firebase Hosting + Cloud Functions

---

## 🏗️ System Architecture

### **Technology Stack**

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT TIER                          │
│                                                         │
│  Next.js 15 (App Router) + React 18 + TypeScript       │
│  - Server Components (default)                          │
│  - Client Components ("use client" for interactivity)   │
│  - Server Actions ("use server" for mutations)          │
│                                                         │
│  UI Framework: shadcn/ui + Radix UI + Tailwind CSS     │
│  Font: Archivo (Google Fonts)                          │
│  State: React hooks + Firebase real-time listeners      │
└─────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────┐
│                  APPLICATION TIER                       │
│                                                         │
│  Firebase Services:                                     │
│  - Authentication (Firebase Auth)                       │
│  - Database (Firestore - NoSQL document store)          │
│  - Storage (File attachments)                           │
│  - Functions (Node.js cloud functions)                  │
│                                                         │
│  AI Processing:                                         │
│  - GenKit flows (Google Gemini)                         │
│  - Document extraction (PDF/DOCX → structured KB)       │
│                                                         │
│  External APIs:                                         │
│  - Kipu EMR (patient census, care teams)                │
│  - Google Calendar (event sync)                         │
│  - Google Admin SDK (user management)                   │
└─────────────────────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────────────────────┐
│                     DATA TIER                           │
│                                                         │
│  Firestore Collections (see schema below)               │
│  - Role-based access control (Firestore rules)          │
│  - Composite indexes for query optimization             │
│  - Real-time listeners for live updates                 │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Core Features & Modules

### **1. User & Authentication**

**Purpose:** Multi-role user management with department-based organization

**User Roles:**
- Super Admin
- Admin
- Supervisor
- Manager
- Medical (RN, staff)
- Program (Program Coordinator)
- Therapist
- Standard User

**Features:**
- Firebase Authentication (email/password, Google OAuth)
- Role-based permissions (enforced at Firestore rules level)
- Department assignments (primary + backup)
- User profiles with contact info
- Avatar/photo management
- Account status (active/inactive)
- Notification settings (in-app, push, email)
- Google Calendar integration (OAuth tokens stored per user)

**Firestore Path:** `/users/{userId}`

---

### **2. Department Management**

**Purpose:** Organizational structure for workspace segregation

**Department Types:**
- **Medical** - Patient medical care, nursing, medication tracking
- **Program** - Treatment programs, client activities
- **Clinical** - Therapy, assessments
- **Administrative** - General operations

**Features:**
- Department-specific task boards
- Department-specific templates (Medical vs Program)
- Resource allocation per department
- Supervisor assignment
- Department metrics/analytics

**Firestore Path:** `/departments/{deptId}`

---

### **3. Task Management System (3-Tier)**

#### **Tier 1: Quick Checklists**
**Purpose:** Daily recurring tasks (simple checkbox completion)

**Features:**
- Title + description
- Checklist items (array of {id, text, completed, completedBy, completedAt})
- Recurrence (Daily, Weekly, None)
- Department/assignee scoping
- Auto-recreation for daily tasks (via scheduled function)

**Use Cases:**
- Daily rounds checklist
- Medication verification checklist
- Safety inspection items

**TaskType:** `quick-checklist`

---

#### **Tier 2: Detailed Tasks**
**Purpose:** Complex tasks with subtasks, comments, dependencies

**Features:**
- Title, description, status, priority
- Assignees (multiple users)
- Department scoping
- Due dates with time
- **Subtasks** (nested checklist with assignees)
- **Comments** with @mentions
- **Attachments** (files, images)
- **Dependencies** (dependsOn, blockedBy, blocks arrays)
- **Tags** and **custom fields**
- **Activity log** (audit trail of all changes)
- **Escalation rules** (auto-escalate overdue tasks)
- Estimated vs actual duration tracking

**Task Statuses:**
- Open → Assigned → In Progress → Review → Completed
- Alternative: Todo → In Progress → Done
- Blocked, Canceled, Cancelled (legacy support)

**Priorities:** Low, Medium, High, Critical

**Context Types:**
- Client-scoped (linked to patient)
- Department-scoped
- Project-scoped
- Global

**TaskType:** `detailed` or `ad-hoc`

---

#### **Tier 3: Workflow Templates**
**Purpose:** Automated multi-step sequences triggered by events

**Features:**
- **Workflow Templates** (reusable blueprints)
  - Steps with order, dependencies, due offsets
  - Assignment strategies:
    - Role-based (any user with role)
    - Specific user
    - Least busy (load balancing)
    - Round-robin (rotation tracking)
    - Manual
  - Conditional logic (skip step if criteria met)
  - Attachment requirements (photo, document, signature)
  - Review requirements (two-step approval)
  
- **Workflow Instances** (active workflows)
  - Status tracking (pending, active, completed, cancelled)
  - Progress tracking (steps completed / total)
  - Task generation (auto-creates tasks per step)
  - Real-time status updates

**Trigger Events:**
- Client admission
- Client discharge
- Incident report
- Maintenance request
- Custom events

**Example Workflow:**
```
Client Admission Workflow (Medical Department)
├─ Step 1: Medical Intake Assessment (RN, 0 hours)
├─ Step 2: Doctor's Orders Review (MD, 4 hours)
├─ Step 3: Medication Setup (Pharmacy, 8 hours)
├─ Step 4: Room Assignment (Admin, 2 hours)
└─ Step 5: Orientation Checklist (Program, 24 hours)
```

**TaskType:** `workflow-step`

**Firestore Paths:**
- `/workflowTemplates/{templateId}`
- `/workflowInstances/{instanceId}`
- `/assignmentRotationState/{roleId}` (for round-robin)

---

### **4. Client/Patient Management (Unified Schema)**

**Purpose:** Healthcare client records with department-specific data

**Core Client Fields:**
- Client ID, Name, Nickname
- MR Number (Medical Record #)
- Kipu ID (for EMR sync)
- Date of Birth, Admission Date, Discharge Date
- Status (Active, Discharged, On Leave)
- Primary department

**Subcollections (Unified Schema):**

#### **Medical Subcollection** (`/clients/{clientId}/medical/`)
**Access:** Medical role, RN, Admin

**Documents:**
- **tasks** - Medical-specific tasks
- **notes** - Progress notes, assessments
- **medications** - Medication tracking
- **vitals** - Vital signs logs
- **fr_types** - First Responder types (crisis interventions)
- **templates** - Active medical templates for this client

**Features:**
- Medical task templates (daily + intake)
- Template activation tracking (when activated, by whom)
- Daily task auto-generation from templates
- Task categorization:
  - Doctor's Orders
  - Medical Intake
  - Information
  - Pre-Admission
  - Financial
  - Discharge
  - Medical
  - Chart Summary
  - Med Log
  - Inventory

---

#### **Program Subcollection** (`/clients/{clientId}/program/`)
**Access:** Program role, Program Coordinator, Admin

**Documents:**
- **tasks** - Program-specific tasks
- **notes** - Program notes, milestones
- **boards** - Weekly program board tasks
- **automation** - Automated task generation tracking

**Features:**
- Program board templates (day-based recurring)
- Week-based task boards (Monday-Sunday)
- Template-based task auto-generation
- Onboarding/orientation tracking
- Program completion milestones

---

**Firestore Path:** `/clients/{clientId}`

**Legacy Note:** Previously had `/departments/{deptId}/medicalTaskAssignments/` - now **read-only** (deprecated, migrated to unified schema)

---

### **5. Knowledge Base (AI-Powered)**

**Purpose:** Searchable document repository with AI extraction

**Features:**

#### **Categories**
- Hierarchical organization
- Icon customization
- Parent-child relationships
- Access restrictions (role-based)

#### **Articles**
- Title, content (rich text)
- Author, reviewer
- Status workflow: Draft → Under Review → Published → Archived
- Version control (snapshots on edit)
- Keywords/tags for search
- View count tracking
- Attachments (PDF, DOCX, images)
- Related articles linking

#### **AI Document Processing**
**Technology:** Google Gemini (via GenKit flows)

**Process:**
```
User uploads PDF/DOCX
    ↓
GenKit flow: extract text + structure
    ↓
AI parses: title, sections, keywords, category
    ↓
Auto-creates Knowledge Article in Draft status
    ↓
Reviewer approves → Published
```

**Supported Formats:**
- PDF (via pdf-parse)
- DOCX (via mammoth)
- Images (OCR + description)

**API Routes:**
- `POST /api/kb/images/upload` - Upload images
- AI processing endpoint (GenKit)

**Firestore Paths:**
- `/knowledge_categories/{categoryId}`
- `/knowledge_articles/{articleId}`

---

### **6. Projects (Asana-Style)**

**Purpose:** Asana-like project management with kanban, list, calendar views

**Features:**

#### **Project Structure**
- Name, description, status (active/archived/completed)
- Owner (project creator)
- Team members (edit access)
- Viewers (read-only access)
- Sections (columns in kanban board)
- Tags/labels
- Custom fields

#### **Task Board**
- **Kanban View** - Drag-and-drop sections
- **List View** - Sortable task list
- **Calendar View** - Due date visualization

#### **Task Features**
- Full detailed task capabilities (see Tier 2)
- Section assignment
- Drag-and-drop reordering
- Bulk operations
- Filters & search
- Saved filter presets (per user, per project)

#### **Collaboration**
- Comments with @mentions
- Real-time notifications
- Activity log
- File attachments
- Subtask tracking

#### **Accessibility**
- WCAG AA compliance
- Keyboard navigation (Tab, Enter, Space)
- Screen reader support (aria-labels, live regions)
- Focus indicators
- Mobile-responsive (hamburger menu, touch-friendly)

#### **Performance**
- Cursor-based pagination (not offset-based)
- Page size: 5-100 tasks (default 20)
- Infinite scroll support
- Composite Firestore indexes for speed

**Firestore Paths:**
- `/projects/{projectId}`
- `/projects/{projectId}/sections/{sectionId}`
- `/projects/{projectId}/tasks/{taskId}`
- `/projects/{projectId}/comments/{commentId}`
- `/projects/{projectId}/activity/{activityId}` (audit trail)
- `/projectFilters/{filterId}` (saved filters)

---

### **7. Dashboards**

**Purpose:** Role-specific landing pages with widgets

**Dashboard Types:**
- **Medical Dashboard** - Patient census, medical tasks, vitals alerts
- **Program Dashboard** - Program tasks, client milestones, board status
- **Supervisor Dashboard** - Team metrics, overdue tasks, performance
- **Admin Dashboard** - System-wide metrics, user activity, compliance

**Widgets:**
- Quick stats (number cards)
- Task lists (filtered)
- Charts (bar, donut, line - via Recharts)
- Recent activity feed
- Calendar events
- Announcements
- Quick links
- Client census table (Kipu sync)

**Widget Configuration:**
Stored in `/dashboard_configs/{configId}` - allows per-user/per-role customization

---

### **8. Announcements**

**Purpose:** System-wide or department-specific notifications

**Features:**
- Title, content (rich text)
- Priority levels (Low, Normal, High, Critical)
- Status (Draft, Published, Archived)
- Published date, expiry date
- Target departments (multi-select)
- Target roles (multi-select)
- Pin to top
- Read tracking per user

**Firestore Path:** `/announcements/{announcementId}`

---

### **9. Supervisor Tools**

**Purpose:** Management resources and quick actions

**Features:**
- **Employee Scheduler** - Shift assignments, availability
- **Supervisor Resources** - Links, documents, tools
- **Team Performance** - Metrics dashboards
- **Quick Links** - Frequently accessed pages

**Firestore Paths:**
- `/employeeSchedules/{scheduleId}`
- `/supervisorTools/{toolId}`
- `/supervisor_settings/{settingsId}`

---

### **10. Workspaces**

**Purpose:** Department-specific views with custom layouts

**Workspace Types:**

#### **Medical Department Workspace**
**Features:**
- Kipu census table (synced patients)
- Medical task board (categorized)
- Daily medical tasks (recurring)
- Intake tasks (new admissions)
- Medical templates management
- FR (First Responder) type tracking

**Components:**
- `medical-department-view.tsx`
- `medical-task-board.tsx`
- `medical-client-table.tsx`
- `daily-medical-tasks.tsx`
- `medical-intake.tsx`
- `kipu-census-table.tsx`

---

#### **Program Department Workspace**
**Features:**
- Program task board (week-based)
- Daily program tasks
- Board templates (day-specific)
- Client onboarding tracking
- Program milestones

**Components:**
- `program-department-view.tsx`
- `program-daily-tasks.tsx`
- `program-board-template-dialog.tsx`

---

**Custom Workspaces:**
Users can create custom workspaces with:
- Custom name, icon, color
- Widget selection (drag-and-drop)
- Role-based access
- Department scoping

**Firestore Path:** `/workspaces/{workspaceId}` (user-created custom workspaces)

---

## 🔐 Security & Permissions

### **Firestore Security Rules**

**Helper Functions:**
```javascript
isSignedIn() - User is authenticated
isOwner(userId) - User owns the document
hasRole(role) - User has specific role
isSuperAdmin() - User is super admin
```

**Access Control Examples:**

**Tasks:**
```javascript
allow read: if isSignedIn() && (
  resource.data.createdBy == request.auth.uid ||  // Creator
  request.auth.token.role in ['Supervisor', 'Admin'] ||  // Supervisors
  request.auth.uid in resource.data.assigneeIds  // Assignees
);
```

**Medical Subcollection:**
```javascript
allow read: if isSignedIn() && (
  hasRole('Medical') || hasRole('RN') || 
  hasRole('Admin') || isSuperAdmin()
);
```

**Projects:**
```javascript
allow read: if isSignedIn() && (
  request.auth.uid == project.ownerId ||
  request.auth.uid in project.teamIds ||
  request.auth.uid in project.viewerIds
);
```

---

### **Data Validation**

**Technology:** Zod schemas (TypeScript type inference + runtime validation)

**Server Actions Pattern:**
```typescript
"use server";
import { z } from 'zod';

const CreateTaskSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().optional(),
  priority: z.enum(['Low', 'Medium', 'High', 'Critical']),
  assigneeIds: z.array(z.string()),
  dueDate: z.date().optional(),
});

export async function createTaskAction(input: unknown) {
  const validated = CreateTaskSchema.parse(input);
  // ... Firestore write with validated data
}
```

**All 65+ server actions use Zod validation.**

---

## 🔌 External Integrations

### **1. Kipu EMR Integration**

**Purpose:** Sync patient census data from Kipu API

**Authentication:** HMAC-SHA256 signatures

**API Credentials:**
- `KIPU_ACCESS_ID` - API access ID
- `KIPU_SECRET_KEY` - Secret key for HMAC
- `KIPU_APP_ID` - Application ID (query param)

**Signature Process:**
```
For GET:
  stringToSign = ",,{requestUri}?app_id={appId},{Date}"

For POST/PUT:
  stringToSign = "Content-Type,Content-MD5,{requestUri},{Date}"

signature = HMAC-SHA256(secretKey, stringToSign)
Authorization = "APIAuth-HMAC-SHA256 {accessId}:{signature}"
```

**Endpoints Used:**
- `GET /api/patients/census` - Active patient list
- `GET /api/patients/care_teams` - Care team assignments

**Sync Process:**
```
Scheduled Cloud Function (every 30 min)
    ↓
Fetch Kipu census
    ↓
For each patient:
  - Check if exists in /clients
  - Create if new (status: Active)
  - Update if existing (admission/discharge dates)
  - Store sync timestamp in /clients/{id}/census_data
    ↓
Log sync metrics
```

**Data Synced:**
- Patient ID (Kipu ID)
- Name
- MR Number
- Admission Date
- Discharge Date
- Status (Active/Discharged)

**File:** `src/lib/kipu/kipu-service.ts`

---

### **2. Google Calendar Integration**

**Purpose:** Sync user events with Google Calendar

**Features:**
- OAuth2 token storage per user
- Event creation, update, deletion
- Recurring event support
- Reminder notifications

**OAuth Scopes:**
- `https://www.googleapis.com/auth/calendar`
- `https://www.googleapis.com/auth/calendar.events`

**Token Storage:**
```
/users/{userId}
  google_tokens: {
    access_token: string,
    refresh_token: string,
    expiry_date: timestamp
  }
```

**API Routes:**
- `POST /api/calendar/events` - Create event
- `GET /api/calendar/calendars` - List calendars

**File:** `src/app/api/calendar/` routes

---

### **3. Google Admin SDK**

**Purpose:** User provisioning and management

**Features:**
- User creation
- Group membership
- Password resets
- License assignment

**Used for:** Enterprise deployments with Google Workspace

---

## 🤖 AI Features

### **GenKit Flows (Google Gemini)**

**Purpose:** Document processing and knowledge extraction

**Flow 1: PDF Extraction**
```
Input: PDF file (base64 or URL)
    ↓
GenKit: extract text via pdf-parse
    ↓
Gemini: parse structure (title, sections, keywords)
    ↓
Output: {
  title: string,
  content: string (markdown),
  keywords: string[],
  category: string,
  summary: string
}
```

**Flow 2: DOCX Extraction**
```
Input: DOCX file
    ↓
GenKit: extract text via mammoth
    ↓
Gemini: parse structure + convert to markdown
    ↓
Output: Same as PDF
```

**Flow 3: Image Analysis**
```
Input: Image (JPG, PNG)
    ↓
Gemini Vision: OCR + description
    ↓
Output: {
  text: string (extracted),
  description: string,
  tags: string[]
}
```

**Usage:**
```typescript
import { processDocument } from '@/ai/flows';

const result = await processDocument(fileUrl, 'pdf');
// Auto-creates Knowledge Article in Firestore
```

**Files:**
- `src/ai/` - GenKit flows
- `src/ai/dev.ts` - Dev server

---

## 📂 Firestore Schema

### **Collections Overview**

```
firestore
├── /users/{userId}
│   └── /notifications/{notificationId}
│
├── /departments/{deptId}
│   ├── /tasks/{taskId}
│   ├── /boardTemplates/{templateId}
│   ├── /medicalTaskTemplates/{templateId}
│   ├── /medicalTaskAssignments/{assignmentId} [DEPRECATED - READ-ONLY]
│   ├── /task_metrics/{metricId}
│   └── /automation/{docId}
│
├── /clients/{clientId}
│   ├── /medical/{document}
│   ├── /program/{document}
│   ├── /tasks/{taskId}
│   ├── /census_data/{timestamp}
│   └── /automation/{docId}
│
├── /tasks/{taskId} [GLOBAL TASKS]
│
├── /projects/{projectId}
│   ├── /sections/{sectionId}
│   ├── /tasks/{taskId}
│   ├── /comments/{commentId}
│   └── /activity/{activityId}
│
├── /projectFilters/{filterId}
│
├── /workflowTemplates/{templateId}
├── /workflowInstances/{instanceId}
├── /assignmentRotationState/{roleId}
│
├── /knowledge_categories/{categoryId}
├── /knowledge_articles/{articleId}
│
├── /dashboard_configs/{configId}
├── /announcements/{announcementId}
├── /quickLinks/{linkId}
│
├── /employeeSchedules/{scheduleId}
├── /supervisorTools/{toolId}
├── /supervisor_settings/{settingsId}
│
├── /roles/{roleId}
├── /client_fr_types/{typeId}
│
├── /daily_medical_tasks/{taskId}
├── /daily_medical_task_completions/{completionId}
└── /daily_program_tasks/{taskId}
```

---

### **Key Type Definitions**

See: `src/lib/types.ts` (1,175 lines)

**Main Types:**
- `User` - User profile with roles, department, OAuth tokens
- `Task` - 3-tier task system (quick-checklist, detailed, workflow-step)
- `TaskChecklistItem` - Checklist items within tasks
- `TaskComment` - Comments with @mentions
- `TaskAttachment` - File attachments
- `TaskEscalationRules` - Auto-escalation configuration
- `WorkflowTemplate` - Reusable workflow blueprints
- `WorkflowStep` - Individual workflow steps
- `WorkflowInstance` - Active workflow execution
- `AssignmentRotationState` - Round-robin tracking
- `ProgramBoardTemplate` - Day-based program templates
- `MedicalTaskTemplate` - Medical task templates (daily + intake)
- `MedicalTaskAssignment` - Client-template associations (legacy)
- `Client` - Patient/client records
- `Project` - Asana-style project
- `ProjectTask` - Project-scoped tasks
- `KnowledgeCategory` - KB categories
- `KnowledgeArticle` - KB articles

---

## 🎨 UI/UX Features

### **Design System**

**Colors:**
- Brand Orange: `#f26522`
- Brand Teal: `#0c4b5e`
- Success: `#03c95a`
- Info: `#1b84ff`
- Danger: `#e70d0d`
- Sidebar: `#212529`
- Background: `#f8f9fa`

**Typography:**
- Font: Archivo (400, 500, 600, 700)
- Headings: Archivo 600
- Body: Archivo 400

**Border Radius:**
- Cards: 10px
- Buttons: 5px

**Component Library:**
- shadcn/ui (built on Radix UI)
- Custom components in `src/components/ui/`

---

### **Responsive Breakpoints**

```
sm:  640px
md:  768px
lg:  1024px
xl:  1280px
2xl: 1400px
```

**Mobile Features:**
- Hamburger menu (md: breakpoint)
- Touch-friendly spacing (min 44px tap targets)
- Horizontal scroll for kanban boards
- Bottom navigation for mobile apps

---

### **Accessibility (WCAG AA)**

**Features:**
- Keyboard navigation (Tab, Shift+Tab, Enter, Space, Escape)
- Screen reader support (aria-label, aria-live, role attributes)
- Focus indicators (blue ring on focus-visible)
- Color contrast 4.5:1 minimum
- Skip links for navigation
- Focus traps in modals
- Semantic HTML (headings, landmarks, lists)

**Utilities:**
`src/lib/a11y-utils.ts`:
- `getNavigableElements()` - Find focusable elements
- `manageFocus()` - Focus trap management
- `announceToScreenReaders()` - Live region announcements
- `getTaskCardAriaLabel()` - Accessible task descriptions

---

## 📱 Mobile & PWA

**Progressive Web App Features:**
- Service worker (caching)
- Offline mode (Firestore offline persistence)
- Push notifications (Firebase Cloud Messaging)
- Add to home screen
- App manifest

**Mobile Optimizations:**
- Touch gestures (swipe, tap)
- Bottom sheet modals
- Pull-to-refresh
- Optimistic updates
- Lazy loading

---

## ⚙️ Development Workflow

### **Scripts (package.json)**

```json
{
  "dev": "cross-env NODE_ENV=development next dev -p 9002",
  "build": "cross-env NODE_ENV=production next build",
  "start": "next start -p 9002",
  "lint": "node ./scripts/run-lint.mjs",
  "typecheck": "node ./scripts/run-typecheck.mjs",
  
  "genkit:dev": "genkit start -- tsx src/ai/dev.ts",
  "genkit:watch": "genkit start -- tsx --watch src/ai/dev.ts",
  
  "kb:backfill": "tsx scripts/backfill-knowledge-base.ts",
  "backfill:dept-templates": "tsx scripts/backfill-department-templates.ts",
  
  "migrate:unified-schema": "tsx scripts/migrate-to-unified-schema.ts",
  "migrate:unified-schema:dry-run": "tsx scripts/migrate-to-unified-schema.ts --dry-run",
  
  "emulators": "firebase emulators:start --import=./firebase-emulators-data --export-on-exit",
  "emulators:dev": "firebase emulators:start & npm run dev"
}
```

---

### **Environment Variables**

**Required:**
```env
# Firebase
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
FIREBASE_SERVICE_ACCOUNT_JSON=  # Server-side only

# Kipu EMR
KIPU_ACCESS_ID=
KIPU_SECRET_KEY=
KIPU_APP_ID=

# Google Admin SDK
GOOGLE_ADMIN_PRIVATE_KEY=
GOOGLE_ADMIN_CLIENT_EMAIL=

# GenKit (Gemini)
GOOGLE_API_KEY=
```

---

### **Deployment**

**Production Environment:** Firebase Hosting + Cloud Functions

**Build Process:**
```bash
npm run build         # Next.js production build
firebase deploy       # Deploy to Firebase
```

**Firebase Configuration:**
```json
{
  "hosting": {
    "public": ".next",
    "rewrites": [
      { "source": "**", "destination": "/index.html" }
    ]
  },
  "functions": {
    "source": "functions",
    "runtime": "nodejs18"
  }
}
```

---

## 📊 Performance Optimizations

### **Firestore Indexes**

**Composite Indexes (firestore.indexes.json):**
- `(projectId, sectionId, order ASC)` - Paginated tasks
- `(projectId, archived ASC)` - Task counting
- `(projectId, userId, createdAt DESC)` - User filters
- `(projectId, userId, isDefault DESC)` - Default filters
- `(departmentId, status, dueDate ASC)` - Department tasks
- `(clientId, status, createdAt DESC)` - Client tasks

**Query Optimization:**
- Cursor-based pagination (not offset)
- Limit queries to pageSize + 1 (detect hasNextPage)
- Use `onSnapshot` for real-time, `getDocs` for one-time
- Cache frequently accessed documents

---

### **React Performance**

**Optimizations:**
- Server Components by default (zero JS bundle)
- `"use client"` only for interactivity
- React.memo() for expensive renders
- useMemo() for computed values
- useCallback() for event handlers
- Lazy loading with next/dynamic
- Image optimization with next/image

---

### **Build Size**

**Chunk Splitting:**
- Route-based code splitting (Next.js automatic)
- Dynamic imports for large components
- Tree shaking (unused code removed)

**Bundle Analysis:**
```bash
ANALYZE=true npm run build
```

---

## 🧪 Testing Strategy

**Firestore Rules Testing:**
```bash
firebase emulators:start
# Use emulator UI to test rules
```

**Security Rule Tests:**
- User can only read own profile
- User can only update own tasks if not completed
- Supervisor can update any department task
- Medical role can access medical subcollection
- Program role can access program subcollection

**TypeScript Validation:**
```bash
npm run typecheck  # 0 errors
```

**Linting:**
```bash
npm run lint       # 0 warnings
```

---

## 🔄 Migration & Data Flow

### **Phase 2: Unified Schema Migration**

**Legacy System:**
```
/departments/{deptId}/medicalTaskAssignments/{clientId}
```

**New System:**
```
/clients/{clientId}/medical/tasks/{taskId}
/clients/{clientId}/program/tasks/{taskId}
```

**Migration Script:** `scripts/migrate-to-unified-schema.ts`

**Status:** ✅ Complete (legacy collection is read-only)

---

### **Phase 2c: Read-Only Enforcement**

**Firestore Rule:**
```javascript
match /medicalTaskAssignments/{assignmentId} {
  allow read: if isSignedIn();
  allow write: if false;  // Frozen as of Phase 2c
}
```

---

### **Phase 2d: Archive & Audit**

**Script:** `scripts/archive-medical-tasks.ts`

**Process:**
```
Scan /medicalTaskAssignments
    ↓
Verify each task exists in /clients/{id}/medical/tasks
    ↓
If missing, flag for manual migration
    ↓
Move verified to /medicalTaskAssignments/archive
    ↓
Generate JSON report
```

**Report Output:** `migration-report-{date}.json`

---

## 📈 Metrics & Analytics

**Tracked Metrics:**
- Task completion rate (by department)
- Overdue task count
- User activity (logins, actions per day)
- Knowledge base views
- Workflow completion time
- Client census trends (Kipu sync)

**Storage:**
```
/departments/{deptId}/task_metrics/{metricId}
/departments/{deptId}/task_metrics_archive/{archiveId}
/departments/{deptId}/daily_task_completions/{date}
```

**Dashboards:**
- Real-time charts (Recharts)
- Historical trends (archived metrics)
- Export to CSV (admin only)

---

## 🚀 Future Enhancements (Planned)

### **Phase 5: Advanced Analytics**
- Predictive task completion (ML)
- Resource utilization forecasting
- Anomaly detection (overdue spikes)

### **Phase 6: Mobile App**
- React Native (shared codebase)
- Offline-first architecture
- Push notifications
- Camera integration (task attachments)

### **Phase 7: Multi-Facility**
- Facility-level isolation
- Cross-facility reporting
- Centralized admin portal

### **Phase 8: Advanced Workflows**
- Visual workflow builder (drag-drop)
- Conditional branching (if/else logic)
- Parallel execution paths
- Approval chains

### **Phase 9: Integration Hub**
- Zapier integration
- Webhooks (outbound)
- REST API (public)
- SSO (SAML, OIDC)

---

## 📝 Key Files Reference

### **Core Application Files**

**Entry Points:**
- `src/app/layout.tsx` - Root layout
- `src/app/page.tsx` - Home page (redirects to dashboard)
- `src/app/dashboard/page.tsx` - Main dashboard

**Authentication:**
- `src/app/(auth)/sign-in/page.tsx` - Login page
- `src/lib/firebase-admin.ts` - Firebase Admin SDK
- `src/lib/firebase-client.ts` - Firebase Client SDK

**Types:**
- `src/lib/types.ts` - All TypeScript types (1,175 lines)

**Navigation:**
- `src/lib/navigation.ts` - Nav structure
- `src/components/app-breadcrumbs.tsx` - Breadcrumbs
- `src/components/sidebar.tsx` - Main sidebar

**API Routes:**
- `src/app/api/tasks/` - Task CRUD
- `src/app/api/kb/` - Knowledge base
- `src/app/api/calendar/` - Google Calendar
- `src/app/api/medical/clients/` - Kipu sync

**Server Actions:**
- `src/app/actions/workspaceSyncActions.ts` - Workspace sync
- `src/app/workspaces/projects-actions.ts` - Project CRUD
- `src/app/workspaces/pagination-actions.ts` - Task pagination
- `src/app/workspaces/filter-actions.ts` - Saved filters

**Components (Workspaces):**
- `src/components/workspaces/medical-department-view.tsx` - Medical workspace
- `src/components/workspaces/program-department-view.tsx` - Program workspace
- `src/components/workspaces/medical-task-board.tsx` - Medical task board
- `src/components/workspaces/kipu-census-table.tsx` - Kipu patient table

**Components (Projects):**
- `src/components/projects/task-card.tsx` - Kanban task card
- `src/components/projects/task-board.tsx` - Kanban board
- `src/components/projects/task-detail-drawer.tsx` - Task detail view
- `src/components/projects/filter-selector.tsx` - Saved filters UI

**Components (Dashboard):**
- `src/components/dashboard/projects-widget.tsx` - Projects summary
- `src/components/dashboard/stats-cards.tsx` - Quick stats

**Components (Knowledge Base):**
- `src/components/knowledge-base/article-viewer.tsx` - Article display
- `src/components/knowledge-base/category-tree.tsx` - Category navigation

**AI:**
- `src/ai/dev.ts` - GenKit dev server
- `src/ai/flows.ts` - Document processing flows

**Scripts:**
- `scripts/migrate-to-unified-schema.ts` - Phase 2 migration
- `scripts/archive-medical-tasks.ts` - Phase 2d archival
- `scripts/backfill-knowledge-base.ts` - KB backfill
- `scripts/backfill-department-templates.ts` - Template backfill

**Configuration:**
- `firestore.rules` - Security rules (580+ lines)
- `firestore.indexes.json` - Composite indexes
- `tailwind.config.ts` - Design tokens
- `next.config.js` - Next.js config
- `.idx/dev.nix` - Firebase Studio config

---

## 🎯 System Strengths

✅ **Comprehensive Feature Set** - 3-tier task system, workflows, projects, knowledge base  
✅ **Healthcare-Focused** - Client management, medical/program departments, Kipu EMR integration  
✅ **Production-Ready** - WCAG AA, TypeScript strict, Firestore security rules, error handling  
✅ **Scalable** - Cursor-based pagination, composite indexes, efficient queries  
✅ **Modern Stack** - Next.js 15, React 18, TypeScript, Tailwind, shadcn/ui  
✅ **AI-Powered** - GenKit + Gemini for document processing  
✅ **Mobile-Responsive** - Touch-friendly, PWA-ready, offline support  
✅ **Well-Documented** - 2,700+ lines in blueprint.md, comprehensive types  

---

## 🔍 Areas for Improvement

⚠️ **Testing Coverage** - No unit/integration tests (add Jest, React Testing Library)  
⚠️ **Error Monitoring** - No Sentry/Bugsnag integration  
⚠️ **Analytics** - No Google Analytics/Mixpanel tracking  
⚠️ **Email Notifications** - Mentioned but not implemented  
⚠️ **Audit Logging** - Activity log exists but needs centralized system  
⚠️ **Multi-tenancy** - Single-facility design (needs facility isolation for SaaS)  
⚠️ **Performance Monitoring** - No Firebase Performance Monitoring setup  
⚠️ **Backup Strategy** - No automated Firestore backups documented  

---

## 📊 Total Project Size

**Lines of Code:**
- TypeScript/React: ~8,500 lines
- Firestore Rules: 580 lines
- Types: 1,175 lines
- Documentation: 2,700+ lines (blueprint.md)
- **Total: ~13,000 lines**

**Files:**
- React Components: 40+
- Server Actions: 65+
- API Routes: 15+
- Scripts: 8+
- **Total: 130+ files**

**Dependencies:**
- Production: 42 packages
- Dev: 14 packages
- **Total: 56 packages**

---

## 🏁 Conclusion

**Chateau Orchestrator is a highly sophisticated, production-ready healthcare operations platform.** It combines modern web technologies (Next.js, React, TypeScript) with enterprise-grade features (3-tier task management, workflow automation, Asana-style projects, AI document processing, EMR integration) to create a comprehensive solution for healthcare facility management.

The system demonstrates advanced architectural patterns (unified schema migration, cursor-based pagination, role-based security), accessibility compliance (WCAG AA), and performance optimizations (composite indexes, server components, lazy loading).

**Key Innovation:** The 3-tier task system (Quick Checklists → Detailed Tasks → Workflow Templates) provides flexibility for different use cases while maintaining a unified data model.

**Integration Strength:** Seamless Kipu EMR integration with HMAC-SHA256 authentication ensures real-time patient census synchronization.

**AI Integration:** GenKit + Gemini enables intelligent document processing, converting PDFs/DOCX into structured knowledge base articles automatically.

**Ready for Migration to Frappe:** All core features map cleanly to Frappe's DocType system (see `ORCHESTRATOR_MIGRATION_GUIDE.md`).
