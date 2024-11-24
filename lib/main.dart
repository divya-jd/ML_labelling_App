import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageLabelingPage(),
    );
  }
}

class ImageLabelingPage extends StatefulWidget {
  @override
  _ImageLabelingPageState createState() => _ImageLabelingPageState();
}

class _ImageLabelingPageState extends State<ImageLabelingPage> {
  File? _image;
  final picker = ImagePicker();
  List<Map<String, dynamic>> _labels = [];

  /// Picks an image from the gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _labels = []; // Clear previous labels
      });

      // Perform image labeling
      await labelImage(_image!);
    }
  }

  /// Uses ML Kit to label the image
  Future<void> labelImage(File image) async {
    final InputImage inputImage = InputImage.fromFile(image);

    // Initialize the ImageLabeler
    final ImageLabeler labeler = ImageLabeler(options: ImageLabelerOptions());

    // Process the image and get labels
    final List<ImageLabel> labels = await labeler.processImage(inputImage);

    setState(() {
      _labels = labels
          .map((label) => {
                'label': label.label,
                'confidence': label.confidence,
              })
          .toList();
    });

    labeler.close(); // Clean up resources
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Labeling with Confidence"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          if (_image != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                _image!,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => pickImage(ImageSource.camera),
                icon: Icon(Icons.camera),
                label: Text("Camera"),
              ),
              SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () => pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo_library),
                label: Text("Gallery"),
              ),
            ],
          ),
          Expanded(
            child: _labels.isNotEmpty
                ? ListView.builder(
                    itemCount: _labels.length,
                    itemBuilder: (context, index) {
                      final label = _labels[index];
                      return ListTile(
                        title: Text(label['label']),
                        subtitle: Text(
                          "Confidence: ${(label['confidence'] * 100).toStringAsFixed(2)}%",
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "No labels detected",
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
