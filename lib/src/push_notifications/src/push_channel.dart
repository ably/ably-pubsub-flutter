import 'package:ably_pubsub_device_flutter/ably_pubsub_device_flutter.dart';
import 'package:ably_pubsub_device_flutter/src/platform/platform_internal.dart';

/// Enables devices to subscribe to push notifications for a channel.
class PushChannel extends PlatformObject {
  final String _name;

  /// @nodoc
  /// A realtime client used platform side to invoke push notification methods
  final PubSubClient realtime;

  /// @nodoc
  /// Pass the channel name and an Ably realtime client.
  PushChannel(this._name, {required this.realtime});

  /// @nodoc
  @override
  Future<int?> createPlatformInstance() => realtime.handle;

  /// Subscribes the device to push notifications for the channel.
  Future<void> subscribeDevice() => invoke(
      PlatformMethod.pushSubscribeDevice, {TxTransportKeys.channelName: _name});

  /// Unsubscribes the device from receiving push notifications for the channel.
  Future<void> unsubscribeDevice() => invoke(
      PlatformMethod.pushUnsubscribeDevice,
      {TxTransportKeys.channelName: _name});

  /// Subscribes all devices associated with the current device's `clientId` to
  /// push notifications for the channel.
  Future<void> subscribeClient() => invoke(
      PlatformMethod.pushSubscribeClient, {TxTransportKeys.channelName: _name});

  /// Unsubscribes all devices associated with the current device's `clientId`
  /// from receiving push notifications for the channel.
  Future<void> unsubscribeClient() => invoke(
      PlatformMethod.pushUnsubscribeClient,
      {TxTransportKeys.channelName: _name});

  /// Retrieves all push subscriptions for the channel.
  ///
  /// [params] must contain exactly one of `deviceId` or `clientId` to filter
  /// subscriptions by, and can contain a `limit` on the number of
  /// subscriptions returned, up to 1,000.
  ///
  /// Throws an [AblyException] if [params] contains neither or both of
  /// `deviceId` and `clientId`.
  ///
  /// Returns a [PaginatedResult] object containing a list of
  /// [PushChannelSubscription] objects.
  Future<PaginatedResult<PushChannelSubscription>> listSubscriptions(
      Map<String, String> params) async {
    // ably-pubsub-cocoa only supports filtering by one of these, so it is
    // enforced here on both platforms to keep the API consistent.
    if (params.containsKey('deviceId') == params.containsKey('clientId')) {
      throw AblyException(
        message: "expected exactly one of 'deviceId' and 'clientId'",
      );
    }

    final message = await invokeRequest<AblyMessage<dynamic>>(
      PlatformMethod.pushListSubscriptions,
      {TxTransportKeys.params: params, TxTransportKeys.channelName: _name},
    );

    return PaginatedResult<PushChannelSubscription>.fromAblyMessage(
        AblyMessage.castFrom<dynamic, PaginatedResult<dynamic>>(message));
  }
}
