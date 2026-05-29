import 'package:example/country_selector.dart';
import 'package:flutter/material.dart';
import 'package:universal_country_picker/universal_country_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Country Picker Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Color(0xFF1D9A98))),
      home: const MyHomePage(title: 'Universal Country Picker Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Country? selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color(0xFF1D9A98),
      //   title: Text(widget.title, style: TextStyle(color: Colors.white)),
      // ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: .spaceBetween,
          children: [
            Align(alignment: .topLeft, child: CountrySelector()),
            SizedBox(height: 20),
            countrySelector(
              context,
              alignment: OverlayAlignment.bottomLeft,
              labelType: CountryLabelType.nameAndPhoneCode,
            ),
            Align(
              alignment: .bottomRight,
              child: countrySelector(context, alignment: .bottomLeft),
            ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------
  Widget countrySelector(
    BuildContext context, {
    OverlayAlignment alignment = OverlayAlignment.topLeft,
    CountryLabelType labelType = CountryLabelType.nameAndCurrency,
  }) {
    return UniCountryPicker(
      // scaffoldContext: context,
      labelType: labelType,
      emptyCountryMessage: "No Country Found",
      hintText: "Search country",
      // insetPadding: 15,
      overlayAlignment: alignment,
      overlayHeight: 300,
      initialCountry: Country.ghana,
      showWorldWideOption: true,
      countryItemStyle: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: .circular(100)),
      ),
      builder: (context, Country? country, showOverlay) {
        if (country != null) {
          selectedCountry = country;
        }
        return GestureDetector(
          onTap: () => showOverlay(),
          child: Container(
            height: 55,

            padding: EdgeInsets.all(4),
            width: 300,
            decoration: BoxDecoration(
              color: Color(0xFFECF7F7),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCountry == null
                        ? "Select Country"
                        : "${selectedCountry!.flag}     ${selectedCountry!.name} ${selectedCountry!.currencySymbol}",
                    style: TextStyle(
                      color: selectedCountry == null
                          ? Colors.grey.shade600
                          : Color(0xFF424242),
                      fontVariations: [FontVariation.weight(600)],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF1D9A98),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
