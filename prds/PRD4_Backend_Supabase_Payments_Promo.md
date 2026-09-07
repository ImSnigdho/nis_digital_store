### **PRODUCT REQUIREMENTS DOCUMENT — PART 4 OF 4** 

# **Backend Platform — Supabase Schema, Dynamic Payment Methods, Promo Codes & Settings** 

_The foundational data model, security rules, and new systems that PRDs 1–3 depend on_ 

|**Product**|**YBT Digital Store (Flutter customer app + Web**<br>**Admin Panel)**|
|---|---|
|Document|PRD 4 of 4|
|Document Owner|Nowrid — Product Owner|
|Status|Draft v1.0 — For Review|
|Date|August 23, 2026|
|Backend|Supabase (Postgres + Auth + Storage), Google<br>OAuth|
|Depends On|None — this is the foundation. Build this first.|
|Recommended Build<br>Order|Build 1st. PRDs 1, 2, and 3 all depend on the tables,<br>storage buckets, and RLS policies defined here.|



## **1. Summary** 

Every bug described in PRDs 1–3 traces back to the same root cause: the app's screens are not reliably reading from or writing to a working backend. The project uses Supabase (Postgres + Auth + Storage) with Google OAuth already configured for sign-in. This document defines the complete data model, security policies, storage buckets, and the two new systems requested — dynamic Payment Methods and a professional Promo Code engine — plus the Settings screen restructure. 

## **2. Authentication** 

- Confirm Google OAuth is correctly configured in Supabase Auth (Authorized redirect URIs, client ID/secret) for both the customer app and, separately, a restricted sign-in path for the admin panel. 

- On first sign-in, a Postgres trigger should copy relevant fields from auth.users into a public profiles table (id, name, email, created_at) so the rest of the schema can foreign-key to a normal table instead of the auth schema. 

- Admin access is controlled by an is_admin boolean (or a separate admin_users table) checked by RLS policies — never by trusting a client-side flag. 

## **3. Core Schema** 

#### **3.1 Tables** 

|**Table**|**Key Columns**|
|---|---|
|profiles|id (uuid, = auth.users.id), name, email, phone, is_admin, status, created_at|
|categories|id, name, slug, description, status, created_at|
|products|id, title, short_description, full_description, price, sale_price, category_id (fk),<br>status, is_featured, thumbnail_url, file_url, downloads_count, created_at,<br>updated_at|
|payment_methods|id, name (e.g. bKash), account_number, icon_url, is_active, sort_order,<br>created_at, updated_at|
|promo_codes|id, code (unique, case-insensitive), discount_type (percentage / fixed),<br>percentage_value, fixed_amount, fixed_currency (BDT / USD, null for<br>percentage), min_order_amount, usage_limit, times_used, expires_at,<br>is_active, created_at|
|orders|id, order_number, customer_id (fk profiles, nullable for guest),<br>customer_name, phone, delivery_email, payment_method_id (fk), txid,<br>currency (BDT / USD), subtotal, discount_amount, promo_code_id (fk,<br>nullable), total_amount, status, admin_notes, created_at, updated_at|
|order_items|id, order_id (fk), product_id (fk), quantity, unit_price, line_total|
|order_status_log|id, order_id (fk), old_status, new_status, changed_by (fk profiles), changed_at|
|store_settings|id (singleton row), store_name, banner_url, updated_at|



#### **3.2 Removed From Scope** 

- "Store Theme Colors" is explicitly dropped per stakeholder direction — no primary/accent color customization field is needed on store_settings. 

## **4. Row Level Security (RLS) — Required Policies** 

|**Table**|**Policy Summary**|
|---|---|
|products, categories,<br>payment_methods,<br>promo_codes|Public/anon: SELECT only where is_active = true (or status = 'Active').<br>Admin: full SELECT/INSERT/UPDATE/DELETE.|
|orders, order_items|Authenticated customer: INSERT their own order/items; SELECT only<br>rows where customer_id = auth.uid() (or a guest lookup by<br>delivery_email + order token). Admin: full SELECT/UPDATE on all<br>orders.|
|order_status_log|Admin: INSERT/SELECT only. Not writable by customers.|
|store_settings,<br>profiles.is_admin|Only admin role may UPDATE. All other writes rejected at the<br>database level, not just hidden in the UI.|



This closes the current gap where actions appear to succeed in the UI but silently fail (or silently no-op) against the database — every write path above must be tested against these policies, signed in as both a normal customer and an admin. 

## **5. Storage Buckets** 

|**Bucket**|**Access**|**Used For**|
|---|---|---|
|product-thumbnails|Public read|Product Featured Image|
|product-files|Private — signed<br>URL only|The actual digital deliverable, released only after an order<br>is Completed|
|payment-icons|Public read|Icons shown next to each payment method at checkout|
|store-banner|Public read|Homepage banner image (Settings → Store Banner)|



## **6. Dynamic Payment Methods System** 

Replaces the hardcoded bKash/Nagad pair everywhere in the app. Payment methods become fully admin-managed records, added the same way a product is added. 

#### **6.1 Admin Screen (Settings → Payment Methods)** 

- List of existing payment methods with icon, name, account number, active/inactive toggle, and reorder/sort control. 

- "Add Payment Method" opens a form: Name, Account Number / Handle, Icon upload (image, stored in the payment-icons bucket), Active toggle — mirrors the Add Product form pattern. 

- Edit opens the same form pre-filled; Delete requires confirmation and should be blocked (or the method archived) if past orders reference it. 

- Any change here (e.g. updating the bKash number) must be reflected at checkout immediately, since checkout always reads the live table — never a cached/hardcoded copy. 

#### **6.2 Checkout Consumption** 

- Checkout fetches all rows where is_active = true, ordered by sort_order, and renders one selectable option per row with its icon, name, and account number. 

## **7. Promo Code System** 

A professional two-type discount engine, replacing the current total absence of any promo code functionality. 

#### **7.1 Discount Types** 

|**Type**|**Fields Used**|**Behavior**|
|---|---|---|
|Percentage|percentage_value (e.g. 10 =<br>10% off)|Applies to the order subtotal regardless of currency<br>(BDT or USD) — currency-agnostic.|
|Fixed Amount|fixed_amount,<br>fixed_currency (BDT or<br>USD)|Deducts a flat amount, valid only for orders placed<br>in the matching currency. A BDT-denominated<br>code must be rejected on a USD order, and a USD-<br>denominated code must be rejected on a BDT order.|



#### **7.2 Additional Fields & Rules** 

- code is unique and matched case-insensitively at checkout. 

- min_order_amount (optional) — order subtotal must meet or exceed this for the code to apply. 

- usage_limit / times_used — once times_used reaches usage_limit, the code is rejected; times_used increments atomically when an order using it is successfully placed. 

- expires_at — codes are rejected after this date/time. 

- is_active — admin can disable a code instantly without deleting it. 

#### **7.3 Validation Function (server-side)** 

Promo validation must happen in the backend (a Postgres function or Supabase Edge Function), not only in client-side code, so a customer cannot bypass currency or usage-limit checks by manipulating the app. 

1. Look up the code case-insensitively; if not found or is_active = false, reject. 

2. If expires_at has passed, reject. 

3. If times_used >= usage_limit, reject. 

4. If discount_type = fixed and fixed_currency does not match the order's currency, reject with a currency-mismatch reason. 

5. If subtotal < min_order_amount, reject. 

6. Otherwise compute the discount, return it to the client for display, and only increment times_used once the order is actually placed (not merely previewed). 

#### **7.4 Admin Screen** 

- A full CRUD screen for promo codes: list (code, type, value/currency, usage, expiry, active toggle) plus Add/Edit forms matching the fields above. 

- Per stakeholder direction, this screen moves out of Settings and becomes its own top-level tab in the admin bottom navigation, alongside Dashboard, Products, Categories, Orders, and Settings. 

## **8. Settings Screen Restructure** 

Reference: uploaded Settings screenshot. Currently none of these entries persist changes to the backend. 

- Remove "Store Theme Colors" entirely — explicitly out of scope per stakeholder request (the yellow-highlighted item). 

- Remove "Promo Codes" from this list — it becomes its own bottom-navigation tab (Section 7.4), not a Settings sub-page. 

- Store Name — must persist to store_settings.store_name and reflect on the customer app's header/branding. 

- Payment Methods — replaced by the full dynamic CRUD screen in Section 6.1 (no longer just two fixed number fields). 

- Store Banner — image upload must persist to the store-banner bucket and store_settings.banner_url, and actually render on the customer app's home screen. 

- Featured Categories — selecting categories here must persist (e.g. an is_featured boolean or a join table) and control what appears in a "Featured" section on the customer app home screen. 

## **9. Acceptance Criteria** 

- A signed-in customer can place an order and the row appears in Postgres immediately, visible to the admin role but not to other customers. 

- Editing a payment method or promo code in the admin panel is reflected on the customer app within the same session, with no redeploy. 

- A fixed-amount BDT promo code is correctly rejected on a USD order and accepted on a BDT order that meets its minimum order amount and hasn't exceeded its usage limit — and vice versa for a USD code. 

- All RLS policies have been tested from both a normal authenticated customer session and an admin session, confirming customers cannot read or modify other customers' orders or write to admin-only tables. 

- Store Name, Store Banner, Featured Categories, and Payment Methods changes in Settings all persist and visibly affect the customer app. 

- "Store Theme Colors" no longer appears anywhere in the admin panel. 

