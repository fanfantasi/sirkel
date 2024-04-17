import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:screenshare/core/utils/config.dart';
import 'package:screenshare/core/utils/debouncer.dart';
import 'package:screenshare/core/widgets/loadingwidget.dart';

class PlaceWidget extends StatefulWidget {
  const PlaceWidget({super.key});

  @override
  State<PlaceWidget> createState() => _PlaceWidgetState();
}

class _PlaceWidgetState extends State<PlaceWidget> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  int limit = 10;
  List<Map<String, dynamic>> location = [];

  final debouncer = Debouncer(milliseconds: 500);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> searchPlace() async {
    if (textController.text.length >= 3) {
      location.clear();
      setState(() {
        isLoading = true;
      });
      SearchBoxAPI search = SearchBoxAPI(
        apiKey: Config.mapBox,
        limit: 10,
        country: "ID",
      );

      ApiResponse<SuggestionResponse> searchPlace = await search.getSuggestions(
        textController.text,
      );

      for (var e in searchPlace.success!.suggestions) {
        location.add({'mapboxId':e.mapboxId, 'name': e.name});
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: .9,
      initialChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            children: [
              FractionallySizedBox(
                widthFactor: 0.25,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 12.0,
                  ),
                  child: Container(
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(2.5)),
                    ),
                  ),
                ),
              ),
              Text(
                'location'.tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 38,
                margin: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(fontSize: 14),
                    hintText: 'search location'.tr(),
                    suffixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4),
                  ),
                  onChanged: (value) => {
                    debouncer.run(() {
                      searchPlace();
                    })
                  },
                ),
              ),
              Flexible(
                child: isLoading
                    ? const Center(
                        child: LoadingWidget(),
                      )
                    : ListView.separated(
                        separatorBuilder: (context, i) =>
                            const Divider(height: 1),
                        itemCount: location.length,
                        physics: const BouncingScrollPhysics(),
                        controller: controller,
                        itemBuilder: (context, i) {
                          return ListTile(
                              minLeadingWidth: 0,
                              title: Text(
                                location[i]['name'],
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              onTap: () async {
                                Navigator.pop(context, location[i]['name']);
                              });
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
