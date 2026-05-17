class LostItem {
  final String id;
  final String title;
  final String location;
  final DateTime date; // Kullanıcının seçtiği tarih 
  final DateTime createdAt; //Supabase'e eklenme tarihi
  final String description;
  final List<String> imageUrls;
  final bool isApproved;
  final String ownerEmail;
  final String userId;
  final bool isArchived;

  LostItem({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.createdAt,
    required this.description,
    required this.imageUrls,
    required this.isApproved,
    required this.ownerEmail,
    required this.userId,
    this.isArchived = false,
  });

  factory LostItem.fromMap(Map<String, dynamic> map) {
    return LostItem(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(), // YENİ EKLENDİ
      description: map['description'] ?? '',
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      ownerEmail: map['owner_email'] ?? '',
      isApproved: map['is_approved'] ?? false,
      userId: map['user_id']?.toString() ?? '',
      isArchived: map['is_archived'] ?? false,
    );
  }
}