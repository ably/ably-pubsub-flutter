import 'package:ably_pubsub_device_flutter/ably_pubsub_device_flutter.dart';
import 'package:ably_pubsub_device_flutter/src/platform/platform_internal.dart';
import 'package:meta/meta.dart';

/// Creates and destroys [RealtimeChannel] objects.
class RealtimeChannels extends Channels<RealtimeChannel> {
  /// @nodoc
  /// instance of ably realtime client
  Realtime realtime;

  /// @nodoc
  /// instantiates with the ably [Realtime] instance
  RealtimeChannels(this.realtime);

  /// @nodoc
  @override
  @protected
  RealtimeChannel createChannel(String name) => RealtimeChannel(realtime, name);

  /// Releases a [RealtimeChannel] object with a specified [name], deleting it.
  ///
  /// It also removes any listeners associated with the channel. A realtime
  /// channel can only be released when it is in the `INITIALIZED`,
  /// `DETACHED`, or `FAILED` state. If the channel is in any other state, the
  /// returned future completes with an [AblyException] with code 90011 and
  /// the channel is not released. Await [RealtimeChannel.detach] before calling
  /// `release()` on an attached channel. Releasing a channel that does not
  /// exist completes without error.
  @override
  Future<void> release(String name) async {
    // The check against the channel state is left to the platform SDK, as
    // [RealtimeChannel.state] is updated asynchronously and can lag behind it.
    await realtime.invoke<void>(PlatformMethod.releaseRealtimeChannel, {
      TxTransportKeys.channelName: name,
    });
    super.release(name);
  }
}
