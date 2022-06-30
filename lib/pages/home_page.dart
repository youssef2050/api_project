import 'dart:convert';

import 'package:api_project/pages/create_task_page.dart';
import 'package:api_project/pages/edit_task_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String results = '';
  bool isLoading = false;

  List<dynamic> tasks = [];

  @override
  void initState() {
    super.initState();
    _getApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Of Users'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : RefreshIndicator(
                onRefresh: _getApi,
                child: ListView(
                  children: [
                    for (var _task in tasks)
                      Slidable(
                        key: ValueKey(_task['id']),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          dismissible: DismissiblePane(onDismissed: () async {
                            bool status = await _deleteTask(_task['id']);
                            debugPrint(status.toString());
                          }),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) async {
                                bool status = await _deleteTask(_task['id']);
                                if (status) {
                                  Slidable.of(context)!.dismiss(ResizeRequest(
                                      Duration(milliseconds: 300), () {}));
                                }
                              },
                              backgroundColor: Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) {
                                openEditTaskPage(_task['id']);
                              },
                              backgroundColor: Color(0xFF0392CF),
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Eidet',
                            ),
                          ],
                        ),
                        child: ListTile(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(_task['story']),
                                );
                              },
                            );
                          },
                          leading: Text(_task['id'].toString()),
                          title: Text(_task['title'].toString()),
                          subtitle: Text(_task['task_time']),
                          trailing: _task['status'] == 'new'
                              ? Icon(Icons.lock_clock)
                              : Icon(Icons.check),
                        ),
                      )
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openCreateTaskPage,
        tooltip: 'Increment',
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : Icon(
                Icons.add,
                color: isLoading ? Colors.grey : Colors.white,
              ),
      ),
    );
  }

  void openCreateTaskPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskPage()),
    );
  }

  void openEditTaskPage(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTaskPage(id: id)),
    );
  }

  Future<void> _getApi() async {
    results = 'Loading ...';
    isLoading = true;
    setState(() {});

    Uri _url = Uri.parse('https://gtc.test.ps/api/tasks');

    try {
      Response response = await http.get(_url);

      if (response.statusCode == 200) {
        Map<String, dynamic>? resultsAsJson =
            jsonDecode(response.body) as Map<String, dynamic>;

        tasks = resultsAsJson['data'] ?? [];
        setState(() {});
      } else {
        results = 'Error: ${response.statusCode} -  ${response.reasonPhrase} ';
      }
    } catch (e) {
      results = e.toString();
    }

    isLoading = false;
    setState(() {});
  }

  void _getApiWithoutFuture() {
    results = 'Loading ...';
    isLoading = true;
    setState(() {});

    Uri _url = Uri.parse('http://httpbin.org/response-headers');

    http.get(_url).then((Response response) {
      results = response.body;
      isLoading = false;
      setState(() {});
    });
  }

  Future<bool> _deleteTask(int id) async {
    Uri _url = Uri.parse('https://gtc.test.ps/api/tasks/$id');
    http.Response response = await http.delete(_url);
    return response.statusCode == 202;
  }
}
