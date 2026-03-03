import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class Note {
  String id;
  String title;
  String content;
  String? imagePath;

  Note({required this.id, required this.title, required this.content, this.imagePath});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'imagePath': imagePath,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        imagePath: json['imagePath'],
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Notas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class NotePage extends StatefulWidget {
  final Note? note;
  const NotePage({super.key, this.note});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? "");
    _contentController = TextEditingController(text: widget.note?.content ?? "");
    _imagePath = widget.note?.imagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(pickedFile.path);
      final File savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Añadir Nota' : 'Editar Nota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'title': _titleController.text,
                  'content': _contentController.text,
                  'imagePath': _imagePath,
                });
              } else {
                Fluttertoast.showToast(msg: "El título no puede estar vacío");
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            if (_imagePath != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => setState(() => _imagePath = null),
                  ),
                ],
              ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showImageSourceActionSheet(context),
                  icon: const Icon(Icons.image),
                  label: const Text("Añadir Imagen"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Settings extends StatefulWidget {
  const Settings({super.key, required this.titel});
  final String titel;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://github.com/D3vDeft');
    if (!await launchUrl(url)) {
      Fluttertoast.showToast(msg: "No se pudo abrir el enlace");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titel)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Me"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Acerca de"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Desarrollado por D3vDeft en agradecimiento a Staicy :D, contacteme en:", textAlign: TextAlign.start,),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: _launchUrl,
                          child: const Text(
                            "https://github.com/D3vDeft",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cerrar"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, List<Note>> _allNotes = {};

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  String _getDateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString('notes_data');
    if (notesJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(notesJson);
      setState(() {
        _allNotes = decoded.map((key, value) {
          return MapEntry(
            key,
            (value as List).map((n) => Note.fromJson(n)).toList(),
          );
        });
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_allNotes.map((key, value) {
      return MapEntry(key, value.map((n) => n.toJson()).toList());
    }));
    await prefs.setString('notes_data', encoded);
  }

  void _selectADay() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      Fluttertoast.showToast(
        msg: 'Notas del día ${picked.day}/${picked.month}/${picked.year}',
      );
    }
  }

  void _navigateToNotePage({Note? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotePage(note: note),
      ),
    );

    if (result != null) {
      final dateKey = _getDateKey(_selectedDate);
      setState(() {
        if (!_allNotes.containsKey(dateKey)) {
          _allNotes[dateKey] = [];
        }

        if (note == null) {
          _allNotes[dateKey]!.add(Note(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: result['title'],
            content: result['content'],
            imagePath: result['imagePath'],
          ));
        } else {
          final index = _allNotes[dateKey]!.indexWhere((n) => n.id == note.id);
          if (index != -1) {
            _allNotes[dateKey]![index].title = result['title'];
            _allNotes[dateKey]![index].content = result['content'];
            _allNotes[dateKey]![index].imagePath = result['imagePath'];
          }
        }
      });
      _saveNotes();
    }
  }

  void _deleteNote(Note note) {
    final dateKey = _getDateKey(_selectedDate);
    setState(() {
      _allNotes[dateKey]?.removeWhere((n) => n.id == note.id);
    });
    _saveNotes();
    Fluttertoast.showToast(msg: 'Nota eliminada');
  }

  @override
  Widget build(BuildContext context) {
    final dateKey = _getDateKey(_selectedDate);
    final currentNotes = _allNotes[dateKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("${widget.title} - ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
      ),
      body: currentNotes.isEmpty
          ? const Center(child: Text("No hay notas para este día."))
          : ListView.builder(
              itemCount: currentNotes.length,
              itemBuilder: (context, index) {
                final note = currentNotes[index];
                return Dismissible(
                  key: Key(note.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _deleteNote(note);
                  },
                  child: ListTile(
                    leading: note.imagePath != null
                        ? Image.file(File(note.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image_not_supported_outlined),
                    title: Text(note.title),
                    subtitle: Text(
                      note.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _navigateToNotePage(note: note),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Settings(titel: 'Settings'),
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: _selectADay,
            tooltip: 'Seleccionar día',
            child: const Icon(Icons.calendar_month),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () => _navigateToNotePage(),
            tooltip: 'Añadir nota',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
