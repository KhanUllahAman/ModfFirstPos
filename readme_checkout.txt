=====================================================================
 Checkout APIs Integration - Files Modified & Created
=====================================================================

Maine checkout ke pure flow ko home screen ke side panel me integrate karne ke liye niche likhi files me kaam kiya hai:

CREATING NEW FILES (Nayi Files):
--------------------------------
1. lib/modules/checkout/service/checkout_service.dart
   - Isme addresses/list, pickup-locations/list, orders/create, coupons/validate, aur orders/checkout APIs ke network calls write kiye hain.

2. lib/modules/checkout/controller/checkout_controller.dart
   - Isme state management code likha hai jo delivery select karna, existing address load karna, naya address form fill karna, pickup location select karna, coupon validate karna, aur split payment amounts calculate karne ki details control karta hai.

3. lib/modules/home/widgets/checkout_flow_panel.dart
   - Isme inline CheckoutFlowPanel widget (side-panel wizard UI) build kiya hai jo dialog ki jagah home screen ke side panel me step-by-step complete checkout process dikhata hai. Isme inputs ke liye `CustomTextFormField` ka use kiya hai jo login screen jaisa design maintain karti hai.

MODIFYING EXISTING FILES (Purani Files):
---------------------------------------
4. lib/modules/home/model/product_item.dart
   - ProductItem class me `productId` aur `variantId` parameters add kiye hain taaki pinned products me unke database IDs safe rahen.

5. lib/modules/home/model/cart_item_model.dart
   - CartProduct class me `productId` aur `variantId` add kiye hain taaki database se item orders table ke details create order API me safely map kiye ja saken.

6. lib/modules/home/controller/home_controller.dart
   - Product list aur pinned product list se item cart me add karte waqt `productId` aur `variantId` map karne ki logic updates ki hai aur `showCheckoutPanel` status control track kiya hai.

7. lib/modules/home/binding/home_binding.dart
   - Get.lazyPut dynamic registration check add kiya hai taaki CheckoutController automatically load ho jaye jab home view build ho.

8. lib/modules/home/widgets/product_list_panel_widget.dart
   - Right-hand panel switcher me check lagaya hai taaki jab `showCheckoutPanel` true ho, tab `CheckoutFlowPanel` render ho.

9. lib/modules/home/widgets/bottom_buttons_widget.dart
   - Cashier App ke Payment button ko update kiya hai taaki click karne par direct `controller.showCheckoutPanel.value = true` active ho jaye (agar customer selected hai).

=====================================================================
