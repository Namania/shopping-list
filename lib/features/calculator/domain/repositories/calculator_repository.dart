import 'package:shopping_list/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

import '../../../article/data/models/article_model.dart';
import '../../data/models/Calculator_model.dart';

abstract interface class CalculatorRepository {
  Future<Either<Failure, List<CalculatorModel>>> getAll();
  Future<Either<Failure, List<CalculatorModel>>> getAllWithArticle();
  Future<Either<Failure, List<CalculatorModel>>> getAllWithoutArticle();
  Future<Either<Failure, List<CalculatorModel>>> add({required CalculatorModel value});
  Future<Either<Failure, List<CalculatorModel>>> addWithoutArticle({required double price});
  Future<Either<Failure, List<CalculatorModel>>> subtract({required CalculatorModel value});
  Future<Either<Failure, List<CalculatorModel>>> subtractWithoutArticle({required CalculatorModel value});
  Future<Either<Failure, List<CalculatorModel>>> reset();
  Future<Either<Failure, List<CalculatorModel>>> resetWith({List<ArticleModel> articles = const []});
  Future<Either<Failure, List<CalculatorModel>>> resetWithoutArticle({List<String> articles = const []});
}
