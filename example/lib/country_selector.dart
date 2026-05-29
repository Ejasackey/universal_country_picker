import 'package:flutter/material.dart';
import 'package:universal_country_picker/universal_country_picker.dart';

class CountrySelector extends StatelessWidget {
  Country? initialCountry;
  BuildContext? mainContext;
  Function(Country)? onSelected;
  CountrySelector({
    super.key,
    this.initialCountry,
    this.onSelected,
    this.mainContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      alignment: .bottomCenter,
      child: UniCountryPicker(
        // context: mainContext,
        labelType: CountryLabelType.nameAndCurrency,
        emptyCountryMessage: "No country found",
        hintText: "Search country",
        // insetPadding: 15,
        overlayAlignment: OverlayAlignment.topLeft,
        overlayHeight: 200,
        builder: (context, Country? country, showOverlay) {
          if (country != null) {
            initialCountry = country;
            onSelected?.call(country);
          }
          return GestureDetector(
            onTap: () => showOverlay(),
            child: Container(
              height: 50,
              padding: EdgeInsets.all(4),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      initialCountry == null
                          ? "Select country"
                          : "${initialCountry!.flag}     ${initialCountry!.name} ${initialCountry!.currencySymbol}",
                      style: TextStyle(
                        color: initialCountry == null
                            ? Colors.grey.shade600
                            : Colors.black,
                        fontVariations: [FontVariation.weight(600)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.green,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
