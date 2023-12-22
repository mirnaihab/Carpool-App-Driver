import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/AddRoutePage.dart';
import 'package:project/Profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LoginPage.dart';
import 'firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Requests extends StatefulWidget {
  // const Requests({super.key});
  final String? driverID; // Add a parameter to receive the price
  Requests({ required this.driverID});

  @override
  State<Requests> createState() => _RequestsState();
}
class _RequestsState extends State<Requests> {
  late Stream<QuerySnapshot> _requestsStream;

  @override
  void initState() {
    super.initState();
    _requestsStream = FirebaseFirestore.instance
        .collection('Requests')
        .where('Driver ID', isEqualTo: widget.driverID)
        .snapshots();
  }

  Future<Map<String, dynamic>?> fetchUserData(String userID) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data();
      if (userData != null) {
        return {
          'username': userData['username'],
          'phone': userData['phone'],
        };
      }
    }
    return null; // Return null if data doesn't exist or is null
  }

  Future<Map<String, dynamic>?> fetchRouteData(String routeID) async {
    final routeSnapshot = await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(widget.driverID)
        .collection('Routes')
        .doc(routeID)
        .get();

    if (routeSnapshot.exists) {
      final routeData = routeSnapshot.data();
      if (routeData != null) {
        return {
          'name': routeData['name'],
          'price': routeData['price'],
          'imagePath': routeData['imagePath'],
          'meetingpoint': routeData['meetingpoint'],
        };
      }
    }
    return null; // Return null if data doesn't exist or is null
  }

  void checkTimeConstraints(DocumentSnapshot requestSnapshot) {
    final requestData = requestSnapshot.data() as Map<String, dynamic>;
    final direction = requestData['Direction'];
    final date = requestData['date'];

    // Define your time constraints here
    final asuGates = ['ASU Gate 3', 'ASU Gate 4'];
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    if (direction.isNotEmpty &&
        asuGates.contains(direction) &&
        date != null) {
      final requestDateTime = (date as Timestamp).toDate();

      // Check if the direction is from ASU Gate 3 or 4
      if (direction.contains('From ASU Gate') && currentTime.hour >= 16 && now.isBefore(requestDateTime)) {
        // Do not accept requests after 4:30 PM on the same day
        updateStatusInFirestore(requestSnapshot, 0, 'declined');
        return;
      }

      // Check if the direction is to ASU Gate 3 or 4
      if (direction.contains('ASU Gate') && currentTime.hour >= 23 && now.isBefore(requestDateTime)) {
        // Do not accept requests after 11:30 PM the previous day
        updateStatusInFirestore(requestSnapshot, 0, 'declined');
        return;
      }
    }

    // Accept the request if it passes all constraints
    updateStatusInFirestore(requestSnapshot, 0, 'approved');
  }

  void updateStatusInFirestore(
      DocumentSnapshot? requestSnapshot, int index, String newStatus) async {
    try {
      if (requestSnapshot == null) {
        print('Error: Request snapshot is null');
        return;
      }

      final requestId = requestSnapshot.id;

      await FirebaseFirestore.instance
          .collection('Requests')
          .doc(requestId)
          .update({'status': newStatus});

      // setState(() {
      //   final currentData = requestSnapshot.data();
      //   if (currentData != null) {
      //     currentData['status'] = newStatus;
      //   }
      // });
    } catch (e) {
      print('Error updating status: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.location_pin),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) =>
                      AddRoutePage(driverID: widget.driverID)),);
            },
          ),
          centerTitle: true,
          title: Text(
            "Requests",
            style: GoogleFonts.pangolin(
              textStyle: TextStyle(
                  fontSize: screenHeight * 0.04, color: Colors.grey.shade900),
            ),
          ),
          backgroundColor: Colors.blueGrey.shade300,
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      ProfilePage(driverID: widget
                          .driverID)), // Replace with your profile page
                );
              },
            ),

            Padding(
              padding: EdgeInsets.only(
                  right: screenHeight * 0.04, left: screenWidth * 0.005),
              child: IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        LoginPage(), // Replace with your OrderHistory page
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade200,
        body: StreamBuilder<QuerySnapshot>(
            stream: _requestsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No requests found'));
              } else {
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final requestData =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final userID = requestData['User ID'];
                      final routeID = requestData['Route ID'];
                      final direction = requestData['Direction'];
                      final status = requestData['status'];
                      final date = requestData['date'];

                      return FutureBuilder<Map<String, dynamic>?>(
                          future: fetchUserData(userID),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ListTile(
                                title: Text('Loading...'),
                              );
                            } else if (userSnapshot.hasError) {
                              return ListTile(
                                title: Text('Error: ${userSnapshot.error}'),
                              );
                            } else if (!userSnapshot.hasData) {
                              return ListTile(
                                title: Text('No user data found'),
                              );
                            } else {
                              final userData = userSnapshot.data!;
                              final username = userData['username'];
                              final phone = userData['phone'];

                              return FutureBuilder<Map<String, dynamic>?>(
                                  future: fetchRouteData(routeID),
                                  builder: (context, routeSnapshot) {
                                    if (routeSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return ListTile(
                                        title: Text('Loading...'),
                                      );
                                    } else if (routeSnapshot.hasError) {
                                      return ListTile(
                                        title: Text(
                                            'Error: ${routeSnapshot.error}'),
                                      );
                                    } else if (!routeSnapshot.hasData) {
                                      return ListTile(
                                        title: Text('No route data found'),
                                      );
                                    } else {
                                      final routeData = routeSnapshot.data!;
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                screenHeight * 0.03),
                                            // Adjust the vertical padding as needed
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey),
                                                color: Colors.grey
                                                    .shade300, // Set darker background color here
                                              ),
                                              child: ListTile(
                                                title: Row(
                                                  children: [
                                                    Image.asset(
                                                      routeData['imagePath'],
                                                      width: screenWidth * 0.25,
                                                      height: screenHeight *
                                                          0.25,
                                                      fit: BoxFit.cover,

                                                    ),
                                                    SizedBox(
                                                      width: screenWidth * 0.3,
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .only(
                                                            right: screenWidth *
                                                                0.07,
                                                            left: screenWidth *
                                                                0.05,
                                                            top: screenHeight *
                                                                0.01),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            Text(
                                                              "Place: ${routeData['name']}\n"
                                                                  "meeting point: ${routeData['meetingpoint']}",
                                                              style: GoogleFonts
                                                                  .pangolin(
                                                                textStyle: TextStyle(
                                                                  fontSize: screenHeight *
                                                                      0.04,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade900,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: screenHeight *
                                                                    0.01),
                                                            Text(
                                                              // " Date:${DateFormat('dd/MM/yyyy hh:mm a').format(requests[index].date)}\n"
                                                              " Date:$date\n"
                                                                  "Price:${routeData['price']}\n"
                                                                  "Destination:$direction\n",
                                                              style: GoogleFonts
                                                                  .pangolin(
                                                                textStyle: TextStyle(
                                                                  fontSize: screenHeight *
                                                                      0.04,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade900,
                                                                ),
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "Status: ",
                                                                  style: GoogleFonts
                                                                      .pangolin(
                                                                    textStyle: TextStyle(
                                                                      fontSize: screenHeight *
                                                                          0.04,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade900,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Image.asset(
                                                                  'assets/$status.png',
                                                                  width: screenWidth *
                                                                      0.055,
                                                                  height: screenHeight *
                                                                      0.035,
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
                                                      padding: EdgeInsets.only(
                                                          right: screenWidth *
                                                              0.07,
                                                          left: screenWidth *
                                                              0.02),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "Rider's name: \n "
                                                                "$username\n"
                                                                "Rider's number : \n "
                                                                "0$phone",
                                                            style: GoogleFonts
                                                                .pangolin(
                                                              textStyle: TextStyle(
                                                                fontSize: screenHeight *
                                                                    0.034,
                                                                color: Colors
                                                                    .grey
                                                                    .shade900,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // )
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: screenWidth *
                                                              0.02),
                                                      child: Column(
                                                        children: [
                                                          if (status ==
                                                              'pending')
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .circular(
                                                                    screenHeight *
                                                                        0.025),
                                                                gradient: LinearGradient(
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                  colors: [
                                                                    Colors.blue
                                                                        .shade300,
                                                                    Colors
                                                                        .deepPurple
                                                                        .shade200
                                                                  ],
                                                                ),
                                                              ),
                                                              child: ElevatedButton(
                                                                onPressed: () {
                                                                  checkTimeConstraints(snapshot.data!.docs[index]);
                                                                  // updateStatusInFirestore(snapshot.data!.docs[index], index, 'approved');

                                                                },
                                                                child: Text(
                                                                  'Accept',
                                                                  style: GoogleFonts
                                                                      .pangolin(
                                                                    textStyle: TextStyle(
                                                                        fontSize: screenHeight *
                                                                            0.03,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade900),
                                                                  ),
                                                                ),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius
                                                                        .circular(
                                                                        screenHeight *
                                                                            0.015),
                                                                  ),
                                                                  minimumSize: Size(
                                                                      0,
                                                                      screenHeight *
                                                                          0.005),
                                                                  elevation: 0,
                                                                  // Optional: Set elevation to 0 for a flat design
                                                                  backgroundColor: Colors
                                                                      .transparent,
                                                                  // Set the button's background to transparent
                                                                  foregroundColor: Colors
                                                                      .transparent, // Set the button's splash color to transparent
                                                                ),
                                                              ),
                                                            ),


                                                          SizedBox(
                                                              height: screenHeight *
                                                                  0.1),
                                                          if (status ==
                                                              'pending')
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .circular(
                                                                    screenHeight *
                                                                        0.025),
                                                                gradient: LinearGradient(
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                  colors: [
                                                                    Colors.blue
                                                                        .shade300,
                                                                    Colors
                                                                        .deepPurple
                                                                        .shade200
                                                                  ],
                                                                ),
                                                              ),
                                                              child: ElevatedButton(
                                                                onPressed: () {
                                                                  updateStatusInFirestore(snapshot.data!.docs[index], index, 'declined');

                                                                },
                                                                child: Text(
                                                                  'Decline',
                                                                  style: GoogleFonts
                                                                      .pangolin(
                                                                    textStyle: TextStyle(
                                                                        fontSize: screenHeight *
                                                                            0.03,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade900),
                                                                  ),
                                                                ),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius
                                                                        .circular(
                                                                        screenHeight *
                                                                            0.015),
                                                                  ),
                                                                  minimumSize: Size(
                                                                      0,
                                                                      screenHeight *
                                                                          0.005),
                                                                  elevation: 0,
                                                                  // Optional: Set elevation to 0 for a flat design
                                                                  backgroundColor: Colors
                                                                      .transparent,
                                                                  // Set the button's background to transparent
                                                                  foregroundColor: Colors
                                                                      .transparent, // Set the button's splash color to transparent
                                                                ),
                                                              ),
                                                            ),

                                                          if (status ==
                                                              'approved')
                                                            Text(
                                                                'Request is Accepted'),
                                                          SizedBox(
                                                              height: screenHeight *
                                                                  0.02),
                                                          if (status ==
                                                              'declined')
                                                            Text(
                                                                'Request is Declined'),
                                                          SizedBox(
                                                              height: screenHeight *
                                                                  0.02),
                                                          if (status ==
                                                              'approved')
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .circular(
                                                                    screenHeight *
                                                                        0.025),
                                                                gradient: LinearGradient(
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                  colors: [
                                                                    Colors.blue
                                                                        .shade300,
                                                                    Colors
                                                                        .deepPurple
                                                                        .shade200
                                                                  ],
                                                                ),
                                                              ),
                                                              child: ElevatedButton(
                                                                onPressed: () {
                                                                  updateStatusInFirestore(snapshot.data!.docs[index], index, 'finish');

                                                                },
                                                                child: Text(
                                                                  'Ride is completed',
                                                                  style: GoogleFonts
                                                                      .pangolin(
                                                                    textStyle: TextStyle(
                                                                        fontSize: screenHeight *
                                                                            0.03,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade900),
                                                                  ),
                                                                ),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius
                                                                        .circular(
                                                                        screenHeight *
                                                                            0.015),
                                                                  ),
                                                                  minimumSize: Size(
                                                                      0,
                                                                      screenHeight *
                                                                          0.005),
                                                                  elevation: 0,
                                                                  // Optional: Set elevation to 0 for a flat design
                                                                  backgroundColor: Colors
                                                                      .transparent,
                                                                  // Set the button's background to transparent
                                                                  foregroundColor: Colors
                                                                      .transparent, // Set the button's splash color to transparent
                                                                ),
                                                              ),
                                                            ),
                                                          if (status ==
                                                              'finish')
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
                                    }
                                  });
                            };
                          });
                    });
              }
            }));
  }
}

