# ModFirst POS — Payment Integration (Flutter)

Complete, payment-only guide for the Flutter POS app. Covers the single payment API,
every payment type, and the **full Stripe Terminal (card-present)** flow end to end.

> Prerequisite: you already have an order (`order_code`) that is `payment_status:
> pending`. Create it with `POST /orders/pos`. This document is only about paying it.

**Headers on every request**
```
x-api-key: <ApiUser key>
x-api-password: <ApiUser password>
Authorization: Bearer <staff accessToken>
Content-Type: application/json
```

---

## 1. One endpoint for all POS payments

`POST /payments/pos/pay`

`payment_type` decides the flow. The amounts you send must equal the order total.
The chosen type is saved on the order as `pos_payment_type`; each real `Payment` row
keeps its atomic method, and a split creates one row per part.

| `payment_type` | Send | Settles |
|---|---|---|
| `cash` | `cash_amount?` (default = total) | instantly |
| `bank_transfer` | `bank_amount?` (default = total), `bank_reference?` | instantly |
| `stripe_terminal` | `reader_id`, `terminal_amount?` | after poll + capture |
| `cash_bank_transfer` | `cash_amount` + `bank_amount` (sum = total) | instantly |
| `cash_stripe_terminal` | `cash_amount` + `terminal_amount` + `reader_id` | cash now, terminal after capture |

### Request examples

```jsonc
// Cash
{ "order_code": "MF-000123", "payment_type": "cash" }

// Bank transfer
{ "order_code": "MF-000123", "payment_type": "bank_transfer", "bank_reference": "TXN-98" }

// Card present (Stripe Terminal)
{ "order_code": "MF-000123", "payment_type": "stripe_terminal", "reader_id": 1 }

// Split: cash + bank
{ "order_code": "MF-000123", "payment_type": "cash_bank_transfer",
  "cash_amount": 15.90, "bank_amount": 15.89 }

// Split: cash + card present
{ "order_code": "MF-000123", "payment_type": "cash_stripe_terminal",
  "cash_amount": 15.90, "terminal_amount": 15.89, "reader_id": 1 }
```

### Response (same shape for every type)

```jsonc
{
  "success": true,
  "payload": {
    "order_code": "MF-000123",
    "payment_type": "cash_stripe_terminal",
    "pos_payment_type": "cash_stripe_terminal",
    "total_amount": 31.79,
    "paid_amount": 15.90,          // sum of parts already paid
    "fully_paid": false,          // true once everything is captured
    "requires_action": true,      // true = a card-present part still needs capture
    "parts": [
      { "method": "cash",            "amount": 15.90, "status": "paid",    "payment_reference": "..." },
      { "method": "stripe_terminal", "amount": 15.89, "status": "pending", "payment_reference": "pr_...", "payment_intent_id": "pi_...", "reader_id": 1 }
    ],
    "terminal": {                 // present ONLY when there is a card-present part
      "payment_reference": "pr_...",
      "payment_intent_id": "pi_...",
      "reader_id": 1,
      "reader_status": "in_progress",
      "next_steps": [ "GET /terminal/payment-status/pr_...", "POST /terminal/capture { payment_reference }" ]
    }
  }
}
```

### Decision logic in Flutter

```dart
final res = (await api.post('/payments/pos/pay', body))['payload'];

if (res['requires_action'] == true) {
  // Card-present part exists -> run the Terminal flow (section 3)
  await captureTerminal(res['terminal']['payment_reference']);
} else {
  // cash / bank / cash+bank -> already fully paid
  await printReceipt(orderId);
}
```

### Errors

| Status | Meaning |
|---|---|
| `400` | amounts don't sum to the total, or a required field is missing (e.g. `reader_id` for terminal) |
| `404` | order not found |
| `409` | order is already fully paid |

---

## 2. Stripe Terminal — one-time setup

Card-present uses the **Stripe Terminal SDK** on the device to drive the physical
reader. The backend creates and captures the PaymentIntent; **the app never touches
card data** (PCI stays with Stripe).

1. **Plugin** — add a Stripe Terminal Flutter plugin, e.g. `mek_stripe_terminal`:
   ```yaml
   dependencies:
     mek_stripe_terminal: ^<latest>
   ```
2. **Android** — `minSdkVersion 26+`; permissions: `BLUETOOTH_CONNECT`,
   `BLUETOOTH_SCAN`, `ACCESS_FINE_LOCATION` (readers are discovered over BLE/location).
3. **iOS** — Info.plist: `NSBluetoothAlwaysUsageDescription`,
   `NSLocationWhenInUseUsageDescription`; enable the *Location updates* and
   *Uses Bluetooth LE accessories* background modes.
4. **Reader** — must already be **registered to the branch** by an admin
   (`POST /terminal/readers` with `branch_id`). Get its `reader_id` from
   `POST /terminal/readers/list` (or from `GET /pos/bootstrap`).

---

## 3. Stripe Terminal — the flow (end to end)

```
┌ App ────────────────┐        ┌ Backend ───────────────┐        ┌ Stripe ┐
│ initTerminal        │ ─────► │ POST /terminal/         │ ─────► │        │
│  (fetch token)      │ ◄───── │   connection-token      │ ◄───── │        │
│ discoverReaders     │        │                         │        │        │
│ connectReader       │        │                         │        │        │
│                     │        │                         │        │        │
│ POST /payments/pos/ │ ─────► │ creates manual-capture  │ ─────► │ PI +   │
│   pay (stripe_...)  │ ◄───── │ card_present PaymentIntent      │ reader │
│                     │        │ + sends to reader       │        │ prompt │
│  customer taps card │        │                         │        │        │
│ poll payment-status │ ─────► │ GET /terminal/          │ ─────► │ read   │
│  until can_capture  │ ◄───── │   payment-status/:ref   │ ◄───── │ status │
│ POST /terminal/     │ ─────► │ captures PI, marks      │ ─────► │ capture│
│   capture           │ ◄───── │ order paid              │ ◄───── │        │
└─────────────────────┘        └─────────────────────────┘        └────────┘
```

### 3.1 Initialise the SDK (fetch token from backend)

```dart
await Terminal.initTerminal(
  fetchToken: () async {
    final r = await api.post('/terminal/connection-token');
    return r['payload']['secret'];   // Stripe connection token secret
  },
);
```

### 3.2 Discover & connect the reader (keep connected while the till is open)

```dart
final readers = await Terminal.discoverReaders(/* bluetooth | internet */);
final reader  = readers.firstWhere((r) => r.serialNumber == myReaderSerial);
await Terminal.connectReader(reader);
```

### 3.3 Start the payment (backend drives the intent)

```dart
final res = (await api.post('/payments/pos/pay', {
  'order_code': orderCode,
  'payment_type': 'stripe_terminal',   // or 'cash_stripe_terminal' for a split
  'reader_id': readerId,
}))['payload'];

final ref = res['terminal']['payment_reference'];
// The reader now shows "Present card". The customer taps / inserts / swipes.
```

### 3.4 Poll the status until the card is read

`GET /terminal/payment-status/:payment_reference`

```jsonc
{
  "payload": {
    "state": "waiting_for_card",   // waiting_for_card | succeeded | declined | failed
    "can_capture": false,          // true once Stripe has the card (requires_capture)
    "failure_message": null,
    "decline_code": null,
    "order": { "order_code", "payment_status", "total", "paid" }
  }
}
```

```dart
Future<void> _pollUntilReady(String ref) async {
  while (true) {
    final s = (await api.get('/terminal/payment-status/$ref'))['payload'];
    if (s['can_capture'] == true || s['state'] == 'succeeded') return;
    if (s['state'] == 'declined' || s['state'] == 'failed') {
      throw PaymentDeclined(s['failure_message'] ?? 'Card declined');
    }
    await Future.delayed(const Duration(seconds: 2));
  }
}
```

### 3.5 Capture (finalise)

`POST /terminal/capture`
```json
{ "payment_reference": "pr_..." }
```
```jsonc
{
  "payload": {
    "payment_reference": "pr_...",
    "status": "paid",
    "amount": "31.79",
    "receipt_url": "https://...",       // Stripe receipt
    "order_paid_amount": 31.79,
    "order_fully_paid": true            // false if a split still has an unpaid part
  }
}
```
On capture the order is marked paid. For a **split**, the order becomes fully paid
only when the terminal part is captured — `order_paid_amount` is the sum of the cash
part plus this captured amount.

### 3.6 Cancel (customer walked away)

`POST /terminal/cancel-action`
```json
{ "reader_id": 1 }
```

### 3.7 Full Flutter helper

```dart
Future<void> captureTerminal(String ref) async {
  try {
    await _pollUntilReady(ref);
    final cap = (await api.post('/terminal/capture', { 'payment_reference': ref }));
    if (cap['success'] == true) {
      showPaid(receiptUrl: cap['payload']['receipt_url']);
      await printReceipt(orderId);
    } else {
      showError(cap['message']);
    }
  } on PaymentDeclined catch (e) {
    showError(e.message);          // let the cashier retry or pick another method
  }
}
```

---

## 4. Handling each type in the UI

| Type | UI flow |
|---|---|
| `cash` | Take cash → call pay → `requires_action=false` → print |
| `bank_transfer` | Confirm transfer → call pay → print |
| `stripe_terminal` | Call pay → reader prompts → poll → capture → print |
| `cash_bank_transfer` | Enter both amounts → call pay → print (both instant) |
| `cash_stripe_terminal` | Enter cash + terminal amounts → call pay → cash recorded, reader prompts for the rest → poll → capture → print |

For splits, always show `paid_amount` vs `total_amount` so the cashier sees what's
left until `fully_paid: true`.

---

## 5. Edge cases & tips

- **Amounts must equal the total** (within 1 cent) or you get `400`. Compute the second
  split part as `total - firstPart` to avoid rounding drift.
- **Already paid** → `409`. Guard the pay button once `fully_paid` is true.
- **Declined card** → poll returns `state: "declined"` with `failure_message`. The cash
  part of a split (if any) is already recorded; let the cashier retry the terminal part
  or switch methods; the order stays partially paid until settled.
- **Reader disconnected** → re-run discover/connect; the PaymentIntent is still valid,
  so you can resume polling/capture with the same `payment_reference`.
- **Card-present is online-only** — it cannot be done offline. Offline sales settle with
  cash or bank transfer (`POST /orders/pos/sync`).
- **Receipt** — after payment, `POST /orders/print-receipt { order_id, print_type }`.

---

## 6. Endpoint reference

| Action | Method | Endpoint |
|---|---|---|
| Pay (all types) | POST | `/payments/pos/pay` |
| Terminal: connection token | POST | `/terminal/connection-token` |
| Terminal: list readers | POST | `/terminal/readers/list` |
| Terminal: poll status | GET | `/terminal/payment-status/:payment_reference` |
| Terminal: capture | POST | `/terminal/capture` |
| Terminal: cancel | POST | `/terminal/cancel-action` |
| Print receipt | POST | `/orders/print-receipt` |
