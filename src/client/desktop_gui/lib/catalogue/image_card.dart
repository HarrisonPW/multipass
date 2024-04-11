import 'package:flutter/material.dart' hide ImageInfo;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers.dart';
import 'launch_form.dart';
import 'launch_panel.dart';

class ImageCard extends ConsumerWidget {
  final ImageInfo image;
  final double width;

  const ImageCard(this.image, this.width, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 275,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffdddddd)),
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.all(16),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'Ubuntu',
          fontSize: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset('assets/ubuntu.svg'),
            Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 18),
              child: Text(
                '${image.os} ${image.release}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Canonical ',
                  style: TextStyle(color: Color(0xff666666)),
                ),
                SvgPicture.asset('assets/verified.svg')
              ],
            ),
            Expanded(
              child: Align(
                alignment: const Alignment(-1, 0.2),
                child: Text(image.codename),
              ),
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    final grpcClient = ref.read(grpcClientProvider);
                    final name = ref.read(randomNameProvider);
                    final request = LaunchRequest(instanceName: name);
                    final aliasInfo = image.aliasesInfo.first;
                    request.image = aliasInfo.alias;
                    if (aliasInfo.hasRemoteName()) {
                      request.remoteName = aliasInfo.remoteName;
                    }

                    final stream = grpcClient.launch(request);
                    ref.read(launchOperationProvider.notifier).state =
                        (stream, name, imageName(image));
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: const Text('Launch'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    ref.read(launchingImageProvider.notifier).state = image;
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: SvgPicture.asset(
                    'assets/settings.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
