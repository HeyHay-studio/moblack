class AppConstants {
  // --- HELPERS ---
  static String getWhatsAppBuyUrl(
    String publicId,
    bool isVideo,
  ) {
    // Basic sanitization: only allow alphanumeric, dots, and slashes for publicId
    final sanitizedId = publicId.replaceAll(RegExp(r'[^\w\.\-/]'), '');
    
    // Construct the URL using our trusted base to prevent external link injection
    final mediaPath = isVideo ? 'video/upload/' : 'image/upload/';
    final trustedBase = "https://res.cloudinary.com/$cloudName/$mediaPath";
    final fullUrl = "$trustedBase$sanitizedId";

    final message = "Hello Moblack! ✨\n\n"
        "I'm interested in this product:\n"
        "Reference ID: $sanitizedId\n\n"
        "Product Details: $fullUrl";
    
    final encodedMessage = Uri.encodeComponent(message);
    return "https://wa.me/$phoneNum?text=$encodedMessage";
  }

  // --- CONTACT INFO ---
  static const String phoneNum = '+233555207062';
  static const String gmail = 'beautybymoblack@gmail.com';

  // --- CLOUDINARY CONFIG (Optional but Recommended) ---
  // Replace with your Cloudinary Cloud Name if you want to use shortened paths
  static const String cloudName = "di6avgdw1";
  static const String galleryTag = "gallery";
  static const String mainTag = "gallery";
  static const String cloudinaryBaseUrl =
      "https://res.cloudinary.com/$cloudName/image/upload/";

  // --- NAVIGATION ---
  static const List<String> navLinks = [
    'Home',
    'Services',
    'Products',
    'Gallery',
    'About',
  ];

  // --- HERO SECTION ASSETS ---
  static const List<String> heroImages = [
    "https://plus.unsplash.com/premium_photo-1694618624500-3abfdba0bfd6?q=80&w=687&auto=format&fit=crop",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkjBsJ4B6ymbBMaBdZE3DJ0vGhUt8dWQFZTw&s",
    "https://cdn11.bigcommerce.com/s-1xo6r218zd/images/stencil/1280x1280/products/4373/6133/CL-3500_WEB_Features_06__47834.1771413115.jpg?c=1",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQOX4D_9v7Mm_efn2WILRfZ9Kxyo9UFykm41A&s",
    "https://www.rootflage.com/cdn/shop/articles/how-to-bleach-black-hair.jpg?v=1642703449",
    "https://www.bellanaija.com/wp-content/uploads/2023/05/314734446_747597160120355_8537999063044706868_n.jpg",
    'https://img.freepik.com/premium-photo/hairdresser-black-gloves-paints-brunette-woman-s-hair-beauty-salon_427957-3324.jpg',
  ];

  // --- SERVICES DATA ---
  static const List<Map<String, dynamic>> services = [
    {
      'title': 'Braiding',
      'folderKey': 'services/Braiding/images',
      'videoFolderKey': 'services/Braiding/videos',
      'img': [],
    },
    {
      'title': 'Installation',
      'folderKey': 'services/Installation/images',
      'videoFolderKey': 'services/Installation/videos',
      'img': [],
    },
    {
      'title': 'Revamping',
      'folderKey': 'services/Revamping/images',
      'videoFolderKey': 'services/Revamping/videos',
      'img': [],
    },
    {
      'title': 'Ventilation',
      'folderKey': 'services/Ventilation/images',
      'videoFolderKey': 'services/Ventilation/videos',
      'img': [],
    },
    {
      'title': 'Coloring/Bleaching',
      'folderKey': 'services/Bleaching/images',
      'videoFolderKey': 'services/Bleaching/videos',
      'img': [],
    },
    {
      'title': 'Styling',
      'folderKey': 'services/Styling/images',
      'videoFolderKey': 'services/Styling/videos',
      'img': [],
    },
    {
      'title': 'Wig making',
      'folderKey': 'services/Wig making/images',
      'videoFolderKey': 'services/Wig making/videos',
      'img': [],
    },
    {
      'title': 'Makeup',
      'folderKey': 'services/Makeup/images',
      'videoFolderKey': 'services/Makeup/videos',
      'img': [],
    },
    {
      'title': 'Pedicure',
      'folderKey': 'services/Pedicure/images',
      'videoFolderKey': 'services/Pedicure/videos',
      'img': [],
    },
    {
      'title': 'Manicure',
      'folderKey': 'services/Manicure/images',
      'videoFolderKey': 'services/Manicure/videos',
      'img': [],
    },
  ];

  // --- PRODUCTS DATA ---
  static const String productFolderKey = 'Products/Hairs/images';
  static const String productVideoFolderKey = 'Products/Hairs/videos';

  // --- GALLERY SECTION ---
  static const List<String> galleryImages = [
    "https://images.unsplash.com/photo-1616166183781-0fdd2ef83374?w=500&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?q=80&w=1374&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1492106087820-71f1a00d2b11?q=80&w=1374&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=1374&auto=format&fit=crop",
  ];
}
