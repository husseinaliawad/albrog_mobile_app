class SearchFilter {
  final String? query;
  final String? type;
  final String? status;
  final String? city;
  final String? district;
  final double? minPrice;
  final double? maxPrice;
  final double? minArea;
  final double? maxArea;
  final int? bedrooms;
  final int? bathrooms;
  final bool? furnished;
  final List<String>? features;
  final List<String>? amenities;
  final String? sortBy;
  final bool? isFeatured;
  final double? latitude;
  final double? longitude;
  final double? radius; // في كيلومتر

  SearchFilter({
    this.query,
    this.type,
    this.status,
    this.city,
    this.district,
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.bedrooms,
    this.bathrooms,
    this.furnished,
    this.features,
    this.amenities,
    this.sortBy,
    this.isFeatured,
    this.latitude,
    this.longitude,
    this.radius,
  });

  factory SearchFilter.fromJson(Map<String, dynamic> json) {
    return SearchFilter(
      query: json['query'],
      type: json['type'],
      status: json['status'],
      city: json['city'],
      district: json['district'],
      minPrice: json['min_price'] != null ? (json['min_price']).toDouble() : null,
      maxPrice: json['max_price'] != null ? (json['max_price']).toDouble() : null,
      minArea: json['min_area'] != null ? (json['min_area']).toDouble() : null,
      maxArea: json['max_area'] != null ? (json['max_area']).toDouble() : null,
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      furnished: json['furnished'],
      features: json['features'] != null ? List<String>.from(json['features']) : null,
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : null,
      sortBy: json['sort_by'],
      isFeatured: json['is_featured'],
      latitude: json['latitude'] != null ? (json['latitude']).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude']).toDouble() : null,
      radius: json['radius'] != null ? (json['radius']).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (query != null) json['query'] = query;
    if (type != null) json['type'] = type;
    if (status != null) json['status'] = status;
    if (city != null) json['city'] = city;
    if (district != null) json['district'] = district;
    if (minPrice != null) json['min_price'] = minPrice;
    if (maxPrice != null) json['max_price'] = maxPrice;
    if (minArea != null) json['min_area'] = minArea;
    if (maxArea != null) json['max_area'] = maxArea;
    if (bedrooms != null) json['bedrooms'] = bedrooms;
    if (bathrooms != null) json['bathrooms'] = bathrooms;
    if (furnished != null) json['furnished'] = furnished;
    if (features != null) json['features'] = features;
    if (amenities != null) json['amenities'] = amenities;
    if (sortBy != null) json['sort_by'] = sortBy;
    if (isFeatured != null) json['is_featured'] = isFeatured;
    if (latitude != null) json['latitude'] = latitude;
    if (longitude != null) json['longitude'] = longitude;
    if (radius != null) json['radius'] = radius;
    
    return json;
  }

  // Helper methods
  bool get hasFilters {
    return query?.isNotEmpty == true ||
           type != null ||
           status != null ||
           city != null ||
           district != null ||
           minPrice != null ||
           maxPrice != null ||
           minArea != null ||
           maxArea != null ||
           bedrooms != null ||
           bathrooms != null ||
           furnished != null ||
           features?.isNotEmpty == true ||
           amenities?.isNotEmpty == true ||
           isFeatured != null;
  }

  int get activeFiltersCount {
    int count = 0;
    
    if (query?.isNotEmpty == true) count++;
    if (type != null) count++;
    if (status != null) count++;
    if (city != null) count++;
    if (district != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minArea != null || maxArea != null) count++;
    if (bedrooms != null) count++;
    if (bathrooms != null) count++;
    if (furnished != null) count++;
    if (features?.isNotEmpty == true) count++;
    if (amenities?.isNotEmpty == true) count++;
    if (isFeatured != null) count++;
    
    return count;
  }

  String get priceRangeText {
    if (minPrice != null && maxPrice != null) {
      return '${_formatPrice(minPrice!)} - ${_formatPrice(maxPrice!)}';
    } else if (minPrice != null) {
      return 'من ${_formatPrice(minPrice!)}';
    } else if (maxPrice != null) {
      return 'حتى ${_formatPrice(maxPrice!)}';
    }
    return '';
  }

  String get areaRangeText {
    if (minArea != null && maxArea != null) {
      return '${minArea!.toInt()} - ${maxArea!.toInt()} م²';
    } else if (minArea != null) {
      return 'من ${minArea!.toInt()} م²';
    } else if (maxArea != null) {
      return 'حتى ${maxArea!.toInt()} م²';
    }
    return '';
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)} مليون';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)} ألف';
    } else {
      return price.toStringAsFixed(0);
    }
  }

  SearchFilter copyWith({
    String? query,
    String? type,
    String? status,
    String? city,
    String? district,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? bedrooms,
    int? bathrooms,
    bool? furnished,
    List<String>? features,
    List<String>? amenities,
    String? sortBy,
    bool? isFeatured,
    double? latitude,
    double? longitude,
    double? radius,
    bool clearQuery = false,
    bool clearType = false,
    bool clearStatus = false,
    bool clearCity = false,
    bool clearDistrict = false,
    bool clearPrice = false,
    bool clearArea = false,
    bool clearBedrooms = false,
    bool clearBathrooms = false,
    bool clearFurnished = false,
    bool clearFeatures = false,
    bool clearAmenities = false,
    bool clearLocation = false,
  }) {
    return SearchFilter(
      query: clearQuery ? null : (query ?? this.query),
      type: clearType ? null : (type ?? this.type),
      status: clearStatus ? null : (status ?? this.status),
      city: clearCity ? null : (city ?? this.city),
      district: clearDistrict ? null : (district ?? this.district),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      minArea: clearArea ? null : (minArea ?? this.minArea),
      maxArea: clearArea ? null : (maxArea ?? this.maxArea),
      bedrooms: clearBedrooms ? null : (bedrooms ?? this.bedrooms),
      bathrooms: clearBathrooms ? null : (bathrooms ?? this.bathrooms),
      furnished: clearFurnished ? null : (furnished ?? this.furnished),
      features: clearFeatures ? null : (features ?? this.features),
      amenities: clearAmenities ? null : (amenities ?? this.amenities),
      sortBy: sortBy ?? this.sortBy,
      isFeatured: isFeatured ?? this.isFeatured,
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
      radius: clearLocation ? null : (radius ?? this.radius),
    );
  }

  SearchFilter clearAll() {
    return SearchFilter(
      sortBy: sortBy,
    );
  }

  // Convert filter to API query parameters
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    
    // Basic search parameters that match our API
    if (query?.isNotEmpty == true) params['search'] = query;
    if (type != null) params['type'] = type;
    if (status != null) params['status'] = status;
    if (city != null) params['city'] = city;
    if (district != null) params['district'] = district;
    if (minPrice != null) params['min_price'] = minPrice!.toInt();
    if (maxPrice != null) params['max_price'] = maxPrice!.toInt();
    if (minArea != null) params['min_area'] = minArea!.toInt();
    if (maxArea != null) params['max_area'] = maxArea!.toInt();
    if (bedrooms != null) params['bedrooms'] = bedrooms;
    if (bathrooms != null) params['bathrooms'] = bathrooms;
    if (furnished != null) params['furnished'] = furnished! ? 1 : 0;
    if (features?.isNotEmpty == true) params['features'] = features!.join(',');
    if (amenities?.isNotEmpty == true) params['amenities'] = amenities!.join(',');
    if (sortBy != null) params['orderby'] = sortBy;
    if (isFeatured != null) params['featured'] = isFeatured! ? 1 : 0;
    if (latitude != null) params['latitude'] = latitude;
    if (longitude != null) params['longitude'] = longitude;
    if (radius != null) params['radius'] = radius;
    
    return params;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SearchFilter &&
           other.query == query &&
           other.type == type &&
           other.status == status &&
           other.city == city &&
           other.district == district &&
           other.minPrice == minPrice &&
           other.maxPrice == maxPrice &&
           other.minArea == minArea &&
           other.maxArea == maxArea &&
           other.bedrooms == bedrooms &&
           other.bathrooms == bathrooms &&
           other.furnished == furnished &&
           _listEquals(other.features, features) &&
           _listEquals(other.amenities, amenities) &&
           other.sortBy == sortBy &&
           other.isFeatured == isFeatured &&
           other.latitude == latitude &&
           other.longitude == longitude &&
           other.radius == radius;
  }

  @override
  int get hashCode {
    return Object.hash(
      query,
      type,
      status,
      city,
      district,
      minPrice,
      maxPrice,
      minArea,
      maxArea,
      bedrooms,
      bathrooms,
      furnished,
      features,
      amenities,
      sortBy,
      isFeatured,
      latitude,
      longitude,
      radius,
    );
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
} 