# Rock & Stone Restaurant 2.0 — Owner & Operations Manual

> **Destination**: Rock & Stone Restaurant  
> **Location**: V.P.O. Tatal, Near Indian Oil Petrol Pump, P/O Khel, Tehsil Nurpur, Kangra, Himachal Pradesh 176205  
> **Phone**: +91 76781 29577 | **Email**: ashmitkumarbwj@gmail.com  
> **FSSAI License**: 10925004000220 | **GSTIN**: 02DKLPP2797H1ZR  
> **Dietary Classification**: Strictly 100% Pure Vegetarian  

---

## 1. Project Overview & Isolated Preview Setup

This project is the complete, production-ready system for **Rock & Stone Restaurant 2.0**.
As mandated by Non-Negotiable Requirement #1, all development, staging, and testing are hosted inside this isolated preview directory:
`c:\xampp\htdocs\xampp\rock-stone-preview/`

The existing live website and production domain remain **100% untouched**. No DNS change, deployment cutover, or live payment gateway activation will be performed without explicit sign-off from the restaurant owner.

---

## 2. Directory & Page Map

| Public Page | Purpose & URL |
| :--- | :--- |
| **Home** | [`index.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/index.html) — Hero, pure veg philosophy, signature dishes, hours, FSSAI & GSTIN |
| **Menu** | [`menu.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/menu.html) — Real-time search, category filters, pure veg badges, Add to Cart |
| **Cart & Checkout** | [`cart.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/cart.html) — Dine-in, Takeaway, and Delivery checkout with authoritative server pricing |
| **Order Confirmation** | [`order-confirmation.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/order-confirmation.html) — Unique order ID (`RS-YYYYMMDD-XXXX`), WhatsApp confirmation alert |
| **Order Tracking** | [`order-tracking.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/order-tracking.html) — Live status stepper (`PENDING` → `ACCEPTED` → `PREPARING` → `READY` → `COMPLETED`) |
| **Reservations** | [`reservations.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/reservations.html) — Table booking form with duplicate-booking validation |
| **Our Story** | [`story.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/story.html) — Kangra Valley roots, slate stone architecture, Himachali Dham traditions |
| **Gallery** | [`gallery.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/gallery.html) — High-definition ambience, outdoor terrace dining, clay tandoori preparations |
| **Reviews** | [`reviews.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/reviews.html) — Verified customer testimonials and moderated submission queue |
| **Contact** | [`contact.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/contact.html) — Location map, phone, email, hours, FSSAI 10925004000220 & GSTIN |
| **Legal Information** | [`legal/privacy-policy.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/legal/privacy-policy.html), [`legal/terms.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/legal/terms.html), [`legal/refund-policy.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/legal/refund-policy.html) |

### Administrative Suite (Role Protected)
| Admin Page | Purpose & URL |
| :--- | :--- |
| **Admin Login** | [`admin/login.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/admin/login.html) — Role-based staff authentication |
| **Dashboard** | [`admin/index.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/admin/index.html) — Today's revenue, active orders, pending reservations, quick shortcuts |
| **Kitchen KDS** | [`admin/kitchen.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/admin/kitchen.html) — Live kitchen display board with synthesized audio chime & order stage progression |
| **Menu Manager** | [`admin/menu.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/admin/menu.html) — Add/Edit pure veg dishes, toggle availability, CSV menu importer |
| **Reservations Manager** | [`admin/reservations.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/admin/reservations.html) — Accept, reject, or assign dining tables |
| **Review Moderation** | [`admin/reviews.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/admin/reviews.html) — Moderate customer reviews prior to publishing |
| **Settings** | [`admin/settings.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/admin/settings.html) — Change hours, phone, email, FSSAI, GSTIN, and delivery rates |

---

## 3. Strict 100% Pure Vegetarian Enforcement

1. **Schema Check Constraints**:
   `menu_items` table contains `is_pure_veg BOOLEAN NOT NULL DEFAULT TRUE CHECK (is_pure_veg = TRUE)`.
2. **Zero Non-Veg Keywords**:
   Data entry and CSV import engines enforce regex word filters banning meat, chicken, egg, mutton, fish, or gelatin terms.
3. **No Non-Veg Filter**:
   The public menu contains no filter for "veg / non-veg" because 100% of the entire kitchen and menu is pure vegetarian.

---

## 4. How to Operate the Restaurant System

### 4.1 How to Edit and Publish Menu Items
1. Login to `admin/login.html` using authorized credentials.
2. Navigate to **Menu Management** (`admin/menu.html`).
3. Click **"+ Add New Dish"** or click **"Edit"** on any existing dish.
4. Update the item name, price, description, and dietary tags.
5. All sample items are initially marked as **UNPUBLISHED (PREVIEW)**. Once verified with the owner, mark them published.
6. To import the owner's menu from spreadsheet, click **"Import CSV Menu"**. Upload a CSV with headers: `name, category, price, description, dietary_tags`. The system will validate every row for pure veg compliance.

### 4.2 How to Manage Orders on the Kitchen Display (KDS)
1. Keep `admin/kitchen.html` open on a tablet or kitchen display monitor.
2. When a customer places an order, the system sounds an **audio chime** and displays a highlighted card.
3. Advance the ticket lifecycle:
   - Click **"Accept & Start"** (Transitions `PENDING` → `ACCEPTED`)
   - Click **"Send To Cooking"** (Transitions `ACCEPTED` → `PREPARING`)
   - Click **"Mark Food Ready"** (Transitions `PREPARING` → `READY`)
   - Click **"Order Completed / Served"** (Transitions `READY` → `COMPLETED`)
4. The customer's live tracking page updates automatically in real-time.

### 4.3 How to Change Restaurant Details & Hours
1. Go to **Restaurant Settings** (`admin/settings.html`).
2. Update phone (+91 76781 29577), email, operating hours, delivery radius, or packaging fees.
3. Click **"Save Settings & Update System"**.

### 4.4 How to Manage SBI Merchant QR Payments & Bank Reconciliation
- **Authentic Merchant Standee**:
  - Standee image: [`assets/images/sbi-merchant-qr.png`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/assets/images/sbi-merchant-qr.png)
  - Preserved uncropped and unredrawn.
  - Merchant Name: `ROCK AND STONE RESTRAUNT`
  - VPA / UPI ID: `SBIBHIM.INSTANT58346251347481864@sbipay`
  - Terminal ID (TID): `SB797564` | Merchant ID (MID): `022211900799141`
- **Customer Experience**:
  - The customer selects **"SBI Payments Merchant QR"** at checkout.
  - The system displays the full standee, exact payable amount, and merchant details.
  - After scanning with GPay/PhonePe/Paytm/BHIM/Yono, the diner submits their 12-digit UPI Reference / UTR number.
  - The order is created with payment status strictly set to `PENDING`.
- **Reconciliation Admin Workflow** ([`admin/orders.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/admin/orders.html)):
  1. Open **Orders & Payments** in the admin sidebar.
  2. Filter by **Pending Bank Reconciliation**.
  3. Click **"Reconcile Bank Credit"** on the customer's order.
  4. Compare the customer's UTR against the credit in your SBI Merchant App or bank statement.
  5. Click **"✓ Verify & Mark PAID"** to record the authorized staff name, timestamp, and update the order state.
  6. If no credit arrived, click **"Flag as Unmatched / Failed"**. Never treat customer screenshots alone as proof.

### 4.5 Authentic Media & Official Instagram Integration
- **Official Instagram Profile**: [https://www.instagram.com/rock_and_stone_restraunt/](https://www.instagram.com/rock_and_stone_restraunt/)
- **Media Manager** ([`admin/gallery.html`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/admin/gallery.html)):
  - Authorized staff can upload original photos of the restaurant exterior, interior, seating, and authentic pure vegetarian dishes.
  - Every asset includes descriptive alt text, categorization, and pure vegetarian confirmation.
  - Reorder, caption, and delete photos directly from the admin panel.
  - Preview/mockup assets are clearly labelled until the owner uploads verified authentic photos from their Instagram library.

### 4.5 How to Back Up and Restore the Database
- **PostgreSQL / Supabase Schema**:
  The full DDL schema and seeds are stored under:
  - [`database/schema.sql`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/database/schema.sql)
  - [`database/seeds.sql`](file:///c:/xampp/htdocs/xampp/rock-stone-preview/database/seeds.sql)
- **Backup Command**:
  ```bash
  pg_dump -h <supabase_host> -U postgres -d postgres > rock_stone_backup_$(date +%F).sql
  ```
- **Restore Command**:
  ```bash
  psql -h <supabase_host> -U postgres -d postgres < rock_stone_backup_YYYY-MM-DD.sql
  ```

---

## 5. Launch & Rollback Checklist

- [x] Himalayan visual design system implemented (Forest green, warm cream, stone grey, terracotta).
- [x] 100% Pure Vegetarian guardrails implemented in UI, JS validation, and Database SQL DDL.
- [x] Complete public responsive pages created and tested.
- [x] Authoritative server-side price recalculation endpoint created.
- [x] Idempotent order numbers (`RS-YYYYMMDD-XXXX`) generated.
- [x] Live order status tracking stepper functioning.
- [x] Kitchen Display System (KDS) board with synthesized audio chime operational.
- [x] Table reservation engine with duplicate-booking validation operational.
- [x] Review moderation queue operational.
- [x] Statutory compliance verified (FSSAI 10925004000220 & GSTIN 02DKLPP2797H1ZR).
- [x] Current live production domain remains completely untouched on separate preview.
- [ ] **Owner Sign-Off Gate**: Awaiting owner verification of exact menu dishes and prices before live deployment.
