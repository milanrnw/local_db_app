import 'package:flutter/material.dart';
import 'package:local_database_app/data/local/db_helper.dart';

class NoteBottomSheet extends StatefulWidget {
  final DbHelper dbHelper;
  final VoidCallback onNoteAddedOrUpdated;
  final Map<String, dynamic>? note; // Nullable for adding a new note

  const NoteBottomSheet({
    super.key,
    required this.dbHelper,
    required this.onNoteAddedOrUpdated,
    this.note,
  });

  @override
  State<NoteBottomSheet> createState() => _NoteBottomSheetState();
}

class _NoteBottomSheetState extends State<NoteBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late bool _isUpdate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.note?[DbHelper.COLUMN_NOTE_TITLE] ?? '',
    );
    _descController = TextEditingController(
      text: widget.note?[DbHelper.COLUMN_NOTE_DESC] ?? '',
    );
    _isUpdate = widget.note != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _addOrUpdateNote() async {
    final title = _titleController.text;
    final desc = _descController.text;

    if (title.isNotEmpty && desc.isNotEmpty) {
      bool success = false;
      if (_isUpdate) {
        success = await widget.dbHelper.updateNote(
          mTitle: title,
          mDesc: desc,
          srno: widget.note![DbHelper.COLUMN_NOTE_SRNO],
        );
      } else {
        success = await widget.dbHelper.addNote(mTitle: title, mDesc: desc);
      }

      if (success) {
        widget.onNoteAddedOrUpdated();
        Navigator.pop(context); // Close the bottom sheet
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all details")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for bottom sheet
        children: [
          Text(
            _isUpdate ? "Update Note" : "Add Note",
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: "Note Title",
              labelText: "Title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              hintText: "Note Description",
              labelText: "Description",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _addOrUpdateNote,
                  child: Text(_isUpdate ? "Update Note" : "Add Note"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
