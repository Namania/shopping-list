import 'package:equatable/equatable.dart';

/// An amount entered in the calculator: the price of an article, or an
/// amount added by hand ([articleId] is then `null`). Amounts added from the
/// calculator of all lists belong to no list ([listId] is `null`).
class Price extends Equatable {
  final String id;
  final String? listId;
  final String? articleId;
  final int cents;

  const Price({required this.id, required this.cents, this.listId, this.articleId});

  double get amount => cents / 100;

  Price copyWithCents(int cents) => Price(id: id, listId: listId, articleId: articleId, cents: cents);

  @override
  List<Object?> get props => [id, listId, articleId, cents];
}
