import 'package:ably_pubsub_device_flutter/ably_pubsub_device_flutter.dart';

/// Contains properties used to filter [PushChannelSubscriptions] channels.
abstract class PushChannelsParams {
  /// A limit on the number of channels returned, up to 1,000.
  int? limit;
}
