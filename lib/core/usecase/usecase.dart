import 'package:equatable/equatable.dart';
import 'package:fileflow/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract class Usecase<Success, Params> {
  Future<Either<Failure, Success>> call(Params params);
}

abstract class StreamUseCase<T, Params> {
  Stream<T> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
