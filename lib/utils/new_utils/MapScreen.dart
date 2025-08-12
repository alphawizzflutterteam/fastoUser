import 'package:flutter/material.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.keyboard_arrow_left),
        ),
        title: const Text(
          "Select Location",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Styled Search Bar Container
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GooglePlacesAutoCompleteTextFormField(
                      textEditingController: locationCtr,
                      googleAPIKey: "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                      debounceTime: 400,
                      fetchCoordinates: true,
                      onPlaceDetailsWithCoordinatesReceived: (prediction) {
                        selectedLat =
                            double.tryParse(prediction.lat.toString());
                        selectedLng =
                            double.tryParse(prediction.lng.toString());
                        locationCtr.text = prediction.description!;
                        locationCtr.selection = TextSelection.fromPosition(
                          TextPosition(offset: locationCtr.text.length),
                        );

                        if (selectedLat != null && selectedLng != null) {
                          Navigator.pop(context, {
                            'address': locationCtr.text,
                            'lat': selectedLat,
                            'lng': selectedLng,
                          });
                        }
                      },
                      onSuggestionClicked: (prediction) {
                        locationCtr.text = prediction.description!;
                        locationCtr.selection = TextSelection.fromPosition(
                          TextPosition(offset: prediction.description!.length),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
