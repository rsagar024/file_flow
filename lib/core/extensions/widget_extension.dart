import 'package:fileflow/core/themes/text_styles.dart';
import 'package:flutter/material.dart';

extension TextWidgetExtension on Text {
  Widget appendDot({TextOverflow overflow = TextOverflow.ellipsis}) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              data ?? '',
              style: style,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow,
              softWrap: softWrap,
              textDirection: textDirection,
              locale: locale,
              strutStyle: strutStyle,
            ),
          ),
          const SizedBox(width: 6),
          Text('\u2022', style: CustomTextStyles.custom10Bold.copyWith(color: Colors.grey)),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget withFlexible({TextOverflow overflow = TextOverflow.ellipsis}) {
    return Flexible(
      child: Text(
        data ?? '',
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        softWrap: softWrap,
      ),
    );
  }
}
