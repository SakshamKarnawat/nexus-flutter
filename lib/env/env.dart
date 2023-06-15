import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'HUGGINGFACE_KEY' /* , obfuscate: true */)
  // Any variables annotated with the obfuscate flag should be declared as final (not const).
  static const String huggingFaceKey = _Env.huggingFaceKey;

  @EnviedField(varName: 'RAPIDAPI_KEY' /* , obfuscate: true */)
  // Any variables annotated with the obfuscate flag should be declared as final (not const).
  static const String rapidAPIKey = _Env.rapidAPIKey;
}
