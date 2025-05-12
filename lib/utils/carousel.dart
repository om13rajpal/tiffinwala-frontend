import 'package:shadcn_flutter/shadcn_flutter.dart';

class PosterCarousel extends StatefulWidget {
  const PosterCarousel({super.key});

  @override
  State<PosterCarousel> createState() => _PosterCarouselState();
}

List<String> _posters = [
  'assets/1.png',
  'assets/2.png',
  'assets/3.png',
  'assets/1.png',
  'assets/2.png',
];

class _PosterCarouselState extends State<PosterCarousel> {
  final CarouselController controller = CarouselController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 190,
              child: Carousel(
                transition: const CarouselTransition.fading(),
                controller: controller,
                draggable: false,
                autoplaySpeed: const Duration(seconds: 4),
                itemCount: _posters.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(_posters[index], fit: BoxFit.cover),
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
                        const Duration(milliseconds: 500),
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
