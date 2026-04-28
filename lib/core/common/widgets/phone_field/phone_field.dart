import 'package:fileflow/core/common/widgets/phone_field/countries.dart';
import 'package:fileflow/core/common/widgets/selectable_item_bottom_sheet.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  final int maxLength;

  PhoneNumberFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.length > maxLength) {
      newText = newText.substring(0, maxLength);
    }
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class PhoneField extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final bool isRequired;
  final TextEditingController? controller;
  final String? selectedDialCode;
  final Function(bool isValid, Country? country, String? phoneNumber)? onValidationChanged;
  final bool isEnabled;
  final String? Function(String? phoneNumber, String? countryCode)? validation;
  final EdgeInsetsGeometry padding;

  const PhoneField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.isRequired = false,
    this.selectedDialCode,
    this.onValidationChanged,
    this.isEnabled = true,
    this.validation,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> with SingleTickerProviderStateMixin {
  late final List<SelectableItem<Country>> _countries;
  SelectableItem<Country>? _selectedCountry;
  final TextEditingController _internalController = TextEditingController();
  String? _lastProcessedValue;
  late AnimationController _animationController;
  late Animation<Color?> _backgroundColorAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _errorText;

  TextEditingController get _effectiveController => widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _initializeCountries();
    _setupControllerListener();
    _setupFocusListener();
    _setupAnimation();
    _processInitialValue();
  }

  void _initializeCountries() {
    _countries = countryCodes.map((e) => SelectableItem<Country>(title: '${e.flag} ${e.name}', value: e)).toList();
    _updateSelectedCountry();
  }

  void _updateSelectedCountry() {
    final dialCode = widget.selectedDialCode?.replaceAll('+', '') ?? '91';
    setState(() {
      _selectedCountry = _countries.firstWhere(
        (element) => element.value?.dialCode == dialCode,
        orElse: () => _countries.first,
      );
      _effectiveController.text = '';
      _effectiveController.selection = const TextSelection.collapsed(offset: 0);
    });
  }

  void _setupFocusListener() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  void _setupAnimation() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _backgroundColorAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: AppColors.neutral50.withAlpha((0.1 * 255).toInt()),
        ).animate(_animationController)..addListener(() {
          setState(() {});
        });
  }

  void _setupControllerListener() {
    _effectiveController.addListener(() {
      final newValue = _effectiveController.text;
      if (newValue != _lastProcessedValue) {
        _lastProcessedValue = newValue;
        _processPhoneNumber(newValue);
        _animationController.forward().then((_) => _animationController.reverse());
        if (_focusNode.hasFocus) {
          _effectiveController.selection = TextSelection.collapsed(offset: newValue.length);
        }
      }
    });
  }

  void _processInitialValue() {
    if (_effectiveController.text.isNotEmpty) {
      _processPhoneNumber(_effectiveController.text);
    }
  }

  void _processPhoneNumber(String value) {
    if (value.isEmpty) {
      _triggerValidationCallback(false, _selectedCountry?.value, null);
      return;
    }
    _triggerValidationCallback(true, _selectedCountry?.value, value);
  }

  void _triggerValidationCallback(bool isValid, Country? country, String? phoneNumber) {
    if (widget.onValidationChanged != null) {
      widget.onValidationChanged!(isValid, country, phoneNumber);
    }
  }

  String? _baseValidator(String? value) {
    final digitsOnly = RegExp(r'^\d+$');
    final country = _selectedCountry?.value;
    final maxLength = country?.maxLength ?? 10;

    if (value == null || value.isEmpty) {
      if (widget.isRequired) {
        _errorText = '${widget.labelText} is required field';
        _triggerValidationCallback(false, null, null);
        return _errorText;
      } else {
        _errorText = null;
        _triggerValidationCallback(true, country, null);
        return null;
      }
    }

    if (!digitsOnly.hasMatch(value)) {
      _errorText = 'Only digits are allowed';
      _triggerValidationCallback(false, null, null);
      return _errorText;
    }

    final startingDigits = country?.startingDigits ?? [];
    if (startingDigits.isNotEmpty) {
      final isValidStart = startingDigits.any((prefix) => value.startsWith(prefix));
      if (!isValidStart) {
        _errorText = 'Number must start with ${startingDigits.join(', ')}';
        _triggerValidationCallback(false, country, null);
        return _errorText;
      }
    }

    if (value.length != maxLength || (int.tryParse(value) ?? 0) <= 0) {
      _errorText = 'Invalid contact number';
      _triggerValidationCallback(false, country, null);
      return _errorText;
    }

    _errorText = null;
    _triggerValidationCallback(true, country, value);
    return null;
  }

  @override
  void didUpdateWidget(PhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_setupControllerListener);
      _setupControllerListener();
      _processInitialValue();
    }

    if ((widget.selectedDialCode != oldWidget.selectedDialCode) && (widget.controller?.text.isNotEmpty ?? false)) {
      _updateSelectedCountry();
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_setupControllerListener);
    _focusNode.dispose();
    _animationController.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  double _calculateTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final maxLength = _selectedCountry?.value?.maxLength ?? 10;
    final inputText = _effectiveController.text;
    final inputLength = inputText.replaceAll(RegExp(r'[^0-9]'), '').length;
    final effectiveLength = inputLength > maxLength ? maxLength : inputLength;
    final typedText = inputText.substring(0, effectiveLength);
    final hintZeros = '0' * (maxLength - effectiveLength);
    final isComplete = effectiveLength == maxLength;

    final baseTextStyle = CustomTextStyles.custom15Medium.copyWith(
      height: 1.5,
      textBaseline: TextBaseline.alphabetic,
      leadingDistribution: TextLeadingDistribution.even,
      letterSpacing: 1.2,
      wordSpacing: 2.0,
    );

    final prefixText = ' +${_selectedCountry?.value?.dialCode ?? ''} ${_selectedCountry?.value?.flag ?? ''}';
    final prefixTextWidth = _calculateTextWidth(prefixText, baseTextStyle);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56.0, minWidth: 200.0),
          child: Padding(
            padding: widget.padding,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _backgroundColorAnimation.value,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _isFocused ? AppColors.white : AppColors.white.withAlpha((0.7 * 255).toInt()),
                ),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  if (!isComplete)
                    Transform.translate(
                      offset: Offset(
                        prefixTextWidth + 8 + 4 + 1.5 + 5, // Prefix text + padding + separator + margin
                        0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 13, 0, 12),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: typedText,
                                style: baseTextStyle.copyWith(color: Colors.white),
                              ),
                              TextSpan(
                                text: hintZeros,
                                style: baseTextStyle.copyWith(color: AppColors.white.withAlpha((0.5 * 255).toInt())),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // TextFormField
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _effectiveController,
                    focusNode: _focusNode,
                    autofocus: false,
                    inputFormatters: [PhoneNumberFormatter(maxLength)],
                    decoration: InputDecoration(
                      isDense: false,
                      counterText: '',
                      hintText: '',
                      border: InputBorder.none,
                      errorText: null,
                      errorStyle: const TextStyle(height: 0, fontSize: 0),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SelectableItemBottomSheet(
                              title: 'select country',
                              selectableItems: _countries,
                              selectedItem: _selectedCountry,
                              canSearchItems: true,
                              isEnabled: widget.isEnabled,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(prefixText, style: baseTextStyle.copyWith(color: Colors.white)),
                                  Container(
                                    width: 1.5,
                                    height: 40,
                                    color: Colors.grey.withAlpha((0.3 * 255).toInt()),
                                    margin: const EdgeInsets.only(left: 10, right: 5),
                                  ),
                                ],
                              ),
                              onItemSelected: (selectedValue) {
                                setState(() {
                                  _selectedCountry = selectedValue;
                                  _effectiveController.text = '';
                                  _effectiveController.selection = const TextSelection.collapsed(offset: 0);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    style: baseTextStyle.copyWith(
                      color: isComplete ? Colors.white : Colors.transparent,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                    maxLength: maxLength,
                    readOnly: false,
                    onTap: () {
                      _focusNode.requestFocus();
                      _effectiveController.selection = TextSelection.collapsed(offset: _effectiveController.text.length);
                    },
                    enabled: widget.isEnabled,
                    cursorColor: AppColors.white,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        _triggerValidationCallback(false, _selectedCountry?.value, null);
                      }
                      setState(() {});
                    },
                    validator: (value) {
                      _baseValidator(value);
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
