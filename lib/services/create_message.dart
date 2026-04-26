// NOTE: Make sure to run `flutter pub add nobodywho` in your terminal!
// download model into /assets from https://huggingface.co/NobodyWho/Google_Gemma3-270M-GGUF/tree/main
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:nobodywho/nobodywho.dart' as nobodywho;
import 'package:path_provider/path_provider.dart';
import '../UI/small_card/small_card.dart';



class MessageCreationService {
  nobodywho.Chat? _chatEngine;

  /// Initializes the local LLM. You should ideally call this once when your app starts.
  Future<void> initModel() async {
    if (_chatEngine != null) return;

    await nobodywho.NobodyWho.init();
    
    // NobodyWho reads the model from the filesystem, so we copy it from 
    // Flutter's asset bundle to the app's documents directory on first launch.
    final dir = await getApplicationDocumentsDirectory();
    final model = File('${dir.path}/gemma-3-270m-it-Q4_K_M.gguf');

    if (!await model.exists()) {
      final data = await rootBundle.load('assets/gemma-3-270m-it-Q4_K_M.gguf');
      await model.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }

    // Initialize the engine with the local filesystem path
    _chatEngine = await nobodywho.Chat.fromPath(
      modelPath: model.path,
    );
  }

  /// Generates a push notification text using context and a recommended shop.
  Future<String> generatePushNotification({
    required DateTime time,
    required double rain,
    required double temperature,
    required ShopData recommendedShop,
  }) async {
    // 1. Construct the prompt for the language model
    String weatherContext = rain > 0 ? "It's raining outside." : "The weather is clear.";
    String prompt = '''
You are a helpful assistant for a local referral app.
Context:
- Time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}
- Weather: $temperature°C, $weatherContext
- Recommended Shop: ${recommendedShop.name} (Category: ${recommendedShop.category})
- Coupon Amount: ${recommendedShop.couponAmount}% off

Generate a short, friendly, and engaging push notification (max 100 characters) 
suggesting the user to visit this shop right now. Include the context and coupon amount.
''';

    // 2. Ensure model is initialized
    await initModel();

    // 3. Ask the local model to generate the response.
    // Note: The exact method name might differ slightly depending on the package version 
    // (e.g., .sendMessage(), .generate(), or a stream listener). 
    try {
      // Using the exact API from the docs:
      final response = await _chatEngine!.ask(prompt).completed(); 
      return response; 
    } catch (e) {
      print("Local LLM failed: $e");
      return "Check out ${recommendedShop.name} today!"; // Fallback required by Dart since the function must return a String
    }
  }

  /// Generates widget text using context and a recommended shop.
  /// Provides more detailed text than push notifications since widgets have more space.
  Future<String> generateWidgetText({
    required DateTime time,
    required double rain,
    required double temperature,
    required ShopData recommendedShop,
  }) async {
    // 1. Construct the prompt for the language model
    String weatherContext = rain > 0 ? "It's raining outside." : "The weather is clear.";
    String prompt = '''
You are a helpful assistant for a local referral app.
Context:
- Time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}
- Weather: $temperature°C, $weatherContext
- Recommended Shop: ${recommendedShop.name} (Category: ${recommendedShop.category})
- Coupon Amount: ${recommendedShop.couponAmount}% off

Generate a friendly and engaging widget text (max 300 characters) 
recommending the user to visit this shop. You have more space, so provide more detail and context.
Include the shop name, category, weather/time relevance, and coupon amount.
Make it informative and persuasive.
''';

    // 2. Ensure model is initialized
    await initModel();

    // 3. Ask the local model to generate the response.
    try {
      final response = await _chatEngine!.ask(prompt).completed(); 
      return response; 
    } catch (e) {
      print("Local LLM failed: $e");
      return "${recommendedShop.name} - ${recommendedShop.category}\n${recommendedShop.couponAmount}% off | Perfect for this weather!"; // Fallback
    }
  }
}
