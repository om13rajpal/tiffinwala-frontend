import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/providers/banner.dart';
import 'package:url_launcher/url_launcher.dart';

class PosterCarousel extends ConsumerStatefulWidget {
  const PosterCarousel({super.key});

  @override
  ConsumerState<PosterCarousel> createState() => _PosterCarouselState();
}

Future<void> getBanners(WidgetRef ref) async {
  try {
    final response = await http.get(Uri.parse("${BaseUrl.url}/banner"));
    if (response.statusCode == 200) {
      final jsonRes = await jsonDecode(response.body);
      List<dynamic> banners =
          jsonRes['data'].map((banner) => banner['url']).toList();

      List<dynamic> bannerLink =
          jsonRes['data'].map((banner) {
            return banner['redirect'] ?? "";
          }).toList();

      ref.read(bannerLinkProvider.notifier).state = bannerLink;
      ref.read(bannerProvider.notifier).state = banners;
    }
  } catch (e) {
    log(e.toString());
  }
}

class _PosterCarouselState extends ConsumerState<PosterCarousel> {
  @override
  void initState() {
    getBanners(ref);
    super.initState();
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      log("Could not launch $url");
    }
  }

  final CarouselController controller = CarouselController();
  List<dynamic> _posters = [];
  List<dynamic> postersLink = [];

  @override
  Widget build(BuildContext context) {
    _posters = ref.watch(bannerProvider);
    postersLink = ref.watch(bannerLinkProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: (MediaQuery.of(context).size.width - 24) * (270 / 400),
              child: Carousel(
                transition: const CarouselTransition.fading(),
                controller: controller,
                draggable: false,
                autoplaySpeed: const Duration(seconds: 4),
                itemCount: _posters.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GestureDetector(
                      onTap: () {
                        final url = postersLink[index];
                        _openUrl(url);
                      },
                      child: Image.network(_posters[index], fit: BoxFit.cover),
                    ),
                  );
                },
                duration: const Duration(seconds: 1),
              ),
            ),
            const Gap(7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OutlineButton(
                    shape: ButtonShape.circle,
                    size: ButtonSize.xSmall,
                    onPressed: () {
                      controller.animatePrevious(
                        const Duration(milliseconds: 800),
                      );
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                  gap(10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: OverflowMarquee(
                      duration: Duration(seconds: 4),
                      fadePortion: 20,
                      child: Text(
                        'No more boring meals – try our homestyle tiffin today & get 20% off your first order! Get your first tiffin at just ₹49 – homemade taste, delivered fresh to your doorstep!',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ),
                  ),
                  gap(10),
                  OutlineButton(
                    shape: ButtonShape.circle,
                    size: ButtonSize.xSmall,
                    onPressed: () {
                      controller.animateNext(const Duration(milliseconds: 500));
                    },
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
