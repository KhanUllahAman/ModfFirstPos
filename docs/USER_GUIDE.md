# ModFirst Cashier App — User Guide

This guide is for anyone who will use the POS (cashier) app day-to-day — a cashier or store manager. No technical background needed, just follow the steps below.

---

## 1. Opening the App for the First Time

1. Tap the app icon.
2. The **Store Selection** screen appears — select/confirm your store (this only happens the first time).
3. On the **Login** screen, enter your email/username and password, then tap **Sign In**.
4. After logging in, the app takes you to the Home screen.

---

## 2. Opening a Shift (Always the First Step)

You must **open a shift** before making any sale — no sale can go through without an open shift.

1. Right after login, an "Open Shift" dialog appears automatically (if no shift is already open).
2. Enter the **Opening Float** — the amount of cash currently in the drawer (e.g. 100).
3. Optionally add **Opening Notes**.
4. Tap **Open Shift**.

✅ Shifts can be opened **entirely offline** — even without internet, work isn't blocked. It syncs to the server automatically once the connection is back (or you can sync manually from the Menu page — see below).

> If you don't want to open a shift right now, the dialog also has a "Logout" option.

---

## 3. Home Screen — Making a Sale

On the Home screen:

- **Left side**: Categories and their products.
- **Scan/Search bar** (top): Type or scan a product name, SKU, or barcode to search or add directly to the cart — across categories, products, and variants (size/color).
- **Tap a product** → if it has variants (size/color) you'll be asked to choose one, otherwise it's added to the cart right away.
- **Cart** (right side) shows selected items, quantity, and totals.

### Selecting a Customer
A customer must be selected before checkout:
- Search for an existing customer, or
- Tap **Add New Customer** to create one (name, phone, email).
- If no specific customer applies, the **Walk-in Customer** is used.

---

## 4. Checking Out

Once items are in the cart, tap **Checkout**:

1. Choose a **Delivery Option**: Home Delivery or Store Pickup.
2. Select an address or pickup location.
3. Tap **Create Order**.
4. To apply a **discount**, use the "Add Discount" button — choose a percentage or fixed amount, with an optional reason (e.g. "Staff Discount"). *(Note: manual discount currently only applies to Cash / Bank Transfer / Manual payments — not card payments.)*
5. Choose a **Payment Method**:
   - **Cash** — full payment in cash
   - **Bank Transfer** — full payment by bank transfer
   - **Manual / Pay Later** — completes the order without collecting payment now
   - **Card (Stripe Terminal)** — payment via card reader
   - **Split — Cash + Bank** or **Split — Cash + Card** — part cash, part the other method
6. Tap **Confirm & Pay**.

✅ **Cash / Bank Transfer / Manual** payments work **completely offline** — the sale goes through and the receipt prints instantly even without internet. Card payments require an internet connection.

The receipt **prints automatically** once the sale is complete (if a printer is set up — see Settings below).

---

## 5. Printing Receipts

- A receipt prints automatically after every sale.
- On the **Orders** page (from the drawer menu), open any past order and tap **Print Receipt** to reprint it — this also works offline.
- The receipt includes the store logo, items, discount, total, and a "Thank you" message.

---

## 6. Closing a Shift (End of Day)

1. Open the **Shift** page from the drawer.
2. Tap **Close Shift**.
3. Enter the **Counted Cash** — the actual cash counted from the drawer.
4. Optionally add **Closing Notes**.
5. Tap **Close Shift**.

The app automatically calculates the expected cash and shows the variance (any difference from what was counted).

✅ This also works offline. Once closed, tap **Print Shift Receipt** to print a full shift summary (orders, sales, cash reconciliation, etc.).

---

## 7. Customers / Users Page

Drawer → **Users**:
- Full list of customers, with their photo (if available), phone/email.
- Wholesale customers show a badge (if they have a discount tier assigned).
- Tap **Add Customer** to create a new one.
- Tap a customer to see their past orders.

---

## 8. Orders Page

Drawer → **Orders**:
- List of all orders (both offline and online).
- Filter by status, payment status, or delivery type.
- Tap an order to see full details (items, customer, discount breakdown, payment history).
- Receipts can be reprinted from here.

---

## 9. Inventory Page

Drawer → **Inventory**:
- Shows current stock for all products.
- Stock automatically decreases after an offline sale (so the same device won't oversell before syncing).

---

## 10. Settings Page (One-Time Setup)

Drawer → **Setting**:

- **Printer Setup**: Configure the thermal printer's name/IP so receipts can print.
- **Customer IP + Pairing Code**: If a customer-facing display (a second tablet) is used, enter its IP and pairing code here so the cart syncs live to it.
- **Stripe Terminal Reader ID**: If a card reader is in use, set its Reader ID here.

---

## 11. Menu Page — Manual Sync

Drawer → **Menu**:
- **Sync Shifts** / **Sync Orders** — manually push anything that hasn't auto-synced yet once internet is back.
- **Refresh Website Settings** — reloads the store's logo/theme/colors.

---

## 12. Reporting Page

Drawer → **Reporting**:
- View sales reports, top products, and a business summary.

---

## 13. Offline Mode — What Happens Without Internet?

- Opening/closing shifts and Cash/Bank/Manual sales **work fully offline** — no internet needed.
- Receipts print instantly from local data — no waiting.
- Everything (shifts, orders) syncs to the server automatically once internet is back.
- **Card payments (Stripe Terminal)** require internet — this only works online.

---

## 14. Logging Out

- The **Logout** button is at the bottom of the drawer menu.
- If a shift is currently open, the app will warn you first — the shift must be closed before logging out (so no cash/sale ever goes unaccounted for).

---

## Need Help?

If something is unclear or you run into an error, take a screenshot and send it to your developer/support team.
