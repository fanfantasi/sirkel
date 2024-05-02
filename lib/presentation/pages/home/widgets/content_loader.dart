import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ContentLoader extends StatelessWidget {
  const ContentLoader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 35,
                      width: 35,
                      child: Shimmer.fromColors(
                        baseColor: Colors.black45,
                        highlightColor: Colors.white,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 18,
                          width: MediaQuery.of(context).size.width * .5,
                          child: Shimmer.fromColors(
                            baseColor: Colors.black45,
                            highlightColor: Colors.white,
                            child: Container(
                              height: 18,
                              width: MediaQuery.of(context).size.width * .5,
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        SizedBox(
                          height: 8,
                          width: MediaQuery.of(context).size.width * .3,
                          child: Shimmer.fromColors(
                            baseColor: Colors.black45,
                            highlightColor: Colors.white,
                            child: Container(
                              height: 8,
                              width: MediaQuery.of(context).size.width * .5,
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 32,
                  width: 12,
                  child: Shimmer.fromColors(
                    baseColor: Colors.black45,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 32,
                      width: 12,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          AspectRatio(
            aspectRatio: 5 / 3,
            child: Shimmer.fromColors(
              baseColor: Colors.black45,
              highlightColor: Colors.white,
              child: Container(
                height: 400,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.black12,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 35,
                      width: 35,
                      child: Shimmer.fromColors(
                        baseColor: Colors.black45,
                        highlightColor: Colors.white,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      height: 35,
                      width: 35,
                      child: Shimmer.fromColors(
                        baseColor: Colors.black45,
                        highlightColor: Colors.white,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      height: 35,
                      width: 35,
                      child: Shimmer.fromColors(
                        baseColor: Colors.black45,
                        highlightColor: Colors.white,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 12,
                  width: MediaQuery.of(context).size.width * .4,
                  child: Shimmer.fromColors(
                    baseColor: Colors.black45,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 12,
                      width: MediaQuery.of(context).size.width * .4,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 12,
                  width: MediaQuery.of(context).size.width,
                  child: Shimmer.fromColors(
                    baseColor: Colors.black45,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 12,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 12,
                  width: MediaQuery.of(context).size.width,
                  child: Shimmer.fromColors(
                    baseColor: Colors.black45,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 12,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                SizedBox(
                  height: 8,
                  width: MediaQuery.of(context).size.width * .3,
                  child: Shimmer.fromColors(
                    baseColor: Colors.black45,
                    highlightColor: Colors.white,
                    child: Container(
                      height: 8,
                      width: MediaQuery.of(context).size.width * .5,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
