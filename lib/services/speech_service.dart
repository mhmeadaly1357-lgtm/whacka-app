import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isListening = false;
  String recognizedText = '';

  Function(String)? onResult;
  Function(String)? onError;

  Future<bool> initialize() async {
    final hasPermission = await Permission.microphone.request();
    if (!hasPermission.isGranted) {
      onError?.call('لم يتم منح إذن الميكروفون.');
      return false;
    }

    final available = await _speech.initialize(
      onError: (error) => onError?.call(error.errorMsg ?? 'حدث خطأ في التعرف على الصوت.'),
      onStatus: (status) {
        if (status == 'done') {
          isListening = false;
        }
      },
    );

    return available;
  }

  Future<void> startListening() async {
    recognizedText = '';
    isListening = true;

    await _speech.listen(
      localeId: 'ar_SA',
      onResult: (result) {
        recognizedText = result.recognizedWords;
        onResult?.call(recognizedText);
      },
      partialResults: true,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: false,
    );
  }

  Future<String> stopListening() async {
    await _speech.stop();
    isListening = false;
    return recognizedText;
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    isListening = false;
    recognizedText = '';
  }
}
