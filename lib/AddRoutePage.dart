import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Profile.dart';
import 'LoginPage.dart';
import 'Requests.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AddRoutePage extends StatefulWidget {
  final String? driverID;

  const AddRoutePage({Key? key, required this.driverID}) : super(key: key);

  @override
  _AddRoutePageState createState() => _AddRoutePageState();
}

class _AddRoutePageState extends State<AddRoutePage> {
  final TextEditingController imagePathController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController meetingPointController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String errorMessage = '';
  // Future<void> addRoute() async {
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //
  //   try {
  //     if (widget.driverID != null) {
  //       await firestore.collection('Drivers').doc(widget.driverID).collection('Routes').add({
  //         'imagePath': imagePathController.text,
  //         'name': nameController.text,
  //         'meetingpoint': meetingPointController.text,
  //         'price': double.parse(priceController.text),
  //       });
  //
  //       // Clear text fields after adding the route
  //       imagePathController.clear();
  //       nameController.clear();
  //       meetingPointController.clear();
  //       priceController.clear();
  //
  //       // Show a success message or navigate to another page
  //       // Navigator.pop(context); // Example: Go back to the previous page
  //     } else {
  //       print('Driver ID is null');
  //     }
  //   } catch (e) {
  //     // Handle errors here
  //     print('Error adding route: $e');
  //   }
  // }

  Future<void> addRoute() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    setState(() {
      errorMessage = '';
    });
    if( imagePathController.text.isEmpty ||
        nameController.text.isEmpty ||
        meetingPointController.text.isEmpty ||
        priceController.text.isEmpty)
      errorMessage = 'Some fields are missing';
    try {
      if (widget.driverID != null) {
        String enteredName = nameController.text;

        // Query for the routes of the specific driver
        QuerySnapshot<Map<String, dynamic>> routesSnapshot =
        await firestore.collection('Drivers').doc(widget.driverID).collection('Routes').get();

        // Check if the route exists for the current driver
        bool routeExists = routesSnapshot.docs.any((doc) =>
        doc.get('name').toString().toLowerCase() == enteredName.toLowerCase());

        // If the route exists for the current driver, check for other drivers
        if (routeExists) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Route Exists'),
                content: Text('The route name already exists for this driver.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
        // else {
        //   // Fetch routes from all drivers
        //   QuerySnapshot<Map<String, dynamic>> allDriversSnapshot =
        //   await firestore.collection('Drivers').get();
        //
        //   bool routeExistsForOtherDriver = false;
        //
        //   // Iterate through each driver's routes to check for the existence of the entered route name
        //   await Future.forEach(allDriversSnapshot.docs, (driverDoc) async {
        //     QuerySnapshot<Map<String, dynamic>> otherRoutesSnapshot =
        //     await driverDoc.reference.collection('Routes').get();
        //
        //     // Check if the entered route name exists for any other driver
        //     bool exists = otherRoutesSnapshot.docs.any((doc) =>
        //     doc.get('name').toString().toLowerCase() == enteredName.toLowerCase());
        //
        //     if (exists) {
        //       routeExistsForOtherDriver = true;
        //       return;
        //     }
        //   });
        //
        //   if (routeExistsForOtherDriver) {
        //     showDialog(
        //       context: context,
        //       builder: (context) {
        //         return AlertDialog(
        //           title: Text('Route Exists'),
        //           content: Text('The route name already exists for another driver.'),
        //           actions: [
        //             TextButton(
        //               onPressed: () {
        //                 Navigator.pop(context);
        //               },
        //               child: Text('OK'),
        //             ),
        //           ],
        //         );
        //       },
        //     );
        //   }
      else {
            // If the route doesn't exist for any driver, add the route
            await firestore.collection('Drivers').doc(widget.driverID).collection('Routes').add({
              'imagePath': imagePathController.text,
              'name': nameController.text,
              'meetingpoint': meetingPointController.text,
              'price': double.parse(priceController.text),
            });

            // Clear text fields after adding the route
            imagePathController.clear();
            nameController.clear();
            meetingPointController.clear();
            priceController.clear();
          }

      } else {
        print('Driver ID is null');
      }
    } catch (e) {
      // Handle errors here
      print('Error adding route: $e');
    }
  }

  // void isFieldsEmpty() async{
  //
  //   setState(() {
  //     errorMessage = '';
  //   });
  //   if( imagePathController.text.isEmpty ||
  //       nameController.text.isEmpty ||
  //       meetingPointController.text.isEmpty ||
  //       priceController.text.isEmpty)
  //     errorMessage = 'Some fields are missing';
  //   return;
  // }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        icon: Icon(Icons.shopping_cart),
        onPressed: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Requests(driverID: widget.driverID)));
        },
        ),
        centerTitle: true,
        title: Text(
        "Add Route",
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
      body:
      SingleChildScrollView(
        child:
        Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.35, vertical: screenHeight * 0.14),
          color: Colors.grey.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, // Background color for the TextField
                    borderRadius: BorderRadius.circular(screenHeight * 0.015), // Adjust the border radius as needed
                  ),
                  child: TextField(
                    controller: imagePathController,
                    decoration: InputDecoration(
                      labelText: 'Image Path',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(screenHeight * 0.03)),
                    ),

                  ),
                ),
                SizedBox(height: screenHeight * 0.05),

                // TextFormField(
                //   controller: imagePathController,
                //   decoration: InputDecoration(labelText: 'Image Path'),
                // ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, // Background color for the TextField
                    borderRadius: BorderRadius.circular(screenHeight * 0.015), // Adjust the border radius as needed
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'District Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(screenHeight * 0.03)),
                    ),

                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                // TextFormField(
                //   controller: nameController,
                //   decoration: InputDecoration(labelText: 'Name'),
                // ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, // Background color for the TextField
                    borderRadius: BorderRadius.circular(screenHeight * 0.015), // Adjust the border radius as needed
                  ),
                  child: TextField(
                    controller: meetingPointController,
                    decoration: InputDecoration(
                      labelText: 'Meeting Point',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(screenHeight * 0.03)),
                    ),

                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                // TextFormField(
                //   controller: meetingPointController,
                //   decoration: InputDecoration(labelText: 'Meeting Point'),
                // ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300, // Background color for the TextField
                    borderRadius: BorderRadius.circular(screenHeight * 0.015), // Adjust the border radius as needed
                  ),
                  child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(screenHeight * 0.03)),
                    ),
                  ),
                ),
                 SizedBox(height: screenHeight * 0.11),
                // TextFormField(
                //   controller: priceController,
                //   keyboardType: TextInputType.number,
                //   decoration: InputDecoration(labelText: 'Price'),
                // ),
                // SizedBox(height: 20),
                if (errorMessage.isNotEmpty) // Check if there's an error message
                  Text(
                    errorMessage,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: screenHeight*0.027// Customize the error text color
                    ),
                  ),
                SizedBox(height: screenHeight * 0.03),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenHeight * 0.015),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade300, Colors.deepPurple.shade200],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      addRoute();
                    },
                    child: Text(
                      'Add Route',
                      style: GoogleFonts.pangolin(
                        textStyle: TextStyle(fontSize: screenHeight * 0.035, color: Colors.grey.shade900),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.015),
                      ),
                      minimumSize: Size(double.infinity, screenHeight * 0.075),
                      elevation: 0, // Optional: Set elevation to 0 for a flat design
                      backgroundColor: Colors.transparent, // Set the button's background to transparent
                      foregroundColor: Colors.transparent, // Set the button's splash color to transparent
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.09),
              ],
            ),

        ),
      ),

    );
  }
}
