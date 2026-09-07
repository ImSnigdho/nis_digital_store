### **PRODUCT REQUIREMENTS DOCUMENT — PART 3 OF 4** 

# **Admin Panel — Orders Management Rebuild** 

_Fixing layout overflow, wiring real order data end-to-end, and redesigning the list around a simple status view plus a detailed order page_ 

|**Product**|**YBT Digital Store (Flutter customer app + Web**<br>**Admin Panel)**|
|---|---|
|Document|PRD 3 of 4|
|Document Owner|Nowrid — Product Owner|
|Status|Draft v1.0 — For Review|
|Date|August 23, 2026|
|Backend|Supabase (Postgres + Auth + Storage), Google<br>OAuth|
|Depends On|PRD 4 (Backend/Supabase orders/order_items<br>tables) and PRD 1 (checkout must actually submit<br>orders).|
|Recommended Build<br>Order|Build 4th — after Backend (PRD 4), Admin<br>Products/Categories (PRD 2), and the Checkout<br>order-submission fix (PRD 1, Section 5).|



## **1. Summary** 

The Orders screen currently has multiple layout overflow errors on its summary cards and header row, and — most critically — shows "No orders found" even after a customer has completed a real checkout, because orders placed on the customer app never reach the backend the admin panel reads from. This document also redesigns the order list per the stakeholder's request: a simple, scannable list (status, date, name, email) with a "watch" icon that opens a full detail page for everything else. 

## **2. Bug: Orders Never Appear (Critical)** 

Reference: uploaded Orders screenshot showing "No orders found" and all summary cards at 0, immediately after a test purchase (uploaded Checkout screenshot) was completed on the customer app. 

#### **2.1 Root Cause To Verify & Fix** 

- Confirm the customer app's "Place Order" action actually calls a backend write (see PRD 1, Section 5) — if it currently only updates local/UI state, no order can ever reach Supabase. 

- Confirm the orders table exists in Supabase with the schema in PRD 4 and that Row Level Security policies allow: (a) an authenticated customer to INSERT their own order, and (b) the admin role to SELECT all orders. 

- Confirm the admin Orders screen queries the same Supabase project/table the customer app writes to (check for environment/config mismatches, e.g. pointing at local mock data or a different Supabase project). 

- Add basic logging/telemetry around order creation so failures are visible instead of silently disappearing. 

## **3. Bug: Layout Overflow on Orders Screen** 

The four summary cards (Total Orders, Pending, Completed, Revenue) each show a "BOTTOM OVERFLOWED" warning, and the column header row (Order ID, Customer, TXID (Ref), Total, Status, Date) is visually cramped and overlapping. 

- Fix each summary card's internal layout so label + value + icon fit within the card at all screen widths (reduce font size responsively, allow text wrap, or increase card min-height) — apply the same responsive pattern used for the Products screen fix in PRD 2. 

- Remove the stray "Featured Categories management coming soon!" banner pinned to the bottom of the Orders screen — it does not belong here and is a leftover placeholder (Featured Categories lives in Settings, see PRD 4). 

## **4. Redesigned Orders List (Simplified)** 

Per stakeholder direction, the order list itself should be simple and scannable — full detail belongs in a separate detail page, not crammed into the row. 

#### **4.1 List Columns** 

|**Column**|**Content**|
|---|---|
|Status|Color-coded pill: Pending (amber), Completed (green), Refunded (blue/grey),<br>Cancelled (red)|
|Date|Order placed date/time|
|Customer Name|From the order's shipping/customer info|
|Customer Email|The delivery email captured at checkout|



|**Column**|**Content**|
|---|---|
|View ("watch"<br>icon)|Eye icon — opens the full Order Detail page for that specific order|



- Everything else that used to be crammed into the row — Items, TXID, Total, Payment method — moves into the Order Detail page (Section 5) and is reached only via the eye icon. 

- Summary cards above the list (Total Orders, Pending, Completed, Revenue) stay, once the overflow bug in Section 3 is fixed, and must reflect real live counts/sums. 

## **5. Order Detail Page (Opened via the Eye/Watch Icon)** 

Tapping the eye icon on any order opens a dedicated page for that single order, containing everything the admin needs to verify and fulfil it: 

- Customer info: full name, phone, delivery email. 

- Items ordered: product thumbnail, title, quantity, unit price, and line total for every item in the order. 

- Payment details: payment method used (e.g. bKash/Nagad/other), the Transaction ID / Reference the customer entered, with a one-tap "Copy" action. 

- Promo code applied (if any) and the discount amount, plus the final total after discount. 

- Current status, with a control (dropdown or segmented buttons) to change it among Pending, Completed, Refunded, Cancelled. 

- A status-change history/timeline: what changed, when, and by which admin. 

- An admin notes field for free-text internal remarks. 

- Changing status here must save immediately to the backend and reflect back on the list view without a manual refresh. 

## **6. Acceptance Criteria** 

- A test purchase made on the customer app appears in the admin Orders list within seconds, with correct name, email, date, and Pending status. 

- No overflow warnings appear anywhere on the Orders screen at common phone widths. 

- The order list shows only Status, Date, Name, Email, and the eye icon — no cramped extra columns. 

- Tapping the eye icon opens a detail page showing items, TXID, payment method, promo/discount, and a working status changer. 

- Changing an order's status in the detail page persists and is immediately visible in the list. 

- The "Featured Categories management coming soon!" banner no longer appears on the Orders screen. 

