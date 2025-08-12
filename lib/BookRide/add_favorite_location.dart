import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:pristine_andaman/Components/custom_button.dart';
import 'package:pristine_andaman/Components/entry_field.dart';
import 'package:pristine_andaman/utils/ApiBaseHelper.dart';
import 'package:pristine_andaman/utils/Session.dart';
import 'package:pristine_andaman/utils/constant.dart';
import 'package:pristine_andaman/utils/new_utils/ui.dart';

class AddFavoriteLocation extends StatefulWidget {
  @override
  _AddFavoriteLocationState createState() => _AddFavoriteLocationState();
}

class _AddFavoriteLocationState extends State<AddFavoriteLocation> {
  TextEditingController addressTypeController = TextEditingController();
  ApiBaseHelper apiBase = new ApiBaseHelper();
  double totalBal = 0;
  double minimumBal = 0;
  bool isNetwork = false;
  bool saveStatus = false;
  addAddress() async {
    try {
      setState(() {
        saveStatus = true;
      });
      Map params = {
        "user_id": curUserId.toString(),
        "address": addressController.text,
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "type": addressTypeController.text.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "authentication/create_favourite_addressess"),
          params);
      setState(() {
        saveStatus = false;
      });
      if (response['status']) {
        UI.setSnackBar(response['message'], context, color: Colors.green);
        back(context);
      } else {
        UI.setSnackBar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getSupportList();
  }

  TextEditingController addressController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Add Favorite Location',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
      // drawer: AppDrawer(false),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EntryField(
              prefixIcon: Icons.home,
              controller: addressTypeController,
              label: 'Type',
            ),
            EntryField(
                controller: addressController,
                readOnly: true,
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => PlacePicker(
                  //       apiKey: Platform.isAndroid
                  //           ? "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI"
                  //           : "AIzaSyD65ula_94BY_XziYpJOLXFN-DOVwnBdcI",
                  //       onPlacePicked: (result) {
                  //         setState(() {
                  //           addressController.text = result.formattedAddress.toString();
                  //           latitude = result.geometry!.location.lat;
                  //           longitude = result.geometry!.location.lng;
                  //         });
                  //
                  //         Navigator.of(context).pop();
                  //       },
                  //       initialPosition: LatLng(latitude, longitude),
                  //       useCurrentLocation: true,
                  //     ),
                  //   ),
                  // );
                },
                label: 'Select Location',
                prefixIcon: Icons.location_on),
          ],
        ),
      ),
      bottomNavigationBar: !saveStatus
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                textColor: Colors.white,
                text: 'Add',
                onTap: () {
                  if (addressTypeController.text == "") {
                    UI.setSnackBar('Please enter location type', context);
                    return;
                  } else if (addressTypeController.text == "") {
                    UI.setSnackBar('Please Select Location', context);
                    return;
                  }
                  addAddress();
                },
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
