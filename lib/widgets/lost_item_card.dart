import 'package:flutter/material.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';

class LostItemCard extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final bool isApproved;
  final String? imageUrl;

  const LostItemCard({
    Key? key,
    required this.title,
    required this.location,
    required this.date,
    required this.isApproved,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: const Color.fromARGB(255, 200, 188, 188),
        ), // İnce dış çizgi
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16.0),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? Icon(Icons.camera_alt, color: Colors.grey[600], size: 30)
                : null,
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    date,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
