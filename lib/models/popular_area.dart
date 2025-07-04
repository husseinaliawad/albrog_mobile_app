class PopularArea {
  final String id;
  final String name;
  final String nameEn;
  final int propertyCount;
  final String image;
  final double? averagePrice;
  final String? description;

  PopularArea({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.propertyCount,
    required this.image,
    this.averagePrice,
    this.description,
  });

  /// ✅ تحويل JSON إلى PopularArea
  factory PopularArea.fromJson(Map<String, dynamic> json) {
    return PopularArea(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      propertyCount: _parseInt(json['count']), // ✅ صحح المفتاح هنا
      image: json['image'] ?? '',
      averagePrice: json['average_price'] != null
          ? _parseDouble(json['average_price'])
          : null,
      description: json['description'],
    );
  }

  /// ✅ تحويل PopularArea إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'count': propertyCount, // ✅ مطابق للـ API
      'image': image,
      'average_price': averagePrice,
      'description': description,
    };
  }

  /// ✅ طرق مساعدة للتحويل الآمن
  static int _parseInt(dynamic raw) {
    if (raw == null || raw == false || raw == '') return 0;
    if (raw is num) return raw.toInt();
    final parsed = int.tryParse(raw.toString());
    return parsed ?? 0;
  }

  static double _parseDouble(dynamic raw) {
    if (raw == null || raw == false || raw == '') return 0.0;
    if (raw is num) return raw.toDouble();
    final parsed = double.tryParse(raw.toString());
    return parsed ?? 0.0;
  }

  /// ✅ Getter: عدد العقارات بصيغة ودية
  String get formattedPropertyCount {
    if (propertyCount >= 1000) {
      return '${(propertyCount / 1000).toStringAsFixed(1)}k';
    }
    return propertyCount.toString();
  }

  /// ✅ Getter: متوسط السعر بصيغة ودية
  String get formattedAveragePrice {
    if (averagePrice == null) return '';
    if (averagePrice! >= 1000000) {
      return '${(averagePrice! / 1000000).toStringAsFixed(1)} مليون ريال';
    } else if (averagePrice! >= 1000) {
      return '${(averagePrice! / 1000).toStringAsFixed(0)} ألف ريال';
    } else {
      return '${averagePrice!.toStringAsFixed(0)} ريال';
    }
  }

  /// ✅ Getter: اسم العرض المفضل
  String get displayName => name.isNotEmpty ? name : nameEn;

  /// ✅ Getter: نص عدد العقارات مع كلمة عقار
  String get propertyCountText {
    return '$propertyCount عقار${propertyCount != 1 ? '' : ''}';
  }
}
