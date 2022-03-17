import 'package:flutter/material.dart';
import 'package:myapp/Backend/storage_adapter.dart';
import 'package:myapp/value/value_classes.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:myapp/widget/error_dialog.dart';

class ThingsboardAdapterClient {
  StorageAdapter sa = StorageAdapter();
  // ignore: prefer_typing_uninitialized_variables
  var _tbClient;

  /// Variable for the Thingsboard Client
  // ignore: prefer_typing_uninitialized_variables
  var _device;

  /// Variablelist for all device
  late BuildContext _context;

  /// BuildContext
  late TelemetrySubscriber _subscription;

  /// Variable to controll the Subscription
  bool _logedin = false;
  bool _subscriped = false;

  /// Last Values
  Value lastCo2 = Value(0, 0, 'Co2');
  Value lastTemp = Value(0, 0, 'Temperature');
  Value lastHum = Value(0, 0, 'Humidity');

  /// Constructor
  ThingsboardAdapterClient();

  void setcontext(context) {
    _context = context;
  }

  /// reset the values when you change the device
  void resetvalues() {
    lastCo2.resetvalues();
    lastTemp.resetvalues();
    lastHum.resetvalues();
  }

  /// Function to get the information if the client is logedin for other classes
  bool islogedin() {
    return _logedin;
  }

  /// Function to login to the WebSocket
  Future<void> login() async {
    debugPrint('http://${sa.getElementwithkey("IPAddress")}:8080');
    // setApi();
    if (!_logedin) {
      try {
        // Create instance of ThingsBoard API Client
        _tbClient = ThingsboardClient(
            'http://${sa.getElementwithkey("IPAddress")}:8080');
        debugPrint("Client init.");
        await _tbClient.login(LoginRequest(sa.getElementwithkey("Username"),
            sa.getElementwithkey("Password")));
        debugPrint("Is loged in?");
        if (_tbClient.isAuthenticated()) {
          _logedin = true;
          debugPrint("Is loged in.");
        } else {
          showMyDialog(_context, this);
          debugPrint("Is not loged in.");
        }
      } catch (e) {
        showMyDialog(_context, this);
      }
    }
  }

  /// Function for getting import info about a device
  Future<void> getdevice(var deviceId) async {
    if (!_logedin) {
      login();
    }
    _device = await _tbClient.getDeviceService().getDeviceInfo(deviceId);
  }

  /// Function for getting the List of possible devices
  Future<List?> getDevices() async {
    if (_logedin) {
      var _devices = [[], []];

      var pageLink = PageLink(10);
      PageData<DeviceInfo> devices;

      devices = await _tbClient.getDeviceService().getCustomerDeviceInfos(
          _tbClient!.getAuthUser()!.customerId, pageLink);
      var dev = devices.data.iterator;
      while (dev.moveNext()) {
        var id = dev.current.id!.id;
        var name = dev.current.name;
        _devices[0].add(name);
        _devices[1].add(id);
      }
      debugPrint('devices: $_devices');
      return _devices;
    } else {
      return null;
    }
  }

  /// Function for loging out the Client
  Future<void> logout() async {
    if (_logedin && !_subscriped) {
      await _tbClient.logout();
      _logedin = false;
    }
  }

  /// Function for subscribing the WebSocket
  /// Source: https://thingsboard.io/docs/reference/dart-client/
  Future<TelemetrySubscriber> subscripe() async {
    /// Create entity filter to get device by its name
    var entityFilter = EntityNameFilter(
        entityType: EntityType.DEVICE, entityNameFilter: _device.name);

    /// Prepare list of queried device fields
    var deviceFields = <EntityKey>[
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'name'),
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'type'),
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'createdTime')
    ];

    /// Prepare list of queried device timeseries
    var deviceTelemetry = <EntityKey>[
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'Temperature'),
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'Humidity'),
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'Co2')
    ];

    /// Create entity query with provided entity filter, queried fields and page link
    var devicesQuery = EntityDataQuery(
        entityFilter: entityFilter,
        entityFields: deviceFields,
        latestValues: deviceTelemetry,
        pageLink: EntityDataPageLink(
            pageSize: 10,
            sortOrder: EntityDataSortOrder(
                key: EntityKey(
                    type: EntityKeyType.ENTITY_FIELD, key: 'createdTime'),
                direction: EntityDataSortOrderDirection.DESC)));

    /// Create timeseries subscription command to get data for 'temperature' and 'humidity' keys for last hour with realtime updates
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var timeWindow = const Duration(hours: 1).inMilliseconds;

    var tsCmd = TimeSeriesCmd(
        keys: ['Temperature', 'Humidity', 'Co2'],
        startTs: currentTime - timeWindow,
        timeWindow: timeWindow);

    /// Create subscription command with entities query and timeseries subscription
    var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);

    /// Create subscription with provided subscription command
    var telemetryService = _tbClient.getTelemetryService();
    _subscription = TelemetrySubscriber(telemetryService, [cmd]);

    /// Perform subscribe (send subscription command via WebSocket API and listen for responses)
    _subscription.subscribe();

    debugPrint('Subscriped!');
    _subscriped = true;
    return _subscription;
  }

  /// Function for Dataprocessing
  void dataupdate(EntityDataUpdate entityDataUpdate) {
    // debugPrint(entityDataUpdate.toString());
    // debugPrint("------------------------------------------------");
    try {
      if (entityDataUpdate.data != null) {
        // debugPrint(
        //     "first: ${entityDataUpdate.data!.data.first.latest.values.first.toString().contains("Temperature", 0)}");
        // debugPrint(
        //     "last: ${entityDataUpdate.data!.data.last.latest.values.last.toString().contains("Temperature", 0)}");

        var keys =
            entityDataUpdate.data!.data.first.latest.values.first.keys.iterator;
        var values = entityDataUpdate
            .data!.data.first.latest.values.first.values.iterator;

        if (entityDataUpdate.data!.data.last.latest.values.last
            .toString()
            .contains("Temperature", 0)) {
          keys =
              entityDataUpdate.data!.data.last.latest.values.last.keys.iterator;
          values = entityDataUpdate
              .data!.data.last.latest.values.last.values.iterator;
        }

        while (keys.moveNext() && values.moveNext()) {
          debugPrint(
              '----First----${keys.current}----${values.current.ts}----${values.current.value}----');

          if (keys.current == 'Co2') {
            debugPrint('----------------Co2----------------');
            lastCo2.setts(values.current.ts);
            if (values.current.ts == 0) {
              lastCo2.setvalue(0);
            } else {
              lastCo2.setvalue(int.parse(values.current.value.toString()));
            }
          }
          if (keys.current == 'Temperature') {
            debugPrint('----------------Temperature----------------');
            lastTemp.setts(values.current.ts);
            if (values.current.ts == 0) {
              lastTemp.setvalue(0);
            } else {
              lastTemp.setvalue(int.parse(values.current.value.toString()));
            }
          }
          if (keys.current == 'Humidity') {
            debugPrint('----------------Humidity----------------');
            lastHum.setts(values.current.ts);
            if (values.current.ts == 0) {
              lastHum.setvalue(0);
            } else {
              lastHum.setvalue(int.parse(values.current.value.toString()));
            }
          }
        }
      } else {
        debugPrint("----Data-Update----");

        var it = entityDataUpdate.update!.first.timeseries.values.iterator;
        var keys = entityDataUpdate.update!.first.timeseries.keys.iterator;

        while (it.moveNext() && keys.moveNext()) {
          String? value = it.current.first.value;
          int ts = it.current.first.ts;
          debugPrint(
              "----Update----${keys.current}----${ts.toString()}----$value----");

          if (keys.current == 'Co2') {
            debugPrint('----------------Co2----------------');
            lastCo2.setts(ts);
            lastCo2.setvalue(int.parse(value.toString()));
          }
          if (keys.current == 'Temperature') {
            debugPrint('----------------Temperature----------------');
            lastTemp.setts(ts);
            lastTemp.setvalue(int.parse(value.toString()));
          }
          if (keys.current == 'Humidity') {
            debugPrint('----------------Humidity----------------');
            lastHum.setts(ts);
            lastHum.setvalue(int.parse(value.toString()));
          }
        }
      }
    } catch (e) {
      debugPrint("ERROR: Datenverarbeitung");
      debugPrint(e.toString());
    }
  }

  /// Function for unsubscribe the WebSocket
  Future<void> unsubscripe() async {
    if (_subscriped) {
      try {
        /// Finally unsubscribe to release subscription
        _subscription.unsubscribe();
        _subscriped = false;
        debugPrint('Unsubscriped');
      } catch (e) {
        debugPrint('ERROR: Unscription failed!');
        debugPrint(e.toString());
      }
    }
  }
}
