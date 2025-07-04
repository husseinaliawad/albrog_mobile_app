import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../models/property.dart';
import 'wordpress_image.dart';
import '../models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool isFavorite;
  final double? distance;

  const PropertyCard({
    Key? key,
    required this.property,
    required this.onTap,
    required this.onFavorite,
    required this.isFavorite,
    this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container - ارتفاع أقل للمساحة
            SizedBox(
              height: 160, // تقليل من 180 إلى 160
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background
                    Container(
                      color: Colors.grey[200],
                    ),
                    // Image
                    _buildImage(),
                    // Featured Badge
                    if (property.isFeatured)
                      Positioned(
                        top: 8, // تقليل من 12 إلى 8
                        right: 8, // تقليل من 12 إلى 8
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2), // تقليل padding
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius:
                                BorderRadius.circular(8), // تقليل من 12 إلى 8
                          ),
                          child: const Text(
                            'مميز',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9, // تقليل من 10 إلى 9
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Favorite Button
                    Positioned(
                      top: 8, // تقليل من 12 إلى 8
                      left: 8, // تقليل من 12 إلى 8
                      child: GestureDetector(
                        onTap: onFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(4), // تقليل من 6 إلى 4
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 16, // تقليل من 18 إلى 16
                            color: isFavorite ? Colors.red : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content - إصلاح كامل للـ overflow
            Expanded(
              // تغيير من Flexible إلى Expanded
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Price and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            property.formattedPrice,
                            style: const TextStyle(
                              fontSize: 14, // تقليل من 15 إلى 14
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1), // تقليل padding
                          decoration: BoxDecoration(
                            color:
                                property.isForSale ? Colors.green : Colors.blue,
                            borderRadius:
                                BorderRadius.circular(6), // تقليل من 8 إلى 6
                          ),
                          child: Text(
                            property.statusDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2), // تقليل من 3 إلى 2

                    // Contribution Amount
                    if (property.contributionAmount != null && property.contributionAmount! > 0) ...[
                      Text(
                        'المساهمة: ${property.formattedContributionAmount}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                    ],

                    // Title
                    Flexible(
                      // لف في Flexible
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 12, // تقليل من 13 إلى 12
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Location
                    Flexible(
                      // لف في Flexible
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 10, // تقليل من 11 إلى 10
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              property.location,
                              style: const TextStyle(
                                fontSize: 9, // تقليل من 10 إلى 9
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 3), // تقليل من 4 إلى 3

                    // Property Details
                    Flexible(
                      // لف في Flexible
                      child: Row(
                        children: [
                          if (property.bedrooms > 0) ...[
                            _buildDetailItem(
                                Icons.bed, property.bedrooms.toString()),
                            const SizedBox(width: 6), // تقليل من 8 إلى 6
                          ],
                          if (property.bathrooms > 0) ...[
                            _buildDetailItem(
                                Icons.bathtub, property.bathrooms.toString()),
                            const SizedBox(width: 6), // تقليل من 8 إلى 6
                          ],
                          Expanded(
                            // لجعل العنصر الأخير يأخذ المساحة المتبقية
                            child: _buildDetailItem(
                                Icons.square_foot, property.formattedArea),
                          ),
                        ],
                      ),
                    ),

                    // Distance
                    if (distance != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.navigation_outlined,
                              size: 8, color: Colors.blue), // تقليل من 9 إلى 8
                          const SizedBox(width: 2),
                          Text(
                            '${distance!.toStringAsFixed(1)} كم',
                            style: const TextStyle(
                                fontSize: 8, color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 10, color: AppColors.textSecondary), // تقليل من 11 إلى 10
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
              fontSize: 8, color: AppColors.textSecondary), // تقليل من 9 إلى 8
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (property.thumbnail.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image,
            size: 40, color: Colors.grey),
      );
    }

    // ✅ استخدام WordPress Image Widget مع Base64
    return WordPressImage(
      imageUrl: property.thumbnail,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
