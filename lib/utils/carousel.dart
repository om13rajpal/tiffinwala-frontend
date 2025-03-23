import 'package:shadcn_flutter/shadcn_flutter.dart';

class PosterCarousel extends StatefulWidget {
  const PosterCarousel({super.key});

  @override
  State<PosterCarousel> createState() => _PosterCarouselState();
}

class _PosterCarouselState extends State<PosterCarousel> {
  final CarouselController controller = CarouselController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150,
              child: Carousel(
                transition: const CarouselTransition.fading(),
                controller: controller,
                draggable: false,
                autoplaySpeed: const Duration(seconds: 2),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),

                      color: Colors.primaries[index % Colors.primaries.length],
                    ),
                    child: Center(child: Text('Poster $index')),
                  );
                },
                duration: const Duration(seconds: 1),
              ),
            ),
            const Gap(7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20,child: CarouselDotIndicator(itemCount: 5, controller: controller,),),
                  const Spacer(),
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
                  const Gap(8),
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
