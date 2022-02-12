import 'package:myapp/wert.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

class Client {
  static const _thingsBoardApiEndpoint = 'http://192.168.2.117:8080';
  // ignore: prefer_typing_uninitialized_variables
  var _tbClient;
  // ignore: prefer_typing_uninitialized_variables
  var _device;
  // ignore: unused_field
  late TelemetrySubscriber _subscription;
  bool _logedin = false;
  bool _deviceknown = false;
  bool _subscriped = false;
  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  Wert LastCo2 = Wert(0, 0, 'Co2');
  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  Wert LastTemp = Wert(0, 0, 'Temperature');
  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  Wert LastHum = Wert(0, 0, 'Humidity');

  Future<void> login() async {
    // Create instance of ThingsBoard API Client
    _tbClient = ThingsboardClient(_thingsBoardApiEndpoint);
    // ignore: avoid_print
    print("Client init.");
    // Perform login with default Tenant Administrator credentials
    await _tbClient.login(LoginRequest('test1@thingsboard.org', 'test1234'));
    // // ignore: avoid_print
    // print('isAuthenticated=${_tbClient.isAuthenticated()}');
    // // ignore: avoid_print
    // print('authUser: ${_tbClient.getAuthUser()}');

    _logedin = true;
  }

  Future<void> getdevice() async {
    // ignore: prefer_conditional_assignment
    if (!_deviceknown) {
      _device = await _tbClient
          .getDeviceService()
          .getDeviceInfo("909c4110-7857-11ec-9ec5-313c7e792047");
      // // ignore: avoid_print
      // print('foundDevice: $device');
      _deviceknown = true;
    }
  }

  Future<void> logout() async {
    if (_logedin && !_subscriped) {
      await _tbClient.logout();
      _logedin = false;
    }
  }

  Future<TelemetrySubscriber> subscripe() async {
    if (!_logedin) {
      await login();
    }
    if (!_deviceknown) {
      await getdevice();
    }
    // Create entity filter to get device by its name
    var entityFilter = EntityNameFilter(
        entityType: EntityType.DEVICE, entityNameFilter: _device.name);

    // Prepare list of queried device fields
    var deviceFields = <EntityKey>[
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'name'),
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'type'),
      EntityKey(type: EntityKeyType.ENTITY_FIELD, key: 'createdTime')
    ];

    // Prepare list of queried device timeseries
    var deviceTelemetry = <EntityKey>[
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'Temperature'),
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'Humidity'),
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'Co2')
    ];

    // Create entity query with provided entity filter, queried fields and page link
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

    // Create timeseries subscription command to get data for 'temperature' and 'humidity' keys for last hour with realtime updates
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var timeWindow = const Duration(hours: 1).inMilliseconds;

    var tsCmd = TimeSeriesCmd(
        keys: ['Temperature', 'Humidity', 'Co2'],
        startTs: currentTime - timeWindow,
        timeWindow: timeWindow);

    // Create subscription command with entities query and timeseries subscription
    var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);

    // Create subscription with provided subscription command
    var telemetryService = _tbClient.getTelemetryService();
    _subscription = TelemetrySubscriber(telemetryService, [cmd]);

    // Perform subscribe (send subscription command via WebSocket API and listen for responses)
    _subscription.subscribe();

    _subscriped = true;
    return _subscription;
  }

  void dataupdate(EntityDataUpdate entityDataUpdate) {
    try {
      if (entityDataUpdate.data != null) {
        var keys =
            entityDataUpdate.data!.data.first.latest.values.first.keys.iterator;
        var values = entityDataUpdate
            .data!.data.first.latest.values.first.values.iterator;

        while (keys.moveNext() && values.moveNext()) {
          // ignore: avoid_print
          print('--------------------------');
          // ignore: avoid_print
          print(keys.current);
          // ignore: avoid_print
          print(values.current.ts);
          // ignore: avoid_print
          print(values.current.value);
          // ignore: avoid_print
          print('--------------------------');

          if (keys.current == 'Co2') {
            // ignore: avoid_print
            print('----------------Co2----------------');
            LastCo2.setts(values.current.ts);
            LastCo2.setvalue(int.parse(values.current.value.toString()));
          }
        }
      } else {
        // ignore: avoid_print
        print("The Data is Empty!");
        // ignore: avoid_print
        print("values: ");

        var it = entityDataUpdate.update!.first.timeseries.values.iterator;
        var keys = entityDataUpdate.update!.first.timeseries.keys.iterator;
        while (it.moveNext() && keys.moveNext()) {
          String? value;
          int ts = 0;
          // ignore: avoid_print
          print("--------------------------");
          var it2 = it.current.iterator;
          while (it2.moveNext()) {
            // ignore: avoid_print
            print(it2.current.ts);
            ts = it2.current.ts;
            // ignore: avoid_print
            print(it2.current.value);
            value = it2.current.value;
          }
          // ignore: avoid_print
          print(keys.current);
          // ignore: avoid_print
          print("--------------------------");

          if (keys.current == 'Co2') {
            // ignore: avoid_print
            print('----------------Co2----------------');
            LastCo2.setts(ts);
            LastCo2.setvalue(int.parse(value.toString()));
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("ERROR: Datenverarbeitung");
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> unsubscripe() async {
    if (_subscriped) {
      try {
        // Finally unsubscribe to release subscription
        _subscription.unsubscribe();
        // ignore: avoid_print
        print('Unsubscriped');
      } catch (e) {
        // ignore: avoid_print
        print('ERROR: Unscription failed!');
      }
    }
  }
}
