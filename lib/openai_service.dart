import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nexus/env/env.dart';

enum StatusCodes {
  success,
  invalidKey,
  limitReached,
  internalError,
}

class OpenAIService {
  final List<Map<String, String>> messages = [];

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(
            // "https://api-inference.huggingface.co/models/microsoft/DialoGPT-large",
            "https://chatgpt53.p.rapidapi.com"),
        headers: {
          "content-type": "application/json",
          'X-RapidAPI-Key': Env.rapidAPIKey,
          'X-RapidAPI-Host': 'chatgpt53.p.rapidapi.com',
          // "Authorization": "Bearer ${Env.huggingFaceKey}",
        },
        body: jsonEncode({
          // "inputs": {
          //   "text":
          //       "Does this message want to generate an AI picture, image, art, or anything similar to that: $prompt \n\n Just reply with a one word answer of either a 'yes' or a 'no'.",
          // },
          // "parameters": {
          //   "max_length": 3,
          // },
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content":
                  "Does this message want to generate an AI picture, image, art, or anything similar to that: $prompt \n\n Just reply with a one word answer of either a 'yes' or a 'no' in lowercase and without any punctuation.",
            },
          ],
        }),
      );
      if (response.statusCode == 200) {
        String chatGPTResponse =
            jsonDecode(response.body)["choices"][0]["message"]["content"];
        chatGPTResponse = chatGPTResponse.trim().toLowerCase();
        if (chatGPTResponse.contains("yes")) {
          final res = await dallEAPI(prompt);
          return res;
        } else {
          final res = await chatGPTAPI(prompt);
          return res;
        }
      } else if (response.statusCode == 401) {
        throw Exception("Invalid API Key.");
      } else if (response.statusCode == 429) {
        throw Exception("API Key has reached its limit.");
      }
      throw Exception("An internal error occured.");
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add(
      {
        "role": "user",
        "content": prompt,
      },
    );
    try {
      final response = await http.post(
        Uri.parse("https://chatgpt53.p.rapidapi.com"),
        headers: {
          "content-type": "application/json",
          'X-RapidAPI-Key': Env.rapidAPIKey,
          'X-RapidAPI-Host': 'chatgpt53.p.rapidapi.com',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );
      if (response.statusCode == 200) {
        String chatGPTResponse =
            jsonDecode(response.body)["choices"][0]["message"]["content"];
        chatGPTResponse = chatGPTResponse.trim();
        messages.add(
          {
            "role": "assistant",
            "content": chatGPTResponse,
          },
        );
        return chatGPTResponse;
      } else if (response.statusCode == 401) {
        throw Exception("Invalid API Key.");
      } else if (response.statusCode == 429) {
        throw Exception("API Key has reached its limit.");
      }
      throw Exception("An internal error occured.");
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add(
      {
        "role": "user",
        "content": prompt,
      },
    );
    try {
      print("inside dalle api with prompt: $prompt");
      final response = await http.post(
        Uri.parse("https://openai80.p.rapidapi.com/images/generations"),
        headers: {
          "content-type": "application/json",
          'X-RapidAPI-Key': Env.rapidAPIKey,
          'X-RapidAPI-Host': 'openai80.p.rapidapi.com',
        },
        body: jsonEncode({
          "prompt": prompt,
          "n": 1,
          "response_format": "url",
        }),
      );
      print("status code: ${response.statusCode}");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        String imageUrl = jsonDecode(response.body)["data"][0]["url"];
        imageUrl = imageUrl.trim();
        messages.add(
          {
            "role": "assistant",
            "content": imageUrl,
          },
        );
        return imageUrl;
      } else if (response.statusCode == 401) {
        throw Exception("Invalid API Key.");
      } else if (response.statusCode == 429) {
        throw Exception("API Key has reached its limit.");
      }
      throw Exception("An internal error occured.");
    } catch (e) {
      return e.toString();
    }
  }
}
