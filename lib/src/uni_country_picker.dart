import 'package:flutter/material.dart';
import 'package:universal_country_picker/src/country.dart';

enum CountryLabelType {
  nameOnly,
  phoneCodeOnly,
  currencyOnly,
  nameAndCurrency,
  nameAndPhoneCode,
  countryCodeOnly,
}

enum OverlayAlignment { topRight, topLeft, bottomRight, bottomLeft }

// ignore: must_be_immutable
class UniCountryPicker extends StatefulWidget {
  bool showWorldWideOption;
  CountryLabelType labelType;
  double? overlayHeight;
  double? overlayWidth;
  Country? initialCountry;
  bool showFlag;
  OverlayAlignment overlayAlignment;
  late Duration openAnimationDuration;
  late Duration closeAnimationDuration;
  late Curve openAnimationCurve;
  late Curve closeAnimationCurve;
  EdgeInsets overlayPadding;
  late BoxDecoration overlayDeco;

  /// This is the space between the edge of the screen
  /// and the dialog in case  the dialog overflows beyond
  /// the screen
  double insetPadding;

  TextStyle searchTextStyle;
  Widget? searchHint;
  String hintText;
  TextStyle? hintStyle;
  InputBorder? searchBorder;

  /// Defines the button style of the TextButton widget used to render each country in the list.
  /// The style is merged with the default style defined in the package, so you can override specific properties without losing the default styling. For example, if you want to change only the padding of the country items, you can provide a TextButton.styleFrom with just the padding property set, and it will keep the other default styles intact.
  ButtonStyle? countryItemStyle;
  double flagSize;

  /// This is the style of the country name text in the list. It is merged with a default TextStyle. You can provide your own TextStyle to customize the appearance of the country names, and it will override the default values while keeping any properties you don't specify intact.
  TextStyle? countryNameStyle;

  ///This is the style of the phone code text in the list. There is no default style so you need to provide a complete TextStyle if you want to customize it.
  TextStyle? phoneCodeStyle;

  ///This is the style of the currency symbol text in the list. There is not default style so you need to provide a complete TextStyle if you want to customize it.
  TextStyle? currencySymbolStyle;

  ///This is the style of the country code text in the list. There is no default style so you need to provide a complete TextStyle if you want to customize it.
  TextStyle? countryCodeStyle;

  /// Countries to exclude from the list.
  List<Country> excludeCountries;

  ///Exclude all countries except these from the list.
  List<Country> onlyTheseCountries;

  /// This context must be from a scaffold widget to register keyboard inset.
  /// Only provide if you need the overlay to reposition when keyboard is opened
  BuildContext? scaffoldContext;

  /// use `showOverlay` to display the country list overlay when the child widget is tapped.
  Widget Function(
    BuildContext context,
    Country? selectedCountry,
    Function showOverlay,
  )
  builder;

  ///Added this just in case your app supports multiple languages
  ///and you need to add custom empty state message
  String emptyCountryMessage;

  /// This is the space between the child widget and the overlay
  double overlayOffset;

  ButtonStyle clearIconButtonStyle;
  double clearIconSize;
  Widget clearIcon;

  UniCountryPicker({
    super.key,
    this.showWorldWideOption = false,
    this.labelType = CountryLabelType.nameOnly,
    this.overlayHeight,
    this.initialCountry,
    BoxDecoration? decoration,
    this.overlayWidth,
    required this.builder,
    this.showFlag = true,
    this.overlayAlignment = OverlayAlignment.bottomLeft,
    this.openAnimationDuration = const Duration(milliseconds: 500),
    this.closeAnimationDuration = const Duration(milliseconds: 250),
    this.openAnimationCurve = Curves.easeOutCubic,
    this.closeAnimationCurve = Curves.easeOutCubic,
    this.insetPadding = 10,
    this.overlayPadding = const EdgeInsets.only(left: 10, right: 10, top: 10),
    BoxDecoration? overlayDeco,
    this.searchTextStyle = const TextStyle(fontSize: 15),
    this.hintText = "Search country",
    this.emptyCountryMessage = "No country found",
    this.hintStyle = const TextStyle(color: Colors.grey),
    this.searchHint,
    this.searchBorder,
    this.countryItemStyle,
    this.flagSize = 14,
    this.countryNameStyle,
    this.phoneCodeStyle,
    this.currencySymbolStyle,
    this.countryCodeStyle,
    this.excludeCountries = const [],
    this.onlyTheseCountries = const [],
    this.scaffoldContext,
    this.overlayOffset = 8,
    this.clearIconButtonStyle = const ButtonStyle(),
    this.clearIconSize = 22,
    this.clearIcon = const Icon(Icons.clear_rounded),
  }) {
    this.overlayDeco =
        overlayDeco ??
        BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              offset: Offset(2, 2),
              color: Colors.black12,
              blurRadius: 12,
            ),
          ],
        );
  }

  // // 1. The static hidden key that will anchor to the root of the app
  // static final GlobalKey _rootKey = GlobalKey();

  // /// 2. The configuration method the user places in MaterialApp's builder
  // static Widget init(BuildContext context, Widget? child) {
  //   return Container(key: _rootKey, child: child ?? const SizedBox.shrink());
  // }

  // /// 3. The public/internal getter to grab the root context anywhere
  // BuildContext get globalContext {
  //   if (scaffoldContext != null) {
  //     return scaffoldContext!;
  //   }
  //   final ctx = _rootKey.currentContext;
  //   if (ctx == null) {
  //     throw FlutterError(
  //       'UniCountryPicker Error: Root context is null.\n'
  //       'Make sure to add "UniCountryPicker.init" to your MaterialApp`s builder field.\n',
  //     );
  //   }
  //   return ctx;
  // }

  @override
  State<UniCountryPicker> createState() => _UniCountryPickerState();
}

class _UniCountryPickerState extends State<UniCountryPicker>
    with SingleTickerProviderStateMixin {
  TextEditingController countrySearchController = TextEditingController(
    text: "",
  );

  final GlobalKey _countrySelectorKey = GlobalKey();
  final GlobalKey _searchBarKey = GlobalKey();

  late Size screenSize;
  double safeAreaTop = 0;
  double safeAreaBottom = 0;
  late OverlayPortalController overlayController;
  late Animation<double> overlayAnimation;
  late AnimationController _animationController;

  void showOverlay() {
    overlayController.toggle();
    _animationController.forward();
  }

  void hideOverlay() async {
    _animationController.reverse();
    await Future.delayed(widget.closeAnimationDuration);
    await Future.delayed(Duration(milliseconds: 10));
    overlayController.hide();
    countrySearchController.clear();
  }

  @override
  void initState() {
    super.initState();
    overlayController = OverlayPortalController();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.openAnimationDuration,
      reverseDuration: widget.closeAnimationDuration,
    );
    overlayAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.openAnimationCurve,
        reverseCurve: widget.closeAnimationCurve,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.searchBorder == null) {
        widget.searchBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            width: .8,
            color: Theme.of(context).primaryColor,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.sizeOf(context);
    safeAreaTop = MediaQuery.viewPaddingOf(context).top;
    safeAreaBottom = MediaQuery.viewPaddingOf(context).bottom;
    return OverlayPortal(
      controller: overlayController,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (context) {
        RenderBox childBox =
            _countrySelectorKey.currentContext?.findRenderObject() as RenderBox;
        Offset position = childBox.localToGlobal(Offset.zero);

        //
        if (widget.overlayWidth == null) {
          widget.overlayWidth = childBox.size.width;
        }

        double x =
            position.dx -
            (widget.overlayAlignment == OverlayAlignment.bottomRight ||
                    widget.overlayAlignment == OverlayAlignment.topRight
                ? (widget.overlayWidth! - childBox.size.width)
                : 0);

        //TOP ALIGNMENT CALCULATIONS FOR Y COORDINATE AND DEFAULT
        // OVERLAY HEIGHT
        double y = position.dy;
        if (widget.overlayAlignment == OverlayAlignment.topLeft ||
            widget.overlayAlignment == OverlayAlignment.topRight) {
          if (widget.overlayHeight == null) {
            // calculate auto height
            // which is the remaining space between
            // the child widget and top boundary
            widget.overlayHeight =
                y - widget.overlayOffset - safeAreaTop - widget.insetPadding;
          }
          y = y - widget.overlayOffset - widget.overlayHeight!;
        }
        //BOTTOM ALIGNMENT CALCULATIONS
        else {
          y = position.dy + childBox.size.height + widget.overlayOffset;
          if (widget.overlayHeight == null) {
            // calculate auto height
            // which is the remaining space between
            // the child widget and bottom boundary
            if (widget.overlayAlignment == OverlayAlignment.bottomRight ||
                widget.overlayAlignment == OverlayAlignment.bottomLeft) {
              widget.overlayHeight =
                  screenSize.height - y - widget.insetPadding - safeAreaBottom;
            }
          }
        }

        // ensure overlay height and width is lower than screenSize--------
        if (widget.overlayHeight! >= screenSize.height) {
          // in recalculating the height we've to subtract two
          // times the insetPadding so it's half the amount up and down
          // more like a symmetric vertical padding of `insetPadding`/2
          widget.overlayHeight =
              screenSize.height -
              (widget.insetPadding * 2) -
              (safeAreaTop + safeAreaBottom);
        }

        if (widget.overlayWidth! >= screenSize.width) {
          widget.overlayWidth = screenSize.width - (widget.insetPadding * 2);
        }

        // Check Right Boundary--------------------------------------------
        if (x + widget.overlayWidth! >= screenSize.width) {
          // send x to the right edge of the screen
          // move it back by overlaywidth
          // move it further back by padding
          x =
              screenSize.width -
              widget.overlayWidth! -
              widget.insetPadding; //padding from edge
        }

        // Check Left Boundary
        if (x < 0) x = widget.insetPadding;

        // Check Top  Boundary
        if (y <= safeAreaTop) y = widget.insetPadding + safeAreaTop;

        // Check Bottom Boundary
        if (y + widget.overlayHeight! > screenSize.height) {
          // calculate how much has entered into the bottom
          // move y up by that amount, add a little padding and the bottom save area
          double offset = (y + widget.overlayHeight!) - screenSize.height;
          y = y - offset - widget.insetPadding - safeAreaBottom;
        }

        // OFFSET OVERLAY IF COVERED BY KEYBOARD--------------------------
        RenderBox searchBarBox =
            _countrySelectorKey.currentContext?.findRenderObject() as RenderBox;
        // Offset searchBarPosition = childBox.localToGlobal(Offset.zero);
        double bottomInset = MediaQuery.viewInsetsOf(
          widget.scaffoldContext ?? context,
        ).bottom;
        // search bar edge is the y coordinate + the padding around the text field
        // + the height of the search bar.
        // I am multiplying the overlayPadding by 2, because there's no bottomPadding
        // so in order to get equal distance at the top and bottom of the search bar
        // I have to multiply it by 2.
        double searchBarEdge =
            y + (widget.overlayPadding.vertical * 2) + searchBarBox.size.height;
        // the searchBar's y coordinate from bottom
        double searchBarEdgeFromBottom = screenSize.height - searchBarEdge;
        double searchBarOffset = searchBarEdgeFromBottom - bottomInset;
        // log('SEARCH BAR OFFSET: $searchBarOffset');
        // log('SAVE AREA BOTTOM: $safeAreaBottom');
        // log('SAVE AREA TOP: $safeAreaBottom');

        if (searchBarOffset <= 0) {
          // move overlay up by  `offset` amount and some extra space
          // we're adding because offset is negative.
          y = y + searchBarOffset;
        }

        return Stack(
          children: [
            GestureDetector(
              onTap: () async {
                hideOverlay();
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              top: y,
              left: x,
              child: AnimatedBuilder(
                animation: overlayAnimation,
                builder: (context, child) {
                  return Container(
                    width: widget.overlayWidth,
                    height:
                        (widget.overlayHeight ?? 300) * overlayAnimation.value,
                    padding: widget.overlayPadding,
                    decoration: widget.overlayDeco,
                    child: countryListView(),
                  );
                },
              ),
            ),
          ],
        );
      },
      child: SizedBox(
        key: _countrySelectorKey,
        child: widget.builder(context, widget.initialCountry, showOverlay),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------
  InputBorder defaultSearchBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(width: .8, color: Theme.of(context).primaryColor),
  );

  //--------------------------------------------------------------------------------------------
  StatefulBuilder countryListView() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        // search algorithm
        List<Country> countries = [...Country.all];
        // List<Country> countries = countriesMap
        //     .map((e) => Country.fromMap(e))
        //     .toList();
        if (countrySearchController.text.isNotEmpty) {
          countries = countries
              .where(
                (e) =>
                    e.name.toLowerCase().startsWith(
                      countrySearchController.text.toLowerCase(),
                    ) ||
                    e.countryCode.toLowerCase().contains(
                      countrySearchController.text.toLowerCase(),
                    ),
              )
              .toList();
        }
        if (widget.onlyTheseCountries.isNotEmpty) {
          countries = widget.onlyTheseCountries;
        }
        if (widget.excludeCountries.isNotEmpty) {
          countries.removeWhere(
            (e) => widget.excludeCountries
                .map((e) => e.countryCode)
                .contains(e.countryCode),
          );
        }
        if (!widget.showWorldWideOption) {
          countries.removeWhere((e) => e.countryCode.isEmpty);
        }

        //
        return Column(
          children: [
            TextField(
              key: _searchBarKey,
              controller: countrySearchController,
              onChanged: (val) {
                setDialogState(() {});
              },
              style: widget.searchTextStyle,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: widget.searchHint == null ? widget.hintText : null,
                hintStyle: widget.searchHint == null
                    ? widget.searchTextStyle.merge(widget.hintStyle)
                    : null,
                hint: widget.searchHint,
                suffixIcon: countrySearchController.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: IconButton(
                          style: widget.clearIconButtonStyle.merge(
                            IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              foregroundColor: Color(0xFF424242),
                            ),
                          ),
                          onPressed: () => setDialogState(
                            () => countrySearchController.clear(),
                          ),
                          icon: widget.clearIcon,
                          iconSize: widget.clearIconSize,
                        ),
                      )
                    : null,
                enabledBorder: widget.searchBorder ?? defaultSearchBorder(),
                focusedBorder: widget.searchBorder ?? defaultSearchBorder(),
                border: widget.searchBorder ?? defaultSearchBorder(),
              ),
            ),
            Expanded(
              child: countries.isEmpty
                  ? Center(child: Text(widget.emptyCountryMessage))
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      itemCount: countries.length,
                      itemBuilder: (context, index) {
                        if (countries[index].countryCode.isEmpty) {
                          return Column(
                            children: [
                              countryItem(Country.worldWide),
                              Divider(color: Colors.grey.shade400),
                            ],
                          );
                        }
                        return countryItem(countries[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  //--------------------------------------------------------------------------------------------
  StatefulBuilder countryItem(Country e) {
    bool hovered = false;
    return StatefulBuilder(
      builder: (context, setButtonState) {
        return TextButton(
          style: (widget.countryItemStyle ?? TextButton.styleFrom()).merge(
            TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              foregroundColor: Color(0xFF424242),
              overlayColor: Theme.of(context).primaryColor,
              backgroundColor: hovered
                  ? Theme.of(context).primaryColor.withValues(alpha: .07)
                  : null,
            ),
          ),
          onPressed: () async {
            widget.initialCountry = e;
            setState(() {});
            hideOverlay();
          },
          onHover: (val) {
            hovered = val;
            setButtonState(() {});
          },
          child: Row(
            children: [
              if (widget.showFlag) ...[
                Text(e.flag, style: TextStyle(fontSize: widget.flagSize)),
                SizedBox(width: 10),
              ],
              if (widget.labelType != CountryLabelType.countryCodeOnly &&
                  widget.labelType != CountryLabelType.currencyOnly &&
                  widget.labelType != CountryLabelType.phoneCodeOnly) ...[
                Expanded(
                  child: Text(
                    e.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: (widget.countryNameStyle ?? TextStyle()).merge(
                      TextStyle(
                        fontSize: 16,
                        fontVariations: [FontVariation.weight(500)],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
              ],
              if (widget.labelType == CountryLabelType.phoneCodeOnly ||
                  widget.labelType == CountryLabelType.nameAndPhoneCode)
                Text(e.phoneCode, style: widget.phoneCodeStyle),
              if (widget.labelType == CountryLabelType.currencyOnly ||
                  widget.labelType == CountryLabelType.nameAndCurrency)
                Text(e.currencySymbol, style: widget.currencySymbolStyle),
              if (widget.labelType == CountryLabelType.countryCodeOnly)
                Text(e.countryCode, style: widget.countryCodeStyle),
            ],
          ),
        );
      },
    );
  }
}
