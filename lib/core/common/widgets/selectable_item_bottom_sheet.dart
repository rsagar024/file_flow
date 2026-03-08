import 'package:fileflow/core/common/shapes/sharp_divider_painter.dart';
import 'package:fileflow/core/extensions/string_extension.dart';
import 'package:fileflow/core/extensions/widget_extension.dart';
import 'package:fileflow/core/resources/common/image_resources.dart';
import 'package:fileflow/core/themes/text_styles.dart';
import 'package:fileflow/core/utilities/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SelectableItemBottomSheet<T> extends StatefulWidget {
  final String title;
  final Function(SelectableItem<T> selectedValue)? onItemSelected;
  final Function(List<SelectableItem<T>> selectedValues)? onItemsSelected;
  final List<SelectableItem<T>> selectableItems;
  final SelectableItem<T>? selectedItem;
  final List<SelectableItem<T>>? initialSelectedItems;
  final bool isMultipleSelection;
  final bool canSearchItems;
  final String searchHintText;
  final Widget? child;
  final EdgeInsets childPadding;
  final bool isEnabled;
  final bool saveSelectedValues;
  final String? disabledSnackBarMessage;
  final bool canAddNewItems;

  const SelectableItemBottomSheet({
    super.key,
    required this.title,
    required this.selectableItems,
    this.onItemSelected,
    this.onItemsSelected,
    this.selectedItem,
    this.initialSelectedItems,
    this.isMultipleSelection = false,
    this.canSearchItems = false,
    this.child,
    this.childPadding = EdgeInsets.zero,
    this.searchHintText = 'Search item here',
    this.isEnabled = true,
    this.saveSelectedValues = true,
    this.disabledSnackBarMessage,
    this.canAddNewItems = false,
  }) : assert(
         (isMultipleSelection && onItemsSelected != null) || (!isMultipleSelection && onItemSelected != null),
         'Provide onItemSelected for single selection or onItemsSelected for multiple selection',
       );

  @override
  State<StatefulWidget> createState() => _SelectableItemBottomSheetState<T>();
}

class _SelectableItemBottomSheetState<T> extends State<SelectableItemBottomSheet<T>> {
  late List<SelectableItem<T>> _items;
  late List<SelectableItem<T>> _filteredItems;
  late List<SelectableItem<T>> _selectedItems;
  late List<SelectableItem<T>> _tempSelectedItems;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

  @override
  void didUpdateWidget(SelectableItemBottomSheet<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectableItems != widget.selectableItems ||
        oldWidget.selectedItem != widget.selectedItem ||
        oldWidget.initialSelectedItems != widget.initialSelectedItems) {
      _initializeItems();
    }
  }

  void _initializeItems() {
    _items = List.from(widget.selectableItems);
    _filteredItems = List.from(_items);
    _selectedItems = widget.isMultipleSelection
        ? (widget.initialSelectedItems != null ? List.from(widget.initialSelectedItems!) : [])
        : (widget.selectedItem != null ? [widget.selectedItem!] : []);
    _tempSelectedItems = List.from(_selectedItems);
    _searchController = TextEditingController();

    for (var item in _selectedItems) {
      final index = _items.indexWhere((element) => element.value == item.value);
      if (index != -1) {
        _items[index].isSelected = true;
      }
    }
    _updateFilteredItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchItems(String value) {
    setState(() {
      if (value.length > 1) {
        _filteredItems = _items.where((element) => element.title.toLowerCase().contains(value.toLowerCase())).toList();
      } else {
        _updateFilteredItems();
      }
    });
  }

  void _updateFilteredItems() {
    _filteredItems = [
      ...(widget.saveSelectedValues ? _tempSelectedItems : []),
      ..._items.where((item) => !_tempSelectedItems.contains(item)),
    ];
  }

  void _toggleItemSelection(SelectableItem<T> item) {
    setState(() {
      if (widget.isMultipleSelection) {
        item.isSelected = !item.isSelected;
        if (item.isSelected) {
          _tempSelectedItems.add(item);
        } else {
          _tempSelectedItems.removeWhere((element) => element.value == item.value);
        }
      } else {
        _tempSelectedItems.clear();
        _tempSelectedItems.add(item);
        for (var element in _items) {
          element.isSelected = element.value == item.value;
        }
      }
    });
  }

  void _addNewItem(String newItemTitle) {
    if (newItemTitle.trim().isEmpty) {
      return;
    }
    setState(() {
      final newItem = SelectableItem<T>(title: newItemTitle, value: '${newItemTitle}_${_items.length}' as T);
      _items.add(newItem);
      _toggleItemSelection(newItem);
      _updateFilteredItems();
    });
  }

  void _showItemListModal(BuildContext context) {
    if ((!widget.isEnabled || _filteredItems.isEmpty) && !(widget.canAddNewItems)) {
      if (widget.disabledSnackBarMessage?.isNotNullOrEmpty ?? false) {
        CustomSnackbar.show(type: SnackbarType.error, message: widget.disabledSnackBarMessage!);
      }
      return;
    }
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
          context: context,
          isDismissible: !widget.isMultipleSelection,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(0.0))),
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DraggableScrollableSheet(
                    initialChildSize: 0.5,
                    minChildSize: 0.4,
                    maxChildSize: 0.5,
                    expand: false,
                    builder: (_, scrollController) {
                      return PopScope(
                        canPop: false,
                        // onPopInvoked: (didPop) {
                        //   if (didPop) {
                        //     _tempSelectedItems = List.from(_selectedItems);
                        //     _updateFilteredItems();
                        //     return;
                        //   }
                        // },
                        onPopInvokedWithResult: (didPop, result) {
                          if (didPop) {
                            _tempSelectedItems = List.from(_selectedItems);
                            _updateFilteredItems();
                            return;
                          }
                        },
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header
                              Container(
                                width: MediaQuery.of(context).size.width,
                                color: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.title,
                                        style: CustomTextStyles.custom14Bold.copyWith(
                                          color: Colors.black,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _tempSelectedItems = List.from(_selectedItems);
                                          _updateFilteredItems();
                                          Navigator.pop(context);
                                        },
                                        child: SvgPicture.asset(ImageResources.iconMore),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CustomPaint(size: const Size(double.infinity, 4), painter: SharpDividerPainter()),
                              // Search bar (if enabled)
                              if (widget.canSearchItems)
                                Container(
                                  height: 50,
                                  padding: const EdgeInsets.only(left: 24, right: 14, top: 10),
                                  child: TextField(
                                    controller: _searchController,
                                    cursorColor: Colors.black,
                                    style: CustomTextStyles.custom12Medium.copyWith(color: Colors.black),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchItems(value);
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: widget.searchHintText,
                                      hintStyle: CustomTextStyles.custom11Regular.copyWith(color: Colors.grey),
                                      prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                                      suffixIcon: _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                                              onPressed: () {
                                                setState(() {
                                                  _searchController.clear();
                                                  _updateFilteredItems();
                                                });
                                              },
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              // List of items
                              Expanded(
                                child: (_filteredItems.isEmpty)
                                    ? _buildEmptyWidget()
                                    : ListView.builder(
                                        controller: scrollController,
                                        itemCount: _filteredItems.length,
                                        itemBuilder: (context, index) {
                                          final item = _filteredItems[index];
                                          return Column(
                                            children: [
                                              ListTile(
                                                visualDensity: const VisualDensity(vertical: -3),
                                                contentPadding: const EdgeInsets.only(left: 24, right: 14),
                                                title: Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: item.title,
                                                        style: CustomTextStyles.custom12Regular.copyWith(
                                                          color: _tempSelectedItems.contains(item)
                                                              ? Colors.black
                                                              : (item.isEnabled)
                                                              ? Colors.grey
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                      if (!item.isEnabled)
                                                        TextSpan(
                                                          text: '  (disabled)',
                                                          style: CustomTextStyles.custom10Light.copyWith(
                                                            color: _tempSelectedItems.contains(item)
                                                                ? Colors.black
                                                                : Colors.red,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                trailing: _tempSelectedItems.contains(item)
                                                    ? Container(
                                                        alignment: Alignment.center,
                                                        width: 22,
                                                        height: 22,
                                                        margin: const EdgeInsets.only(right: 8),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(100),
                                                          border: Border.all(color: Colors.black, width: 1.5),
                                                        ),
                                                        child: const Icon(
                                                          Icons.check_rounded,
                                                          color: Colors.black,
                                                          size: 16,
                                                        ),
                                                      )
                                                    : null,
                                                onTap: () {
                                                  FocusScope.of(context).unfocus();
                                                  if (!item.isEnabled) return;
                                                  setState(() {
                                                    _toggleItemSelection(item);
                                                  });
                                                  if (!widget.isMultipleSelection) {
                                                    widget.onItemSelected?.call(item);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                              ),
                                              if (index != _filteredItems.length - 1)
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 25),
                                                  child: Divider(color: Colors.black, thickness: .2, height: .5),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                              ),
                              // Footer buttons for multiple selection mode
                              if (widget.isMultipleSelection)
                                Container(
                                  padding: const EdgeInsets.only(left: 24, right: 14, top: 10, bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withAlpha((.4 * 255).toInt()),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _tempSelectedItems = List.from(_selectedItems);
                                          _updateFilteredItems();
                                          FocusScope.of(context).unfocus();
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Cancel',
                                          style: CustomTextStyles.custom11Medium.copyWith(
                                            color: Colors.black,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          _selectedItems = List.from(_tempSelectedItems);
                                          widget.onItemsSelected?.call(_selectedItems);
                                          FocusScope.of(context).unfocus();
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          backgroundColor: Colors.black,
                                        ),
                                        child: Text(
                                          'Save',
                                          style: CustomTextStyles.custom12Medium.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        )
        .whenComplete(() {
          FocusManager.instance.primaryFocus?.unfocus();
        })
        .then((_) {
          setState(() {
            if (widget.isMultipleSelection) {
              _tempSelectedItems = List.from(_selectedItems);
              for (var filterElement in _filteredItems) {
                filterElement.isSelected = _selectedItems.any(
                  (selectedElement) =>
                      selectedElement.value == filterElement.value || selectedElement.title == filterElement.title,
                );
              }
            } else {
              _selectedItems = List.from(_tempSelectedItems);
            }
            _updateFilteredItems();
          });
        });
    _searchController.text = '';
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return GestureDetector(onTap: () => _showItemListModal(context), child: widget.child!);
    }
    return GestureDetector(
      onTap: () => _showItemListModal(context),
      child: Padding(
        padding: widget.childPadding,
        child: Container(
          padding: const EdgeInsets.only(left: 24, right: 18, top: 11, bottom: 11),
          decoration: BoxDecoration(color: Colors.white60, borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedItems.isEmpty
                    ? 'Select'
                    : _selectedItems.length == 1
                    ? _selectedItems.first.title
                    : '${_selectedItems.length} items selected',
                style: CustomTextStyles.custom12Regular.copyWith(color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).withFlexible(),
              const SizedBox(width: 10),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    if (widget.canAddNewItems && _searchController.text.trim().isNotEmpty) {
      return ListTile(
        contentPadding: const EdgeInsets.only(left: 24, right: 14),
        onTap: () {
          final newItemTitle = _searchController.text.trim();
          FocusManager.instance.primaryFocus?.unfocus();
          _addNewItem(newItemTitle);
          _searchController.clear();
          setState(() {});
        },
        title: Text(_searchController.text.trim(), style: CustomTextStyles.custom12Medium.copyWith(color: Colors.grey)),
        trailing: const Icon(Icons.add_circle_outline, color: Colors.black),
      );
    }
    return Center(
      child: Text(
        'No data found\ntry again later',
        style: CustomTextStyles.custom10SemiBold.copyWith(color: Colors.black),
      ),
    );
  }
}

class SelectableItem<T> {
  final String title;
  final bool isEnabled;
  bool isSelected;
  final T? value;

  SelectableItem({required this.title, this.isSelected = false, this.value, this.isEnabled = true});

  SelectableItem<T> copyWith({String? title, bool? isSelected, T? value, bool? isEnabled}) {
    return SelectableItem(
      title: title ?? this.title,
      isSelected: isSelected ?? this.isSelected,
      value: value ?? this.value,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
