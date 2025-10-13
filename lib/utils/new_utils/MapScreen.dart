import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
// import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

class MapSearchScreen extends StatefulWidget {
  @override
  _MapSearchScreenState createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final TextEditingController locationCtr = TextEditingController();
  double? selectedLat;
  double? selectedLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.keyboard_arrow_left),
        ),
        title: const Text(
          "Select Location",
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Styled Search Bar Container
            Row(
              children: [
                // const Icon(Icons.search, color: Colors.black),
                const SizedBox(width: 8),
                // Expanded(
                //   child: GooglePlacesAutoCompleteTextFormField(
                //     textEditingController: locationCtr,
                //     googleAPIKey: "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                //     debounceTime: 400,
                //     fetchCoordinates: true,
                //     decoration: InputDecoration(
                //       prefixIcon: Icon(Icons.search),
                //       hintText: "Search location here",
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(8),
                //         borderSide: BorderSide(color: Colors.grey),
                //       ),
                //       contentPadding:
                //           EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                //     ),
                //     onPlaceDetailsWithCoordinatesReceived: (prediction) {
                //       selectedLat = double.tryParse(prediction.lat.toString());
                //       selectedLng = double.tryParse(prediction.lng.toString());
                //       locationCtr.text = prediction.description!;
                //       locationCtr.selection = TextSelection.fromPosition(
                //         TextPosition(offset: locationCtr.text.length),
                //       );
                //       if (selectedLat != null && selectedLng != null) {
                //         Navigator.pop(context, {
                //           'address': locationCtr.text,
                //           'lat': selectedLat,
                //           'lng': selectedLng,
                //         });
                //       }
                //     },
                //     onSuggestionClicked: (prediction) {
                //       locationCtr.text = prediction.description!;
                //       locationCtr.selection = TextSelection.fromPosition(
                //         TextPosition(offset: prediction.description!.length),
                //       );
                //     },
                //   ),
                // ),
                Expanded(
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: locationCtr,
                    googleAPIKey: "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                    inputDecoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: "Search location...",
                    ),
                    debounceTime: 400,
                    isLatLngRequired: true,
                    getPlaceDetailWithLatLng: (Prediction prediction) {
                      if (prediction.lat != null && prediction.lng != null) {
                        selectedLat = double.tryParse(prediction.lat!);
                        selectedLng = double.tryParse(prediction.lng!);
                        Navigator.pop(context, {
                          'address': prediction.description ?? '',
                          'lat': selectedLat,
                          'lng': selectedLng,
                        });
                      }
                    },
                    itemClick: (Prediction prediction) {
                      locationCtr.text = prediction.description ?? '';
                      locationCtr.selection = TextSelection.fromPosition(
                        TextPosition(offset: locationCtr.text.length),
                      );
                    },
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
