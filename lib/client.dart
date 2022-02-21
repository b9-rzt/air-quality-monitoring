import 'package:flutter/material.dart';
import 'package:myapp/value/wert.dart';
import 'package:thingsboard_client/thingsboard_client.dart';
import 'package:myapp/widget/error_dialog.dart';

class Client {
  static const _thingsBoardApiEndpoint = 'http://192.168.2.117:8080';
  // ignore: prefer_typing_uninitialized_variables
  var _tbClient;
  // ignore: prefer_typing_uninitialized_variables
  var _device;
  late BuildContext _context;
  late TelemetrySubscriber _subscription;
  bool _logedin = false;
  bool _subscriped = false;
  var _devices = [[], []];
  Wert lastCo2 = Wert(0, 0, 'Co2');
  Wert lastTemp = Wert(0, 0, 'Temperature');
  Wert lastHum = Wert(0, 0, 'Humidity');

  void setcontext(context) {
    _context = context;
  }

  void resetvalues() {
    lastCo2.resetvalues();
    lastTemp.resetvalues();
    lastHum.resetvalues();
  }

  bool islogedin() {
    return _logedin;
  }

  Future<void> login() async {
    if (!_logedin) {
      try {
        // Create instance of ThingsBoard API Client
        _tbClient = ThingsboardClient(_thingsBoardApiEndpoint);
        debugPrint("Client init.");
        await _tbClient
            .login(LoginRequest('zimmer1@thingsboard.org', 'zimmer1'));

        if (_tbClient.isAuthenticated()) {
          _logedin = true;
        } else {
          showMyDialog(_context);
        }
      } catch (e) {
        showMyDialog(_context);
      }
    }
  }

  Future<void> getdevice(var deviceId) async {
    if (!_logedin) {
      login();
    }
    _device = await _tbClient.getDeviceService().getDeviceInfo(deviceId);
  }

  Future<List?> getDevices() async {
    if (_logedin) {
      _devices = [[], []];

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

  Future<void> logout() async {
    if (_logedin && !_subscriped) {
      await _tbClient.logout();
      _logedin = false;
    }
  }

  Future<TelemetrySubscriber> subscripe() async {
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

    debugPrint('Subscriped!');
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
          debugPrint(
              '----First----${keys.current}----${values.current.ts}----${values.current.value}----');

          if (keys.current == 'Co2') {
            debugPrint('----------------Co2----------------');
            lastCo2.setts(values.current.ts);
            lastCo2.setvalue(int.parse(values.current.value.toString()));
          }
          if (keys.current == 'Temperature') {
            debugPrint('----------------Temperature----------------');
            lastTemp.setts(values.current.ts);
            lastTemp.setvalue(int.parse(values.current.value.toString()));
          }
          if (keys.current == 'Humidity') {
            debugPrint('----------------Humidity----------------');
            lastHum.setts(values.current.ts);
            lastHum.setvalue(int.parse(values.current.value.toString()));
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

  Future<void> unsubscripe() async {
    if (_subscriped) {
      try {
        // Finally unsubscribe to release subscription
        _subscription.unsubscribe();
        debugPrint('Unsubscriped');
      } catch (e) {
        debugPrint('ERROR: Unscription failed!');
        debugPrint(e.toString());
      }
    }
  }
}
