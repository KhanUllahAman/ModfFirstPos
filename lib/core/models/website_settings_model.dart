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
      id: json['id'] as int?,
      siteName: json['site_name'] as String?,
      siteTagline: json['site_tagline'] as String?,
      siteDescription: json['site_description'] as String?,
      logoUrl: json['logo_url'] as String?,
      faviconUrl: json['favicon_url'] as String?,
      footerLogoUrl: json['footer_logo_url'] as String?,
      primaryColor: json['primary_color'] as String?,
      secondaryColor: json['secondary_color'] as String?,
      accentColor: json['accent_color'] as String?,
      fontPrimary: json['font_primary'] as String?,
      fontHeading: json['font_heading'] as String?,
      contactEmail: json['contact_email'] as String?,
      supportEmail: json['support_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      countryCode: json['country_code'] as String?,
      postalCode: json['postal_code'] as String?,
      provinceCode: json['province_code'] as String?,
      businessHours: json['business_hours'] as String?,
      facebookUrl: json['facebook_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      youtubeUrl: json['youtube_url'] as String?,
      tiktokUrl: json['tiktok_url'] as String?,
      pinterestUrl: json['pinterest_url'] as String?,
      playstoreUrl: json['playstore_url'] as String?,
      appstoreUrl: json['appstore_url'] as String?,
      currency: json['currency'] as String?,
      currencySymbol: json['currency_symbol'] as String?,
      taxPercentage: json['tax_percentage']?.toString(),
      defaultShippingFee: json['default_shipping_fee']?.toString(),
      freeShippingThreshold: json['free_shipping_threshold']?.toString(),
      minOrderAmount: json['min_order_amount']?.toString(),
      firstOrderDiscountEnabled: json['first_order_discount_enabled'] as bool?,
      firstOrderDiscountType: json['first_order_discount_type'] as String?,
      firstOrderDiscountValue: json['first_order_discount_value']?.toString(),
      firstOrderMaxDiscount: json['first_order_max_discount']?.toString(),
      metaTitle: json['meta_title'] as String?,
      metaDescription: json['meta_description'] as String?,
      metaKeywords: json['meta_keywords'] as String?,
      ogImageUrl: json['og_image_url'] as String?,
      isActive: json['is_active'] as bool?,
      isDeleted: json['is_deleted'] as bool?,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      deletedBy: json['deleted_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
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
      model = WebsiteSettingsModel.fromJson(
        rawPayload.first as Map<String, dynamic>,
      );
    }

    return WebsiteSettingsResponse(
      isSuccess: json['success'] as bool? ?? false,
      status: json['status'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      payload: model,
    );
  }

  String get displayMessage => message;
}