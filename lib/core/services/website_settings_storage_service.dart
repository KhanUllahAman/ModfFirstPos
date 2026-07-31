// lib/core/services/website_settings_storage_service.dart

import 'package:modfirstpos/core/contants/storage_keys.dart';
import 'package:modfirstpos/core/database/key_value_store.dart';
import 'package:modfirstpos/core/models/website_settings_model.dart';

/// Website settings cache. Non-secret configuration, so it lives in the
/// SQLite-backed [KeyValueStore] (with transparent migration from the legacy
/// secure-storage backend), not in Flutter Secure Storage.
class WebsiteSettingsStorageService {
  static Future<void> _write(String key, String value) =>
      KeyValueStore.setString(key, value);

  static Future<String?> _read(String key) => KeyValueStore.getString(key);

  static Future<void> _writeIfNotNull(String key, dynamic value) async {
    if (value == null) return;
    await _write(key, value.toString());
  }

  static Future<void> saveFromModel(WebsiteSettingsModel model) async {
    await _writeIfNotNull(StorageKeys.keySiteId, model.id);
    await _writeIfNotNull(StorageKeys.keySiteName, model.siteName);
    await _writeIfNotNull(StorageKeys.keySiteTagline, model.siteTagline);
    await _writeIfNotNull(
      StorageKeys.keySiteDescription,
      model.siteDescription,
    );
    await _writeIfNotNull(StorageKeys.keyLogoUrl, model.logoUrl);
    await _writeIfNotNull(StorageKeys.keyLogoWhiteUrl, model.logoWhiteUrl);
    await _writeIfNotNull(StorageKeys.keyLogoBlackUrl, model.logoBlackUrl);
    await _writeIfNotNull(StorageKeys.keyFaviconUrl, model.faviconUrl);
    await _writeIfNotNull(StorageKeys.keyFooterLogoUrl, model.footerLogoUrl);
    await _writeIfNotNull(StorageKeys.keyPrimaryColor, model.primaryColor);
    await _writeIfNotNull(StorageKeys.keySecondaryColor, model.secondaryColor);
    await _writeIfNotNull(StorageKeys.keyAccentColor, model.accentColor);
    await _writeIfNotNull(StorageKeys.keyFontPrimary, model.fontPrimary);
    await _writeIfNotNull(StorageKeys.keyFontHeading, model.fontHeading);
    await _writeIfNotNull(StorageKeys.keyContactEmail, model.contactEmail);
    await _writeIfNotNull(StorageKeys.keySupportEmail, model.supportEmail);
    await _writeIfNotNull(StorageKeys.keyContactPhone, model.contactPhone);
    await _writeIfNotNull(StorageKeys.keyWhatsappNumber, model.whatsappNumber);
    await _writeIfNotNull(StorageKeys.keySiteAddress, model.address);
    await _writeIfNotNull(StorageKeys.keySiteCity, model.city);
    await _writeIfNotNull(StorageKeys.keyCountryCode, model.countryCode);
    await _writeIfNotNull(StorageKeys.keyPostalCode, model.postalCode);
    await _writeIfNotNull(StorageKeys.keyProvinceCode, model.provinceCode);
    await _writeIfNotNull(StorageKeys.keyBusinessHours, model.businessHours);
    await _writeIfNotNull(StorageKeys.keyFacebookUrl, model.facebookUrl);
    await _writeIfNotNull(StorageKeys.keyInstagramUrl, model.instagramUrl);
    await _writeIfNotNull(StorageKeys.keyTwitterUrl, model.twitterUrl);
    await _writeIfNotNull(StorageKeys.keyLinkedinUrl, model.linkedinUrl);
    await _writeIfNotNull(StorageKeys.keyYoutubeUrl, model.youtubeUrl);
    await _writeIfNotNull(StorageKeys.keyTiktokUrl, model.tiktokUrl);
    await _writeIfNotNull(StorageKeys.keyPinterestUrl, model.pinterestUrl);
    await _writeIfNotNull(StorageKeys.keyPlaystoreUrl, model.playstoreUrl);
    await _writeIfNotNull(StorageKeys.keyAppstoreUrl, model.appstoreUrl);
    await _writeIfNotNull(StorageKeys.keyCurrency, model.currency);
    await _writeIfNotNull(StorageKeys.keyCurrencySymbol, model.currencySymbol);
    await _writeIfNotNull(StorageKeys.keyTaxPercentage, model.taxPercentage);
    await _writeIfNotNull(
      StorageKeys.keyDefaultShippingFee,
      model.defaultShippingFee,
    );
    await _writeIfNotNull(
      StorageKeys.keyFreeShippingThreshold,
      model.freeShippingThreshold,
    );
    await _writeIfNotNull(StorageKeys.keyMinOrderAmount, model.minOrderAmount);
    await _writeIfNotNull(
      StorageKeys.keyFirstOrderDiscountEnabled,
      model.firstOrderDiscountEnabled,
    );
    await _writeIfNotNull(
      StorageKeys.keyFirstOrderDiscountType,
      model.firstOrderDiscountType,
    );
    await _writeIfNotNull(
      StorageKeys.keyFirstOrderDiscountValue,
      model.firstOrderDiscountValue,
    );
    await _writeIfNotNull(
      StorageKeys.keyFirstOrderMaxDiscount,
      model.firstOrderMaxDiscount,
    );
    await _writeIfNotNull(StorageKeys.keyMetaTitle, model.metaTitle);
    await _writeIfNotNull(
      StorageKeys.keyMetaDescription,
      model.metaDescription,
    );
    await _writeIfNotNull(StorageKeys.keyMetaKeywords, model.metaKeywords);
    await _writeIfNotNull(StorageKeys.keyOgImageUrl, model.ogImageUrl);
    await _writeIfNotNull(StorageKeys.keySiteIsActive, model.isActive);
    await _writeIfNotNull(StorageKeys.keySiteCreatedAt, model.createdAt);
    await _writeIfNotNull(StorageKeys.keySiteUpdatedAt, model.updatedAt);
  }

  static Future<String?> getSiteName() => _read(StorageKeys.keySiteName);
  static Future<String?> getSiteTagline() => _read(StorageKeys.keySiteTagline);
  static Future<String?> getSiteDescription() =>
      _read(StorageKeys.keySiteDescription);
  static Future<String?> getLogoUrl() => _read(StorageKeys.keyLogoUrl);
  static Future<String?> getLogoWhiteUrl() =>
      _read(StorageKeys.keyLogoWhiteUrl);
  static Future<String?> getLogoBlackUrl() =>
      _read(StorageKeys.keyLogoBlackUrl);
  static Future<String?> getFaviconUrl() => _read(StorageKeys.keyFaviconUrl);
  static Future<String?> getFooterLogoUrl() =>
      _read(StorageKeys.keyFooterLogoUrl);
  static Future<String?> getPrimaryColor() =>
      _read(StorageKeys.keyPrimaryColor);
  static Future<String?> getSecondaryColor() =>
      _read(StorageKeys.keySecondaryColor);
  static Future<String?> getAccentColor() => _read(StorageKeys.keyAccentColor);
  static Future<String?> getFontPrimary() => _read(StorageKeys.keyFontPrimary);
  static Future<String?> getFontHeading() => _read(StorageKeys.keyFontHeading);
  static Future<String?> getContactEmail() =>
      _read(StorageKeys.keyContactEmail);
  static Future<String?> getSupportEmail() =>
      _read(StorageKeys.keySupportEmail);
  static Future<String?> getContactPhone() =>
      _read(StorageKeys.keyContactPhone);
  static Future<String?> getWhatsappNumber() =>
      _read(StorageKeys.keyWhatsappNumber);
  static Future<String?> getSiteAddress() => _read(StorageKeys.keySiteAddress);
  static Future<String?> getSiteCity() => _read(StorageKeys.keySiteCity);
  static Future<String?> getCountryCode() => _read(StorageKeys.keyCountryCode);
  static Future<String?> getPostalCode() => _read(StorageKeys.keyPostalCode);
  static Future<String?> getProvinceCode() =>
      _read(StorageKeys.keyProvinceCode);
  static Future<String?> getBusinessHours() =>
      _read(StorageKeys.keyBusinessHours);
  static Future<String?> getFacebookUrl() => _read(StorageKeys.keyFacebookUrl);
  static Future<String?> getInstagramUrl() =>
      _read(StorageKeys.keyInstagramUrl);
  static Future<String?> getTwitterUrl() => _read(StorageKeys.keyTwitterUrl);
  static Future<String?> getLinkedinUrl() => _read(StorageKeys.keyLinkedinUrl);
  static Future<String?> getYoutubeUrl() => _read(StorageKeys.keyYoutubeUrl);
  static Future<String?> getTiktokUrl() => _read(StorageKeys.keyTiktokUrl);
  static Future<String?> getPinterestUrl() =>
      _read(StorageKeys.keyPinterestUrl);
  static Future<String?> getPlaystoreUrl() =>
      _read(StorageKeys.keyPlaystoreUrl);
  static Future<String?> getAppstoreUrl() => _read(StorageKeys.keyAppstoreUrl);
  static Future<String?> getCurrency() => _read(StorageKeys.keyCurrency);
  static Future<String?> getCurrencySymbol() =>
      _read(StorageKeys.keyCurrencySymbol);
  static Future<String?> getTaxPercentage() =>
      _read(StorageKeys.keyTaxPercentage);
  static Future<String?> getDefaultShippingFee() =>
      _read(StorageKeys.keyDefaultShippingFee);
  static Future<String?> getFreeShippingThreshold() =>
      _read(StorageKeys.keyFreeShippingThreshold);
  static Future<String?> getMinOrderAmount() =>
      _read(StorageKeys.keyMinOrderAmount);

  static Future<bool> getFirstOrderDiscountEnabled() async {
    final data = await _read(StorageKeys.keyFirstOrderDiscountEnabled);
    return data == 'true';
  }

  static Future<String?> getFirstOrderDiscountType() =>
      _read(StorageKeys.keyFirstOrderDiscountType);
  static Future<String?> getFirstOrderDiscountValue() =>
      _read(StorageKeys.keyFirstOrderDiscountValue);
  static Future<String?> getFirstOrderMaxDiscount() =>
      _read(StorageKeys.keyFirstOrderMaxDiscount);
  static Future<String?> getMetaTitle() => _read(StorageKeys.keyMetaTitle);
  static Future<String?> getMetaDescription() =>
      _read(StorageKeys.keyMetaDescription);
  static Future<String?> getMetaKeywords() =>
      _read(StorageKeys.keyMetaKeywords);
  static Future<String?> getOgImageUrl() => _read(StorageKeys.keyOgImageUrl);

  static Future<bool> getSiteIsActive() async {
    final data = await _read(StorageKeys.keySiteIsActive);
    return data == 'true';
  }

  static Future<String?> getSiteCreatedAt() =>
      _read(StorageKeys.keySiteCreatedAt);
  static Future<String?> getSiteUpdatedAt() =>
      _read(StorageKeys.keySiteUpdatedAt);

  static Future<bool> hasSettings() async {
    final name = await _read(StorageKeys.keySiteName);
    return name != null && name.trim().isNotEmpty;
  }
}
