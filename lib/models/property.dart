import 'package:intl/intl.dart'; // لا تنسَ إضافة هذا إلى pubspec.yaml: dependencies: flutter: sdk: flutter intl: ^0.18.1

class Property {
  final String id;
  final String title;
  final String description;
  final double? price; // ✅ جعل حقل السعر قابلاً للـ null
  final double area;
  final int bedrooms;
  final int bathrooms;
  final String location;
  final String thumbnail;
  final List<String> images;
  final String type;
  final String status;
  final bool isFeatured;
  final DateTime createdAt;
  final double latitude;
  final double longitude;
  final PropertyAgent agent;
  final double completion;

  final List<String>? features; // ميزات العقار (مثال: "مسبح", "حديقة")
  final List<String>? amenities; // وسائل الراحة (مثال: "نادي رياضي", "أمن 24/7")
  final int? yearBuilt; // سنة البناء
  final bool? furnished; // هل العقار مفروش
  final int? parking; // عدد مواقف السيارات المتاحة
  final double? rating; // تقييم العقار
  final int? views; // عدد المشاهدات

  final List<String>? updates; // آخر التحديثات أو التطورات في المشروع
  final List<String>? notes; // ملاحظات إضافية حول العقار أو المشروع
  final List<String>? videos; // روابط فيديوهات المشروع/العقار
  final String? deliveryDate; // تاريخ التسليم المتوقع (نص حر)
  final double? contributionAmount; // مبلغ المساهمة أو الاستثمار

  Property({
    required this.id,
    required this.title,
    required this.description,
    this.price, // ✅ يمكن أن يكون null
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    required this.location,
    required this.thumbnail,
    required this.images,
    required this.type,
    required this.status,
    required this.isFeatured,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
    required this.agent,
    this.completion = 0.0, // قيمة افتراضية لنسبة الإنجاز
    this.features,
    this.amenities,
    this.yearBuilt,
    this.furnished,
    this.parking,
    this.rating,
    this.views,
    this.updates,
    this.notes,
    this.videos,
    this.deliveryDate,
    this.contributionAmount,
  });

  /// دالة مساعدة لترميز عناوين URL إذا كانت تحتوي على مسافات أو أحرف خاصة.
  static String _encodeImageUrl(String url) {
    if (!url.startsWith('http')) return url;
    try {
      final uri = Uri.parse(url);
      // ترميز أجزاء المسار فقط، وليس المضيف أو الاستعلام.
      final encodedPath =
          uri.pathSegments.map((s) => Uri.encodeComponent(s)).join('/');
      // إعادة بناء الـ URI مع المسار المرمز
      return '${uri.scheme}://${uri.host}/${encodedPath}${uri.query.isEmpty ? '' : '?${uri.query}'}${uri.fragment.isEmpty ? '' : '#${uri.fragment}'}';
    } catch (e) {
      // طباعة الخطأ والعودة إلى الـ URL الأصلي لتجنب التعطل
      print('🚨 Error encoding URL: $url - $e');
      return url;
    }
  }

  /// Constructor Factory لتحويل Map<String, dynamic> (عادةً من JSON) إلى كائن Property.
  factory Property.fromJson(Map<String, dynamic> json) {
    final String? rawThumbnail = json['thumbnail'];
    // ✅ تأكد من وجود default-property.jpg في المسار الصحيح على السيرفر
    // يجب أن تكون هذه الصورة متاحة دائمًا كبديل.
    final String safeThumbnail =
        (rawThumbnail != null && rawThumbnail.startsWith('http'))
            ? _encodeImageUrl(rawThumbnail)
            : 'https://albrog.com/wp-content/uploads/2025/default-property.jpg'; // رابط احتياطي

    return Property(
      id: json['id']?.toString() ?? '0', // ضمان أن الـ id ليس null
      title: json['title'] ?? 'بدون عنوان',
      description: json['description'] ?? '',
      price: json['price'] == null
          ? null
          : _parseDouble(json['price']), // ✅ معالجة السعر كـ null
      area: _parseDouble(json['area']),
      bedrooms: _parseInt(json['bedrooms']),
      bathrooms: _parseInt(json['bathrooms']),
      location: json['location'] ?? 'الموقع غير متوفر',
      thumbnail: safeThumbnail,
      images: _parseImages(json, safeThumbnail),
      type: json['type'] ?? 'apartment',
      status: json['status'] ?? 'for_sale',
      isFeatured: _parseBool(json['is_featured']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ??
          DateTime.now(), // تاريخ إنشاء العقار
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      agent: PropertyAgent.fromJson(json['agent'] ?? {}), // بيانات الوكيل
      completion: (json['completion'] is String)
          ? double.tryParse(json['completion']) ?? 0.0
          : (json['completion'] ?? 0.0).toDouble(), // نسبة الإنجاز
      features:
          json['features'] != null ? List<String>.from(json['features']) : [],
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
      yearBuilt: _parseInt(json['year_built']),
      furnished: _parseBool(json['furnished']),
      parking: _parseInt(json['parking']),
      rating: json['rating'] != null ? _parseDouble(json['rating']) : null,
      views: _parseInt(json['views']),
      updates:
          json['updates'] != null ? List<String>.from(json['updates']) : [],
      notes: json['notes'] != null ? List<String>.from(json['notes']) : [],
      videos: json['videos'] != null ? List<String>.from(json['videos']) : [],
      deliveryDate: json['delivery_date'],
      contributionAmount: json['contribution_amount'] != null 
          ? _parseDouble(json['contribution_amount']) 
          : null,
    );
  }

  /// دالة مساعدة لتحليل قائمة الصور من الـ JSON.
  static List<String> _parseImages(
      Map<String, dynamic> json, String safeThumbnail) {
    List<String> imgs = [];
    final dynamic rawImages = json['project_images'] ?? json['images']; // دعم مفتاحين للصور
    if (rawImages is List) {
      for (var item in rawImages) {
        final String img = item.toString();
        if (img.startsWith('http')) {
          final encodedImg = _encodeImageUrl(img);
          imgs.add(encodedImg);
        }
      }
    }
    // إذا لم تكن هناك صور، أضف الصورة المصغرة كصورة رئيسية
    if (imgs.isEmpty && safeThumbnail.isNotEmpty) {
      imgs.add(safeThumbnail);
    }
    return imgs;
  }

  /// دالة مساعدة لتحويل أي قيمة إلى double بأمان.
  static double _parseDouble(dynamic raw, {double defaultValue = 0.0}) {
    if (raw == null) return defaultValue;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString()) ?? defaultValue;
  }

  /// دالة مساعدة لتحويل أي قيمة إلى int بأمان.
  static int _parseInt(dynamic raw, {int defaultValue = 0}) {
    if (raw == null) return defaultValue;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString()) ?? defaultValue;
  }

  /// دالة مساعدة لتحويل أي قيمة إلى bool بأمان.
  static bool _parseBool(dynamic raw) {
    if (raw == null) return false;
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      final lowerCaseRaw = raw.toLowerCase();
      return lowerCaseRaw == '1' || lowerCaseRaw == 'true';
    }
    return false;
  }

  // --- Getters لتنسيق وعرض البيانات بسهولة في الواجهة الأمامية ---

  /// يعرض السعر بشكل منسق (مليون، ألف، ريال) ويتعامل مع القيم الفارغة/الصفرية.
  String get formattedPrice {
    if (price == null || price! <= 0) {
      return 'غير متوفر';
    }
    final formatCurrency = NumberFormat.currency(
        locale: 'ar_SA',
        symbol: 'ريال', // يمكنك جعل العملة ديناميكية إذا كانت متوفرة في الـ API
        decimalDigits: 0); // لا يوجد أرقام عشرية للسعر
    return formatCurrency.format(price!);
  }

  /// يعرض مبلغ المساهمة بشكل منسق
  String get formattedContributionAmount {
    if (contributionAmount == null || contributionAmount! <= 0) {
      return 'غير متوفر';
    }
    final formatCurrency = NumberFormat.currency(
        locale: 'ar_SA',
        symbol: 'ريال',
        decimalDigits: 0);
    return formatCurrency.format(contributionAmount!);
  }

  /// الصورة الرئيسية للعقار (عادةً الـ thumbnail).
  String get mainImage => thumbnail;
  String get primaryImage => thumbnail;

  /// العنوان التفصيلي للعقار.
  String get address => location;

  /// يحدد ما إذا كان العقار معروضًا للبيع.
  bool get isForSale => status == 'for_sale' || status == 'sale';

  /// اسم حالة العقار المعروضة للمستخدم باللغة العربية.
  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'for_sale':
      case 'sale':
        return 'للبيع';
      case 'for_rent':
      case 'rent':
        return 'للإيجار';
      case 'sold':
        return 'تم البيع';
      case 'rented':
        return 'تم التأجير';
      case 'in_progress':
        return 'قيد الإنجاز';
      case 'completed':
        return 'تم الانتهاء';
      default:
        return 'متاح'; // حالة افتراضية
    }
  }

  /// اسم الحالة المختصر للعرض.
  String get statusText => statusDisplayName;

  /// اسم نوع العقار المعروض للمستخدم باللغة العربية.
  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'apartment':
        return 'شقة';
      case 'villa':
        return 'فيلا';
      case 'house':
        return 'منزل';
      case 'office':
        return 'مكتب';
      case 'shop':
        return 'محل';
      case 'warehouse':
        return 'مستودع';
      case 'land':
        return 'أرض';
      case 'building':
        return 'عمارة';
      case 'chalet':
        return 'شاليه'; // إضافة أنواع أخرى شائعة
      case 'farm':
        return 'مزرعة';
      default:
        // إذا لم يتم العثور على ترجمة، قم بترجمة النوع باستخدام خدمة ترجمة أو عرضه كما هو
        return type;
    }
  }

  /// اسم النوع المختصر للعرض.
  String get typeText => typeDisplayName;

  /// المساحة المنسقة مع الوحدة.
  String get formattedArea {
    if (area <= 0) return 'غير محدد';
    // يمكنك إضافة منطق لوحدة المساحة إذا كانت تأتي من الـ API
    return '${area.toStringAsFixed(0)} م²';
  }

  /// السعر لكل متر مربع.
  String get pricePerSqm {
    if (area <= 0 || price == null || price! <= 0)
      return ''; // ✅ معالجة السعر كـ null أو المساحة صفر
    final ppsqm = price! / area;
    return '${ppsqm.toStringAsFixed(0)} ريال/م²';
  }

  // --- toJson لتحويل الكائن إلى JSON (لإرساله إلى API أو حفظه) ---

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price, // هنا يمكن أن يكون null في الـ JSON
      'area': area,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'location': location,
      'thumbnail': thumbnail,
      'images': images,
      'type': type,
      'status': status,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'agent': agent.toJson(),
      'completion': completion,
      'features': features,
      'amenities': amenities,
      'year_built': yearBuilt,
      'furnished': furnished,
      'parking': parking,
      'rating': rating,
      'views': views,
      'updates': updates,
      'notes': notes,
      'videos': videos,
      'delivery_date': deliveryDate,
      'contribution_amount': contributionAmount,
    };
  }
}

class PropertyAgent {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? avatar;
  final String? whatsapp;
  final double? rating;
  final int? reviewsCount;
  final bool? isVerified;
  final String? company;

  PropertyAgent({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatar,
    this.whatsapp,
    this.rating,
    this.reviewsCount,
    this.isVerified,
    this.company,
  });

  factory PropertyAgent.fromJson(Map<String, dynamic> json) {
    return PropertyAgent(
      id: json['id']?.toString() ?? '0',
      name: json['name'] ?? 'مكتب عقاري',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      whatsapp: json['whatsapp'],
      rating:
          json['rating'] != null ? Property._parseDouble(json['rating']) : null,
      reviewsCount: Property._parseInt(json['reviews_count']),
      isVerified: Property._parseBool(json['is_verified']),
      company: json['company'],
    );
  }

  String get whatsappNumber => whatsapp ?? phone;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'whatsapp': whatsapp,
      'rating': rating,
      'reviews_count': reviewsCount,
      'is_verified': isVerified,
      'company': company,
    };
  }
}