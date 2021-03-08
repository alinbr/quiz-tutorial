import 'dart:io';

import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz/models/failure.dart';
import 'package:quiz/models/question_model.dart';
import 'package:quiz/enums/difficulty.dart';
import 'package:quiz/repositories/base_quiz_repository.dart';

final dioProvider = Provider<Dio>((ref) => Dio());


final quizRepositoryProvider = Provider<QuizRepository>((ref) => QuizRepository(ref.read));

class QuizRepository extends BaseQuizRepository {
  final Reader _read;

  QuizRepository(this._read);

  @override
  Future<List<Question>> getQuestions({
    int numQuestions,
    int categoryId,
    Difficulty difficulty,
  }) async {
    
    try {
      final queryParams = {
        'type': 'multiple',
        'amount': numQuestions,
        'category': categoryId,
      };

      if (difficulty != Difficulty.any) {
        queryParams.addAll({
          'difficulty': EnumToString.convertToString(difficulty)
        });
      }

      final response = await _read(dioProvider).get('https://opentdb.com/api.php', queryParameters: queryParams,);

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        print(response.data);
        final results = List<Map<String, dynamic>>.from(data['results'] ?? []);
        if (results.isNotEmpty) {
          return results.map((e) => Question.fromMap(e)).toList();
        }
      }

      return [];

    } on DioError catch (err) {
      print(err);
      throw Failure(message: err.response?.statusMessage);
    } on SocketException catch (err) {
      print(err);
      throw Failure(message: 'Please check connection.');
    }
  }
}
