import 'package:modfirstpos/core/utils/json_utils.dart';

class WebsiteSettingsModel {
  final int? id;
  final String? siteName;
  final String? siteTagline;
  final String? siteDescription;
  final String? logoUrl;
  final String? faviconUrl;
  final String? footerLogoUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final String? accentColor;
  final String? fontPrimary;
  final String? fontHeading;
  final String? contactEmail;
  final String? supportEmail;
  final String? contactPhone;
  final String? whatsappNumber;
  final String? address;
  final String? city;
  final String? countryCode;
  final String? postalCode;
  final String? provinceCode;
  final String? businessHours;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? twitterUrl;
  final String? linkedinUrl;
  final String? youtubeUrl;
  final String? tiktokUrl;
  final String? pinterestUrl;
  final String? playstoreUrl;
  final String? appstoreUrl;
  final String? currency;
  final String? currencySymbol;
  final String? taxPercentage;
  final String? defaultShippingFee;
  final String? freeShippingThreshold;
  final String? minOrderAmount;
  final bool? firstOrderDiscountEnabled;
  final String? firstOrderDiscountType;
  final String? firstOrderDiscountValue;
  final String? firstOrderMaxDiscount;
  final String? metaTitle;
  final String? metaDescription;
  final String? metaKeywords;
  final String? ogImageUrl;
  final bool? isActive;
  final bool? isDeleted;
  final int? createdBy;
  final int? updatedBy;
  final int? deletedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  WebsiteSettingsModel({
    this.id,
    this.siteName,
    this.siteTagline,
    this.siteDescription,
    this.logoUrl,
    this.faviconUrl,
    this.footerLogoUrl,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    this.fontPrimary,
    this.fontHeading,
    this.contactEmail,
    this.supportEmail,
    this.contactPhone,
    this.whatsappNumber,
    this.address,
    this.city,
    this.countryCode,
    this.postalCode,
    this.provinceCode,
    this.businessHours,
    this.facebookUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.linkedinUrl,
    this.youtubeUrl,
    this.tiktokUrl,
    this.pinterestUrl,
    this.playstoreUrl,
    this.appstoreUrl,
    this.currency,
    this.currencySymbol,
    this.taxPercentage,
    this.defaultShippingFee,
    this.freeShippingThreshold,
    this.minOrderAmount,
    this.firstOrderDiscountEnabled,
    this.firstOrderDiscountType,
    this.firstOrderDiscountValue,
    this.firstOrderMaxDiscount,
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.ogImageUrl,
    this.isActive,
    this.isDeleted,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory WebsiteSettingsModel.fromJson(Map<String, dynamic> json) {
    return WebsiteSettingsModel(
      id: JsonUtils.asIntOrNull(json['id']),
      siteName: JsonUtils.asStringOrNull(json['site_name']),
      siteTagline: JsonUtils.asStringOrNull(json['site_tagline']),
      siteDescription: JsonUtils.asStringOrNull(json['site_description']),
      logoUrl: JsonUtils.asStringOrNull(json['logo_url']),
      faviconUrl: JsonUtils.asStringOrNull(json['favicon_url']),
      footerLogoUrl: JsonUtils.asStringOrNull(json['footer_logo_url']),
      primaryColor: JsonUtils.asStringOrNull(json['primary_color']),
      secondaryColor: JsonUtils.asStringOrNull(json['secondary_color']),
      accentColor: JsonUtils.asStringOrNull(json['accent_color']),
      fontPrimary: JsonUtils.asStringOrNull(json['font_primary']),
      fontHeading: JsonUtils.asStringOrNull(json['font_heading']),
      contactEmail: JsonUtils.asStringOrNull(json['contact_email']),
      supportEmail: JsonUtils.asStringOrNull(json['support_email']),
      contactPhone: JsonUtils.asStringOrNull(json['contact_phone']),
      whatsappNumber: JsonUtils.asStringOrNull(json['whatsapp_number']),
      address: JsonUtils.asStringOrNull(json['address']),
      city: JsonUtils.asStringOrNull(json['city']),
      countryCode: JsonUtils.asStringOrNull(json['country_code']),
      postalCode: JsonUtils.asStringOrNull(json['postal_code']),
      provinceCode: JsonUtils.asStringOrNull(json['province_code']),
      businessHours: JsonUtils.asStringOrNull(json['business_hours']),
      facebookUrl: JsonUtils.asStringOrNull(json['facebook_url']),
      instagramUrl: JsonUtils.asStringOrNull(json['instagram_url']),
      twitterUrl: JsonUtils.asStringOrNull(json['twitter_url']),
      linkedinUrl: JsonUtils.asStringOrNull(json['linkedin_url']),
      youtubeUrl: JsonUtils.asStringOrNull(json['youtube_url']),
      tiktokUrl: JsonUtils.asStringOrNull(json['tiktok_url']),
      pinterestUrl: JsonUtils.asStringOrNull(json['pinterest_url']),
      playstoreUrl: JsonUtils.asStringOrNull(json['playstore_url']),
      appstoreUrl: JsonUtils.asStringOrNull(json['appstore_url']),
      currency: JsonUtils.asStringOrNull(json['currency']),
      currencySymbol: JsonUtils.asStringOrNull(json['currency_symbol']),
      taxPercentage: json['tax_percentage']?.toString(),
      defaultShippingFee: json['default_shipping_fee']?.toString(),
      freeShippingThreshold: json['free_shipping_threshold']?.toString(),
      minOrderAmount: json['min_order_amount']?.toString(),
      firstOrderDiscountEnabled: JsonUtils.asBoolOrNull(json['first_order_discount_enabled']),
      firstOrderDiscountType: JsonUtils.asStringOrNull(json['first_order_discount_type']),
      firstOrderDiscountValue: json['first_order_discount_value']?.toString(),
      firstOrderMaxDiscount: json['first_order_max_discount']?.toString(),
      metaTitle: JsonUtils.asStringOrNull(json['meta_title']),
      metaDescription: JsonUtils.asStringOrNull(json['meta_description']),
      metaKeywords: JsonUtils.asStringOrNull(json['meta_keywords']),
      ogImageUrl: JsonUtils.asStringOrNull(json['og_image_url']),
      isActive: JsonUtils.asBoolOrNull(json['is_active']),
      isDeleted: JsonUtils.asBoolOrNull(json['is_deleted']),
      createdBy: JsonUtils.asIntOrNull(json['created_by']),
      updatedBy: JsonUtils.asIntOrNull(json['updated_by']),
      deletedBy: JsonUtils.asIntOrNull(json['deleted_by']),
      createdAt: JsonUtils.asStringOrNull(json['created_at']),
      updatedAt: JsonUtils.asStringOrNull(json['updated_at']),
      deletedAt: JsonUtils.asStringOrNull(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'site_name': siteName,
      'site_tagline': siteTagline,
      'site_description': siteDescription,
      'logo_url': logoUrl,
      'favicon_url': faviconUrl,
      'footer_logo_url': footerLogoUrl,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'accent_color': accentColor,
      'font_primary': fontPrimary,
      'font_heading': fontHeading,
      'contact_email': contactEmail,
      'support_email': supportEmail,
      'contact_phone': contactPhone,
      'whatsapp_number': whatsappNumber,
      'address': address,
      'city': city,
      'country_code': countryCode,
      'postal_code': postalCode,
      'province_code': provinceCode,
      'business_hours': businessHours,
      'facebook_url': facebookUrl,
      'instagram_url': instagramUrl,
      'twitter_url': twitterUrl,
      'linkedin_url': linkedinUrl,
      'youtube_url': youtubeUrl,
      'tiktok_url': tiktokUrl,
      'pinterest_url': pinterestUrl,
      'playstore_url': playstoreUrl,
      'appstore_url': appstoreUrl,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'tax_percentage': taxPercentage,
      'default_shipping_fee': defaultShippingFee,
      'free_shipping_threshold': freeShippingThreshold,
      'min_order_amount': minOrderAmount,
      'first_order_discount_enabled': firstOrderDiscountEnabled,
      'first_order_discount_type': firstOrderDiscountType,
      'first_order_discount_value': firstOrderDiscountValue,
      'first_order_max_discount': firstOrderMaxDiscount,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'meta_keywords': metaKeywords,
      'og_image_url': ogImageUrl,
      'is_active': isActive,
      'is_deleted': isDeleted,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
    };
  }
}

class WebsiteSettingsResponse {
  final bool isSuccess;
  final int status;
  final String message;
  final WebsiteSettingsModel? payload;

  WebsiteSettingsResponse({
    required this.isSuccess,
    required this.status,
    required this.message,
    required this.payload,
  });

  factory WebsiteSettingsResponse.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];

    WebsiteSettingsModel? model;
    if (rawPayload is Map<String, dynamic>) {
      model = WebsiteSettingsModel.fromJson(rawPayload);
    } else if (rawPayload is List && rawPayload.isNotEmpty) {
      final firstMap = JsonUtils.asMapOrNull(rawPayload.first);
      if (firstMap != null) model = WebsiteSettingsModel.fromJson(firstMap);
    }

    return WebsiteSettingsResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      status: JsonUtils.asInt(json['status']),
      message: JsonUtils.asString(json['message']),
      payload: model,
    );
  }

  String get displayMessage => message;
}