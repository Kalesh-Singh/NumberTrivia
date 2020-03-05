import 'package:dartz/dartz.dart';
import 'package:numbertriviaapp/core/error/failures.dart';
import 'package:numbertriviaapp/core/use_cases/use_case.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:numbertriviaapp/features/number_trivia/domain/repositories/number_trivia_repository.dart';

class GetRandomNumberTrivia implements UseCase<NumberTrivia, NoParams> {

  final NumberTriviaRepository repository;

  const GetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(NoParams params) async {
    return await repository.getRandomNumberTrivia();
  }

}
