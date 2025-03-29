import 'package:assignment5/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Animation<double> animation;
  late AnimationController controller;

  bool shouldDelete = false; // Track whether the item should be deleted
  void openItemDialog({
    String? docId,
    String? title,
    String? description,
  }) async {
    if (docId != null) {
      _titleController.text = title ?? '';
      _descriptionController.text = description ?? '';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId != null ? "Update Item" : "Add Item"),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter your title here', // Optional hint text
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ), // Optional hint style
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ), // Optional label style
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ), // Adjust padding
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title cannot be empty';
                      }
                      if (value.length < 3) {
                        return 'Title should be at least 3 characters long';
                      }
                      return null; // No error
                    },
                  ),

                  SizedBox(height: 10),
                  Expanded(
                    child: TextFormField(
                      maxLines: 8,
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ), // Custom label color
                        hintText:
                            'Enter description here', // Optional hint text
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ), // Optional hint text style
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black12,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ), // Adjust padding inside
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description cannot be empty';
                        }
                        if (value.length < 10) {
                          return 'Description should be at least 10 characters long';
                        }
                        return null; // No error
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              style: ButtonStyle(
                side: WidgetStateProperty.all<BorderSide>(
                  BorderSide(color: Colors.green, width: 1),
                ),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.green),
                backgroundColor: WidgetStateProperty.all<Color>(
                  Colors.transparent,
                ), // Transparent background
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ), // Rounded corners
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, proceed
                  String title = _titleController.text;
                  String description = _descriptionController.text;
                  if (docId == null) {
                    String uid =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    _firestoreService.addItem(uid, title, description);
                  } else {
                    _firestoreService.updateItem(docId, title, description);
                  }

                  _titleController.clear();
                  _descriptionController.clear();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Processing Data')));
                }
              },
              child: Text('Save'),
            ),
            OutlinedButton(
              style: ButtonStyle(
                side: WidgetStateProperty.all<BorderSide>(
                  BorderSide(color: Colors.red, width: 1),
                ),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
                backgroundColor: WidgetStateProperty.all<Color>(
                  Colors.transparent,
                ), // Transparent background
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ), // Rounded corners
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> openDeleteConfirmationDialog(String doId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel deletion
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    // Proceed with deletion if confirmed
    return confirmDelete ?? false; // Return true if confirmed, false otherwise
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assignment5 App')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Show skeleton loader while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 10, // Set the number of skeleton items
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: Container(
                        width: 40,
                        height: 40,
                        color: Colors.white,
                      ),
                      title: Container(
                        width: 150,
                        height: 10,
                        color: Colors.white,
                      ),
                      subtitle: Container(
                        width: 100,
                        height: 10,
                        color: Colors.white,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 30, height: 30, color: Colors.white),
                          SizedBox(width: 10),
                          Container(width: 30, height: 30, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Items available."));
          }

          List<DocumentSnapshot> items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = items[index];
              Map<String, dynamic> item =
                  document.data() as Map<String, dynamic>;
              String doId = document.id;

              return Dismissible(
                key: Key(doId), // استخدام المعرف الفريد كـ key
                direction:
                    DismissDirection.endToStart, // السحب من اليمين لليسار
                background: Container(
                  color: Colors.red, // خلفية حمراء لعملية الحذف
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                confirmDismiss: (direction) async {
                  bool? confirmDelete = await openDeleteConfirmationDialog(
                    doId,
                  );
                  return confirmDelete;
                },
                onDismissed: (direction) {
                  _firestoreService.deleteItem(doId);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Item deleted')));
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,

                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.all(10),
                        title: Text(
                          item['title'].toString().isEmpty
                              ? "No Title"
                              : truncateText(item['title']),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item['description'].toString().isEmpty
                              ? "No Description"
                              : truncateText(item['description']),
                          style: TextStyle(color: Colors.grey[700]),
                          softWrap: true,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            openItemDialog(
                              docId: doId,
                              title: item['title'],
                              description: item['description'],
                            );
                          },
                          icon: Icon(Icons.edit, color: Colors.blue),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,

                        children: [IconAnimationScreen()],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          try {
            openItemDialog();
          } catch (e, stack) {
            debugPrint("Error: $e");
            debugPrint("StackTrace: $stack");
          }
        },
        icon: Icon(Icons.add),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        label: Text("Add Item"),
      ),
    );
  }
}

String truncateText(String text, {int maxLength = 20}) {
  if (text.length > maxLength) {
    return '${text.substring(0, maxLength)}...';
  }
  return text;
}

class IconAnimationScreen extends StatefulWidget {
  const IconAnimationScreen({super.key});

  @override
  IconAnimationScreenState createState() => IconAnimationScreenState();
}

class IconAnimationScreenState extends State<IconAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: -20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
      child: Row(
        children: [
          Icon(Icons.arrow_back, color: Colors.red, size: 16),
          SizedBox(width: 5),
          Text("Swipe to delete"),
        ],
      ),
    );
  }
}
