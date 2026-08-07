# ModFirst — Notifications for Flutter (data payloads + examples)

Exactly what arrives in an FCM push, the **`data` map for every event**, and how to
handle it in the Flutter app. Companion to the general
[NOTIFICATIONS_GUIDE.md](./NOTIFICATIONS_GUIDE.md); this file is Flutter-focused and
lists a concrete example for each event.

---

## 1. Message shape

Every push has two parts:

```jsonc
{
  "notification": {                      // shown by the OS in the tray
    "title": "Stock decreased",
    "body": "Stock for product #1 decreased by 65 (now 65)."
  },
  "data": {                              // your app reads this — ALL values are strings
    "event": "stock.decreased",
    "entity_type": "inventory",
    "entity_id": "2",
    "sync": "catalogue",
    "notification_id": "812",
    "product_id": "1",
    "quantity": "65"
  }
}
```

> **Important:** FCM forces every `data` value to be a **string**. Numbers like
> `quantity`, `entity_id`, `product_id`, `total`, `old_price` come as strings — parse
> them client-side (`int.parse`, `double.parse`).

---

## 2. Base fields (in every `data`)

| Key | Always? | Meaning |
|---|---|---|
| `event` | ✅ | The event name, e.g. `stock.decreased` (use this to switch) |
| `entity_type` | ✅ | `product` \| `variant` \| `inventory` |
| `entity_id` | ✅ | Id of the thing that changed (string) |
| `notification_id` | ✅ | The in-app record id (use it to mark read) |
| `sync` | only catalogue/coupon events | `catalogue` \| `coupons` — tells the POS what to re-download |

Everything else is **event-specific** (section 3).

---

## 3. Every event — with example `data`

### Products

**`product.price_increased`** / **`product.price_decreased`** — `sync: catalogue`
extra: `old_price`, `new_price`
```json
{ "event": "product.price_increased", "entity_type": "product", "entity_id": "12",
  "sync": "catalogue", "notification_id": "804", "old_price": "24.99", "new_price": "54.99" }
```

### Variants
### variant.price_increased

Extra fields:

- product_id
- old_price
- new_price

```json
{
  "event": "variant.price_increased",
  "entity_type": "variant",
  "entity_id": "55",
  "sync": "catalogue",
  "notification_id": "809",
  "product_id": "12",
  "old_price": "19.99",
  "new_price": "24.99"
}
```

---

### variant.price_decreased

```json
{
  "event": "variant.price_decreased",
  "entity_type": "variant",
  "entity_id": "55",
  "sync": "catalogue",
  "notification_id": "810",
  "product_id": "12",
  "old_price": "24.99",
  "new_price": "19.99"
}
```

### Inventory / Stock  (extra: `product_id`, `quantity` = new stock)

**`stock.increased`** — manual restock — `sync: catalogue`
```json
{ "event": "stock.increased", "entity_type": "inventory", "entity_id": "2",
  "sync": "catalogue", "notification_id": "810", "product_id": "1", "quantity": "120" }
```

**`stock.decreased`** — manual stock-out — `sync: catalogue`
```json
{ "event": "stock.decreased", "entity_type": "inventory", "entity_id": "2",
  "sync": "catalogue", "notification_id": "811", "product_id": "1", "quantity": "65" }
```

**`stock.adjusted`** — manual set — `sync: catalogue`
```json
{ "event": "stock.adjusted", "entity_type": "inventory", "entity_id": "2",
  "sync": "catalogue", "notification_id": "812", "product_id": "1", "quantity": "80" }
```

**`stock.low`** — crossed the low threshold — `sync: catalogue`
```json
{ "event": "stock.low", "entity_type": "inventory", "entity_id": "2",
  "sync": "catalogue", "notification_id": "813", "product_id": "1", "quantity": "3" }
```

### Manual / custom  (`POST /notifications`)
Whatever `data` you passed, plus `event` (default `custom`) and `notification_id`.
```json
{ "event": "custom", "notification_id": "860", "screen": "dashboard" }
```

---

## 4. Full field matrix

| event | entity_type | sync | extra fields |
|---|---|---|---|
| product.created / updated / deleted | product | catalogue | — |
| product.price_increased / decreased | product | catalogue | `old_price`, `new_price` |
| variant.created / updated / deleted | variant | catalogue | — |
| stock.increased / decreased / adjusted / low | inventory | catalogue | `product_id`, `quantity` |

> Only catalogue events fire (products, variants, stock) — every one carries
> `sync: "catalogue"`, so the POS just re-pulls `GET /pos/bootstrap` on any of them.
> Order, shift, coupon and user notifications are intentionally not emitted.

---

## 5. Handling in Flutter

### 5.1 A model for the data map

```dart
class PushData {
  final String event;
  final String entityType;
  final String? entityId;
  final String? sync;
  final String? notificationId;
  final Map<String, String> raw;   // everything, for event-specific fields

  PushData(Map<String, dynamic> d)
    : event = d['event'] ?? '',
      entityType = d['entity_type'] ?? '',
      entityId = d['entity_id'],
      sync = d['sync'],
      notificationId = d['notification_id'],
      raw = d.map((k, v) => MapEntry(k, '$v'));

  int? get quantity => int.tryParse(raw['quantity'] ?? '');
  int? get productId => int.tryParse(raw['product_id'] ?? '');
  double? get total => double.tryParse(raw['total'] ?? '');
  String? get status => raw['status'];
}
```

### 5.2 Foreground / background / tap

```dart
// App in foreground
FirebaseMessaging.onMessage.listen((m) => _handle(PushData(m.data), tapped: false));

// User tapped the notification (from background)
FirebaseMessaging.onMessageOpenedApp.listen((m) => _handle(PushData(m.data), tapped: true));

// App launched from terminated state by a tap
final initial = await FirebaseMessaging.instance.getInitialMessage();
if (initial != null) _handle(PushData(initial.data), tapped: true);
```

### 5.3 The handler

```dart
void _handle(PushData p, {required bool tapped}) {
  // 1. Keep the POS cache fresh
  switch (p.sync) {
    case 'catalogue': posCache.refreshCatalogue(); break;  // re-call GET /pos/bootstrap
    case 'coupons':   posCache.refreshCoupons();   break;
  }

  // 2. Update the bell badge
  refreshUnreadCount();   // GET /notifications/unread-count

  // 3. If tapped, route to the entity
  if (tapped) {
    switch (p.entityType) {
      case 'product':   openProduct(p.entityId); break;
      case 'variant':   openProduct(p.entityId); break;
      case 'inventory': openProduct(p.raw['product_id']); break;
      default: openNotificationCentre();
    }
    if (p.notificationId != null) {
      api.patch('/notifications/${p.notificationId}/read');   // mark read
    }
  } else {
    showInAppBanner(title: /* from notification */ '', body: '');
  }
}
```

### 5.4 Event-specific reactions (optional)

```dart
switch (p.event) {
  case 'stock.low':
    showLowStockAlert(productId: p.productId, left: p.quantity);
    break;
  case 'product.price_increased':
  case 'product.price_decreased':
    // catalogue refresh already queued by sync; optionally toast the change
    break;
}
```

---

## 6. Quick rules

- **`data` values are always strings** — parse numbers yourself.
- **`sync`** is the POS's cue to re-download (`catalogue` → `GET /pos/bootstrap`,
  `coupons` → refresh coupons). Only catalogue/coupon events carry it.
- **`event`** is your switch key; **`entity_type` + `entity_id`** are for routing.
- **`notification_id`** marks the in-app record read (`PATCH /notifications/:id/read`).
- The in-app feed (`POST /notifications/my`) mirrors these — each row's `data` is the
  **same string map** you get in the push (minus `notification_id`, which is the row's
  own `id` there).
