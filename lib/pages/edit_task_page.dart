import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;

class EditTaskPage extends StatefulWidget {
  final int id;

  EditTaskPage({Key? key, required this.id}) : super(key: key);

  @override
  State<EditTaskPage> createState() => _CreateTaskPageState(id);
}

class _CreateTaskPageState extends State<EditTaskPage> {
  int id;

  _CreateTaskPageState(this.id);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _taskTimeController =
      TextEditingController(text: DateTime.now().toString());
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
             Text(id.toString()),
            TextFormField(
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            const Text('Story'),
            TextFormField(
              controller: _storyController,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Status'),
            TextFormField(
              controller: _statusController,
            ),
            const SizedBox(height: 16),
            const Text('Task Time'),
            TextFormField(
              onTap: _selectDateTime,
              controller: _taskTimeController,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : onSaveTask,
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onSaveTask() async {
    setState(() {
      isLoading = true;
    });
    final Uri _uri = Uri.parse('https://gtc.test.ps/api/tasks');

    final http.Response _response =
        await http.post(_uri, body: <String, dynamic>{
      'title': _titleController.text,
      'story': _storyController.text,
      'status': _statusController.text,
      'task_time': _taskTimeController.text,
    });
    print(_response.body);
    print(_response.statusCode);

    isLoading = false;
    setState(() {});
  }

  void _selectDateTime() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 30)),
      onConfirm: (date) {
        _taskTimeController.text = date.toString();
      },
      currentTime: DateTime.now(),
      locale: LocaleType.ar,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (selected == null) {
      _taskTimeController.text = DateTime.now().toString();
    } else {
      _taskTimeController.text = selected.toString();
    }
    setState(() {});
  }
}
