import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Model/favorite_location_model.dart';
import '../utils/ApiBaseHelper.dart';
import '../utils/Session.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import '../utils/new_utils/ui.dart';
import 'add_favorite_location.dart';

class ChooseFavoriteLocation extends StatefulWidget {
  int from;
  ChooseFavoriteLocation({this.from = 0});

  @override
  State<ChooseFavoriteLocation> createState() => _ChooseFavoriteLocationState();
}

class _ChooseFavoriteLocationState extends State<ChooseFavoriteLocation> {
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool saveStatus = false;
  List<FavoriteLocationData> favoriteLocationList = [];
  getFavoriteList() async {
    try {
      setState(() {
        saveStatus = true;
      });
      Map params = {
        "user_id": curUserId.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "authentication/get_favourite_addressess"),
          params);

      favoriteLocationList = (response['data'] as List)
          .map((e) => FavoriteLocationData.fromJson(e))
          .toList();
      print('lenght--->${favoriteLocationList.length}');
      setState(() {
        saveStatus = false;
      });
      // if (response['status']) {
      //   UI.setSnackBar(response['message'], context);
      //   back(context);
      // } else {
      //   UI.setSnackBar(response['message'], context);
      // }
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
    getFavoriteList();
  }
  deleteAddress(String id) async {
    try {
      setState(() {
        saveStatus = true;
      });
      Map params = {
        "user_id": curUserId.toString(),
        'id':id

      };
      Map response = await apiBase.postAPICall(
          Uri.parse(baseUrl1 + "authentication/delete_favourite_addressess"), params);
      setState(() {
        saveStatus = false;
      });
      if (response['status']) {
        UI.setSnackBar(response['message'], context,color: Colors.green);
        getFavoriteList();
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
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddFavoriteLocation(),
              )).then((value) {
            getFavoriteList();
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: MyColorName.secondary),
            height: 50,
            child: Center(
              child: Text(
                'Add Favorite Location',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            'Choose a location',
            style: TextStyle(color: Colors.black),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            saveStatus
                ? SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).height,
                    child: Center(child: CircularProgressIndicator()))
                : favoriteLocationList.isEmpty
                    ? SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height,
                        child: Center(child: Text('No Data Found')))
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: favoriteLocationList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              if (widget.from == 0) {
                                print('hsjkafhdsdaf');
                                latitude = double.parse(
                                    favoriteLocationList[index]
                                        .latitude
                                        .toString());
                                longitude = double.parse(
                                    favoriteLocationList[index]
                                        .longitude
                                        .toString());
                                Navigator.pop(context,[widget.from,
                                    favoriteLocationList[index].address]);
                              } else {
                                latitude = double.parse(
                                    favoriteLocationList[index]
                                        .latitude
                                        .toString());
                                longitude = double.parse(
                                    favoriteLocationList[index]
                                        .longitude
                                        .toString());
                                Navigator.pop(context, [
                                  widget.from,
                                  favoriteLocationList[index].address,
                                  favoriteLocationList[index]
                                      .latitude
                                      .toString(),
                                  favoriteLocationList[index]
                                      .longitude
                                      .toString()
                                ]);
                              }
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 12, right: 12),
                              child: Card(
                                elevation: 5,
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${favoriteLocationList[index].type}',
                                                  ),
                                                  Text(
                                                    '${favoriteLocationList[index].address}',
                                                    style: TextStyle(
                                                        color: MyColorName
                                                            .textColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                deleteAddress(favoriteLocationList[index].id ?? '');
                                              },
                                                child: Icon(Icons.close,color: Colors.black,))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
          ],
        ),
      ),
    );
  }
}
