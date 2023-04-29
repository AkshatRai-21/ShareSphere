import 'package:fpdart/fpdart.dart';
import './failure.dart';

//Either<type of failure going to be, Type of the successful that is going to be>
typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = Future<Either<Failure, void>>;
