class AppConstants {
  // --- CONTACT INFO ---
  static const String phoneNum = '+233555207062';
  static const String gmail = 'beautybymoblack@gmail.com';

  // --- CLOUDINARY CONFIG (Optional but Recommended) ---
  // Replace with your Cloudinary Cloud Name if you want to use shortened paths
  static const String cloudName = "di6avgdw1";
  static const String galleryTag = "gallery";
  static const String heroTag = "hero";
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

  // Placeholder for background video - Cloudinary/Firebase link goes here
  static const String heroBackgroundVideo = "";

  // --- SERVICES DATA ---
  static const List<Map<String, dynamic>> services = [
    {
      'title': 'Braiding',
      'folderKey': 'services/Braiding/images',
      'img': [],
      'video': '',
    },
    {
      'title': 'Installation',
      'folderKey': 'services/Installation/images',
      'img': [],
    },
    {
      'title': 'Revamping',
      'folderKey': 'services/Revamping/images',
      'img': [],
    },
    {
      'title': 'Ventilation',
      'folderKey': 'services/Ventilation/images',
      'img': [],
    },
    {
      'title': 'Coloring/Bleaching',
      'folderKey': 'services/Coloring/Bleaching/images',
      'img': [],
    },
    {
      'title': 'Styling',
      'folderKey': 'services/Styling/images',
      'img': [],
    },
    {
      'title': 'Wig making',
      'folderKey': 'services/Wig making/images',
      'img': [],
    },
    {
      'title': 'Makeup',
      'folderKey': 'services/Makeup/images',
      'img': [],
    },
    {
      'title': 'Pedicure',
      'folderKey': 'services/Pedicure/images',
      'img': [],
    },
    {
      'title': 'Manicure',
      'folderKey': 'services/Manicure/images',
      'img': [],
    },
  ];

  // --- PRODUCTS DATA ---
  static const String productFolderKey = 'Products/Hairs/images';

  // --- GALLERY SECTION ---
  static const List<String> galleryImages = [
    "https://images.unsplash.com/photo-1522335711546-267924fe378a?q=80&w=1470&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1616166183781-0fdd2ef83374?w=500&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?q=80&w=1374&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1512496011220-42ecaa6b33ec?q=80&w=1542&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1492106087820-71f1a00d2b11?q=80&w=1374&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?q=80&w=1469&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1560066984-138dadb4c035?q=80&w=1374&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1620331311520-246422ff82f9?q=80&w=1374&auto=format&fit=crop",
  ];

  static const List<String> galleryVideos = [
    // Add links to hosted video testimonials or work here
  ];
}
