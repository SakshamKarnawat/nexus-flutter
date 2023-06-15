# nexus

A voice assistant app integrated with ChatGPT and Dall-E to generate images and text based on user input.

## Features
- [x] Generate text based on voice input
- [x] Generate images based on voice input
- [x] Download and share generated images
- [x] Understands conversational context
- [x] Text to Speech functionality
- [x] Animations
<!-- - [x] Dark mode -->
<!-- - [x] Storing messages locally using Hive or SQLite -->

## How to run

1. Clone the repo
2. Generate a new API key from [here](https://openai.com/blog/openai-api/)
3. Create a new file called `.env' in the root directory of the project
4. Add the following line to the `.env` file
   - `OPENAI_KEY=<YOUR_API_KEY>`
5. Run these two commands in the terminal to install the dev dependencies
   - `flutter pub add --dev envied_generator`
   - `flutter pub add --dev build_runner`
6. Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate the `.env.g.dart` file
7. Use `Env.openaiKey` to access the API key in the code
8. Run the app using `flutter run`

## Note

- To obfuscate the API key, the `.env` and `env.g.dart` files are added to the `.gitignore` file. This means that the API key will not be pushed to the repo.

- Uncomment the obfuscate flag in `env.dart` and change `const` to `final` to obfuscate the API key for production builds.