# 📋 Product Requirement Document: FinSight

> **Version:** 1.0  
> **Date:** 2026-09-29  
> **Author:** AI Product Team  
> **Status:** Draft — Awaiting User Approval  

---

## 1. Executive Summary

**FinSight** is a personal expense and income management application designed for iOS 25+ and macOS 25+ as a universal SwiftUI app. It provides comprehensive financial tracking with deep AI integration powered by Google Gemini for receipt OCR, multi-language translation, auto-categorization, recurring transaction detection, and smart SMS parsing.

The app uses Firebase as its backend (Firestore, Auth, Cloud Functions), Google Drive for receipt image storage via user OAuth, and operates fully offline with background sync. It is a free, personal-use application — not published on the App Store — with an architecture explicitly designed for future Android expansion.

> [!IMPORTANT]
> This PRD is the **single source of truth** for building the iOS/macOS app and the future Android version. All design decisions, feature specifications, and architectural choices are documented here.

---

## 2. App Name Options

| # | Name | Rationale | Verdict |
|---|------|-----------|---------|
| 1 | **⭐ FinSight** | Combines "Finance" + "Insight." Professional, highlights AI-driven analytics, memorable, domain-friendly. | **Recommended** |
| 2 | CentSync | Emphasizes offline-first sync and tracking every cent/paisa. | Runner-up |
| 3 | LedgerLogic | Smart AI categorization (logic) applied to a traditional ledger concept. | Strong |
| 4 | RupeeRadar | Nods to INR primary currency; "radar" suggests constant monitoring. | India-specific |
| 5 | WealthWeave | Weaving together various financial strands (cash, investments, loans). | Abstract |

---

## 3. Vision & Goals

### Vision
To provide a private, highly intelligent, and frictionless financial tracking experience that leverages AI to eliminate manual data entry while offering deep insights into personal spending habits.

### Goals
| Goal | Success Metric |
|------|----------------|
| Eliminate manual data entry | AI handles 80%+ of data extraction from receipts and SMS |
| 100% offline availability | All CRUD operations work without internet |
| Clear financial health view | Dashboard shows monthly health in < 2 seconds |
| Total user data control | Export in 4 formats, 12-month rolling retention with proactive reminders |
| Future-proof architecture | Android port requires only UI layer rewrite, not business logic redesign |

---

## 4. Target Users & Personas

### Primary Persona: "The Meticulous Tracker"
- **Demographics:** Individual professional in India
- **Behavior:** Tracks every transaction, keeps receipts, reconciles against bank/card statements monthly
- **Pain Points:** Manual entry is tedious; receipts are in multiple languages; forgets recurring payments; hard to search old transactions
- **Needs:** AI to reduce data entry, smart reminders, powerful filtering, reliable export for long-term archival
- **Tech Comfort:** High — comfortable with OAuth flows, multiple integrations, side-loading apps

### Secondary Use: Family Tagging
- Single-user app but can tag transactions as "shared" or assign to family member names for household expense attribution.

---

## 5. Platform & Technical Requirements

### 5.1 Platforms
| Platform | Version | Framework | Status |
|----------|---------|-----------|--------|
| iPhone | iOS 25+ | SwiftUI (Universal) | **v1 — Primary** |
| iPad | iPadOS 25+ | SwiftUI (Universal) | **v1 — Adaptive layout** |
| Mac | macOS 25+ | SwiftUI (Mac Catalyst / Native) | **v1 — Primary** |
| Android | TBD | Kotlin / Jetpack Compose | **Future** |

### 5.2 Architecture
- **Pattern:** MVVM (Model-View-ViewModel)
- **Data Layer:** Repository pattern with protocol-based abstractions
- **AI Layer:** Protocol-oriented service (`AIServiceProtocol`) — swap Gemini for any provider
- **Dependency Injection:** Environment-based DI in SwiftUI
- **Feature Modularity:** Each major feature in its own Swift Package / module with feature flags
- **Concurrency:** Swift Concurrency (async/await, actors)

### 5.3 Backend Stack
| Service | Provider | Purpose |
|---------|----------|---------|
| Authentication | Firebase Auth | Email/password, Apple Sign-In, Google Sign-In |
| Database | Cloud Firestore | Real-time NoSQL, offline persistence built-in |
| Cloud Functions | Firebase Functions | Scheduled tasks (recurring detection, data purge) |
| Remote Config | Firebase Remote Config | Feature flags, AI prompt templates |
| Image Storage | Google Drive (User's) | Receipt/item images via OAuth |
| AI | Google Gemini API | OCR, translation, categorization, SMS parsing, exchange rates |
| Exchange Rates | Public API + Gemini fallback | Currency conversion |

### 5.4 Theming
- System-adaptive Light/Dark mode with manual toggle in Settings
- Custom accent color picker (future enhancement)
- Dynamic Type support throughout

---

## 6. Feature Specifications

### 6.1 Authentication & Onboarding

**User Story:** As a user, I want to securely sign in so my financial data remains private and synced across my devices.

**Acceptance Criteria:**
- [ ] Login screen presents three options: Sign in with Apple, Google, and Email/Password
- [ ] Email/password supports registration and password reset flows
- [ ] Successful login navigates to Dashboard
- [ ] Session persists across app restarts (Firebase Auth token refresh)
- [ ] First-time users see a brief onboarding carousel (3 slides: AI features, offline sync, export)
- [ ] Google Drive OAuth prompt appears after first login for image storage setup (skippable)
- [ ] User can complete onboarding without Google Drive — images stored locally with Drive setup deferred

---

### 6.2 Transaction Management (Core)

**User Story:** As a user, I want to record various financial transactions with rich metadata so I have an accurate, searchable ledger.

#### 6.2.1 Transaction Types
| Type | Direction | Examples |
|------|-----------|----------|
| Income / Earnings | Credit (+) | Salary, freelance, refunds, interest, dividends |
| Expense / Debit | Debit (−) | Purchases, bills, subscriptions, dining |
| Transfer | Neutral (0) | Savings → Checking, bank → wallet top-up |
| Investment | Debit (−) | SIPs, mutual funds, stocks, FDs |
| Loan Given | Debit (−) | Money lent to a friend/family |
| Loan Received | Credit (+) | Money borrowed |
| Cashback / Reward | Credit (+) | Card cashback, reward points redeemed |

#### 6.2.2 Transaction Fields
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | UUID | Auto | System-generated |
| `type` | Enum | Yes | One of 7 types above |
| `amount` | Decimal | Yes | Positive number |
| `currency` | String | Yes | Default: INR |
| `exchangeRate` | Decimal | Conditional | Required if currency ≠ INR |
| `equivalentINR` | Decimal | Conditional | Auto-calculated |
| `title` | String | Yes | Short description |
| `description` | String | No | Detailed notes |
| `date` | Date | Yes | Default: today |
| `categories` | [String] | No | Multiple labels allowed |
| `paymentMethods` | [SplitEntry] | No | Array of {methodId, amount} |
| `receiptImageLinks` | [String] | No | Google Drive URLs |
| `localImagePaths` | [String] | No | Local paths (pre-upload or offline) |
| `ocrText` | String | No | Extracted text from receipts |
| `translatedText` | String | No | English translation of OCR text |
| `isRecurring` | Bool | No | Default: false |
| `recurringFrequency` | Enum | Conditional | daily/weekly/monthly/quarterly/yearly |
| `isFlagged` | Bool | No | Default: false |
| `flagNote` | String | No | Reason for flagging |
| `isShared` | Bool | No | Default: false |
| `sharedWith` | String | No | Family member name |
| `isExpected` | Bool | No | For future/expected transactions |
| `expectedBy` | Date | No | Expected completion date |
| `note` | String | No | Free-form note for additional context the user wants to remember |
| `location` | GeoPoint | No | Latitude/longitude of transaction location |
| `locationName` | String | No | Human-readable place name (e.g., "Indiranagar, Bangalore") |
| `locationAddress` | String | No | Full address from reverse geocoding |
| `items` | [LineItem] | No | Array of line items extracted from receipt or manually entered (see Section 6.15) |
| `source` | Enum | No | manual / ocr / sms / share_extension |
| `createdAt` | Timestamp | Auto | |
| `updatedAt` | Timestamp | Auto | |
| `syncStatus` | Enum | Auto | synced / pending / conflict |

**Acceptance Criteria:**
- [ ] All 7 transaction types can be created, edited, and deleted
- [ ] Multi-currency support with automatic exchange rate fetching via Gemini → Public API → Manual input fallback chain
- [ ] Exchange rate is fetched for the transaction date, not today's date
- [ ] Split payments allow distributing amount across 2+ payment methods with amounts summing to total
- [ ] Multiple category labels can be applied per transaction
- [ ] Transactions can be tagged as "shared" with a family member name
- [ ] Free-form "Note" field available for capturing additional context the user wants to remember
- [ ] Location capture via Apple Maps: user can tap a map pin button to attach current GPS location or search/pick a location manually
- [ ] Location is stored as coordinates + human-readable place name (reverse geocoded) + full address
- [ ] Location is optional — never blocks transaction saving
- [ ] Location appears on transaction detail as a tappable mini-map that opens Apple Maps
- [ ] Line items can be attached to any transaction — either AI-extracted from receipt OCR or manually entered by user (see Section 6.15)
- [ ] All transactions are persisted to local Firestore cache immediately (offline-first)
- [ ] Sync to server happens automatically when online

---

### 6.3 Payment Method Management

**User Story:** As a user, I want to define my payment methods once and reuse them across transactions for quick entry and statement reconciliation.

#### Payment Method Types
| Type | Fields |
|------|--------|
| Credit Card | Bank name, Last 4 digits, Card network (Visa/MC/Amex/RuPay) |
| Debit Card | Bank name, Last 4 digits, Card network |
| Bank Transfer | Bank name, Account nickname |
| Online Wallet | Wallet name (Amazon Pay, PhonePe, Google Pay, Paytm, etc.) |
| Cash | Label only |
| UPI | UPI ID or app name |

**Acceptance Criteria:**
- [ ] User can add, edit, delete payment methods in Settings
- [ ] Payment methods appear as selectable options in transaction entry
- [ ] "Split Payment" toggle reveals multi-method entry with individual amounts
- [ ] Split amounts must sum to transaction total (validation)
- [ ] Card-based filtering enables credit card statement reconciliation

---

### 6.4 Image & Receipt Handling

**User Story:** As a user, I want to attach receipt images to transactions, have AI read them, and store them efficiently in my Google Drive.

#### Image Pipeline
```
Capture/Select → Compress/Resize → Local Cache → Upload to Google Drive → Store Drive Link → Delete Local Copy (optional)
```

**Acceptance Criteria:**
- [ ] Images can be captured via in-app camera or selected from photo library
- [ ] Images can be received via iOS Share Extension (from Photos, Files, or other apps)
- [ ] Images are compressed to ≤ 500KB (configurable) while maintaining readability
- [ ] Resolution capped at 1920px on longest edge
- [ ] Compressed image stored locally until Drive upload succeeds
- [ ] On upload, image goes to a dedicated FinSight folder in user's Google Drive
- [ ] Drive shareable link is stored in the transaction document
- [ ] If Drive is not connected, images remain local with a persistent reminder to connect
- [ ] Multiple images per transaction (e.g., multi-page receipt)
- [ ] Image viewer within the app loads from Drive link (with local cache)

---

### 6.5 AI Integration (Gemini)

**User Story:** As a user, I want AI to read my receipts, parse SMS, suggest categories, and detect patterns so I spend less time on manual entry.

#### 6.5.1 Receipt OCR & Translation
- Send compressed image to Gemini Vision API
- Extract all text, preserving structure (merchant, items, totals, dates)
- **Line Item Extraction:** AI identifies individual products/items on the receipt and extracts: item name, quantity, unit price, and line total. These are pre-populated as `LineItem` entries on the transaction draft (see Section 6.15).
- Detect source language(s)
- If non-English, translate to English (including item names)
- Present extracted data as pre-filled transaction draft with suggested line items for user review
- **Fallback:** If Gemini fails (API error, unreadable image), show a manual entry form with the image displayed for reference. User can still add items manually.

#### 6.5.2 Auto-Categorization
- On each new transaction, send title + description + OCR text + recent correction history to Gemini
- Return 1-3 suggested category labels
- Display suggestions with a ✨ sparkle icon; user taps to accept or edits
- Store user corrections as training context (few-shot learning via prompt context)
- Corrections stored in a local `CategoryCorrections` collection (last 100 corrections included in prompts)

#### 6.5.3 Recurring Transaction Detection
- **Trigger:** Cloud Function runs on the 1st of every month
- **Logic:** Analyze last 6 months of transactions for patterns (same merchant + similar amount + regular intervals)
- **Output:** List of suggested recurring transactions shown as in-app cards
- **User Action:** Accept (creates RecurringRule) or Dismiss

#### 6.5.4 Smart SMS Parsing
- User shares an SMS via iOS Share Extension → app receives text
- Gemini parses: amount, merchant, date, card last-4, transaction type (debit/credit)
- Pre-fills a transaction draft for user review
- Handles multiple SMS formats (different banks have different templates)

#### 6.5.5 Exchange Rate Lookup
- **Chain:** Gemini API → Public Exchange Rate API (e.g., exchangerate.host) → Manual Input
- Fetch rate for the specific transaction date
- Cache rates locally for 24 hours

#### 6.5.6 Expected Transaction Matching
- When a new credit transaction is recorded, compare against open "Expected" transactions
- If amount and timing match, notify user: "The transaction you were tracking (₹X from Y) seems to have completed. Please check and confirm."

**Acceptance Criteria:**
- [ ] OCR works on receipts in English, Hindi, Tamil, Kannada, Telugu, and other Indian languages
- [ ] Translation produces readable English output (including translated item names)
- [ ] OCR extracts individual line items from receipts (item name, quantity, unit price, line total) and pre-populates the Items section
- [ ] Auto-categorization accuracy improves with user corrections over time
- [ ] Recurring detection identifies at least monthly patterns (same merchant ± 10% amount variance)
- [ ] SMS parsing handles top 10 Indian bank SMS formats
- [ ] All AI operations have clear loading states and graceful fallbacks
- [ ] AI prompt templates stored in Firebase Remote Config for live updates

---

### 6.6 Budget Tracking

**User Story:** As a user, I want to set spending budgets and see visual progress so I can control my finances.

**Budget Types:**
| Scope | Period | Example |
|-------|--------|---------|
| Overall | Monthly | ₹50,000/month total |
| Overall | Weekly | ₹12,000/week total |
| Per Category | Monthly | ₹8,000/month on Food |
| Per Category | Weekly | ₹2,000/week on Transport |

**Acceptance Criteria:**
- [ ] User can create, edit, delete budgets
- [ ] Dashboard shows top 3 category budget progress bars
- [ ] Budget detail screen shows all budgets with progress bars
- [ ] Color coding: Green (< 60%), Yellow (60-80%), Orange (80-95%), Red (> 95%)
- [ ] Push notification at 80% and 100% of budget threshold
- [ ] Budget resets automatically at period boundary (week/month start)
- [ ] Budget calculations only include Expense-type transactions

---

### 6.7 Search & Filtering

**User Story:** As a user, I want to search and filter my transactions with multiple criteria and see aggregate totals on results.

**Filter Dimensions:**
| Filter | Type | Notes |
|--------|------|-------|
| Date Range | Date picker (from–to) | |
| Transaction Type | Multi-select | Income, Expense, etc. |
| Category | Multi-select | From user's categories |
| Payment Method | Single or multi-select | Specific card, bank, wallet |
| Card Last-4 + Bank | Specific filter | For statement reconciliation |
| Flagged Only | Toggle | |
| Shared Only | Toggle | |
| Text Search | Free text | Searches title, description, OCR text, **item names** |
| Item / Product Search | Free text | Searches specifically within line item names across all transactions |
| Amount Range | Min–Max | |

**Acceptance Criteria:**
- [ ] Multiple filters can be combined (AND logic)
- [ ] Results update in real-time as filters change
- [ ] Sticky summary bar shows: **Total Credits | Total Debits | Net | Transaction Count**
- [ ] Text search matches against title, description, OCR extracted text, translated text, **and line item names**
- [ ] Dedicated "Search by Product/Item" filter finds transactions containing a specific item (e.g., search "Tomatoes" → all transactions that included tomatoes, enabling price comparison across receipts)
- [ ] When item search is used, matching item names are highlighted in the result rows
- [ ] Filter state can be saved as a "preset" for reuse (e.g., "HDFC Credit Card Sep 2026")
- [ ] Filtered results can be exported directly

---

### 6.8 Flagging & Follow-up

**User Story:** As a user, I want to flag transactions that need attention and get daily reminders to resolve them.

**Acceptance Criteria:**
- [ ] Any transaction can be flagged/unflagged with a single tap
- [ ] Flag includes an optional note field (reason for flagging)
- [ ] Flagged Transactions view accessible from Dashboard quick-action
- [ ] Daily notification at user-configured time: "You have N flagged transactions to review"
- [ ] Flagged items show a badge count on the Dashboard

---

### 6.9 Expected / Future Transactions

**User Story:** As a user, I want to record expected incoming money (refunds, payments from friends) and track their completion.

**Acceptance Criteria:**
- [ ] Can create an "Expected" transaction with: source, expected amount, expected date, notes
- [ ] Expected transactions appear in a dedicated section on Dashboard or in a "Tracking" tab
- [ ] When a matching credit is recorded, AI notifies: "Transaction from [source] for ~₹[amount] seems completed"
- [ ] User confirms match → Expected transaction marked as "Completed" and linked to actual transaction
- [ ] Overdue expected transactions (past expected date) highlighted in red
- [ ] User can manually mark as completed or cancel

---

### 6.10 Payment Reminders

**User Story:** As a user, I want reminders for manual payments (insurance, LIC, policies) so I never miss a due date.

**Acceptance Criteria:**
- [ ] Create a reminder with: title, amount, due date, recurrence (one-time, monthly, quarterly, annual), notes
- [ ] Notification sent 3 days before, 1 day before, and on the due date
- [ ] After due date, option to "Mark as Paid" (creates a transaction) or "Snooze"
- [ ] Reminder list view shows upcoming and overdue items
- [ ] Recurring reminders auto-regenerate next occurrence after completion

---

### 6.11 Data Retention & Export

**User Story:** As a user, I want my data retained for 12 months with timely reminders and flexible export options.

#### Retention Rules
- Rolling 12-month window — data older than 365 days is purged daily
- At day 335 (11 months), persistent in-app banner + push notification: "Your oldest transactions will be deleted in 30 days. Export now to preserve them."
- Reminder repeats weekly until export is performed or data expires
- Purge runs via Cloud Function daily at 2:00 AM IST

#### Export Formats
| Format | Use Case | Contents |
|--------|----------|----------|
| CSV | Spreadsheet analysis | All fields, flat structure |
| Excel (.xlsx) | Rich spreadsheet with formatting | Multiple sheets (Transactions, Categories, Payment Methods, Summary) |
| JSON | AI/ML analysis, data portability | Full structured data with nested objects |
| PDF | Human-readable report | Formatted ledger with receipt thumbnails, monthly summaries |

**Acceptance Criteria:**
- [ ] Export available from Settings → Data Management
- [ ] User selects date range and format
- [ ] Export includes all transaction data, categories, payment methods, and Drive image links
- [ ] PDF export embeds thumbnail images fetched from Drive links
- [ ] Export file shared via iOS Share Sheet (AirDrop, Files, Email, etc.)
- [ ] Export progress shown for large datasets
- [ ] JSON schema is documented (included in export as `schema.json`) for AI tool consumption

---

### 6.12 iOS Share Extension

**User Story:** As a user, I want to share images or text from other apps directly into FinSight to quickly record transactions.

**Supported Input Types:**
| Input | Action |
|-------|--------|
| Image (from Photos, Camera, Files) | Run OCR → pre-fill transaction draft |
| Text (from Messages, Notes) | Run SMS parser → pre-fill transaction draft |
| URL (from browser) | Extract page title as transaction description |

**Acceptance Criteria:**
- [ ] FinSight appears in iOS Share Sheet for images and text
- [ ] Shared content opens a compact transaction entry view
- [ ] AI processing happens inline with loading indicator
- [ ] User reviews and confirms/edits before saving
- [ ] Share Extension works offline (queues for AI processing when online)

---

### 6.13 SMS / Financial Message Integration

**User Story:** As a user, I want the app to help me record transactions from bank SMS messages and alert me if I have unrecorded financial messages.

**iOS Approach (Share Extension):**
- User manually shares SMS from Messages app → AI parses and pre-fills transaction
- App cannot read SMS directly on iOS due to privacy restrictions

**Smart Notification:**
- App tracks transaction creation frequency
- If no transaction recorded for 48+ hours, send a reminder: "You haven't recorded any transactions in 2 days. Check your recent messages for any financial activity."
- Configurable frequency in Settings

**Future Android Approach:**
- Direct SMS inbox access with permission
- Background service scans new SMS for financial patterns
- Auto-creates draft transactions for user review

**Acceptance Criteria:**
- [ ] Share Extension correctly receives and processes SMS text
- [ ] Parser handles transaction alerts from top Indian banks (HDFC, SBI, ICICI, Axis, Kotak, etc.)
- [ ] Inactivity reminder is configurable (off / 24h / 48h / 72h)
- [ ] Android PRD section documents full SMS access architecture

---

### 6.14 Recurring Transactions

**User Story:** As a user, I want to mark transactions as recurring and have the app auto-detect patterns I might miss.

**Manual:**
- User toggles "Recurring" on a transaction and sets frequency (daily, weekly, monthly, quarterly, yearly)
- App creates future transaction drafts based on frequency
- User receives reminder notification on the recurring date

**AI Auto-Detection:**
- Cloud Function runs monthly on day 1
- Scans 6 months of history for: same merchant/title + similar amount (±10%) + regular interval
- Presents suggestions as dismissible cards in the Dashboard
- User accepts → RecurringRule created; Dismisses → pattern suppressed for 3 months

**Acceptance Criteria:**
- [ ] Manual recurring frequency options: daily, weekly, bi-weekly, monthly, quarterly, semi-annually, yearly
- [ ] Auto-detected patterns shown with confidence score
- [ ] Recurring rules can be paused, edited, or deleted
- [ ] Next occurrence shown on the transaction detail view

---

### 6.15 Item-Level Tracking (Line Items)

**User Story:** As a user, I want to see individual items/products within a transaction so I can search for specific products across my history and compare prices over time.

#### How Items Are Added
| Source | Behavior |
|--------|----------|
| **AI / OCR** | Gemini extracts line items from receipt images automatically. Items appear as editable suggestions marked with ✨. User reviews, edits, or removes before saving. |
| **Manual** | User taps "+ Add Item" on the transaction form and enters item name, quantity, unit price. Line total auto-calculates. |
| **SMS** | Not applicable — bank SMS typically don't contain item details. Items field left empty for SMS-sourced transactions. |

#### LineItem Data Structure
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | String | Yes | Product/item name (e.g., "Basmati Rice 5kg") |
| `nameTranslated` | String | No | English translation if original was in another language |
| `quantity` | Decimal | No | Quantity purchased (default: 1) |
| `unit` | String | No | Unit of measure (kg, pcs, L, etc.) |
| `unitPrice` | Decimal | No | Price per unit |
| `lineTotal` | Decimal | Yes | Total for this line item (quantity × unitPrice, or manually entered) |
| `source` | Enum | No | `ocr` or `manual` — how this item was added |

#### Price Comparison Use Case
1. User searches for a product (e.g., "Tomatoes") in the Item/Product filter
2. App returns all transactions containing that item across the 12-month history
3. Each result shows: date, merchant/title, item quantity, item price, and transaction total
4. User can visually compare how the same product was priced at different merchants or dates
5. User can tap into any transaction to view the full receipt image for verification

**Acceptance Criteria:**
- [ ] AI extracts line items from receipt images with item name, quantity, unit price, and line total
- [ ] User can manually add, edit, and remove line items on any transaction
- [ ] Line items are optional — transactions without items are fully valid
- [ ] Items section shows a running subtotal of all line items (informational, does not override transaction amount)
- [ ] If subtotal of items ≠ transaction amount, a subtle info note appears: "Item subtotal (₹X) differs from transaction total (₹Y) — this may be due to taxes, discounts, or missing items"
- [ ] Item names are searchable via the "Item/Product Search" filter (Section 6.7)
- [ ] Translated item names are also searchable
- [ ] Items are included in all export formats (CSV: flattened rows, JSON: nested array, Excel: separate "Items" sheet, PDF: itemized under each transaction)
- [ ] AI-suggested items are visually distinct (✨ sparkle) and editable before saving

---

## 7. Screen Inventory & Wireframe Descriptions

### 7.1 Launch / Splash Screen
- App icon centered with "FinSight" text below
- Animated gradient background (light: warm gold; dark: deep blue)
- Shows for 1.5s or until auth check completes

### 7.2 Login Screen
- App logo at top (30% of screen height)
- Three auth buttons stacked vertically:
  - "Sign in with Apple" (system button, black/white)
  - "Sign in with Google" (Google branded button)
  - "Sign in with Email" (custom styled, app accent color)
- Email flow: separate screen with email field, password field, "Forgot Password?" link, and "Create Account" link
- Clean, minimal background

### 7.3 Onboarding Carousel (First Launch Only)
- 3 swipeable slides:
  1. "Smart Receipt Scanning" — illustration of receipt → extracted data
  2. "Works Offline" — illustration of sync icon
  3. "Your Data, Your Drive" — illustration of Google Drive integration
- "Skip" in top-right, "Get Started" button on last slide
- Dots indicator at bottom

### 7.4 Dashboard (Home Screen) — Main Tab
**Layout (top to bottom):**

1. **Header Bar**
   - Left: "Good [Morning/Afternoon/Evening], [Name]"
   - Right: Notification bell (badge count) + Settings gear icon

2. **Month Selector**
   - Horizontally scrollable month pills: "← Aug | **Sep 2026** | Oct →"
   - Tapping changes all dashboard data to that month

3. **Summary Cards Row** (Horizontal scroll or grid)
   - Card 1: "Income" — ₹XX,XXX (green text, ↑ arrow icon)
   - Card 2: "Expense" — ₹XX,XXX (red text, ↓ arrow icon)
   - Card 3: "Net" — ₹±XX,XXX (blue/green/red based on sign)
   - Each card is a rounded rectangle with subtle shadow

4. **Budget Snapshot** (if budgets exist)
   - "Budgets" section header with "See All →" link
   - Top 3 category budgets as horizontal progress bars
   - Label: "Food: ₹6,200 / ₹8,000" with colored bar

5. **Quick Actions Row**
   - Horizontal row of icon buttons: "Flagged (3)", "Expected (2)", "Reminders (1)", "Export"

6. **Recent Transactions**
   - Section header: "Recent" with "See All →" link
   - List of 5-10 most recent transactions
   - Each row: Category icon | Title + Subtitle (date, payment method) | Amount (green for credit, red for debit)

7. **Floating Action Button (FAB)**
   - Bottom-right, prominent "+" button with app accent color
   - Tap: opens Add Transaction modal
   - Long-press: shows quick-add options (Camera, Gallery, SMS)

### 7.5 Add / Edit Transaction Screen (Modal / Full Screen)

**Layout (top to bottom):**

1. **Navigation Bar**
   - Left: "Cancel" button
   - Center: "New Transaction" / "Edit Transaction"
   - Right: "Save" button (disabled until required fields filled)

2. **Transaction Type Selector**
   - Segmented control or horizontally scrollable chips:
   - Income | Expense | Transfer | Investment | Loan | Cashback

3. **Amount Section**
   - Large, prominent amount input field (₹ prefix, numeric keyboard)
   - Currency selector button next to amount (default: INR)
   - If foreign currency selected: exchange rate row appears below
     - "Rate: 1 USD = ₹83.45 (Sep 29)" + Edit pencil icon
     - "Equivalent: ₹8,345.00"

4. **Details Section**
   - Title field (single line, required)
   - Description field (multi-line, optional, expandable)
   - Date picker (default: today, allows past dates)

5. **Category Section**
   - "Categories" label
   - Tag cloud of recently used categories
   - AI-suggested categories marked with ✨ sparkle
   - "+ Add Category" chip to type custom
   - Multiple selection allowed

6. **Payment Method Section**
   - Dropdown: select from saved payment methods
   - "Split Payment" toggle
   - If split: dynamic list of {method dropdown + amount field}, with "Add another" button
   - "+" button to add new payment method inline

7. **Note Field**
   - Multi-line text area with placeholder "Add a note to remember..."
   - Optional, expandable (starts as single line, grows as user types)
   - Helps capture any context the user wants to recall later

8. **Location Section**
   - 📍 "Add Location" button
   - Tap → shows options: "Use Current Location" or "Search Place"
   - "Use Current Location" → reverse geocodes GPS to show place name + address
   - "Search Place" → Apple Maps search with autocomplete
   - Once set: shows mini-map preview + place name + ✕ to remove
   - Location is optional — section collapses if not used

9. **Attachments Section**
   - Row of action buttons: 📷 Camera | 🖼 Gallery | 📎 Files
   - Thumbnails of attached images below
   - Each thumbnail has ✕ remove button
   - "Scan with AI" button on each image thumbnail

10. **Items Section**
    - Header: "Items" with item count badge
    - AI-extracted items (from receipt OCR) shown with ✨ sparkle, each editable
    - Each item row: Name | Quantity × Unit Price = Line Total | ✕ remove
    - "+ Add Item" button to manually add items
    - Running subtotal at bottom; if subtotal ≠ transaction amount, subtle info note: "Subtotal differs — may be due to taxes, discounts, or missing items"
    - Items are optional — section shows "+ Add Items" placeholder if empty

11. **Additional Options Section** (collapsible)
   - "Recurring" toggle → frequency picker appears
   - "Flag for Follow-up" toggle → note field appears
   - "Shared" toggle → family member name field appears
   - "Expected Transaction" toggle → expected date picker appears

12. **AI Suggestion Banner** (if AI has suggestions)
   - Light blue/purple banner: "✨ AI suggests: Groceries, BigBasket — Accept | Edit"

### 7.6 Transaction Detail Screen

**Layout:**
- Hero section: Amount (large), Type badge, Date
- Details card: Title, Description, Categories (as tags), Payment methods
- Note card: User's note text in a subtle highlighted box (if present)
- Location card: Tappable mini-map showing pin at transaction location + place name + address (if present). Tap opens Apple Maps.
- Items card: List of line items with name, quantity, unit price, and line total. Subtotal at bottom. Section hidden if no items present.
- Receipt Images: Horizontal scrollable image carousel (tap to zoom)
- OCR Text: Expandable section showing extracted & translated text
- Metadata: Created date, Last modified, Sync status
- Actions bar: Edit | Flag | Delete | Share

### 7.7 Transaction List Screen (Transactions Tab)

**Layout:**
1. **Search Bar** — Fixed at top, with microphone icon
2. **Filter Bar** — Horizontally scrollable chips: Date Range | Type | Category | Payment Method | Flagged | More Filters
3. **Active Filters** — Applied filters shown as removable pills below filter bar
4. **Summary Bar** (Sticky) — "Credits: ₹XX,XXX | Debits: ₹XX,XXX | Net: ₹±X,XXX | Count: N"
5. **Transaction List** — Grouped by date ("Today", "Yesterday", "Sep 27, 2026")
   - Each row: Icon | Title + Category tags | Amount (colored)
   - Swipe left: Delete (red)
   - Swipe right: Flag (yellow)
6. **Empty State** — Illustration + "No transactions found. Adjust your filters or add a new transaction."

### 7.8 Budget Management Screen

**Layout:**
1. **Overall Budget** — Large circular progress indicator with amount in center
2. **Period Toggle** — "Weekly | Monthly"
3. **Category Budgets List**
   - Each row: Category icon + name | Progress bar | "₹X,XXX / ₹X,XXX"
   - Color-coded progress bars (green → yellow → orange → red)
4. **"+ Add Budget"** button at bottom
5. **Budget Detail** (on tap): History chart, daily spending trend for that category

### 7.9 Payment Methods Screen (Settings sub-screen)

**Layout:**
- List grouped by type: Cards | Bank Accounts | Wallets | UPI | Cash
- Each row: Icon + Name + Details (last 4, bank name)
- Swipe to delete, tap to edit
- "+" floating button to add new method

### 7.10 Flagged Items Screen

**Layout:**
- List of all flagged transactions
- Each row shows: flag icon + title + amount + flag note preview + days since flagged
- Tap to view transaction detail
- "Resolve" quick action (unflag + optional note)

### 7.11 Expected Transactions Screen ("Tracking" Tab or Dashboard Section)

**Layout:**
- Two sections: "Pending" and "Completed"
- Pending: Source + Expected amount + Expected by date + Status indicator (on track / overdue)
- Completed: shows matched actual transaction link
- FAB: "+ Track New" button

### 7.12 Payment Reminders Screen

**Layout:**
- Calendar-style view at top showing dots on dates with reminders
- List below grouped: "Upcoming", "Due Today", "Overdue"
- Each row: Title + Amount + Due date + Recurrence badge
- Actions: "Mark as Paid" (creates transaction) | "Snooze" | "Edit"

### 7.13 Settings Screen

**Layout (grouped list):**
1. **Account** — Profile photo, name, email, sign out
2. **Google Drive** — Connection status, connected email, Disconnect button
3. **Appearance** — Theme toggle (Light / Dark / System)
4. **Notifications** — Toggles for: Daily summary, Budget alerts, Flag reminders, Due date reminders, Inactivity reminders, Export warnings
5. **Data Management** — Export data, Data retention info, Clear local cache
6. **AI Settings** — Toggle AI suggestions, View/clear category corrections
7. **Payment Methods** — Manage saved methods
8. **About** — Version, licenses, feedback

### 7.14 Export Screen (Settings sub-screen)

**Layout:**
1. **Date Range Picker** — From and To date selectors
2. **Format Selector** — Radio buttons: CSV | Excel | JSON | PDF
3. **Options** — Toggles: Include images (PDF only), Include OCR text, Include category corrections
4. **Preview** — Row count and estimated file size
5. **"Export" button** — Triggers generation, shows progress, then Share Sheet

### 7.15 Share Extension View (Compact)

**Layout:**
- Compact modal (iOS Share Extension size)
- Shows: extracted text / image thumbnail
- Loading indicator during AI processing
- Pre-filled mini form: Amount, Title, Type, Date
- "Save Draft" and "Save & Close" buttons

---

## 8. Data Model

### 8.1 Entity-Relationship Diagram (Description)

```
User (1) ──→ (N) Transaction
User (1) ──→ (N) PaymentMethod
User (1) ──→ (N) Budget
User (1) ──→ (N) RecurringRule
User (1) ──→ (N) Reminder
User (1) ──→ (N) CategoryCorrection
User (1) ──→ (N) ExpectedTransaction

Transaction (N) ←──→ (N) PaymentMethod  (via SplitEntry)
Transaction (N) ←──→ (N) Category       (via categories array)
RecurringRule (1) ──→ (N) Transaction    (generated from rule)
ExpectedTransaction (1) ──→ (0..1) Transaction (matched actual)
```

### 8.2 Firestore Collection Structure

```
users/{userId}/
├── profile                    # User preferences, Drive token
├── transactions/{txId}        # All transactions
├── paymentMethods/{pmId}      # Saved payment methods
├── budgets/{budgetId}         # Budget definitions
├── recurringRules/{ruleId}    # Recurring transaction rules
├── reminders/{reminderId}     # Payment reminders
├── expectedTransactions/{etId} # Future/tracked transactions
├── categoryCorrections/{ccId} # AI correction history
└── exportHistory/{exportId}   # Export audit trail
```

### 8.3 Detailed Entity Schemas

#### User Profile
```json
{
  "id": "firebase_uid",
  "email": "user@example.com",
  "displayName": "User Name",
  "primaryCurrency": "INR",
  "driveConnected": true,
  "driveEmail": "user@gmail.com",
  "driveFolderId": "google_drive_folder_id",
  "preferences": {
    "theme": "system",
    "dailySummaryTime": "20:00",
    "inactivityReminderHours": 48,
    "notificationsEnabled": {
      "dailySummary": true,
      "budgetAlerts": true,
      "flagReminders": true,
      "dueReminders": true,
      "exportWarnings": true
    }
  },
  "createdAt": "2026-09-29T00:00:00Z",
  "lastActiveAt": "2026-09-29T00:00:00Z"
}
```

#### Transaction
```json
{
  "id": "uuid",
  "type": "expense|income|transfer|investment|loan_given|loan_received|cashback",
  "amount": 1500.00,
  "currency": "INR",
  "exchangeRate": null,
  "equivalentINR": 1500.00,
  "title": "BigBasket Groceries",
  "description": "Weekly grocery order",
  "date": "2026-09-29",
  "categories": ["Groceries", "Food"],
  "paymentSplits": [
    {"methodId": "pm_001", "amount": 1000.00},
    {"methodId": "pm_002", "amount": 500.00}
  ],
  "receiptLinks": ["https://drive.google.com/..."],
  "localImagePaths": [],
  "ocrText": "BigBasket... Total: Rs 1500",
  "translatedText": null,
  "note": "Bought extra fruits for the weekend party",
  "location": {"latitude": 12.9716, "longitude": 77.5946},
  "locationName": "Indiranagar, Bangalore",
  "locationAddress": "12th Main Rd, Indiranagar, Bengaluru, Karnataka 560038",
  "items": [
    {
      "name": "Basmati Rice 5kg",
      "nameTranslated": null,
      "quantity": 1,
      "unit": "pcs",
      "unitPrice": 350.00,
      "lineTotal": 350.00,
      "source": "ocr"
    },
    {
      "name": "Tomatoes",
      "nameTranslated": null,
      "quantity": 1,
      "unit": "kg",
      "unitPrice": 40.00,
      "lineTotal": 40.00,
      "source": "ocr"
    },
    {
      "name": "Amul Butter 500g",
      "nameTranslated": null,
      "quantity": 2,
      "unit": "pcs",
      "unitPrice": 280.00,
      "lineTotal": 560.00,
      "source": "manual"
    }
  ],
  "isRecurring": true,
  "recurringRuleId": "rule_001",
  "recurringFrequency": "weekly",
  "isFlagged": false,
  "flagNote": null,
  "isShared": true,
  "sharedWith": "Spouse",
  "isExpected": false,
  "expectedTransactionId": null,
  "source": "ocr",
  "createdAt": "2026-09-29T10:30:00Z",
  "updatedAt": "2026-09-29T10:30:00Z"
}
```

#### PaymentMethod
```json
{
  "id": "pm_001",
  "type": "credit_card|debit_card|bank_transfer|wallet|upi|cash",
  "bankName": "HDFC Bank",
  "last4": "4532",
  "cardNetwork": "Visa",
  "walletName": null,
  "upiId": null,
  "nickname": "HDFC Visa Credit",
  "isDefault": true,
  "createdAt": "2026-09-29T00:00:00Z"
}
```

#### Budget
```json
{
  "id": "budget_001",
  "period": "monthly|weekly",
  "category": "Food",
  "limitAmount": 8000.00,
  "isOverall": false,
  "createdAt": "2026-09-29T00:00:00Z"
}
```

#### RecurringRule
```json
{
  "id": "rule_001",
  "templateTransaction": { /* transaction fields minus id/dates */ },
  "frequency": "monthly",
  "startDate": "2026-01-15",
  "nextOccurrence": "2026-10-15",
  "isActive": true,
  "isAIDetected": false,
  "createdAt": "2026-09-29T00:00:00Z"
}
```

#### Reminder
```json
{
  "id": "rem_001",
  "title": "LIC Premium Payment",
  "amount": 12500.00,
  "dueDate": "2026-10-15",
  "recurrence": "quarterly",
  "notes": "Policy #LIC12345",
  "isCompleted": false,
  "linkedTransactionId": null,
  "notifyDaysBefore": [3, 1, 0],
  "createdAt": "2026-09-29T00:00:00Z"
}
```

#### ExpectedTransaction
```json
{
  "id": "et_001",
  "source": "Amazon Refund",
  "expectedAmount": 2499.00,
  "amountTolerance": 0.05,
  "expectedBy": "2026-10-05",
  "notes": "Return for damaged headphones",
  "status": "pending|completed|cancelled",
  "matchedTransactionId": null,
  "createdAt": "2026-09-29T00:00:00Z"
}
```

#### CategoryCorrection
```json
{
  "id": "cc_001",
  "originalSuggestion": ["Shopping"],
  "correctedTo": ["Groceries", "Food"],
  "transactionTitle": "BigBasket Order",
  "ocrContext": "BigBasket... fruits vegetables",
  "createdAt": "2026-09-29T00:00:00Z"
}
```

---

## 9. API & Integration Points

### 9.1 Firebase Services
| Service | Usage |
|---------|-------|
| Firebase Auth | User identity (Email, Apple, Google providers) |
| Cloud Firestore | Primary database with offline persistence |
| Cloud Functions | Scheduled tasks: data purge, recurring detection, export reminders |
| Firebase Remote Config | Feature flags, AI prompt templates, configurable thresholds |

### 9.2 Google Drive API v3
| Operation | Endpoint | Purpose |
|-----------|----------|---------|
| Create Folder | `POST /files` | Create "FinSight" folder on first use |
| Upload Image | `POST /upload/files?uploadType=multipart` | Upload compressed receipt images |
| Get File Link | `GET /files/{id}?fields=webViewLink` | Retrieve shareable link |
| Delete File | `DELETE /files/{id}` | Remove image when transaction is deleted |
| OAuth Scopes | `drive.file` | Access only files created by the app |

### 9.3 Gemini API
| Capability | Model | Input | Output |
|------------|-------|-------|--------|
| Receipt OCR | Gemini Pro Vision | Image bytes | Structured text (JSON) |
| Translation | Gemini Pro | OCR text + source lang | English text |
| Categorization | Gemini Pro | Title + desc + corrections context | Category suggestions |
| SMS Parsing | Gemini Pro | SMS text | Structured transaction data (JSON) |
| Recurring Detection | Gemini Pro | 6-month transaction summary | Pattern suggestions |
| Exchange Rate | Gemini Pro | Currency pair + date | Exchange rate |

### 9.4 Exchange Rate API (Fallback)
- Primary: `exchangerate.host` or `open.er-api.com` (free, no key required)
- Returns rate for specific date
- Cached locally for 24 hours per currency pair per date

---

## 10. Notification Strategy

| Notification | Type | Trigger | Default Time |
|-------------|------|---------|-------------|
| Daily Summary | Local | Daily at user-set time | 8:00 PM |
| Budget 80% Warning | Local | Real-time on transaction save | Immediate |
| Budget 100% Alert | Local | Real-time on transaction save | Immediate |
| Flagged Item Reminder | Local | Daily | 9:00 AM |
| Payment Due (3 days) | Local | Scheduled | 9:00 AM |
| Payment Due (1 day) | Local | Scheduled | 9:00 AM |
| Payment Due (today) | Local | Scheduled | 9:00 AM |
| Expected Overdue | Local | Daily check | 10:00 AM |
| Inactivity Reminder | Local | After 48h no transaction | Variable |
| Export Warning (30 days) | Local + In-app banner | Day 335 | 10:00 AM, weekly repeat |
| Recurring Suggestions | In-app | 1st of month | On app open |
| Expected Match Found | Local | On transaction save | Immediate |

---

## 11. Data Retention & Export Strategy

### Retention Timeline
```
Day 0                    Day 335 (Month 11)           Day 365
│                        │                             │
├────── Active Data ─────┤── Warning Period (30 days) ──┤── Purge ──→
│                        │   Banner + notifications     │
│  Full read/write       │   "Export before deletion"   │  Oldest day
│  access                │                              │  dropped daily
```

### Purge Logic (Cloud Function — Daily at 2 AM IST)
1. Query transactions where `date < (today - 365 days)`
2. For each transaction: delete Firestore document
3. Associated Drive images are **NOT** deleted (user retains receipts forever)
4. Log purge count to `exportHistory` for audit

### Export Pipeline
1. User selects date range + format in Export screen
2. App queries Firestore for matching transactions
3. Generates file locally:
   - **CSV:** Standard comma-separated with headers
   - **Excel:** `XLSXWriter` library — sheets: Transactions, Payment Methods, Categories, Monthly Summary
   - **JSON:** Full structured export with `schema.json` file for AI tools
   - **PDF:** `PDFKit` — formatted ledger with receipt thumbnails, page headers, monthly sections
4. File presented via iOS Share Sheet

---

## 12. AI/ML Strategy

### Principles
1. **Privacy First:** Only data strictly necessary for the task is sent to Gemini
2. **User Control:** All AI suggestions require explicit user approval
3. **Graceful Degradation:** Every AI feature has a manual fallback
4. **Learning Loop:** User corrections improve future suggestions via few-shot prompting
5. **Configurable Prompts:** All AI prompt templates stored in Firebase Remote Config for live updates without app changes

### Category Learning Loop
```
New Transaction → Gemini (with last 100 corrections as context)
                     ↓
              Category Suggestions
                     ↓
         User Accepts ────────→ Save transaction
                     ↓
         User Corrects ───→ Save correction → Include in future prompts
```

### AI Cost Management
- Batch OCR requests where possible
- Cache exchange rates (24h per currency pair per date)
- Limit correction context to 100 most recent entries
- Use Gemini Pro (text) for most tasks; Gemini Pro Vision only for images
- Track API usage in a local counter for user visibility

---

## 13. Offline & Sync Strategy

### Architecture
```
┌─────────────────┐          ┌──────────────────┐
│   SwiftUI View  │          │   Cloud Firestore │
│                 │          │   (Remote)        │
│   ↕ ViewModel   │          │                  │
│   ↕ Repository  │          └────────┬─────────┘
│   ↕             │                   │
│  Firestore SDK  │←── Auto Sync ────→│
│  (Local Cache)  │   (when online)   │
└─────────────────┘                   │
                                      │
┌─────────────────┐                   │
│  Image Queue    │── Upload when ────┘
│  (Local files)  │   online
└─────────────────┘
```

### Offline Capabilities
| Operation | Offline Behavior |
|-----------|-----------------|
| Create/Edit/Delete Transaction | Writes to local cache, syncs when online |
| View Transactions | Full access from local cache |
| Attach Image | Saved locally, queued for Drive upload |
| AI Features (OCR, categorization) | Unavailable — manual entry fallback |
| Search & Filter | Full functionality on local data |
| Export | Works on local data |
| Budget Calculations | Full functionality on local data |

### Conflict Resolution
- Firestore's built-in last-write-wins for simple fields
- For the rare multi-device conflict: server timestamp wins, local changes queued for re-review

---

## 14. Security & Privacy

| Concern | Mitigation |
|---------|------------|
| Data Access | Firestore Security Rules: `userId == auth.uid` on all documents |
| Image Privacy | Stored in user's own Google Drive (not app-controlled storage) |
| AI Data | Only transaction text/images sent to Gemini; no personal identifiers |
| Auth Tokens | Managed by Firebase SDK; stored in iOS Keychain |
| Local Data | Firestore local cache encrypted by iOS Data Protection |
| API Keys | Gemini API key stored in Firebase Remote Config, not hardcoded |
| Drive OAuth | `drive.file` scope — app can only access files it created |
| Export Files | Generated locally, shared via Share Sheet — user controls destination |

---

## 15. Accessibility

| Feature | Implementation |
|---------|---------------|
| Dynamic Type | All text uses SwiftUI `.font()` modifiers with system styles |
| VoiceOver | All interactive elements have accessibility labels and hints |
| Color Contrast | WCAG AA compliance for all text/background combinations |
| Reduce Motion | Respect `UIAccessibility.isReduceMotionEnabled` for animations |
| Bold Text | Support system bold text setting |
| Haptic Feedback | Subtle haptics on transaction save, flag toggle, budget alerts |

---

## 16. Future Considerations

### Android App
- **UI:** Kotlin + Jetpack Compose (mirror SwiftUI patterns)
- **Backend:** Same Firebase project — shared Firestore, Auth, Functions
- **SMS:** Full SMS inbox access with `READ_SMS` permission — background service for auto-detection
- **Images:** Same Google Drive integration
- **Architecture:** Same MVVM + Repository pattern — business logic portable

### Potential Future Features
- Widgets (iOS/macOS) — monthly summary, quick-add shortcut
- Apple Watch companion — quick expense entry
- Shared household ledger (multi-user)
- Investment portfolio tracking with market prices
- Bill scanner with QR/barcode support
- Custom accent color picker
- Charts and analytics dashboard (pie, bar, trend lines)
- Siri Shortcuts integration
- Import from bank CSV statements

---

## 17. Glossary

| Term | Definition |
|------|-----------|
| OCR | Optical Character Recognition — extracting text from images |
| FAB | Floating Action Button — prominent action button, typically bottom-right |
| SIP | Systematic Investment Plan — recurring mutual fund investment |
| LIC | Life Insurance Corporation of India |
| MVVM | Model-View-ViewModel — UI architecture pattern |
| UPI | Unified Payments Interface — India's real-time payment system |
| INR | Indian Rupee (₹) |
| Few-shot Learning | AI technique where examples are provided in the prompt to improve output |
| Share Extension | iOS mechanism allowing apps to receive content from other apps via the Share Sheet |
| Remote Config | Firebase service for changing app behavior without deploying updates |

---

## 18. Decision Log

| # | Date | Decision | Options Considered | Rationale |
|---|------|----------|-------------------|-----------|
| 1 | 2026-09-29 | **Auth:** Email + Apple + Google via Firebase | Apple-only, No auth | Maximum flexibility; Firebase handles all three providers |
| 2 | 2026-09-29 | **Backend:** Firebase | Firebase, AWS, Custom backend, iCloud+CloudKit | Easiest setup, good free tier, Gemini integration, offline support built-in |
| 3 | 2026-09-29 | **Image Storage:** User's Google Drive via OAuth | Google Drive, iCloud, Firebase Storage, User-choice | Cross-platform (Android future), user owns their data, works after export |
| 4 | 2026-09-29 | **Currency:** INR primary + multi-currency with auto exchange rates | Single currency, Multi-currency | Handles foreign transactions; Gemini + API fallback for rates |
| 5 | 2026-09-29 | **SMS on iOS:** Share Extension | Direct SMS, Notifications, Shortcuts, Skip | Only viable option on iOS; full SMS planned for Android |
| 6 | 2026-09-29 | **Export Formats:** CSV + Excel + JSON + PDF (user picks) | Single format | Each format serves different use case; AI tools need JSON |
| 7 | 2026-09-29 | **Offline:** Full offline with background sync | Partial, Online-only | Critical for reliable financial tracking; Firestore supports this natively |
| 8 | 2026-09-29 | **Multi-user:** Single user + "shared" tagging | Single, Multi-user | Simplicity for v1; tagging covers household attribution |
| 9 | 2026-09-29 | **Distribution:** Free, personal, not on App Store | App Store, Freemium | Personal tool; avoids review process and monetization complexity |
| 10 | 2026-09-29 | **AI Provider:** Gemini for everything | Apple Vision + Gemini, Multi-provider | Unified API, best multi-language OCR, Remote Config prompts |
| 11 | 2026-09-29 | **Categories:** AI-suggested, user-approved, learning loop | Predefined, Manual-only, Hierarchical | Reduces manual effort; improves over time |
| 12 | 2026-09-29 | **Notifications:** Daily summary + smart alerts | Minimal, Smart-only | Comprehensive awareness without notification fatigue |
| 13 | 2026-09-29 | **UI Framework:** SwiftUI | UIKit, Flutter, React Native | Native feel on iOS/macOS; modern declarative pattern |
| 14 | 2026-09-29 | **Dashboard:** Simple totals + recent transactions | Charts, Minimal, Full analytics | Clean and fast; charts deferred to future version |
| 15 | 2026-09-29 | **Budgeting:** Monthly/weekly + per-category with alerts | No budgeting, Basic target, Deferred | User wants spending control; progress bars provide motivation |
| 16 | 2026-09-29 | **Drive Auth:** User's own Drive via OAuth | App service account, Firebase Storage, Both | User owns images; survives app deletion; privacy |
| 17 | 2026-09-29 | **Transaction Types:** 6 types (income, expense, transfer, investment, loan, cashback) | Fewer types | Comprehensive financial picture covering all flows |
| 18 | 2026-09-29 | **Theme:** System-adaptive light/dark + manual toggle | Light-only, Dark-only | Follows platform convention; user preference respected |
| 19 | 2026-09-29 | **Location:** Capture maps location per transaction via Apple Maps | No location, GPS-only, Third-party maps | Helps user recall where a purchase was made; Apple Maps is native and free; location is optional |
| 20 | 2026-09-29 | **Note Field:** Free-form note on every transaction | No notes, Structured notes only | Users need a flexible way to capture context they want to remember about a transaction |
| 21 | 2026-09-30 | **Item-Level Tracking:** Extract and store individual line items per transaction | No items (simple totals only), Items required | Enables product-level search and price comparison across 12 months of receipts; items are optional to keep quick-entry simple |

---

> [!NOTE]
> **Document Maintenance:** This PRD should be updated whenever requirements change, features are added/removed, or architectural decisions are revised. Each update should add an entry to the Decision Log with the date and rationale.
