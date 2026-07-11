import 'package:get/get.dart';
import 'package:modfirstpos/core/services/website_settings_storage_service.dart';
import 'package:modfirstpos/shared/widgets/helperFunction/get_device_id_function.dart';

class AboutController extends GetxController {
  final RxBool isLoading = true.obs;

  final RxString siteName = ''.obs;
  final RxString siteTagline = ''.obs;
  final RxString siteDescription = ''.obs;
  final RxString logoUrl = ''.obs;

  final RxString contactEmail = ''.obs;
  final RxString supportEmail = ''.obs;
  final RxString contactPhone = ''.obs;
  final RxString whatsappNumber = ''.obs;

  final RxString address = ''.obs;
  final RxString city = ''.obs;
  final RxString provinceCode = ''.obs;
  final RxString postalCode = ''.obs;
  final RxString countryCode = ''.obs;
  final RxString businessHours = ''.obs;

  final RxString facebookUrl = ''.obs;
  final RxString instagramUrl = ''.obs;
  final RxString twitterUrl = ''.obs;
  final RxString tiktokUrl = ''.obs;
  final RxString linkedinUrl = ''.obs;
  final RxString youtubeUrl = ''.obs;
  final RxString pinterestUrl = ''.obs;

  final RxString currency = ''.obs;
  final RxString currencySymbol = ''.obs;

  final RxString appVersion = ''.obs;
  final RxString deviceId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;

    siteName.value = await WebsiteSettingsStorageService.getSiteName() ?? '';
    siteTagline.value =
        await WebsiteSettingsStorageService.getSiteTagline() ?? '';
    siteDescription.value =
        await WebsiteSettingsStorageService.getSiteDescription() ?? '';
    logoUrl.value = await WebsiteSettingsStorageService.getLogoUrl() ?? '';

    contactEmail.value =
        await WebsiteSettingsStorageService.getContactEmail() ?? '';
    supportEmail.value =
        await WebsiteSettingsStorageService.getSupportEmail() ?? '';
    contactPhone.value =
        await WebsiteSettingsStorageService.getContactPhone() ?? '';
    whatsappNumber.value =
        await WebsiteSettingsStorageService.getWhatsappNumber() ?? '';

    address.value = await WebsiteSettingsStorageService.getSiteAddress() ?? '';
    city.value = await WebsiteSettingsStorageService.getSiteCity() ?? '';
    provinceCode.value =
        await WebsiteSettingsStorageService.getProvinceCode() ?? '';
    postalCode.value =
        await WebsiteSettingsStorageService.getPostalCode() ?? '';
    countryCode.value =
        await WebsiteSettingsStorageService.getCountryCode() ?? '';
    businessHours.value =
        await WebsiteSettingsStorageService.getBusinessHours() ?? '';

    facebookUrl.value =
        await WebsiteSettingsStorageService.getFacebookUrl() ?? '';
    instagramUrl.value =
        await WebsiteSettingsStorageService.getInstagramUrl() ?? '';
    twitterUrl.value =
        await WebsiteSettingsStorageService.getTwitterUrl() ?? '';
    tiktokUrl.value = await WebsiteSettingsStorageService.getTiktokUrl() ?? '';
    linkedinUrl.value =
        await WebsiteSettingsStorageService.getLinkedinUrl() ?? '';
    youtubeUrl.value =
        await WebsiteSettingsStorageService.getYoutubeUrl() ?? '';
    pinterestUrl.value =
        await WebsiteSettingsStorageService.getPinterestUrl() ?? '';

    currency.value = await WebsiteSettingsStorageService.getCurrency() ?? '';
    currencySymbol.value =
        await WebsiteSettingsStorageService.getCurrencySymbol() ?? '';

    appVersion.value = await AppInfo.getAppVersion();
    deviceId.value = await AppInfo.getDeviceId();

    isLoading.value = false;
  }
}