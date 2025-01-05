import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tasks/controllers/supabase/supabase_controller.dart';
import 'package:tasks/controllers/themes/theme_style.dart';

class DetailTaskPage extends StatelessWidget {
  final Map<String, dynamic> task;
  DetailTaskPage({required this.task, super.key});

  final SupabaseController controller = Get.put(SupabaseController());
  final RxBool isImportant = false.obs;
  final RxString selectedListName = ''.obs;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final Rx<TextEditingController> dateController = TextEditingController().obs;
  final Rx<TextEditingController> timeController = TextEditingController().obs;

  void _updateTask(BuildContext context) {
    if (selectedListName.value.isEmpty ||
        titleController.text.isEmpty ||
        dateController.value.text.isEmpty ||
        timeController.value.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    final Map<String, dynamic> updatedTask = {
      'list_name': selectedListName.value,
      'task_name': titleController.text,
      'description_task': detailsController.text,
      'date': dateController.value.text,
      'time': timeController.value.text,
      'starred': isImportant.value,
    };

    try {
      controller.updateTask(task['id'], updatedTask);
      Get.snackbar('Success!!!!', 'Task updated successfully');
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = task['task_name'] ?? '';
    detailsController.text = task['description_task'] ?? '';
    dateController.value.text = task['date'] ?? '';
    timeController.value.text = task['time'] ?? '';
    isImportant.value = task['starred'] ?? true ;

    controller.fetchLists().then((_) {
      if (controller.listData.isNotEmpty) {
        final existingListName = task['list_name'];
        if (controller.listData
            .any((list) => list['name'] == existingListName)) {
          selectedListName.value = existingListName;
        } else {
          selectedListName.value = controller.listData.first['name'] ?? '';
        }
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Task Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => _updateTask(context),
            child: const Text('Save'),
          ),
        ],
      ),
      body: Obx(() {
        return controller.listData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.list),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedListName.value.isEmpty
                                ? null
                                : selectedListName.value,
                            items: controller.listData
                                .map<DropdownMenuItem<String>>((list) {
                              final listName = list['name'] as String?;
                              return DropdownMenuItem<String>(
                                value: listName,
                                child: Text(listName ?? 'Unknown'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              selectedListName.value = value ?? '';
                            },
                            decoration: const InputDecoration(
                              hintText: 'Select list',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.title),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              hintText: 'Task title',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.article),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: detailsController,
                            decoration: const InputDecoration(
                              hintText: 'Task details',
                              border: UnderlineInputBorder(),
                            ),
                            minLines: 1,
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: dateController.value,
                            decoration: const InputDecoration(
                              hintText: 'Select date',
                              border: UnderlineInputBorder(),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                dateController.value.text =
                                    '${picked.toLocal()}'.split(' ')[0];
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: timeController.value,
                            decoration: const InputDecoration(
                              hintText: 'Select time',
                              border: UnderlineInputBorder(),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (picked != null) {
                                timeController.value.text =
                                    '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            isImportant.value ? Icons.star : Icons.star_border,
                          ),
                          onPressed: () {
                            isImportant.value = !isImportant.value;
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mark as important',
                          style: TextStyle(
                            color:
                                isImportant.value ? blueLight : blueLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
      }),
    );
  }
}