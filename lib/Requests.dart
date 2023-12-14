import 'package:flutter/material.dart';
import 'package:project/AddRoutePage.dart';
import 'package:project/Profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LoginPage.dart';
import 'firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Profile.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'AddRoutePage.dart';


class Locations {
  final String name;
  final String imagePath;
  final double price;
  final String date;
  final String meetingpoint;
  late String status;
  final String username;
  final int phone;
  final String documentId;
  String? driverID;

  Locations(this.name, this.imagePath, this.price, this.date, this.meetingpoint,this.status, this.username, this.phone, this.documentId, this.driverID);
}
class Requests extends StatefulWidget {
  // const Requests({super.key});
  final String? driverID; // Add a parameter to receive the price
  Requests({ required this.driverID});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  List<Locations> requests = [];
  List<bool> isAccepted = [];


  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
  }
  // Future<void> fetchDataFromFirestore() async {
  //   try {
  //     final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //     final QuerySnapshot requestsSnapshot = await firestore.collection('Requests').get();
  //
  //     final List<Locations> fetchedItems = [];
  //
  //     for (final QueryDocumentSnapshot requestDoc in requestsSnapshot.docs) {
  //       final Map<String, dynamic>? data = requestDoc.data() as Map<String, dynamic>?;
  //
  //       if (data != null) {
  //         final DateTime date = (data['date'] as Timestamp).toDate();
  //         final String visitedLocationId = data['routeID'];
  //         final String userId = data['userID'];
  //         final String status = data['status'];
  //         final QuerySnapshot usersSnapshot = await firestore.collection(
  //             'Users').get();
  //
  //         String phone = '';
  //         String username = '';
  //
  //         for (final QueryDocumentSnapshot usersDoc in usersSnapshot.docs) {
  //           final String uId = usersDoc.id;
  //           if (uId == userId) {
  //             phone = usersDoc['phone'].toString();
  //             username = usersDoc['username'];
  //             break;
  //           }
  //         }
  //
  //         final QuerySnapshot driversSnapshot = await firestore.collection('Drivers').get();
  //
  //         for (final QueryDocumentSnapshot driverDoc in driversSnapshot.docs) {
  //           final QuerySnapshot visitedLocationsSnapshot =
  //           await driverDoc.reference.collection('Routes').get();
  //
  //           for (final QueryDocumentSnapshot visitedLocationDoc in visitedLocationsSnapshot
  //               .docs) {
  //             if (visitedLocationId == visitedLocationDoc.id) {
  //               final imagePath = visitedLocationDoc['imagePath'];
  //               final name = visitedLocationDoc['name'];
  //               final price = visitedLocationDoc['price'].toDouble();
  //               final meetingpoint = visitedLocationDoc['meetingpoint'];
  //
  //               fetchedItems.add(Locations(
  //                   name,
  //                   imagePath,
  //                   price,
  //                   date,
  //                   meetingpoint,
  //                   status,
  //                   username,
  //                   int.parse(phone),
  //                 requestDoc.id,
  //                 widget.driverID ?? "",));
  //             }
  //           }
  //         }
  //       }
  //     }
  //     // print('Fetched Items: $fetchedItems');
  //
  //     setState(() {
  //       requests = fetchedItems;
  //     });
  //   }
  //   catch (e) {
  //     print("Error fetching data: $e");
  //   }
  // }


  Future<void> fetchDataFromFirestore() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Fetch requests where the driverID matches the provided driverID
      final QuerySnapshot requestsSnapshot = await firestore
          .collection('Requests')
          .where('Driver ID', isEqualTo: widget.driverID)
          .get();

      final List<Locations> fetchedItems = [];
        for (final QueryDocumentSnapshot requestDoc in requestsSnapshot.docs) {
          final Map<String, dynamic>? data = requestDoc.data() as Map<
              String,
              dynamic>?;

          if (data != null) {
            final String date = data['date'] ;
            final String visitedLocationId = data['Route ID'];
            final String userId = data['User ID'];
            final String status = data['status'];
            final QuerySnapshot usersSnapshot = await firestore.collection(
                'Users').get();

            String phone = '';
            String username = '';

            for (final QueryDocumentSnapshot usersDoc in usersSnapshot.docs) {
              final String uId = usersDoc.id;
              if (uId == userId) {
                phone = usersDoc['phone'].toString();
                username = usersDoc['username'];
                break;
              }
            }

            final QuerySnapshot driversSnapshot = await firestore.collection(
                'Drivers').get();

            for (final QueryDocumentSnapshot driverDoc in driversSnapshot
                .docs) {
              final QuerySnapshot visitedLocationsSnapshot =
              await driverDoc.reference.collection('Routes').get();

              for (final QueryDocumentSnapshot visitedLocationDoc in visitedLocationsSnapshot
                  .docs) {
                if (visitedLocationId == visitedLocationDoc.id) {
                  final imagePath = visitedLocationDoc['imagePath'];
                  final name = visitedLocationDoc['name'];
                  final price = visitedLocationDoc['price'].toDouble();
                  final meetingpoint = visitedLocationDoc['meetingpoint'];

                  fetchedItems.add(Locations(
                    name,
                    imagePath,
                    price,
                    date,
                    meetingpoint,
                    status,
                    username,
                    int.parse(phone),
                    requestDoc.id,
                    widget.driverID ?? "",));
                }
              }
            }
          }
        }
        print('Fetched Items: $fetchedItems');
      setState(() {
        requests = fetchedItems;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }




  void updateStatusInFirestore(int index, String newStatus) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Assuming 'Requests' collection has a unique document ID for each request
      await firestore.collection('Requests').doc(requests[index].documentId).update({'status': newStatus,'driverID': widget.driverID});
      print("status updated");
      // Update the status locally in the app
      setState(() {
        requests[index].status = newStatus;
        requests[index].driverID = widget.driverID;
      });
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset:false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.location_pin),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddRoutePage(driverID: widget.driverID)),);
          },
        ),
        centerTitle: true,
        title: Text(
          "Requests",
          style: GoogleFonts.pangolin(
            textStyle: TextStyle(fontSize: screenHeight * 0.04, color: Colors.grey.shade900),
          ),
        ),
        backgroundColor: Colors.blueGrey.shade300,
        actions: [
          IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(driverID: widget.driverID)), // Replace with your profile page
                );
              },
            ),

          Padding(
            padding: EdgeInsets.only(right: screenHeight*0.04, left: screenWidth*0.005),
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(), // Replace with your OrderHistory page
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade200,
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(screenHeight * 0.03), // Adjust the vertical padding as needed
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey.shade300, // Set darker background color here
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Image.asset(
                          requests[index].imagePath,
                          width: screenWidth * 0.25,
                          height: screenHeight * 0.25,
                          fit: BoxFit.cover,

                        ),
                        SizedBox(
                          width: screenWidth*0.3,
                          child: Padding(
                            padding: EdgeInsets.only(right:screenWidth*0.07, left: screenWidth*0.05, top: screenHeight*0.01),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Place: ${requests[index].name}\n"
                                  "meeting point: ${requests[index].meetingpoint}",
                                  style: GoogleFonts.pangolin(
                                    textStyle: TextStyle(
                                      fontSize: screenHeight * 0.04,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenHeight * 0.01),
                                Text(
                                  // " Date:${DateFormat('dd/MM/yyyy hh:mm a').format(requests[index].date)}\n"
                                  " Date:${requests[index].date}\n"
                                  "Price:${requests[index].price}\n",
                                  style: GoogleFonts.pangolin(
                                    textStyle: TextStyle(
                                      fontSize: screenHeight * 0.04,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                          "Status: ",
                                      style: GoogleFonts.pangolin(
                                        textStyle: TextStyle(
                                          fontSize: screenHeight * 0.04,
                                          color: Colors.grey.shade900,
                                        ),
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/${requests[index].status}.png',
                                      width: screenWidth * 0.055,
                                      height: screenHeight * 0.035,
                                      // fit: BoxFit.cover,
                                    ),

                                  ],

                                ),

                              ],
                            ),
                          ),
                        ),
                        // SizedBox(width: screenWidth*0.1),
                        // SizedBox(
                        //   height: screenHeight * 0.12,
                        //   child:
                          Padding(
                            padding:  EdgeInsets.only(right:screenWidth*0.07,left: screenWidth*0.02),
                            child: Column(
                              children: [
                                Text(
                                      "Rider's name: \n "
                                  "${requests[index].username}\n"
                                "Rider's number : \n "
                                  "0${requests[index].phone}",
                                  style: GoogleFonts.pangolin(
                                    textStyle: TextStyle(
                                      fontSize: screenHeight * 0.034,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // )
                        Padding(
                          padding: EdgeInsets.only(left:screenWidth*0.02),
                          child: Column(
                            children: [
                              if (requests[index].status == 'pending')
                                   Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(screenHeight * 0.025),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [Colors.blue.shade300, Colors.deepPurple.shade200],
                                      ),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        updateStatusInFirestore(index, 'approved');
                                      },
                                      child: Text(
                                        'Accept',
                                        style: GoogleFonts.pangolin(
                                          textStyle: TextStyle(fontSize: screenHeight * 0.03, color: Colors.grey.shade900),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(screenHeight * 0.015),
                                        ),
                                        minimumSize: Size(0, screenHeight * 0.005),
                                        elevation: 0, // Optional: Set elevation to 0 for a flat design
                                        backgroundColor: Colors.transparent, // Set the button's background to transparent
                                        foregroundColor: Colors.transparent,  // Set the button's splash color to transparent
                                      ),
                                    ),
                              ),


                                  SizedBox(height: screenHeight*0.1),
                              if (requests[index].status == 'pending')
                               Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(screenHeight * 0.025),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.blue.shade300, Colors.deepPurple.shade200],
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    updateStatusInFirestore(index, 'declined');
                                  },
                                  child: Text(
                                    'Decline',
                                    style: GoogleFonts.pangolin(
                                      textStyle: TextStyle(fontSize: screenHeight * 0.03, color: Colors.grey.shade900),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(screenHeight * 0.015),
                                    ),
                                    minimumSize: Size(0, screenHeight * 0.005),
                                    elevation: 0, // Optional: Set elevation to 0 for a flat design
                                    backgroundColor: Colors.transparent, // Set the button's background to transparent
                                    foregroundColor: Colors.transparent,  // Set the button's splash color to transparent
                                  ),
                                ),
                              ),

                                if (requests[index].status == 'approved')
                            Text('Request is Accepted'),
                            SizedBox(height: screenHeight*0.02),
                            if (requests[index].status == 'declined')
                            Text('Request is Declined'),
                              SizedBox(height: screenHeight*0.02),
                            if (requests[index].status == 'approved')
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(screenHeight * 0.025),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.blue.shade300, Colors.deepPurple.shade200],
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  updateStatusInFirestore(index, 'finish');
                                },
                                child: Text(
                                  'Ride is completed',
                                  style: GoogleFonts.pangolin(
                                    textStyle: TextStyle(fontSize: screenHeight * 0.03, color: Colors.grey.shade900),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(screenHeight * 0.015),
                                  ),
                                  minimumSize: Size(0, screenHeight * 0.005),
                                  elevation: 0, // Optional: Set elevation to 0 for a flat design
                                  backgroundColor: Colors.transparent, // Set the button's background to transparent
                                  foregroundColor: Colors.transparent,  // Set the button's splash color to transparent
                                ),
                              ),
                            ),
                              if (requests[index].status == 'finish')
                                Text('Finished'),
                            ],

                          ),
                        ),
                      ],
                    ),

                  ),
                ),
              )
          );
        },
      ),
    );
  }
}

