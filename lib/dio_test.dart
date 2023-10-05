import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

final dio = Dio();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = '';
  String desc = '';
  List data = [];

  // Function to open the create item modal
  void _openCreateItemModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    desc = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _createNewItem();
                Navigator.of(context).pop();
              },
              child: const Text('Create'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to send a POST request to create a new item
  void _createNewItem() async {
    try {
      final response =
          await dio.post('http://localhost:8000/api/item/create', data: {
        'name': name,
        'desc': desc,
      });

      if (response.data['status'] == true) {
        // Update the list of items with the new item
        data.add(response.data['data']);
        setState(() {});
      } else {
        // Handle error or no data found
        name = 'Data not found';
      }
    } catch (e) {
      print(e.toString());
      // Handle any network or request errors
      name = 'Error occurred';
    }
  }

  // Function to open the edit item modal
  void _openEditItemModal(BuildContext context, int index) {
    final currentItem = data[index];
    name = currentItem['name'];
    desc = currentItem['desc'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                controller: TextEditingController(text: name),
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    desc = value;
                  });
                },
                controller: TextEditingController(text: desc),
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _updateItem(currentItem['id']); // Pass the item ID to update
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteItem(currentItem['id']); // Pass the item ID to delete
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Use a red color for the delete button
              ),
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

// Function to send a DELETE request to delete an item
  void _deleteItem(int itemId) async {
    try {
      final response =
          await dio.delete('http://localhost:8000/api/item/delete/$itemId');

      if (response.data['status'] == true) {
        // Remove the deleted item from the list
        data.removeWhere((item) => item['id'] == itemId);
        setState(() {});
      } else {
        // Handle error or no data found
        name = 'Data not found';
      }
    } catch (e) {
      print(e.toString());
      // Handle any network or request errors
      name = 'Error occurred';
    }
  }

// Function to send a PUT request to update an item
  void _updateItem(int itemId) async {
    try {
      final response =
          await dio.put('http://localhost:8000/api/item/edit/$itemId', data: {
        'name': name,
        'desc': desc,
      });

      if (response.data['status'] == true) {
        // Update the list of items with the updated item
        final updatedItem = response.data['data'];
        final itemIndex = data.indexWhere((item) => item['id'] == itemId);
        if (itemIndex != -1) {
          data[itemIndex] = updatedItem;
          setState(() {});
        }
      } else {
        // Handle error or no data found
        name = 'Data not found';
      }
    } catch (e) {
      print(e.toString());
      // Handle any network or request errors
      name = 'Error occurred';
    }
  }

  dioGet() async {
    try {
      final response = await dio.get('http://localhost:8000/api/item');
      print(response.data);
      if (response.data['status'] == true) {
        // Extract the name and desc from the data
        data = response.data['data'];
        setState(() {});
      } else {
        // Handle error or no data found
        name = 'Data not found';
      }
    } catch (e) {
      print(e.toString());
      // Handle any network or request errors
      name = 'Error occurred';
    }
  }

  @override
  void initState() {
    dioGet();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: const Color.fromARGB(255, 232, 232, 232),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data[index]['name']),
                        Text(
                          '${data[index]['desc']}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                _openEditItemModal(context,
                                    index); // Open edit dialog with current item data
                              },
                              child: const Text('Edit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // Floating Action Button for creating a new item
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openCreateItemModal(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
