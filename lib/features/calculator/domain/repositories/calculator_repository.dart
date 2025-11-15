import 'package:shopping_list/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

import '../../../article/data/models/article_model.dart';
import '../../data/models/calculator_model.dart';

abstract interface class CalculatorRepository {
  Future<Either<Failure, List<CalculatorModel>>> getAll();
  Future<Either<Failure, List<CalculatorModel>>> getAllWithArticle();
  Future<Either<Failure, List<CalculatorModel>>> getAllWithoutArticle();
  Future<Either<Failure, List<CalculatorModel>>> add({required CalculatorModel value});
  Future<Either<Failure, List<CalculatorModel>>> addWithoutArticle({required String idList, required double price});
  Future<Either<Failure, List<CalculatorModel>>> subtract({required CalculatorModel value});
  Future<Either<Failure, List<CalculatorModel>>> subtractWithoutArticle({required CalculatorModel value});
  Future<Either<Failure, List<CalculatorModel>>> reset({String? idList});
  Future<Either<Failure, List<CalculatorModel>>> resetWith({String? idList, List<ArticleModel> articles = const []});
  Future<Either<Failure, List<CalculatorModel>>> resetWithoutArticle({String? idList, List<String> articles = const []});
}
