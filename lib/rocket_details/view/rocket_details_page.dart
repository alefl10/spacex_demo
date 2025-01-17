import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:spacex_api/spacex_api.dart';
import 'package:spacex_demo/rocket_details/rocket_details.dart';
import 'package:spacex_demo/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class RocketDetailsPage extends StatelessWidget {
  const RocketDetailsPage({Key? key}) : super(key: key);

  static Route<void> route({required Rocket rocket}) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => RocketDetailsCubit(rocket: rocket),
        child: const RocketDetailsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RocketDetailsView();
  }
}

class RocketDetailsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final rocket =
        context.select((RocketDetailsCubit cubit) => cubit.state.rocket);

    return Scaffold(
      appBar: AppBar(
        title: Text(rocket.name),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              if (rocket.flickrImages.isNotEmpty)
                const _ImageHeader(
                  key: Key('rocketDetailsPage_imageHeader'),
                ),
              const _TitleHeader(
                key: Key('rocketDetailsPage_titleHeader'),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: _DescriptionSection(),
              ),
              if (rocket.wikipedia != null)
                const SizedBox(
                  height: 80.0,
                ),
            ],
          ),
          if (rocket.wikipedia != null)
            Positioned(
              left: 16.0,
              bottom: 16.0,
              right: 16.0,
              child: SizedBox(
                height: 64.0,
                child: ElevatedButton(
                  key: const Key(
                    'rocketDetailsPage_openWikipedia_elevatedButton',
                  ),
                  onPressed: () async {
                    final url = rocket.wikipedia!;

                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                  child: Text(l10n.rocketDetailsOpenWikipediaButtonText),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageHeader extends StatelessWidget {
  const _ImageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = context.select(
      (RocketDetailsCubit cubit) => cubit.state.rocket.flickrImages.first,
    );

    return SizedBox(
      height: 240.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(8.0),
          ),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _TitleHeader extends StatelessWidget {
  const _TitleHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final rocket =
        context.select((RocketDetailsCubit cubit) => cubit.state.rocket);

    return ListTile(
      title: Row(
        children: [
          Text(
            rocket.name,
            style: Theme.of(context).textTheme.headline5,
          ),
          if (rocket.active != null) ...[
            const SizedBox(width: 4.0),
            if (rocket.active!)
              const Icon(
                Icons.check,
                color: Colors.green,
              )
            else
              const Icon(
                Icons.close,
                color: Colors.red,
              ),
          ],
        ],
      ),
      subtitle: rocket.firstFlight == null
          ? null
          : Text(l10n.rocketDetailsFirstFlightSubtitle(
              DateFormat('dd-MM-yyyy').format(rocket.firstFlight!),
            )),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final description = context.select(
      (RocketDetailsCubit cubit) => cubit.state.rocket.description,
    );

    return Text(description);
  }
}
