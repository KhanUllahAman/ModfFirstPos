# Stripe Terminal (Card-Present Payments) — Kaisay Kaam Karta Hai

Ye doc Roman Urdu mein hai taake team/client ko samjhaya ja sakay ke Stripe
Terminal integration testing mein kaise perform hoti hai, aur real physical
reader lagane par kya farq aata hai.

## 1. Bunyaadi Idea

App khud Stripe ke saath direct baat nahi karti (koi secret key app ke andar
nahi hai). Poora payment logic — PaymentIntent banana, reader ko bhejna,
capture karna — **backend** karta hai. App ka kaam sirf itna hai:

1. Reader ko connect rakhna (`StripeTerminalService`).
2. Backend ko bolna "payment start karo" (`payPos`).
3. Backend se poochtay rehna "card present hua ya nahi" (poll).
4. Jab payment ho jaye to receipt print karke cart clear karna.

Files:
- [lib/core/services/stripe_terminal_service.dart](../lib/core/services/stripe_terminal_service.dart) — reader se connect/disconnect.
- [lib/core/storage/stripe_terminal_settings_storage.dart](../lib/core/storage/stripe_terminal_settings_storage.dart) — Settings mein save ki gayi reader id, simulated on/off.
- [lib/modules/checkout/controller/checkout_controller.dart](../lib/modules/checkout/controller/checkout_controller.dart) — poora payment flow yahan chalta hai.
- [lib/modules/checkout/service/checkout_service.dart](../lib/modules/checkout/service/checkout_service.dart) — backend APIs call karta hai.
- [lib/core/services/stripe_test_helper_service.dart](../lib/core/services/stripe_test_helper_service.dart) — **sirf testing ke liye**, real client build mein iski zaroorat nahi.

## 2. Testing Mein Ye Kaise Perform Ho Raha Hai (Simulated Reader)

Settings screen mein ek toggle hai **"Use Simulated Reader"** — jab ye ON ho
(default: ON), tab:

1. App `Terminal.instance.discoverReaders(isSimulated: true)` call karti hai
   — ye Stripe ka apna **fake/virtual reader** hai, koi physical hardware
   nahi chahiye. ([stripe_terminal_service.dart:58-61](../lib/core/services/stripe_terminal_service.dart))
2. Connect ho jane ke baad, jab cashier "Card Terminal" se payment select
   karta hai, backend ek PaymentIntent bana kar simulated reader ko bhej deta
   hai — app ko sirf "waiting for card" status milta hai.
3. Chunke ye ek software reader hai, koi asli card nahi present ki ja sakti.
   Isliye app ke andar ek **test-only helper** hai
   (`StripeTestHelperService`) jo Stripe ke special *test-helpers* API ko
   seedha call karke bolta hai "ab card present hui samjho". Ye sirf tab
   chalta hai jab:
   - Settings mein Stripe ka **test secret key** (`sk_test_...`) daala gaya
     ho, aur
   - Reader ka Stripe-side id (`tmr_...`) bhi Settings mein daala gaya ho.
   
   Agar ye dono nahi hain, to ye step chup-chaap skip ho jata hai
   (`_maybeSimulateCardPresent`, [checkout_controller.dart:813-826](../lib/modules/checkout/controller/checkout_controller.dart)).
4. Uske baad app har 2 second mein backend se poochti hai payment ka status
   (`pollTerminalPaymentStatus`) — jab tak "captured/succeeded" ya "declined"
   na aa jaye (max ~2 minute).
5. Payment kamyaab hone par order complete ho jata hai, receipt print hoti
   hai, cart clear ho jata hai.

**Matlab:** testing mein na koi asli card chahiye, na koi asli reader — sab
kuch software se simulate ho raha hai. Ye sk_test_ key sirf is developer ke
device ki secure storage mein hai, kabhi bhi git ya app build mein nahi jati.

## 3. Client Ke Real Terminal Par Kaise Perform Hoga

Jab client apna **asli Stripe reader** (WisePOS E / S700 jaisa hardware,
internet se connected) use karega, sirf ek cheez badalni hai:

1. Settings mein **"Use Simulated Reader" toggle ko OFF** kar dena — bas.
2. Ab discovery `isSimulated: false` ke sath hogi, jo network par mojood
   asli reader ko dhoondegi (reader ON hona chahiye aur internet se connected
   hona chahiye — WiFi setup pehlay se hona zaroori hai).
3. Settings mein reader ki **backend `reader_id`** (jo backend team ne
   `POST /terminal/readers` se register ki hogi) daalni hogi — ye already
   testing mein bhi zaroori tha.
4. `tmr_...` id aur test secret key ki ab zaroorat **nahi** — kyunke woh
   sirf simulate-card-present ke liye thay. Real reader par cashier khud
   apna asli card/tap present karega, koi software simulation ki zaroorat
   nahi.
5. Baaqi poora flow — payment start karna, status poll karna, capture karna,
   receipt print hona — **bilkul waisay hi chalega jaisay testing mein chal
   raha tha**, kyunke ye sab backend-driven logic hai, jo simulated ya real
   reader dono ke liye same hai.

**Short mein:** Testing aur production mein code alag nahi hai — sirf ek
Settings toggle (`Use Simulated Reader`) aur reader ki configuration
(network par real reader ka IP/setup) badalta hai. Baaqi sab automatically
same tareeqay se kaam karta hai.

## 4. Client Ko Kya Batana Hai (Setup Checklist)

Jab client real reader use karay, unhe ye steps follow karnay hongay:

1. Stripe reader ko WiFi se connect karayein (Stripe ki apni setup app/
   instructions se).
2. Backend team se reader register karwayein (`reader_id` milega).
3. App ke Settings > Stripe Terminal mein wahi `reader_id` daalein.
4. **"Use Simulated Reader" ko OFF** kar dein.
5. Test transaction karke confirm karein ke card charge ho raha hai.

Is ke baad system automatically real card payments accept karega — koi code
change ki zaroorat nahi.
