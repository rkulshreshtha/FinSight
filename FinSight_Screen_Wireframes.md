# 🖼️ FinSight — Screen Wireframes & Mockups

> **Note:** Visual mockup generation was temporarily unavailable. These detailed text wireframes serve as precise specifications for UI implementation. Each wireframe can be used directly with Figma, Sketch, or AI design tools to generate visual mockups.

---

## Screen 1: Login / Authentication

```
┌──────────────────────────────────┐
│                                  │
│          ┌──────────┐            │
│          │  ◉ LOGO  │            │
│          │ FinSight  │            │
│          └──────────┘            │
│                                  │
│   "Your AI-Powered Finance       │
│         Companion"               │
│                                  │
│                                  │
│  ┌──────────────────────────┐    │
│  │  Sign in with Apple     │    │
│  └──────────────────────────┘    │
│                                  │
│  ┌──────────────────────────┐    │
│  │ G  Sign in with Google   │    │
│  └──────────────────────────┘    │
│                                  │
│  ┌──────────────────────────┐    │
│  │ ✉  Sign in with Email   │    │
│  └──────────────────────────┘    │
│                                  │
│                                  │
│     ~~~~ abstract chart art ~~~~ │
│                                  │
└──────────────────────────────────┘
```

**Design Notes:**
- Logo: Stylized eye/lens icon merged with ₹ symbol, blue/teal gradient
- Apple button: Black (dark mode) / White outline (light mode), system style
- Google button: White with gray border, Google "G" logo
- Email button: App accent color (blue/teal gradient)
- Background: Clean white/off-white with subtle abstract financial chart illustration at bottom

---

## Screen 2: Onboarding Carousel (First Launch)

```
┌──────────────────────────────────┐
│                          [Skip]  │
│                                  │
│       ┌──────────────────┐       │
│       │                  │       │
│       │   📸 → 📋        │       │
│       │  (illustration)  │       │
│       │                  │       │
│       └──────────────────┘       │
│                                  │
│    "Smart Receipt Scanning"      │
│                                  │
│   Snap a receipt and let AI      │
│   extract merchant, amount,      │
│   and items automatically.       │
│                                  │
│                                  │
│           ● ○ ○                  │
│                                  │
│  ┌──────────────────────────┐    │
│  │        Next →             │    │
│  └──────────────────────────┘    │
└──────────────────────────────────┘

Slide 2: "Works Offline" — sync icon illustration
Slide 3: "Your Data, Your Drive" — cloud + lock illustration
         [Get Started] button on last slide
```

---

## Screen 3: Dashboard (Home) — PRIMARY SCREEN

```
┌──────────────────────────────────┐
│ Good Evening, User         ⚙️ 🔔³│
├──────────────────────────────────┤
│  ← Aug │ ▪ September 2026 ▪│ Oct→│
├──────────────────────────────────┤
│ ┌────────┐ ┌────────┐ ┌────────┐│
│ │ Income │ │Expense │ │  Net   ││
│ │ ↑      │ │ ↓      │ │        ││
│ │₹85,000 │ │₹52,340 │ │₹32,660 ││
│ │ (green)│ │ (red)  │ │ (blue) ││
│ └────────┘ └────────┘ └────────┘│
├──────────────────────────────────┤
│ Budgets                 See All →│
│ ┌──────────────────────────────┐ │
│ │ Food     ₹6,200/₹8,000      │ │
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓░░░░ 77%  🟡   │ │
│ │ Transport ₹3,100/₹5,000     │ │
│ │ ▓▓▓▓▓▓▓▓▓▓░░░░░░ 62%  🟢   │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ ┌──────┐┌──────┐┌──────┐┌─────┐ │
│ │🚩    ││📥    ││⏰    ││📤   │ │
│ │Flag 3││Exp. 2││Rem. 1││Export│ │
│ └──────┘└──────┘└──────┘└─────┘ │
├──────────────────────────────────┤
│ Recent                  See All →│
│ ┌──────────────────────────────┐ │
│ │ 🛒 BigBasket Groceries      │ │
│ │    Sep 29 · HDFC ····4532   │ │
│ │                    -₹1,500  │ │
│ ├──────────────────────────────┤ │
│ │ 💼 Freelance Payment        │ │
│ │    Sep 29 · Bank Transfer   │ │
│ │                   +₹15,000  │ │
│ ├──────────────────────────────┤ │
│ │ 🍽 Swiggy Dinner     🚩     │ │
│ │    Sep 28 · Amazon Pay      │ │
│ │                      -₹680  │ │
│ ├──────────────────────────────┤ │
│ │ ⛽ Indian Oil Petrol         │ │
│ │    Sep 28 · SBI Debit ·1234 │ │
│ │                    -₹1,200  │ │
│ └──────────────────────────────┘ │
│                                  │
│                           ┌───┐  │
│                           │ + │  │
│                           └───┘  │
├──────┬──────┬──────┬──────┬─────┤
│ 🏠   │ 📋   │  ➕  │ 📊   │ ⚙️  │
│ Home │ Txns │ Add  │Track │ More│
└──────┴──────┴──────┴──────┴─────┘
```

**Design Notes:**
- Summary cards: Rounded rectangles with subtle elevation/shadow
- Income amount in green, Expense in red, Net in blue (positive) or red (negative)
- Budget bars: Color transitions green → yellow → orange → red based on percentage
- Quick actions: Horizontal icon row with badge counts
- Recent transactions: Green amounts for credits, red for debits
- Flag icon (🚩) shown on flagged transactions
- FAB: Prominent circular button, app accent color
- Tab bar at bottom: 5 tabs for main navigation

---

## Screen 4: Add / Edit Transaction

```
┌──────────────────────────────────┐
│ Cancel    New Transaction   Save │
├──────────────────────────────────┤
│┌──────┬───────┬──────┬─────┬───┐│
││Income│▪Expns▪│Xfer  │Invest│...││
│└──────┴───────┴──────┴─────┴───┘│
├──────────────────────────────────┤
│                                  │
│        ₹ 1,500.00    [INR ▼]    │
│        ─────────────────         │
│                                  │
├──────────────────────────────────┤
│ Title                            │
│ ┌──────────────────────────────┐ │
│ │ BigBasket Groceries          │ │
│ └──────────────────────────────┘ │
│ Description (optional)           │
│ ┌──────────────────────────────┐ │
│ │ Weekly grocery order         │ │
│ └──────────────────────────────┘ │
│ Date                             │
│ ┌──────────────────────────────┐ │
│ │ 📅 Sep 29, 2026              │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ Categories                       │
│ ┌──────────┐ ┌──────┐ ┌──────┐  │
│ │✨Groceries│ │✨Food │ │+ Add │  │
│ │  (blue)  │ │(blue)│ │(gray)│  │
│ └──────────┘ └──────┘ └──────┘  │
├──────────────────────────────────┤
│ Payment Method                   │
│ ┌──────────────────────────────┐ │
│ │ 💳 HDFC Visa ····4532    ▼  │ │
│ └──────────────────────────────┘ │
│ ○ Split Payment                  │
├──────────────────────────────────┤
│ Note                             │
│ ┌──────────────────────────────┐ │
│ │ Add a note to remember...    │ │
│ │ (multi-line, expandable)     │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ Location                         │
│ ┌──────────────────────────────┐ │
│ │ 📍 Add Location              │ │
│ │  ┌─────────────────────────┐ │ │
│ │  │ ◉ Use Current Location  │ │ │
│ │  │ 🔍 Search Place          │ │ │
│ │  └─────────────────────────┘ │ │
│ └──────────────────────────────┘ │
│ (After selecting:)               │
│ ┌──────────────────────────────┐ │
│ │ ┌────────────────────┐  ✕   │ │
│ │ │ 🗺️  [mini-map]      │      │ │
│ │ └────────────────────┘      │ │
│ │ 📍 Indiranagar, Bangalore   │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ Attachments                      │
│ ┌────┐ ┌────┐ ┌────┐            │
│ │ 📷 │ │ 🖼 │ │ 📎 │            │
│ │Cam │ │Gal │ │File│            │
│ └────┘ └────┘ └────┘            │
│ ┌────────┐                       │
│ │ 🧾     │ ← receipt thumbnail  │
│ │  ✕  🔍 │                       │
│ └────────┘                       │
├──────────────────────────────────┤
│ Items                            │
│ ┌──────────────────────────────┐ │
│ │ ✨ Basmati Rice 5kg           │ │
│ │    1 × ₹350.00    = ₹350  ✕ │ │
│ ├──────────────────────────────┤ │
│ │ ✨ Tomatoes                   │ │
│ │    1 kg × ₹40.00  = ₹40   ✕ │ │
│ ├──────────────────────────────┤ │
│ │ ✨ Amul Butter 500g           │ │
│ │    2 × ₹280.00    = ₹560  ✕ │ │
│ ├──────────────────────────────┤ │
│ │           [+ Add Item]       │ │
│ └──────────────────────────────┘ │
│ Subtotal: ₹950  (Txn: ₹1,500)  │
│ ℹ️ Subtotal differs — taxes or   │
│   items may be missing           │
├──────────────────────────────────┤
│ ▸ Additional Options             │
│   ○ Recurring          [freq ▼]  │
│   ○ Flag for Follow-up           │
│   ○ Shared       [Name field  ]  │
│   ○ Expected      [Date picker]  │
├──────────────────────────────────┤
│ ┌──────────────────────────────┐ │
│ │ ✨ AI: Groceries, BigBasket  │ │
│ │       [Accept] [Edit]        │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

**Design Notes:**
- Amount field: Extra large font size, prominent, numeric keyboard
- Currency selector: Small badge/button next to amount
- Category chips: AI-suggested ones have ✨ sparkle prefix
- Split payment: When toggled ON, expands to show multiple method+amount rows
- Note field: Expandable multi-line text area, starts compact, grows with content
- Location: "Add Location" collapses to just the button when empty; expands to show mini-map when location is set. Uses Apple MapKit for search and display.
- Items: AI-extracted items show ✨ sparkle and are editable. Each row shows name, quantity × unit price = total, with ✕ to remove. "+ Add Item" button at bottom. Subtotal shown with comparison to transaction total if different.
- Attachments: Grid of action buttons + thumbnail previews
- Additional options: Collapsible section to reduce visual clutter
- AI suggestion banner: Light purple/blue background, appears contextually

---

## Screen 5: Transaction Detail

```
┌──────────────────────────────────┐
│ ← Back    Transaction    Edit ✏️ │
├──────────────────────────────────┤
│                                  │
│          -₹1,500.00              │
│           (large, red)           │
│                                  │
│    ┌──────────┐  Sep 29, 2026    │
│    │ EXPENSE  │                  │
│    └──────────┘                  │
├──────────────────────────────────┤
│ BigBasket Groceries              │
│ Weekly grocery order             │
│                                  │
│ Categories:                      │
│ ┌──────────┐ ┌──────┐           │
│ │ Groceries│ │ Food │           │
│ └──────────┘ └──────┘           │
│                                  │
│ Payment:                         │
│ 💳 HDFC Visa ····4532  ₹1,000   │
│ 📱 Amazon Pay          ₹500     │
├──────────────────────────────────┤
│ Note                             │
│ ┌──────────────────────────────┐ │
│ │ 📝 "Bought extra fruits for  │ │
│ │     the weekend party"       │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ Location                         │
│ ┌──────────────────────────────┐ │
│ │ ┌────────────────────────┐   │ │
│ │ │ 🗺️  [mini-map with pin] │   │ │
│ │ └────────────────────────┘   │ │
│ │ 📍 Indiranagar, Bangalore    │ │
│ │ 12th Main Rd, Bengaluru...   │ │
│ │         [Open in Maps]       │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ Items (3)                        │
│ ┌──────────────────────────────┐ │
│ │ Basmati Rice 5kg   1 × ₹350 │ │
│ │ Tomatoes         1kg × ₹40  │ │
│ │ Amul Butter 500g   2 × ₹280 │ │
│ ├──────────────────────────────┤ │
│ │ Subtotal:             ₹950  │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ Receipts                         │
│ ┌──────────┐ ┌──────────┐       │
│ │          │ │          │       │
│ │  🧾 img  │ │  🧾 img  │  ←→  │
│ │          │ │          │       │
│ └──────────┘ └──────────┘       │
├──────────────────────────────────┤
│ ▸ Extracted Text                 │
│   "BigBasket Order #12345       │
│    Tomatoes 1kg - Rs 40         │
│    Rice 5kg - Rs 350..."        │
├──────────────────────────────────┤
│ Metadata                         │
│ Created: Sep 29, 10:30 AM        │
│ Source: OCR Scan                 │
│ Sync: ✅ Synced                  │
│ Recurring: Weekly                │
├──────────────────────────────────┤
│ ┌──────┐ ┌──────┐ ┌──────┐     │
│ │ 🚩   │ │ 🗑    │ │ 📤   │     │
│ │ Flag │ │Delete│ │Share │     │
│ └──────┘ └──────┘ └──────┘     │
└──────────────────────────────────┘
```

---

## Screen 6: Transaction List (with Filters)

```
┌──────────────────────────────────┐
│ 🔍 Search transactions...     🎤│
├──────────────────────────────────┤
│ ┌──────┐┌────────┐┌──────┐┌───┐ │
│ │▪Date▪││Category││ Card ││...│ │
│ └──────┘└────────┘└──────┘└───┘ │
│ Applied: [Sep 1-30 ✕]           │
├──────────────────────────────────┤
│ ┌──────────────────────────────┐ │
│ │Credits ₹85,000 │Debits ₹52K │ │
│ │  Net +₹32,660  │  47 txns   │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ TODAY                            │
│ ┌──────────────────────────────┐ │
│ │🛒 Amazon Order    [Shopping] │ │
│ │   ICICI ····8877             │ │
│ │                    -₹2,499 🔴│ │
│ ├──────────────────────────────┤ │
│ │💼 Freelance Pay    [Income]  │ │
│ │   Bank Transfer              │ │
│ │                   +₹15,000 🟢│ │
│ └──────────────────────────────┘ │
│ YESTERDAY                        │
│ ┌──────────────────────────────┐ │
│ │🍽 Swiggy Dinner 🚩 [Food]    │ │
│ │   Amazon Pay                 │ │
│ │                      -₹680 🔴│ │
│ ├──────────────────────────────┤ │
│ │⛽ Petrol        [Transport]  │ │
│ │   SBI Debit ····1234         │ │
│ │                    -₹1,200 🔴│ │
│ └──────────────────────────────┘ │
│ SEP 27, 2026                     │
│ ┌──────────────────────────────┐ │
│ │🛒 BigBasket     [Groceries]  │ │
│ │   HDFC Visa ····4532         │ │
│ │                    -₹1,500 🔴│ │
│ └──────────────────────────────┘ │
│                                  │
│ ← Swipe Left: Delete (Red)      │
│ → Swipe Right: Flag (Yellow)    │
└──────────────────────────────────┘
```

---

## Screen 7: Budget Management

```
┌──────────────────────────────────┐
│ ← Back       Budgets       + Add│
├──────────────────────────────────┤
│        ┌───────────────┐         │
│       ╱                 ╲        │
│      │    ₹52,340        │       │
│      │   of ₹75,000      │       │
│       ╲    69.8%        ╱        │
│        └───────────────┘         │
│       Overall Monthly Budget     │
│                                  │
│    [▪ Monthly ▪]  [ Weekly ]     │
├──────────────────────────────────┤
│ Category Budgets                 │
│ ┌──────────────────────────────┐ │
│ │ 🍔 Food         ₹6,200/₹8K │ │
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓░░░░  77% 🟡   │ │
│ ├──────────────────────────────┤ │
│ │ 🚗 Transport    ₹3,100/₹5K │ │
│ │ ▓▓▓▓▓▓▓▓▓░░░░░░░  62% 🟢   │ │
│ ├──────────────────────────────┤ │
│ │ 🛍 Shopping    ₹12,400/₹15K │ │
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓▓░░░  83% 🟠   │ │
│ ├──────────────────────────────┤ │
│ │ 🏥 Health       ₹2,800/₹3K │ │
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░  93% 🔴   │ │
│ ├──────────────────────────────┤ │
│ │ 🎬 Entertainment ₹800/₹2K  │ │
│ │ ▓▓▓▓▓░░░░░░░░░░░  40% 🟢   │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

---

## Screen 8: Expected Transactions (Tracking)

```
┌──────────────────────────────────┐
│ ← Back      Tracking      + New │
├──────────────────────────────────┤
│ PENDING (2)                      │
│ ┌──────────────────────────────┐ │
│ │ 📦 Amazon Refund             │ │
│ │    Expected: ₹2,499          │ │
│ │    By: Oct 5, 2026           │ │
│ │    Status: ⏳ On Track       │ │
│ ├──────────────────────────────┤ │
│ │ 👤 Rahul owes money          │ │
│ │    Expected: ₹5,000          │ │
│ │    By: Oct 2, 2026           │ │
│ │    Status: 🔴 Overdue (2d)   │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ COMPLETED (3)                    │
│ ┌──────────────────────────────┐ │
│ │ ✅ Flipkart Refund           │ │
│ │    ₹1,299 · Sep 25           │ │
│ │    Matched: "NEFT CR..."  →  │ │
│ ├──────────────────────────────┤ │
│ │ ✅ Salary September          │ │
│ │    ₹85,000 · Sep 1           │ │
│ │    Matched: "SAL CR..."   →  │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

---

## Screen 9: Payment Reminders

```
┌──────────────────────────────────┐
│ ← Back     Reminders       + New│
├──────────────────────────────────┤
│        September 2026            │
│ Mo Tu We Th Fr Sa Su             │
│  1  2  3  4  5  6  7            │
│  8  9 10 11 12 13 14            │
│ 15•16 17 18 19 20 21            │
│ 22 23 24 25 26 27 28            │
│ 29 30  1• 2  3  4  5            │
│       (• = has reminders)        │
├──────────────────────────────────┤
│ 🔴 OVERDUE                       │
│ ┌──────────────────────────────┐ │
│ │ 🏛 LIC Premium   ₹12,500    │ │
│ │   Due: Sep 15 (14 days ago)  │ │
│ │   Quarterly                  │ │
│ │   [Mark Paid] [Snooze]       │ │
│ └──────────────────────────────┘ │
│ ⏰ UPCOMING                      │
│ ┌──────────────────────────────┐ │
│ │ 🏥 Health Insurance  ₹8,200  │ │
│ │   Due: Oct 1 (2 days)        │ │
│ │   Annual                     │ │
│ │   [Mark Paid] [Edit]         │ │
│ ├──────────────────────────────┤ │
│ │ 📱 Broadband Bill    ₹999   │ │
│ │   Due: Oct 5 (6 days)        │ │
│ │   Monthly                    │ │
│ │   [Mark Paid] [Edit]         │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

---

## Screen 10: Flagged Items

```
┌──────────────────────────────────┐
│ ← Back     Flagged (3)          │
├──────────────────────────────────┤
│ ┌──────────────────────────────┐ │
│ │ 🚩 Swiggy Dinner     -₹680  │ │
│ │    Sep 28 · "Verify charge"  │ │
│ │    Flagged 1 day ago         │ │
│ │              [Resolve] [View]│ │
│ ├──────────────────────────────┤ │
│ │ 🚩 Unknown Debit   -₹1,999  │ │
│ │    Sep 25 · "Check statement"│ │
│ │    Flagged 4 days ago        │ │
│ │              [Resolve] [View]│ │
│ ├──────────────────────────────┤ │
│ │ 🚩 Subscription     -₹499   │ │
│ │    Sep 20 · "Cancel if wrong"│ │
│ │    Flagged 9 days ago        │ │
│ │              [Resolve] [View]│ │
│ └──────────────────────────────┘ │
│                                  │
│        No more flagged items     │
└──────────────────────────────────┘
```

---

## Screen 11: Settings

```
┌──────────────────────────────────┐
│          Settings                │
├──────────────────────────────────┤
│ ACCOUNT                          │
│ ┌──────────────────────────────┐ │
│ │ 👤 John Doe                  │ │
│ │    john@example.com          │ │
│ │                    Sign Out →│ │
│ └──────────────────────────────┘ │
│ GOOGLE DRIVE                     │
│ ┌──────────────────────────────┐ │
│ │ 🟢 Connected                 │ │
│ │    john@gmail.com            │ │
│ │                 Disconnect → │ │
│ └──────────────────────────────┘ │
│ APPEARANCE                       │
│ ┌──────────────────────────────┐ │
│ │ Theme:  Light│Dark│▪System▪  │ │
│ └──────────────────────────────┘ │
│ NOTIFICATIONS                    │
│ ┌──────────────────────────────┐ │
│ │ Daily Summary          [ON ] │ │
│ │ Budget Alerts          [ON ] │ │
│ │ Flag Reminders         [ON ] │ │
│ │ Due Date Reminders     [ON ] │ │
│ │ Inactivity Alerts      [ON ] │ │
│ │ Export Warnings        [ON ] │ │
│ └──────────────────────────────┘ │
│ DATA MANAGEMENT                  │
│ ┌──────────────────────────────┐ │
│ │ Export Data               →  │ │
│ │ Retention: 12mo rolling  ℹ️  │ │
│ │ Clear Local Cache        ⚠️  │ │
│ └──────────────────────────────┘ │
│ AI SETTINGS                      │
│ ┌──────────────────────────────┐ │
│ │ AI Suggestions         [ON ] │ │
│ │ Correction History       →   │ │
│ └──────────────────────────────┘ │
│ PAYMENT METHODS                  │
│ ┌──────────────────────────────┐ │
│ │ Manage Methods (6)       →   │ │
│ └──────────────────────────────┘ │
│ ABOUT                            │
│ ┌──────────────────────────────┐ │
│ │ Version 1.0.0            →   │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

---

## Screen 12: Export Data

```
┌──────────────────────────────────┐
│ ← Back      Export Data          │
├──────────────────────────────────┤
│ Date Range                       │
│ ┌──────────────────────────────┐ │
│ │ From: 📅 Sep 1, 2026         │ │
│ │ To:   📅 Sep 29, 2026        │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ Format                           │
│ ┌──────────────────────────────┐ │
│ │ ○ CSV  (.csv)                │ │
│ │ ○ Excel (.xlsx)              │ │
│ │ ● JSON (.json) — Best for AI │ │
│ │ ○ PDF  (.pdf)  — With images │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ Options                          │
│ ┌──────────────────────────────┐ │
│ │ Include receipt images [ON ] │ │
│ │ Include OCR text       [ON ] │ │
│ │ Include corrections    [OFF] │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ Preview                          │
│ ┌──────────────────────────────┐ │
│ │ 47 transactions              │ │
│ │ Estimated size: ~2.3 MB      │ │
│ └──────────────────────────────┘ │
│                                  │
│ ┌──────────────────────────────┐ │
│ │         📤 Export             │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

---

## Screen 13: Share Extension (Compact)

```
┌──────────────────────────────────┐
│ FinSight              ✕ Close    │
├──────────────────────────────────┤
│ ┌──────────────────────────────┐ │
│ │ 🧾 Receipt image preview     │ │
│ │    or SMS text preview       │ │
│ └──────────────────────────────┘ │
│                                  │
│ ⏳ Processing with AI...         │
│ ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░             │
│                                  │
│ ── After AI processing ──       │
│                                  │
│ Amount:  ₹ 1,500.00             │
│ Title:   BigBasket Groceries     │
│ Type:    [▪Expense▪] [Income]   │
│ Date:    Sep 29, 2026            │
│                                  │
│ ┌────────────┐ ┌──────────────┐ │
│ │ Save Draft │ │Save & Close  │ │
│ └────────────┘ └──────────────┘ │
└──────────────────────────────────┘
```

---

## Screen 14: Payment Methods Management

```
┌──────────────────────────────────┐
│ ← Back   Payment Methods   + Add│
├──────────────────────────────────┤
│ CREDIT CARDS                     │
│ ┌──────────────────────────────┐ │
│ │ 💳 HDFC Bank Visa  ····4532  │ │
│ │    ★ Default                 │ │
│ ├──────────────────────────────┤ │
│ │ 💳 ICICI Mastercard ····8877 │ │
│ └──────────────────────────────┘ │
│ DEBIT CARDS                      │
│ ┌──────────────────────────────┐ │
│ │ 💳 SBI RuPay      ····1234  │ │
│ └──────────────────────────────┘ │
│ WALLETS                          │
│ ┌──────────────────────────────┐ │
│ │ 📱 Amazon Pay                │ │
│ ├──────────────────────────────┤ │
│ │ 📱 PhonePe                   │ │
│ └──────────────────────────────┘ │
│ CASH                             │
│ ┌──────────────────────────────┐ │
│ │ 💵 Cash                      │ │
│ └──────────────────────────────┘ │
│                                  │
│ ← Swipe to delete               │
│   Tap to edit                    │
└──────────────────────────────────┘
```

---

## Screen 15: Recurring Transactions

```
┌──────────────────────────────────┐
│ ← Back      Recurring            │
├──────────────────────────────────┤
│ ✨ AI SUGGESTIONS (2)      New → │
│ ┌──────────────────────────────┐ │
│ │ 🔄 Netflix Subscription      │ │
│ │    ~₹649/month · 6 matches   │ │
│ │    Confidence: 94%           │ │
│ │    [Accept] [Dismiss]        │ │
│ ├──────────────────────────────┤ │
│ │ 🔄 Gym Membership            │ │
│ │    ~₹2,000/month · 5 matches │ │
│ │    Confidence: 87%           │ │
│ │    [Accept] [Dismiss]        │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ ACTIVE RULES (3)                 │
│ ┌──────────────────────────────┐ │
│ │ 🔄 BigBasket Weekly          │ │
│ │    ~₹1,500 · Every week      │ │
│ │    Next: Oct 6              │ │
│ ├──────────────────────────────┤ │
│ │ 🔄 Spotify                   │ │
│ │    ₹119 · Monthly            │ │
│ │    Next: Oct 15              │ │
│ ├──────────────────────────────┤ │
│ │ 🔄 House Rent                │ │
│ │    ₹25,000 · Monthly         │ │
│ │    Next: Oct 1               │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

---

## Tab Bar Structure

```
┌──────┬──────┬──────┬──────┬──────┐
│ 🏠   │ 📋   │  ➕  │ 📊   │ ⋯   │
│Home  │Trans │ Add  │Track │ More │
└──────┴──────┴──────┴──────┴──────┘

Home   → Dashboard (Screen 3)
Trans  → Transaction List (Screen 6)
Add    → Add Transaction (Screen 4) — presented as modal
Track  → Tracking hub: Expected, Reminders, Recurring, Flagged
More   → Settings, Export, Budget, Payment Methods
```

---

## macOS Adaptations

On macOS, the app uses a sidebar navigation instead of a tab bar:

```
┌────────────────┬─────────────────────────────────────────┐
│ FinSight       │                                         │
│                │         [Content Area]                  │
│ 🏠 Dashboard   │                                         │
│ 📋 Transactions│   Same screen content as iOS            │
│ 📊 Tracking    │   but wider layout with                 │
│   📥 Expected  │   multi-column where appropriate        │
│   ⏰ Reminders │                                         │
│   🔄 Recurring │   e.g., Transaction List + Detail       │
│   🚩 Flagged   │   shown side-by-side                    │
│ 📊 Budgets     │                                         │
│ 💳 Methods     │                                         │
│                │                                         │
│ ──────────     │                                         │
│ ⚙️ Settings    │                                         │
│ 📤 Export      │                                         │
└────────────────┴─────────────────────────────────────────┘
```
