### **PRODUCT REQUIREMENTS DOCUMENT — PART 1 OF 4** 

# **Customer App — Navigation, Storefront & Checkout Fixes** 

_Fixing the broken bottom-navigation routing, restoring the missing Products screen, and making checkout reflect real payment methods and promo codes_ 

|**Product**|**YBT Digital Store (Flutter customer app + Web**<br>**Admin Panel)**|
|---|---|
|Document|PRD 1 of 4|
|Document Owner|Nowrid — Product Owner|
|Status|Draft v1.0 — For Review|
|Date|August 23, 2026|
|Backend|Supabase (Postgres + Auth + Storage), Google<br>OAuth|
|Depends On|PRD 4 (Backend/Supabase) must be implemented<br>first for Payment Methods and Promo Codes to<br>function at checkout.|
|Recommended Build<br>Order|Build 3rd — after PRD 4 (Backend) and PRD 2<br>(Admin Products/Categories).|



## **1. Summary** 

The customer-facing Flutter app's bottom navigation is wired incorrectly: each tab opens the screen meant for a different tab, an entire "Browse Products" screen is missing, and the Profile tab renders blank with an error. Separately, the Checkout screen hardcodes payment methods (bKash/Nagad) instead of pulling them from the admin-configured list, and has no way to apply a promo code. This document defines the fix for both. 

## **2. Bug: Bottom Navigation Is Mis-Mapped** 

Reference: uploaded screenshot of the "My Wishlist" screen. The bottom bar shows five tabs — Home, Products, Wishlist, Cart, Profile — with "Products" highlighted as active, but the screen content displayed is the Wishlist empty state. This indicates the tab index and the screen shown for that index are shifted by one position, and the real productbrowsing screen has been dropped from the navigation entirely. 

#### **2.1 Observed (Broken) Behavior** 

|**Tab Tapped**|**Screen Actually Shown**|**Screen That Should Show**|
|---|---|---|
|Home|Unconfirmed — verify separately|Home / storefront landing|
|Products|My Wishlist (empty state)|Product catalog — grid/list of all active<br>products with search + category filter|
|Wishlist|Cart contents|Saved/wishlisted items|
|Cart|Profile screen|Cart items, quantities, subtotal, "Go to<br>Checkout" button|
|Profile|Blank screen with an error|Logged-in user's name/email (from<br>Supabase Auth), order history, logout button|



#### **2.2 Required Fix** 

- Audit the bottom navigation's index-to-screen mapping (e.g. the IndexedStack / route array) and correct the offby-one so each tab renders its own screen, not its neighbor's. 

- Rebuild/restore the Products (catalog) screen if its widget was removed rather than just mis-routed: grid or list of products pulled live from Supabase, each card showing thumbnail, title, price, category, a wishlist-heart toggle, and an add-to-cart action. 

- Fix the Profile screen's blank/error state — identify and resolve the underlying exception (likely a null user object, a failed Supabase query, or a missing route argument) and render actual profile data. 

- Add a basic error boundary/fallback UI to every tab so a future bug shows a retry message instead of a blank screen. 

## **3. Checkout Screen — Dynamic Payment Methods** 

Reference: uploaded Checkout screenshot. Today, Payment Method options (bKash, Nagad) and their "Send to" numbers are hardcoded in the app. The admin Settings screen has a matching "Payment Methods" editor for bKash/Nagad numbers, but changes made there do not affect what the customer sees at checkout — the two are disconnected. 

#### **3.1 Required Behavior** 

- Checkout must fetch the live, active list of payment methods from the backend (see PRD 4, payment_methods table) — not a hardcoded bKash/Nagad pair. 

- Each payment method renders with its admin-uploaded icon, its display name, and its current "Send to" account number/handle, exactly as most recently saved in the admin panel. 

- If the admin adds a brand-new payment method (e.g. "Rocket", "Bank Transfer") in the admin panel, it must appear at checkout without an app update — this is a data-driven list, not a hardcoded UI. 

- If the admin disables a payment method, it must disappear from checkout immediately. 

- The existing fields — Full Name, Phone Number, Email Address (For Delivery), Transaction ID/Reference — and their required-field validation are correct as designed and should be preserved as-is. 

## **4. Checkout Screen — Promo Code Redemption (New)** 

There is currently no way for a customer to apply a discount code. Add a Promo Code field to the Order Summary area of Checkout, above or below the Total. 

#### **4.1 UI Requirements** 

- Text input + "Apply" button, positioned in the Order Summary card. 

- On Apply, validate the code against the backend (see PRD 4 Promo Code system) for: existence, active status, expiry date, usage limit not exceeded, minimum order amount met, and — critically — currency match (a BDT fixed-amount code must be rejected for a USD order and vice-versa; percentage codes apply regardless of currency). 

- On success: show the discount applied (e.g. "Promo SAVE10 applied: −৳250.00"), and recompute the Total shown and the amount on the "Place Order" button. 

- On failure: show a specific inline reason (invalid code / expired / already used / wrong currency / minimum order not met) — never a generic error. 

- Allow removing an applied code before placing the order. 

- The final order sent to the backend must include the promo code used (if any) and the discount amount, so it is auditable from the admin Orders detail view (PRD 3). 

## **5. Order Submission Must Actually Create an Order** 

Placing an order currently does not reliably result in a row appearing in the admin Orders list (see PRD 3, Section 2). On the client side, "Place Order" must call the backend's create-order operation (PRD 4) with: customer name, phone, delivery email, cart line items, payment method selected, TXID/reference entered, promo code + discount (if any), and computed total — and must only navigate to an order-confirmation screen after that call succeeds. A failed submission must show a retry-able error, not a false "success." 

## **6. Acceptance Criteria** 

- Tapping each of the five bottom tabs opens that tab's own correct screen, including a working Products catalog and a populated Profile screen with no error. 

- Editing a payment method's number in the admin panel is reflected at checkout without redeploying the app. 

- Adding a new payment method in the admin panel makes it selectable at checkout; disabling one removes it from checkout. 

- A customer can enter a valid promo code and see the discount applied to the total before placing the order; an invalid/mismatched-currency code is rejected with a clear reason. 

- Placing a real order from the app results in a new row (with all details) visible in the admin Orders list within seconds. 

