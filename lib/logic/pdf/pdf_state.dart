import 'package:equatable/equatable.dart';

abstract class PdfState extends Equatable{
  const PdfState();
  @override
  List<Object> get props => [];
}

class PdfInitial extends PdfState {}

class PdfLoading extends PdfState {}

class PdfSuccess extends PdfState {
  final String message;
  const PdfSuccess(this.message);
}

class PdfError extends PdfState {
  final String message;
  const PdfError(this.message);
}
