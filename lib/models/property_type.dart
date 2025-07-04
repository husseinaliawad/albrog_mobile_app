class PropertyType {
  final String id;
  final String name;
  final String nameEn;
  final int propertyCount;
  final String icon;
  final String image;
  final String? description;
  final String? color;

  PropertyType({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.propertyCount,
    required this.icon,
    required this.image,
    this.description,
    this.color,
  });

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    return PropertyType(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      propertyCount: _parseInt(json['count'] ?? json['property_count']),
      icon: json['icon'] ?? '',
      image: json['image'] ?? '',
      description: json['description'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'count': propertyCount,
      'property_count': propertyCount,
      'icon': icon,
      'image': image,
      'description': description,
      'color': color,
    };
  }

  // ✅ طرق آمنة لتحليل البيانات
  static int _parseInt(dynamic raw) {
    if (raw == null || raw == false || raw == '') return 0;
    if (raw is num) return raw.toInt();
    final parsed = int.tryParse(raw.toString());
    return parsed ?? 0;
  }

  // ✅ Getters مفيدة
  String get formattedPropertyCount {
    if (propertyCount >= 1000) {
      return '${(propertyCount / 1000).toStringAsFixed(1)}k';
    }
    return propertyCount.toString();
  }

  String get displayName => name.isNotEmpty ? name : nameEn;
  
  String get propertyCountText {
    return '$propertyCount ${propertyCount == 1 ? 'عقار' : 'عقار'}';
  }

  // ✅ Default icons mapping
  String get displayIcon {
    if (icon.isNotEmpty) return icon;
    
    final iconMap = {
      'شقة': '🏠',
      'فيلا': '🏡',
      'مكتب': '🏢',
      'محل': '🏪',
      'أرض': '🌍',
      'مستودع': '🏭',
      'مبنى': '🏢',
      'apartment': '🏠',
      'villa': '🏡',
      'office': '🏢',
      'shop': '🏪',
      'land': '🌍',
      'warehouse': '🏭',
      'building': '🏢',
    };
    
    return iconMap[name.toLowerCase()] ?? 
           iconMap[nameEn.toLowerCase()] ?? 
           '🏠';
  }

  // ✅ Default colors mapping
  String get displayColor {
    if (color != null && color!.isNotEmpty) return color!;
    
    final colorMap = {
      'شقة': '#2196F3',
      'فيلا': '#4CAF50',
      'مكتب': '#FF9800',
      'محل': '#9C27B0',
      'أرض': '#795548',
      'مستودع': '#607D8B',
      'مبنى': '#F44336',
    };
    
    return colorMap[name] ?? '#2196F3';
  }
} 