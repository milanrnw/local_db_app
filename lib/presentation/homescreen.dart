import 'package:flutter/material.dart';
import 'package:local_database_app/data/local/db_helper.dart';
import 'package:local_database_app/presentation/note_bottom_sheet.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Map<String, dynamic>> allNotes = [];
  DbHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DbHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes"), centerTitle: true),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                final note = allNotes[index];
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(note[DbHelper.COLUMN_NOTE_TITLE]),
                  subtitle: Text(note[DbHelper.COLUMN_NOTE_DESC]),
                  trailing: SizedBox(
                    width: 100, // Increased width to prevent overflow
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showNoteBottomSheet(note: note);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool check = await dbRef!.deleteNote(
                              srno: note[DbHelper.COLUMN_NOTE_SRNO],
                            );
                            if (check) {
                              getNotes();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Note Deleted")),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(child: Text("No notes yet!")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNoteBottomSheet();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNoteBottomSheet({Map<String, dynamic>? note}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard to not cover the sheet
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: NoteBottomSheet(
            dbHelper: dbRef!,
            onNoteAddedOrUpdated: getNotes,
            note: note,
          ),
        );
      },
    );
  }
}
