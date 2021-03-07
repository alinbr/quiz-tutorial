import 'package:quiz/enums/difficulty.dart';
import 'package:quiz/models/question_model.dart';

abstract class BaseQuizRepository {
  Future<List<Question>> getQuestions({
    int numQuestions,
    int categoryId,
    Difficulty difficulty
  });
}
