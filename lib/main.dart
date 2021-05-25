import 'dart:convert';

import 'package:cat_tinder/model/Vote.dart';
import 'package:cat_tinder/repository/CatRepository.dart';
import 'package:cat_tinder/widgets/CatImage.dart';
import 'package:cat_tinder/widgets/Loading.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'model/Cat.dart';

void main() {
  runApp(ProviderScope(child: CatRater()));
}

final catRepository = Provider<CatRepository>(
  (ref) => CatRepository(),
);

final cat = FutureProvider.autoDispose.family<Cat, int>((ref, id) async {
  return ref.watch(catRepository).fetchCat();
});

class CatRater extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Rate the Cat')),
        body: CatPage(),
      ),
    );
  }
}

class CatPage extends HookWidget {
  rateCat(Vote vote) {
    http.post(Uri.parse("https://api.thecatapi.com/v1/votes"),
        headers: {"x-api-key": "api-key", "Content-Type": "application/json"},
        body: jsonEncode(vote));
  }

  @override
  Widget build(BuildContext context) {
    final counter = useState(0);
    final currentCat = useProvider(cat(counter.value));
    final nextCat = useProvider(cat(counter.value + 1));
    final dragging = useState(false);

    nextCat.when(
      data: (nextCat) {
        precacheImage(Image.network(nextCat.url).image, context);
      },
      loading: () {},
      error: (o, s) {},
    );
    return currentCat.when(
        data: (catData) {
          return new LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Center(
              child: Draggable(
                onDragEnd: (details) {
                  if (details.offset.dx > 20) {
                    rateCat(Vote(catData.id, 1));
                    counter.value++;
                  } else if (details.offset.dx < -20) {
                    rateCat(Vote(catData.id, 0));
                    counter.value++;
                  }
                  dragging.value = false;
                },
                onDragStarted: () {
                  dragging.value = true;
                },
                child: Container(
                  width: constraints.maxWidth - 10,
                  height: constraints.maxHeight - 200,
                  child: Card(
                    child: Stack(children: <Widget>[
                      Loading(),
                      Center(
                        child: dragging.value == false
                            ? CatImage(url: catData.url)
                            : nextCat.when(
                                data: (nextCat) {
                                  return CatImage(url: nextCat.url);
                                },
                                loading: () {
                                  return Loading();
                                },
                                error: (Object error, StackTrace stackTrace) {
                                  return ErrorWidget(stackTrace);
                                },
                              ),
                      )
                    ]),
                  ),
                ),
                feedback: Center(
                  child: Container(
                    width: constraints.maxWidth - 10,
                    height: constraints.maxHeight - 200,
                    child: Card(
                      child: Stack(children: <Widget>[
                        Loading(),
                        Center(child: CatImage(url: catData.url))
                      ]),
                    ),
                  ),
                ),
              ),
            );
          });
        },
        loading: () => Loading(),
        error: (e, s) => ErrorWidget(s));
  }
}
