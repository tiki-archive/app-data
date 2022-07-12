import '../account/account_model.dart';

class FetchProgress {

  int _amountFetched;
  int _totalToFetch;

  FetchProgress(this._amountFetched, this._totalToFetch);

  get totalToFetch => _totalToFetch;
  get amountFetched => _amountFetched;

}