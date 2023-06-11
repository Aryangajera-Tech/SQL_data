import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sql_data/sql_helper.dart';

class DataStore extends StatefulWidget {
  const DataStore({Key? key}) : super(key: key);

  @override
  State<DataStore> createState() => _DataStoreState();
}

class _DataStoreState extends State<DataStore> {
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rollnoController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
      _addressController.text = existingJournal['address'];
      _rollnoController.text = existingJournal['rollno'];
      _ageController.text = existingJournal['age'];
    }

    showModalBottomSheet(
        context: context,
        // elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 80,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ))),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ))),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                      controller: _rollnoController,
                      decoration: InputDecoration(
                          labelText: 'Rollno',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ))),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                      controller: _ageController,
                      decoration: InputDecoration(
                          labelText: 'Age',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ))),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      _nameController.clear();
                      _addressController.clear();
                      _rollnoController.clear();
                      _ageController.clear();

                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            )
    );
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(_nameController.text, _addressController.text,
        _rollnoController.text, _ageController.text);
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _nameController.text,
        _addressController.text, _rollnoController.text, _ageController.text);
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  void showAlertDialog(BuildContext context, index) {
    //get data
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Data"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Name: " + " " + _journals[index]['name'],
            style: TextStyle(fontSize: 25),
          ),
          Text(
            "Address: " + " " + _journals[index]['address'],
            style: TextStyle(fontSize: 25),
          ),
          Text(
            "Rollno: " + " " + _journals[index]['rollno'],
            style: TextStyle(fontSize: 25),
          ),
          Text(
            "Age: " + " " + _journals[index]['age'],
            style: TextStyle(fontSize: 25),
          ),
        ],
      ),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'student data',
          style: TextStyle(fontSize: 25),
        )),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _journals.length,
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  showAlertDialog(context, index);
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.orange, width: 3),
                  ),
                  // color: Colors.orange[200],
                  margin: const EdgeInsets.all(15),
                  // color: const Color.fromARGB(255, 248, 249, 248),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                    child: ListTile(
                        leading: Text('${index + 1}',
                            style:
                                TextStyle(fontSize: 30, color: Colors.black87)),
                        title: Text(
                          _journals[index]['name'],
                          style: TextStyle(fontSize: 25, color: Colors.black87),
                        ),
                        // subtitle: Text(_journals[index]['address']),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.black87,
                                ),
                                onPressed: () =>
                                    _showForm(_journals[index]['id']),
                              ),
                              IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.black87),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Delete"),
                                          content: Text(
                                              "Are you sure you want to delete this item?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                _deleteItem(
                                                    _journals[index]['id']);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Delete"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Cancel"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }),
                            ],
                          ),
                        )),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
