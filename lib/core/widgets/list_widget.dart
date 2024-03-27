import 'package:flutter/material.dart';

Widget buildListItem(
  BuildContext context, {
  Widget? title,
  Widget? leading,
  Widget? trailing,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 24.0,
      vertical: 16.0,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (leading != null) leading,
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: DefaultTextStyle(
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
              child: title,
            ),
          ),
        const Spacer(),
        if (trailing != null) trailing,
      ],
    ),
  );
}
