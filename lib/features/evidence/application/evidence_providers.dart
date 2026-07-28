import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final cameraEvidencePickerProvider = Provider<CameraEvidencePicker>((ref) {
  return CameraEvidencePicker(ImagePicker());
});

class CameraEvidencePicker {
  CameraEvidencePicker(this._picker);

  final ImagePicker _picker;

  Future<XFile?> capture() {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 68,
      maxWidth: 720,
      maxHeight: 720,
    );
  }
}
