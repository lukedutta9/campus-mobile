// import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/models/parking_model.dart';
import 'package:campus_mobile_experimental/core/services/parking_service.dart';
import 'package:flutter/material.dart';

class ParkingDataProvider extends ChangeNotifier {
  ParkingDataProvider() {
    ///DEFAULT STATES
    _isLoading = false;
    selected = 0;

    ///INITIALIZE SERVICES
    _parkingService = ParkingService();
  }

  ///STATES
  bool _isLoading;
  DateTime _lastUpdated;
  String _error;
  int selected; //Keep less than 10
  static const MAX_SELECTED = 10;

  ///MODELS
  Map<String, ParkingModel> _parkingModels;
  Map<String, bool> _parkingViewState = <String, bool>{};

  ///SERVICES
  ParkingService _parkingService;

  /// FETCH PARKING LOT DATA AND SYNC THE ORDER IF USER IS LOGGED IN
  /// TODO: make sure to remove any lots the user has selected and are no longer available
  void fetchParkingLots() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    /// creating  new map ensures we remove all unsupported lots
    Map<String, ParkingModel> newMapOfLots = Map<String, ParkingModel>();
    if (await _parkingService.fetchParkingLotData()) {
      for (ParkingModel model in _parkingService.data) {
        newMapOfLots[model.locationName] = model;

        if (selected <= MAX_SELECTED) {
          _parkingViewState[model.locationName] = true;
          ++selected;
        }else{
          _parkingViewState[model.locationName] = false;
        }
      }

      ///replace old list of lots with new one
      _parkingModels = newMapOfLots;

      //TODO Add user selected spots

      /// if the user is logged in we want to sync the order of parking lots amongst all devices
      // if (_userDataProvider != null) {
      //   reorderLots(_userDataProvider.userProfileModel.selectedLots);
      // }
      _lastUpdated = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error = _parkingService.error;
    }
    _isLoading = false;
    notifyListeners();
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;

  ///RETURNS A List<ParkingModels> IN THE CORRECT ORDER
  List<ParkingModel> get parkingModels {
    ///check if we have an offline _parkingModel
    if (_parkingModels != null) {
      ///check if we have an offline _userProfileModel
      // if (_userDataProvider.userProfileModel != null) {
      //   return makeOrderedList(_userDataProvider.userProfileModel.selectedLots);
      // }
      return _parkingModels.values.toList();
    }
    return List<ParkingModel>();
  }

// add or remove location availability display from card based on user selection, Limit to MAX_SELECTED
  void toggleLot(String location) {
    if (selected <= MAX_SELECTED) {
      _parkingViewState[location] = !_parkingViewState[location];
      _parkingViewState[location] ? selected++ : selected--;
    } else {
      //prevent select
      if (_parkingViewState[location]) {
        selected--;
        _parkingViewState[location] = !_parkingViewState[location];
      }
    }
    notifyListeners();
  }

  Map<String, bool> get parkingViewState => _parkingViewState;
}
