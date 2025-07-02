import 'package:flutter_riverpod/flutter_riverpod.dart';

final bannerProvider = StateProvider<List<dynamic>>(
  (ref) => [
    'https://res.cloudinary.com/drknn3ujj/image/upload/v1751165828/banners/s9jio13oefqyivsxks2g.jpg',
  ],
);

final bannerLinkProvider = StateProvider<List<dynamic>>((ref) => []);