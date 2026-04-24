import 'package:flutter/widgets.dart';

mixin AsyncRequestGuardMixin<T extends StatefulWidget> on State<T> {
  int _requestTicket = 0;

  int nextRequestTicket() => ++_requestTicket;

  bool isRequestStale(int requestTicket) =>
      !mounted || requestTicket != _requestTicket;

  bool isRequestCurrent(int requestTicket) =>
      mounted && requestTicket == _requestTicket;
}
