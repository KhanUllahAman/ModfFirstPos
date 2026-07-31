# ModFirst POS — Security aur Offline Notes (Roman Urdu)

Ye document sirf **findings/notes** hai — abhi tak koi cheez implement nahi ki gayi. Har point ke sath
**"agar ye fix nahi hua to kya hoga"** likha hai taake priority tay karna aasan ho.

Status legend: 🔴 High priority | 🟡 Medium | 🟢 Low/acceptable trade-off

---

## 1. Storage: SQLite vs flutter_secure_storage

### 1.1 🟢 Dono ka use sahi hai, ek dusray ki jagah nahi le sakte
- **Kya hai:** Tokens (access/refresh), PIN hash `flutter_secure_storage` mein hain (Android Keystore /
  iOS Keychain — hardware-backed encryption). Bulk data (products, customers, orders, pending sync queue)
  `sqflite` (SQLite) mein hai — **plain, unencrypted file**.
- **Agar sab SQLite mein daal diya:** Security **kam** ho jayegi, badhegi nahi. Rooted phone ya ADB backup
  se koi bhi `.db` file khol kar tokens/PIN hash seedha padh sakta hai.
- **Sahi fix (implement nahi kiya abhi):** Secrets secure storage mein hi rahein; SQLite ko encrypt karna
  ho to `sqflite` ki jagah `sqflite_sqlcipher` use karna hoga.

### 1.2 🔴 SQLite database khud encrypted nahi hai
- **Kya hai:** Customer names, emails, phones, addresses, cart, order history — sab plain `.db` file mein
  disk par baithay hain.
- **Agar fix nahi hua:** Agar tablet kho jaye, chori ho jaye, ya kisi ko physical/rooted access mil jaye,
  to **customer ka pura data bina password ke padha ja sakta hai** — privacy leak, aur data-protection
  compliance (GDPR jaisay laws) ka masla ban sakta hai agar international customers hain.

---

## 2. Frontend Security Gaps (jo mujhe abhi tak mile)

### 2.1 🔴 `.env` file git history mein committed thi
- **Kya hai:** `.env` (API keys) `.gitignore` mein nahi thi, git tracked thi.
- **Agar fix nahi hua (keys rotate na hui):** Agar repo kisi shared/private-but-not-fully-trusted jagah
  push hui hai, to purani commits mein API keys hamesha ke liye maujood rahengi — kisi ne agar history
  clone ki to keys mil jayengi, chahe aage se file hata bhi di jaye.

### 2.2 🔴 Console logs mein poore Authorization headers print ho rahe hain
- **Kya hai:** `NetworkClient` har request/response ka poora header (Bearer token samet) `log()` se print
  karta hai.
- **Agar fix nahi hua (production build mein bhi ye chalta raha):** Kisi ne agar USB debugging se
  `adb logcat` connect kiya, ya kisi crash-reporting tool ne logs upload kiye, to **live access token
  chori ho sakta hai** — attacker wahi token use kar ke user ban kar API calls kar sakta hai jab tak
  token expire na ho.

### 2.3 🟡 Stripe test secret key device par store ho rahi hai
- **Kya hai:** Testing ke liye maine ek Stripe **test** secret key Settings se secure storage mein save
  karne ka rasta banaya tha.
- **Agar fix nahi hua (production build jaane se pehle na hataya):** Test key hone ki wajah se real paisay
  ka khatra nahi, lekin phir bhi kisi ko chahiye na chahiye production app ke andar koi bhi secret key
  chhorna acha practice nahi — future mein galti se live key daal di gayi to bara masla ban sakta hai.

### 2.4 🟡 PIN hash static salt se banta hai
- **Kya hai:** `PinHashUtil` SHA-256 + ek fixed/hamesha-same salt use karta hai, per-user random salt
  nahi.
- **Agar fix nahi hua:** Agar kisi tarah se PIN hash chori ho jaye (jaise upar wala SQLite-unencrypted
  masla), to static salt hone ki wajah se **rainbow-table attack se PIN nikalna zyada aasan** ho jata hai
  — random salt hota to har user ka hash unique hota aur attack mushkil hota.

### 2.5 🟡 Customer Display WebSocket server bina authentication ke hai
- **Kya hai:** Customer tab ka WebSocket server (port 4040) koi bhi device connect kar sakta hai jo isi
  WiFi par ho — koi pairing code/password nahi chahiye.
- **Agar fix nahi hua:** Same WiFi (jaise store ka guest WiFi agar galti se same network ho) par koi bhi
  device customer screen se cart data dekh sakta hai, ya jaali/fake data bhi bhej sakta hai. Risk
  local-network tak mehdood hai (internet se koi khatra nahi), lekin phir bhi ek chhota pairing-token add
  karna behtar hoga.

### 2.6 🟡 Cleartext traffic config maujood hai
- **Kya hai:** `network_security_config.xml` Android manifest mein already hai (WebSocket ke liye banaya
  gaya tha).
- **Agar fix nahi hua (production mein bhi cleartext allow raha):** Agar isme kahin `cleartextTrafficPermitted="true"`
  chhora gaya, to koi bhi network attacker plain-HTTP traffic ko intercept/modify kar sakta hai jahan
  cleartext allowed hai. Sirf local WebSocket ke liye scope tang honi chahiye, poori app ke liye nahi.

### 2.7 🟢 Koi certificate pinning nahi
- **Kya hai:** API calls normal HTTPS use karti hain, lekin app ye check nahi karta ke server ka
  certificate exactly wahi hai jo expect kiya ja raha hai.
- **Agar fix nahi hua:** Agar koi attacker apna CA certificate victim ke device par install karwa de
  (jaise malicious profile/MDM), to wo saari HTTPS traffic dekh/badal sakta hai (man-in-the-middle). Ye
  ek advanced attack hai, chhota risk hai lekin payment app ke liye acha hoga add karna.

### 2.8 🟢 PIN attempts par local lockout nahi hai
- **Kya hai:** Cashier baar baar galat PIN try kar sakta hai bina kisi cooldown/lockout ke.
- **Agar fix nahi hua:** 4-digit PIN brute-force karna theoretically possible hai (10000 combinations),
  chahe practically kisi ke paas itna waqt/access rarely hota hai. Chhota risk hai lekin easy fix hai
  (jaise 5 wrong attempts ke baad 30 second lock).

---

## 3. Offline Mode — Kya Missing Hai

### 3.1 🔴 Offline sale ke baad local stock turant kam nahi hota
- **Kya hai:** Cashier offline cash sale karta hai, lekin us product ka cached stock number is device par
  turant update nahi hota (sync hone tak).
- **Agar fix nahi hua:** Agar wahi cashier (ya doosra cashier isi device par) sync se pehle dobara wahi
  low-stock item add kare, **available stock se zyada bhi bik sakta hai** — jab aakhir mein sync hoga,
  server par overselling ka pata chalega (order fulfil nahi ho sakega ya manually resolve karna paray ga).

### 3.2 🔴 SQLite unencrypted (offline context mein aur zyada zaroori)
- Section 1.2 wala hi masla — offline mode ka matlab hai data lambe waqt tak device par baitha rehta hai
  bina sync ke, isliye agar device kho jaye ya chori ho, exposure ka waqt bhi zyada hota hai.

### 3.3 🟡 Pehli baar login hamesha online chahiye
- **Kya hai:** Bilkul naya (ya logged-out) device bina internet ke login/OTP verify nahi kar sakta.
- **Agar fix nahi hua:** Naye device ko store mein laane se pehle ek dafa internet chahiye hoga — sirf
  isi ke baad wo offline chal sakta hai. Ye ek design trade-off hai (security ke liye zaroori bhi hai),
  sirf batane ke liye likha hai taake surprise na ho.

### 3.4 🟡 Sync fail hone par cashier ko strong warning nahi milti
- **Kya hai:** Agar koi sale baar baar sync fail ho rahi ho (jaise customer conflict), sirf ek chhota
  pending-count badge dikhta hai.
- **Agar fix nahi hua:** Cashier ko pata nahi chalega ke koi purani sale abhi tak server tak nahi pahonchi
  — din khatam hone tak (jab shift close ho) pata chal sakta hai jab bohot der ho chuki ho.

### 3.5 🟢 Printer IP cache na ho to offline print fail
- **Kya hai:** Agar device kabhi online hi nahi hua (bilkul fresh install + turant offline), printer IP
  cached nahi hogi, print nahi ho sakegi.
- **Agar fix nahi hua:** Rare edge case hai (naya device turant offline chalana) — normal setup flow mein
  nahi hota kyunke pehli baar hamesha online hi login hota hai.

---

## 4. App Kill / Tablet Reboot — Offline Sales Safe Hain?

**✅ Haan, safe hain.** Offline sales aur shifts seedha **SQLite disk file** mein likhe jate hain
(memory mein nahi) — app kill ya tablet reboot se ye data nahi udhta. Jab app dobara khulega, pending
rows wahin milengi aur sync engine unhe automatically uthayega.

*(Isse related risk sirf upar wala 3.2 — file encrypted na hone ka — hai, data-loss ka nahi.)*

---

## 5. Offline Sales ki Printing — API Hit Hoti Hai?

- **Cash / Bank Transfer / Manual (offline) sales:** ✅ **100% local**, koi API call nahi. Receipt cache
  se banti hai, seedha printer IP par ESC/POS commands bhejti hai.
- **Card (Stripe Terminal) / Split-Cash+Bank / Split-Cash+Card:** ❌ Ye backend API
  (`/orders/print-receipt`) hit karti hain — lekin ye theek hai kyunke ye payment types khud hi internet
  ke bina kaam nahi karte.
- **Shift open/close receipt:** ❌ Abhi bhi backend API se print hoti hai, sirf tab available hai jab
  shift sync ho chuki ho. Agar chahein to isay bhi order-receipts ki tarah fully-offline banaya ja sakta
  hai (alag chhota kaam hoga).

---

## Khulasa (Summary) — Priority Order

| # | Point | Priority | Effort (mota andaza) |
|---|---|---|---|
| 1 | SQLite database encrypt karna (SQLCipher) | 🔴 High | Medium |
| 2 | `.env` keys rotate karna (agar repo shared hai) | 🔴 High | Low |
| 3 | Console logs se tokens/headers hataana (production build) | 🔴 High | Low |
| 4 | Offline sale ke baad local stock turant decrement karna | 🔴 High | Medium |
| 5 | Stripe test secret key production se pehle hataana | 🟡 Medium | Low |
| 6 | PIN hash random per-user salt | 🟡 Medium | Low |
| 7 | Customer Display WebSocket pairing-token | 🟡 Medium | Medium |
| 8 | Cleartext traffic config scope tang karna | 🟡 Medium | Low |
| 9 | Certificate pinning | 🟢 Low | Medium |
| 10 | PIN attempt lockout/cooldown | 🟢 Low | Low |
| 11 | Sync-fail strong warning to cashier | 🟢 Low | Low |
| 12 | Shift receipt ko fully offline banana | 🟢 Low | Medium |

**Koi bhi cheez abhi implement nahi ki gayi — jab bolein, is list se number choose kar ke bata dein, main
usi par kaam shuru kar dunga.**
