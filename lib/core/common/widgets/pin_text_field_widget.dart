import 'dart:async';

import 'package:fileflow/core/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinTextFieldWidget extends StatefulWidget {
  final int length;
  final TextEditingController controller = TextEditingController();

  PinTextFieldWidget({super.key, this.length = 4});

  @override
  State<PinTextFieldWidget> createState() => _PinTextFieldWidgetState();
}

class _PinTextFieldWidgetState extends State<PinTextFieldWidget> {
  late FocusNode _focusNode;
  late List<String> _pinValues;
  late List<String> _obsValues;
  late List<Timer?> _timers;
  int _currentFocusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _pinValues = List.filled(widget.length, '');
    _obsValues = List.filled(widget.length, '');
    _timers = List.filled(widget.length, null);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    for (var timer in _timers) {
      timer?.cancel();
    }
    widget.controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    String text = widget.controller.text;

    // Limit the input to the widget's length
    if (text.length > widget.length) {
      widget.controller.text = text.substring(0, widget.length);
      return;
    }

    for (int i = 0; i < widget.length; i++) {
      if (i == text.length - 1) {
        // Show only the last entered digit
        _pinValues[i] = text[i];
        _obsValues[i] = text[i]; // Show current digit initially

        // Cancel any existing timer for this index
        _timers[i]?.cancel();

        // Set a timer to replace the digit with a star after 0.2 seconds
        _timers[i] = Timer(const Duration(milliseconds: 200), () {
          if (widget.controller.text == text) {
            // Ensure text hasn't changed
            setState(() {
              _obsValues[i] = '*';
            });
          }
        });
      } else if (i >= text.length) {
        // Clear values for indexes not yet filled
        _pinValues[i] = '';
        _obsValues[i] = '';
        _timers[i]?.cancel(); // Cancel any existing timer
      } else {
        // Ensure all previous digits remain stars
        if (_pinValues[i].isNotEmpty) {
          _obsValues[i] = '*';
        }
      }
    }

    // Update the current focused index
    _currentFocusedIndex = text.length.clamp(0, widget.length - 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildPinBoxes(), // Visual PIN boxes
        Container(
          width: _calculateTotalWidth(),
          height: 60,
          alignment: Alignment.center,
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLength: widget.length,
            keyboardType: TextInputType.number,
            enableInteractiveSelection: false,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 1, color: Colors.transparent),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(vertical: 20),
            ),
            cursorColor: Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildPinBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length * 2 - 1, (index) {
        if (index.isOdd) return const SizedBox(width: 12);
        final boxIndex = index ~/ 2;
        return _buildSinglePinBox(boxIndex);
      }),
    );
  }

  Widget _buildSinglePinBox(int index) {
    return Container(
      width: 42,
      height: 52,
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.3 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: index == _currentFocusedIndex ? Colors.white : Colors.transparent, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        _obsValues[index],
        style: CustomTextStyles.baseStyle.copyWith(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
      ),
    );
  }

  double _calculateTotalWidth() {
    const boxWidth = 42;
    const spacing = 12;
    return (widget.length * boxWidth) + ((widget.length - 1) * spacing).toDouble();
  }
}
