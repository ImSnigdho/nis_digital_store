### **PRODUCT REQUIREMENTS DOCUMENT — PART 2 OF 4** 

# **Admin Panel — Products & Categories Module Fixes** 

_Fixing layout overflow and wiring Add / Edit / Delete for Products and Categories to a working backend_ 

|**Product**|**YBT Digital Store (Flutter customer app + Web**<br>**Admin Panel)**|
|---|---|
|Document|PRD 2 of 4|
|Document Owner|Nowrid — Product Owner|
|Status|Draft v1.0 — For Review|
|Date|August 23, 2026|
|Backend|Supabase (Postgres + Auth + Storage), Google<br>OAuth|
|Depends On|PRD 4 (Backend/Supabase) — the products and<br>categories tables, storage buckets, and RLS policies<br>must exist first.|
|Recommended Build<br>Order|Build 2nd — right after PRD 4 (Backend).|



## **1. Summary** 

The Products screen has a visible layout overflow bug between the "Add Product" button and the "Total Products" badge, and — more seriously — none of Add, Edit, or Delete actually persist to the backend. Categories has the same problem: Add Category does not save. This document specifies the UI fix and the exact backend wiring required for full CRUD. 

## **2. Bug: Header Layout Overflow (Products Screen)** 

Reference: uploaded Products Management screenshot. The "+ ADD PRODUCT" button and the "14 TOTAL PRODUCTS" badge overlap each other, and Flutter's debug overflow banner (black/yellow stripes, "BOTTOM OVERFLOWED BY 11 PIXELS") is visible in the corner — this is a real rendering error, not just a cosmetic misalignment. 

#### **2.1 Required Fix** 

- Replace the fixed-position Row containing the button and the badge with a responsive layout (e.g. Wrap, or a Row with Flexible/Expanded children) so the two elements never overlap at any screen width, including narrow phone widths. 

- On narrow screens, stack the "Total Products" badge below the "Add Product" button rather than forcing them onto one line. 

- Sweep the rest of the admin panel (Orders screen has the same class of bug — see PRD 3) for any other RenderFlex/overflow warnings and fix them using the same responsive pattern. 

## **3. Products — Full CRUD Must Work** 

#### **3.1 Create (Add Product)** 

- The Add Product form must write a real row to the products table in Supabase (see PRD 4 schema) including the uploaded thumbnail and product file URLs. 

- On save, the new product must appear in the Products list immediately (re-fetch or optimistic update) and survive a full app restart. 

- Required fields, validation rules, and the thumbnail/product-file upload behavior are unchanged from the original Add Product spec: Title, Short Description, Full Description, Price, Sale Price (optional), Category (from live Categories list), Status, Featured toggle, Featured Image upload, Product File upload. 

#### **3.2 Edit — Must Be Field-Identical to Add** 

- Tapping the pencil/edit icon on a product opens the same form component used for Add Product, pre-populated with that product's current values for every field listed above, including showing the currently-set thumbnail and the currently-uploaded product file (with an option to replace either). 

- Saving an edit updates the existing row (never creates a duplicate) and reflects instantly in the Products list. 

#### **3.3 Delete** 

- Tapping the trash icon shows a confirmation dialog before deleting. 

- If the product has existing order history, block hard deletion and either soft-delete (mark inactive/archived) or show an explanatory message — this preserves order integrity for PRD 3's order detail views. 

- A successful delete removes the row from the list immediately without requiring a manual refresh. 

#### **3.4 Error Handling** 

- Every Create/Edit/Delete action must surface a real error message on failure (e.g. network issue, RLS rejection, validation error) rather than failing silently, which is the current behavior. 

## **4. Categories — Full CRUD Must Work** 

- "Add Category" must write a real row to the categories table: Name, auto-suggested Slug (editable), Description, Status. 

- Edit must open the same form pre-filled and update the existing row. 

- Delete must be blocked (or require reassigning affected products first) if any product currently references that category. 

- The "Products" count column and the total categories badge must be computed live from real data, never hardcoded. 

## **5. Acceptance Criteria** 

- The Products screen renders with no overflow warnings at common phone widths (360px–430px) and at tablet width. 

- Creating a product with a thumbnail and file succeeds and is visible after a full app restart. 

- Editing a product shows every field pre-filled, including the existing thumbnail/file, and saves changes to the same record. 

- Deleting a product with no orders removes it permanently; deleting one with orders is blocked or archived, never causing a crash. 

- Adding, editing, and deleting a category all persist and are reflected in the Products form's Category dropdown immediately. 

