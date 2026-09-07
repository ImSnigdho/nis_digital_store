**PRODUCT REQUIREMENTS DOCUMENT**

**NIS Digital Store — Admin Panel Rebuild & Backend Integration**

_Fixing non-functional CRUD operations, redesigning the admin UI, and wiring the Flutter digital-store app to a working backend_

| **Product**           | **NIS Digital Admin (Flutter app + Web Admin Panel)**                      |
| --------------------- | -------------------------------------------------------------------------- |
| **Document Owner**    | Nowrid — Product Owner                                                     |
| **Status**            | Draft v1.0 — For Review                                                    |
| **Date**              | August 22, 2026                                                            |
| **Related Artifacts** | Dashboard, Products, Categories, Orders, Users screenshots (current build) |

# **1\. Executive Summary**

The YBT Digital Admin panel — the back office for a Flutter-based digital products store — currently renders a plausible-looking dashboard, but almost none of the underlying functionality works. Products cannot actually be created because the "Add Product" form does not save or upload files; the Orders section shows a single hard-coded order with no way to see what a customer bought, which email to deliver the file to, or whether payment was actually verified; and the visual design is inconsistent across screens.

This PRD defines the requirements to rebuild the admin panel's UI to match the approved reference screenshots, and — more importantly — to build the backend (API + database + file storage) that makes every screen actually persist and reflect real data. Orders management is called out as the highest-priority section, since it is the core revenue-verification workflow of the store: every purchase must be traceable to a product, a delivery email, and a payment transaction ID (TXID), and must move through a clear status lifecycle (Pending → Completed / Refunded / Cancelled).

# **2\. Problem Statement**

Based on a review of the current build (see reference screenshots 1–6), the following problems were identified:

### **2.1 Dashboard**

- Summary cards (Total Products, Total Revenue, Total Orders, Total Users) and "Top Products" are not reliably reflecting real database counts.
- Quick Action buttons (Add Product, Add Category, Create Coupon, View Reports) are present visually but are not fully wired to their destination screens/actions.

### **2.2 Products**

- The "Add New Product" form (screenshot 3) does not persist data — clicking Save Product does not create a record, and thumbnail/product file uploads do not work at all.
- There is no working file storage for the product thumbnail ("Featured Image") or the downloadable product file.
- Category dropdown on the product form is not connected to the real categories list.
- Edit and Delete actions on the product list are not confirmed to work end-to-end.

### **2.3 Categories**

- Category management UI needs to be standardized to the layout in screenshot 4 (ID, Name, Slug, Description, Products count, Status, Created date, Actions), and product counts must be computed dynamically rather than shown as static "0 PRODUCTS."

### **2.4 Orders — Critical**

- The order list shows only a customer name and a generic "1 items" tag — there is no way for the admin to see exactly which product(s) were purchased.
- There is no visible delivery email captured or shown per order (the email the digital product should be sent/unlocked to).
- There is no payment transaction ID (TXID) captured or displayed, so admins cannot verify that a payment actually happened before releasing a digital product.
- Order status is effectively stuck — there's no working control to move an order between Pending, Completed, Refunded, and Cancelled.

### **2.5 Users**

- User list works at a basic level but actions (view, edit, suspend/ban) are not confirmed functional; order history per user is not linked to real order records.

### **2.6 Backend**

- There is no confirmed working API layer behind these screens — most "saves" appear to be UI-only, meaning nothing survives a refresh.

# **3\. Goals & Success Metrics**

| **Goal**                                             | **Success Metric**                                                                                                    |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Admin panel UI matches approved reference screens    | Dashboard, Products, Add Product, Categories, Orders, Users all pixel-consistent with the reference designs           |
| Every screen is backed by a real, persistent backend | Refreshing the page or reopening the app always shows the latest saved state — zero UI-only mock data                 |
| Product creation fully works, including file uploads | Admin can create a product with a thumbnail image and a downloadable file, and it appears correctly on the storefront |
| Orders show complete, verifiable purchase details    | 100% of orders display product(s) purchased, delivery email, and payment TXID                                         |
| Order status is fully controllable                   | Admin can move any order through Pending → Completed / Refunded / Cancelled, and the customer/app reflects the change |
| Categories are dynamic and accurate                  | Product counts per category always match the real number of products in that category                                 |

# **4\. Scope**

### **4.1 In Scope**

- Redesign/rebuild of: Dashboard, Products list, Add/Edit Product form, Categories, Orders, Users screens.
- Backend API + database schema to support full CRUD for Products, Categories, Orders, Users.
- File upload & storage pipeline for product thumbnails and product files (digital downloads).
- Order data model capturing product(s) ordered, delivery email, payment TXID, and status.
- Order status workflow and the actions/permissions needed to change status.
- Basic dashboard analytics (counts and revenue) computed from real data.

### **4.2 Out of Scope (this phase)**

- Coupons module logic (button exists on dashboard; full coupon CRUD can be a follow-up PRD).
- Advanced Reports module beyond the dashboard summary cards.
- Multi-admin roles/permissions (single Super Admin role assumed for now).
- Automated payment gateway integration beyond capturing/verifying the TXID the customer provides (see Assumptions).

# **5\. Assumptions & Open Questions**

### **5.1 Assumptions**

- Payment collection manual ( customer gives payment txid to manual verify the payment) happens on the customer-facing Flutter app; the admin panel's job is to display and let the admin verify the TXID returned by that gateway, and/or a manually-submitted TXID for manual/bank transfer payments.
- "Delivery email" is the address the customer wants their purchased digital file/access link sent to — this may differ from their account login email, so it must be captured at checkout and stored per order.
- One backend (single source of truth) serves both the Flutter customer app and the web Admin Panel.

### **5.2 Open Questions for Stakeholder**

1. Should completing an order automatically email the product file/download link to the delivery email, or should the admin trigger delivery manually after verifying the TXID?
2. For "Refunded" orders, is refund processing manual (admin marks it refunded after refunding via the payment gateway dashboard) or should the app call a refund API?
3. Which payment gateway(s) must TXID verification support — Razorpay only, or also manual/UPI/bank transfer?

# **6\. Functional Requirements**

## **6.1 Dashboard**

Reference: Screenshot 1. The dashboard is the admin's home screen and must show live, accurate data pulled from the backend — not placeholder values.

### **6.1.1 Summary Cards**

| **Card**       | **Data Source / Rule**                               |
| -------------- | ---------------------------------------------------- |
| Total Products | COUNT of all products in the database (all statuses) |
| Total Revenue  | SUM of order totals where status = Completed         |
| Total Orders   | COUNT of all orders regardless of status             |
| Total Users    | COUNT of all registered customer accounts            |

### **6.1.2 Recent Orders Widget**

- Shows the most recent 5 orders: Order #, Customer, Amount, Status (color-coded pill), Date.
- "View All" navigates to the full Orders Management screen.
- Clicking a row opens that order's detail view (see 6.4.3).

### **6.1.3 Top Products Widget**

- Ranks products by number of completed downloads/sales; shows product name and download/sales count.

### **6.1.4 Quick Actions**

- Add Product → opens Add New Product form (6.2.2).
- Add Category → opens Add Category form (6.3).
- Create Coupon → placeholder screen for now (out of scope, see Section 4.2), but the button must not error out.
- View Reports → navigates to Reports screen (existing sidebar item).
- Refresh button re-fetches all dashboard data from the backend without a full page reload.

## **6.2 Products Management**

Reference: Screenshots 2 (list) and 3 (Add New Product form). The product list UI is close to correct and should be kept; the Add Product form must be rebuilt so every field actually saves, and file uploads must work end-to-end.

### **6.2.1 Products List**

| **Column** | **Notes**                                                                                |
| ---------- | ---------------------------------------------------------------------------------------- |
| ID         | Auto-incrementing product ID                                                             |
| Title      | Shows thumbnail (from Featured Image) + product title                                    |
| Category   | Resolved category name (from Categories table, not free text)                            |
| Price      | Shows original price struck through and Sale Price if one is set, else just Price        |
| Status     | Draft / Active / Inactive — color-coded pill                                             |
| Purchases  | Live count of completed purchases                                                        |
| Created    | Creation date                                                                            |
| Actions    | View (preview), Edit (opens Add/Edit form pre-filled), Delete (with confirmation dialog) |

- "1 TOTAL PRODUCTS" badge must reflect the real, live count — not be hard-coded.
- Delete must ask for confirmation and should soft-delete or block deletion if the product has existing orders (to preserve order history integrity).

### **6.2.2 Add / Edit Product Form — Full Field Spec**

This screen must be rebuilt so every field below is captured, validated, and actually persisted via the backend API described in Section 7.

| **Field**                  | **Type**                       | **Required** | **Validation / Notes**                                                                                                                                         |
| -------------------------- | ------------------------------ | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Product Title              | Text                           | Yes          | 1–150 characters                                                                                                                                               |
| Short Description          | Textarea                       | Yes          | Used in list/cards; max ~200 chars                                                                                                                             |
| Full Description           | Rich text / textarea           | Yes          | Shown on product detail page                                                                                                                                   |
| Price (**৳**)              | Number                         | Yes          | \> 0, 2 decimal places                                                                                                                                         |
| Sale Price (**৳**)         | Number                         | No           | If set, must be less than Price; drives the strikethrough display                                                                                              |
| Category                   | Dropdown                       | Yes          | Populated live from Categories Management (6.3)                                                                                                                |
| Status                     | Dropdown                       | Yes          | Draft / Active / Inactive                                                                                                                                      |
| Featured Product           | Checkbox                       | No           | Surfaces the product in featured sections on the storefront                                                                                                    |
| Featured Image (Thumbnail) | File upload (image)            | Yes          | PNG/JPG/WEBP, max 5MB; stored and a URL saved to the product record; shown as the thumbnail everywhere the product appears                                     |
| Product File               | File upload (any digital file) | Yes          | The actual deliverable (PDF, ZIP, APK, etc.), max configurable size (e.g. 200MB); stored privately, only released to a customer after order status = Completed |

### **6.2.3 Upload Behavior (must actually work)**

- Selecting a file shows a filename + progress indicator while uploading.
- On successful upload, the backend returns a permanent file URL/reference which is stored on the product record.
- Featured Image is uploaded to public storage (used for display); Product File is uploaded to private/secured storage (only accessible via a signed download link generated after a completed order).
- Save Product button is disabled while an upload is in progress, and shows a loading state while the record is being created.
- On success: show a success toast, redirect to Products List, and the new product must immediately appear there with its thumbnail.
- On failure (validation or network): show a clear inline error and do not lose the admin's entered data.
- Cancel button returns to the Products List without saving, with a confirmation if any field has been filled in.

## **6.3 Categories Management**

Reference: Screenshot 4. Keep this table layout as the target design.

| **Column**  | **Notes**                                                                                       |
| ----------- | ----------------------------------------------------------------------------------------------- |
| ID          | Auto-incrementing category ID                                                                   |
| Name        | Category display name, e.g. "E-books"                                                           |
| Slug        | URL-safe identifier, auto-generated from Name (editable)                                        |
| Description | Short text describing the category                                                              |
| Products    | Live count of products assigned to this category (currently hard-coded to 0 — must be computed) |
| Status      | Active / Inactive pill                                                                          |
| Created     | Creation date                                                                                   |
| Actions     | Edit and Delete (delete blocked or requires reassignment if products exist in that category)    |

- "Add Category" opens a simple form: Name, Slug (auto-suggested), Description, Status.
- "6 CATEGORIES" badge must reflect the live count.

## **6.4 Orders Management — Highest Priority**

Reference: Screenshot 5. This is called out by the stakeholder as the most important section of the whole panel, because it is how the business confirms a real customer paid before a digital product is released.

### **6.4.1 Summary Cards**

- Total Orders, Pending Orders, Completed Orders, Total Revenue — all computed live from the Orders table (Total Revenue = sum of Completed order totals).

### **6.4.2 Orders List — Required Columns**

| **Column**     | **Requirement**                                                                                                                                                                      |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Order ID       | Unique order number (e.g. #4 / YBT202598263) and internal reference                                                                                                                  |
| Customer       | Customer name + account email                                                                                                                                                        |
| Items          | Must expand to show which product(s) were ordered — not just an item count. Clicking "1 item" (or similar) opens the full item breakdown.                                            |
| Delivery Email | NEW — the email address the customer wants the digital product delivered/unlocked to (may differ from account email)                                                                 |
| Payment TXID   | NEW — the transaction ID submitted by the customer / returned by the payment gateway, shown with a "Copy" action so the admin can verify it against the payment provider's dashboard |
| Total          | Order amount                                                                                                                                                                         |
| Payment        | Payment method + payment status (e.g. bKash / Pending, Paid, Failed)                                                                                                                 |
| Status         | Order status pill — see workflow in 6.4.4                                                                                                                                            |
| Date           | Order placed date/time                                                                                                                                                               |
| Actions        | View full order detail; Update Status                                                                                                                                                |

### **6.4.3 Order Detail View (new screen/panel)**

Clicking an order opens a detail view containing everything the admin needs to verify and fulfil the order in one place:

- Customer info: name, account email, phone (if available).
- Delivery email (prominently shown — this is where the product should be sent).
- Line items: each product ordered, with thumbnail, title, quantity, unit price, and line total.
- Payment details: method, amount, payment status, and the TXID with a one-click "Copy TXID" button and, where the gateway supports it, a "Verify with gateway" check.
- Order timeline: placed date, and a log of status changes with timestamp and which admin made the change.
- Admin notes field (free text) for internal remarks, e.g. "refund requested by customer via email."

### **6.4.4 Order Status Workflow**

Every order must move through a controlled status lifecycle. The status is changed by the admin from the Orders list or the Order Detail view via a dropdown/action menu — not by free text.

| **Status** | **Meaning**                                                                                  | **Who can enter it**               | **Typical trigger**                                                                   |
| ---------- | -------------------------------------------------------------------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------- |
| Pending    | Order placed; payment submitted but not yet verified/fulfilled                               | System (default on order creation) | Customer completes checkout                                                           |
| Completed  | Payment verified (TXID checked) and digital product released/delivered to the delivery email | Admin                              | Admin confirms TXID is valid and releases the file/access link                        |
| Refunded   | Payment was verified but refunded to the customer; product access should be revoked          | Admin                              | Customer requests refund; admin processes it in the payment gateway and marks it here |
| Cancelled  | Order cancelled before fulfillment, e.g. payment never came through or was fraudulent        | Admin                              | TXID invalid / payment never received                                                 |

- Status changes must be logged (who + when) for auditability.
- Moving to Completed should trigger delivery of the product file (see Open Question 5.2.1) to the Delivery Email.
- Moving to Refunded or Cancelled should revoke any download access previously granted for that order.
- Status pills use consistent colors across the whole app: Pending = amber, Completed = green, Refunded = blue/grey, Cancelled = red.

## **6.5 Users Management**

Reference: Screenshot 6. Keep the current layout; ensure it is backed by real data and that actions work.

- Summary cards (Total, Active, Inactive, New Users) computed live from the Users table.
- Orders column must link to that user's real orders (count and total spent computed from the Orders table, not stored as a static field).
- Actions: View profile, Edit user, Suspend/Ban (with confirmation) — all must actually update the backend.

# **7\. Backend & Data Requirements**

The root cause of most issues above is that the admin UI is not reliably backed by a working API and database. The backend must provide the following.

### **7.1 Core Entities / Data Model**

| **Entity**       | **Key Fields**                                                                                                                                                        |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Product          | id, title, short_description, full_description, price, sale_price, category_id, status, is_featured, thumbnail_url, file_url, downloads_count, created_at, updated_at |
| Category         | id, name, slug, description, status, created_at                                                                                                                       |
| Order            | id, order_number, user_id, delivery_email, txid, payment_method, payment_status, total_amount, status, admin_notes, created_at, updated_at                            |
| Order_Item       | id, order_id, product_id, quantity, unit_price, line_total                                                                                                            |
| Order_Status_Log | id, order_id, old_status, new_status, changed_by_admin_id, changed_at                                                                                                 |
| User             | id, name, email, phone, status, joined_at                                                                                                                             |

### **7.2 Required API Endpoints (minimum set)**

| **Area**   | **Endpoints**                                                                                                                                                                                    |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Dashboard  | GET /admin/dashboard/summary, GET /admin/dashboard/recent-orders, GET /admin/dashboard/top-products                                                                                              |
| Products   | GET /admin/products, POST /admin/products, GET /admin/products/:id, PUT /admin/products/:id, DELETE /admin/products/:id, POST /admin/products/upload-thumbnail, POST /admin/products/upload-file |
| Categories | GET /admin/categories, POST /admin/categories, PUT /admin/categories/:id, DELETE /admin/categories/:id                                                                                           |
| Orders     | GET /admin/orders, GET /admin/orders/:id, PATCH /admin/orders/:id/status, POST /admin/orders/:id/verify-txid, GET /admin/orders/:id/status-log                                                   |
| Users      | GET /admin/users, GET /admin/users/:id, PATCH /admin/users/:id                                                                                                                                   |

### **7.3 File Storage**

- Public bucket/folder for product thumbnails (served directly to the storefront).
- Private bucket/folder for product files; access only via short-lived signed URLs generated after an order reaches Completed status.
- Enforce file type and size limits server-side, not just in the UI.

### **7.4 Payment / TXID Verification**

- Order creation stores the TXID submitted from the Flutter app at checkout.
- Where the gateway (e.g. Razorpay) supports it, the backend calls the gateway's verify/status API using the TXID before allowing the admin to mark an order Completed.
- If the gateway cannot be auto-verified (manual/bank transfer), the admin manually confirms using the payment dashboard and the TXID shown in the order.

### **7.5 Security**

- All /admin endpoints require an authenticated Super Admin session/token.
- Signed download URLs for product files expire after a short window (e.g. 24 hours) and are single-use or rate-limited.
- Input validation and file-type sniffing on all uploads to prevent malicious file uploads.

# **8\. Prioritization (MoSCoW)**

| **Priority**            | **Items**                                                                                                                                                                                                                        |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Must Have               | Working Add/Edit Product with thumbnail + file upload; Orders showing product(s), delivery email, TXID; Order status workflow (Pending/Completed/Refunded/Cancelled); Categories with live product counts; Dashboard live counts |
| Should Have             | Order detail view with status change log and admin notes; Signed, time-limited download links; TXID auto-verification with payment gateway                                                                                       |
| Could Have              | Automatic email delivery of product on order completion; Reports screen backed by real analytics                                                                                                                                 |
| Won't Have (this phase) | Coupon module logic; multi-admin roles/permissions                                                                                                                                                                               |

# **9\. Delivery Roadmap**

| **Phase** | **Focus**              | **Key Deliverables**                                                                                                                                         |
| --------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Phase 1   | Backend foundation     | Database schema for Product, Category, Order, Order_Item, Order_Status_Log, User; core CRUD API endpoints; file upload endpoints with public/private storage |
| Phase 2   | Products & Categories  | Rebuilt Add/Edit Product form wired to API with working thumbnail + file upload; Categories CRUD with live product counts                                    |
| Phase 3   | Orders — critical path | Orders list with product breakdown, delivery email, TXID; Order Detail view; status workflow (Pending/Completed/Refunded/Cancelled) with logging             |
| Phase 4   | Dashboard & Users      | Live dashboard summary cards, recent orders, top products; Users screen wired to real order/spend data                                                       |
| Phase 5   | Hardening              | Admin auth checks on all endpoints; signed download URL expiry; QA pass matching every screen to reference screenshots                                       |

# **10\. Acceptance Criteria (Definition of Done)**

- Creating a product with a thumbnail and a file succeeds, and the product appears in the Products list with its thumbnail after a full page refresh.
- Every order in the Orders list shows the product(s) purchased, the delivery email, and the payment TXID without needing to open a separate screen.
- An admin can change any order's status among Pending, Completed, Refunded, and Cancelled, and the change persists after refresh and is recorded in the status log.
- Category product counts always match the actual number of products assigned to that category.
- Dashboard summary cards match the true counts/sums in the database at all times (verified by refreshing after making a change).
- All screens visually match the approved reference screenshots (1–6) for layout, spacing, and color usage.
- No admin action that appears to "save" silently fails — every save either succeeds with confirmation or shows a clear error.