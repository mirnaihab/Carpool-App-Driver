import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Requests.dart';
import 'LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AddRoutePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class ProfilePage extends StatefulWidget {
  final String? driverID;
  ProfilePage({required this.driverID});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, String> profileDetails = {};

  @override
  void initState() {
    super.initState();
    // Call a function to fetch data when the widget initializes
    fetchDriverDetails();
  }

  Future<void> fetchDriverDetails() async {
    try {
      DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(widget.driverID)
          .get();

      if (driverSnapshot.exists) {
        setState(() {
          // Assign retrieved data to profileDetails map
          profileDetails = {
            'username': driverSnapshot['username']?.toString() ?? 'N/A',
            'phone': driverSnapshot['phone']?.toString() ?? 'N/A',
            'cartype': driverSnapshot['cartype']?.toString() ?? 'N/A',
            'platenumber': driverSnapshot['platenumber']?.toString() ?? 'N/A',
            'email': driverSnapshot['email']?.toString() ?? 'N/A',
          };
        });
      }
    } catch (e) {
      // Handle errors, if any
      print("Error fetching data: $e");
    }
  }

  void _updateDriverDetails(String field, String newValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(widget.driverID)
          .update({field: newValue});

      if (mounted) {
        setState(() {
          // Update the local profileDetails map as well
          profileDetails[field] = newValue;
        });
      }
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.location_pin),
          onPressed: () {
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => AddRoutePage(driverID: widget.driverID)),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          "Profile",
          style: GoogleFonts.pangolin(
            textStyle: TextStyle(fontSize: screenHeight * 0.04, color: Colors.grey.shade900),
          ),
        ),
        backgroundColor: Colors.blueGrey.shade300,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Requests(driverID: widget.driverID),
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.03),
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.35, vertical: screenHeight * 0.1),
          color: Colors.grey.shade200,
          child: Column(
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/profile.png'),
              ),
              SizedBox(height: screenHeight * 0.06),
              itemProfile('Username', profileDetails['username']!, CupertinoIcons.person),
              itemProfile('Phone', profileDetails['phone']!, CupertinoIcons.phone),
              itemProfile('CarType', profileDetails['cartype']!, Icons.directions_car),
              itemProfile('PlateNumber', profileDetails['platenumber']!, Icons.confirmation_number),
              itemProfile('Email', profileDetails['email']!, CupertinoIcons.mail),
              SizedBox(height: screenHeight * 0.06),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'Name':
        return CupertinoIcons.person;
      case 'Phone':
        return CupertinoIcons.phone;
      case 'Email':
        return CupertinoIcons.mail;
      default:
        return Icons.error;
    }
  }

  itemProfile(String title, String subtitle, IconData iconData) {
    TextEditingController textEditingController = TextEditingController(
      text: subtitle,
    );

    return GestureDetector(
      onTap: title == 'Email'
          ? null
          : () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade300,
              title: Text('Edit $title'),
              content: TextField(
                controller: textEditingController,
                decoration: InputDecoration(hintText: 'Enter new $title'),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel', style: TextStyle(fontSize: 20, color: Colors.grey.shade900)),
                ),
                TextButton(
                  onPressed: () {
                    // setState(() {
                    //   profileDetails[title] =
                    //       textEditingController.text; // Update the map entry with edited value
                    // });
                    _updateDriverDetails(title.toLowerCase(), textEditingController.text);

                    Navigator.of(context).pop();
                  },
                  child: Text('Save', style: TextStyle(fontSize: 20, color: Colors.grey.shade900)),
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 5),
                color: Colors.purple.shade300,
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            leading: Icon(iconData),
            trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade500),
            tileColor: Colors.white,
          ),
        ),
      ),
    );
  }
}