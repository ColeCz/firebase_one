import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyAN1m7lq624WumzZZTwcC6HleNI1tvmgNM",
        authDomain: "fir-one-3101b.firebaseapp.com",
        projectId: "fir-one-3101b",
        storageBucket: "fir-one-3101b.appspot.com",
        messagingSenderId: "894810285540",
        appId: "1:894810285540:web:e850c5194144cf5778d3f1",
        measurementId: "G-6HCS1Y3CBK"
    ),
  );
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: LoginPage(),
    );
  }
}

class FireStoreApp extends StatefulWidget {
  final User? user;

  FireStoreApp({required this.user});

  @override
  _FireStoreAppState createState() => _FireStoreAppState();
}

class _FireStoreAppState extends State<FireStoreApp> {
  final CollectionReference groceries =
  FirebaseFirestore.instance.collection('groceries');
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Market Groceries'),
        actions: [
          IconButton(
            onPressed: () => _signOut(context),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${widget.user?.email}',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: _showAddGroceryDialog,
              child: Text('Add Grocery Item'),
            ),
            ElevatedButton(
              onPressed: () {
                _navigateToManageGroceryItems(context);
              },
              child: Text('Manage Grocery Items'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/banana.jpg'),
                Image.asset('assets/strawberry.jpg'),
                Image.asset('assets/blackberry.jpg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  Future<void> _addGroceryItem(String itemName) async {
    try {
      await groceries.add({'name': itemName});
      print('Grocery item added successfully.');
    } catch (e) {
      print('Error adding grocery item: $e');
    }
  }

  void _showAddGroceryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Grocery Item'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(labelText: 'Item Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String itemName = textController.text.trim();
                if (itemName.isNotEmpty) {
                  _addGroceryItem(itemName);
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToManageGroceryItems(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageGroceryItemsPage(),
      ),
    );
  }
}

class ManageGroceryItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Grocery Items'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('groceries').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.docs.map((grocery) {
                return ListTile(
                  title: Text(grocery['name']),
                  onTap: () => _showUpdateGroceryDialog(context, grocery),
                  onLongPress: () => _deleteGroceryItem(grocery.id),
                );
              }).toList(),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Future<void> _updateGroceryItem(String itemId, String updatedItemName) async {
    try {
      await FirebaseFirestore.instance
          .collection('groceries')
          .doc(itemId)
          .update({'name': updatedItemName});
      print('Grocery item updated successfully.');
    } catch (e) {
      print('Error updating grocery item: $e');
    }
  }

  Future<void> _deleteGroceryItem(String itemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('groceries')
          .doc(itemId)
          .delete();
      print('Grocery item deleted successfully.');
    } catch (e) {
      print('Error deleting grocery item: $e');
    }
  }

  void _showUpdateGroceryDialog(BuildContext context, DocumentSnapshot grocery) {
    String updatedItemName = grocery['name'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Grocery Item'),
          content: TextField(
            controller: TextEditingController(text: updatedItemName),
            onChanged: (value) => updatedItemName = value,
            decoration: InputDecoration(labelText: 'Item Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateGroceryItem(grocery.id, updatedItemName);
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
