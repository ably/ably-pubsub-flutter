package io.ably.flutter.plugin;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.ably.flutter.plugin.generated.PlatformConstants;
import io.ably.lib.rest.Auth;
import io.ably.lib.types.AblyException;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class AuthMethodHandler {
    private final AblyInstanceStore instanceStore;
    private final ExecutorService executor = Executors.newSingleThreadExecutor();

    public AuthMethodHandler(AblyInstanceStore instanceStore) {
        this.instanceStore = instanceStore;

    }

    void authorize(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage<Map<String, Object>> ablyMessage = (AblyFlutterMessage) methodCall.arguments;
        final Auth.TokenParams tokenParams =
                (Auth.TokenParams) ablyMessage.message.get(PlatformConstants.TxTransportKeys.params);

        final Auth.AuthOptions options =
                (Auth.AuthOptions) ablyMessage.message.get(PlatformConstants.TxTransportKeys.options);

        executor.execute(() -> {
            try {
                final Auth.TokenDetails tokenDetails = getAuth(ablyMessage)
                        .authorize(tokenParams, options);
                result.success(tokenDetails);
            } catch (AblyException e) {
                result.error(String.valueOf(e.errorInfo.code), e.errorInfo.message, e);
            }
        });

    }

    private Auth getAuth(AblyFlutterMessage<Map<String, Object>> ablyMessage) {
        return instanceStore.getRealtime(ablyMessage.handle).auth;
    }

    void requestToken(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage<Map<String, Object>> ablyMessage = (AblyFlutterMessage) methodCall.arguments;
        final Auth.TokenParams tokenParams =
                (Auth.TokenParams) ablyMessage.message.get(PlatformConstants.TxTransportKeys.params);

        final Auth.AuthOptions options =
                (Auth.AuthOptions) ablyMessage.message.get(PlatformConstants.TxTransportKeys.options);

        executor.execute(() -> {
            try {
                final Auth.TokenDetails tokenDetails = getAuth(ablyMessage)
                        .requestToken(tokenParams, options);
                result.success(tokenDetails);
            } catch (AblyException e) {
                result.error(String.valueOf(e.errorInfo.code), e.errorInfo.message, e);
            }
        });
    }

    void createTokenRequest(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        final AblyFlutterMessage<Map<String, Object>> ablyMessage = (AblyFlutterMessage) methodCall.arguments;
        final Auth.TokenParams tokenParams =
                (Auth.TokenParams) ablyMessage.message.get(PlatformConstants.TxTransportKeys.params);

        final Auth.AuthOptions options =
                (Auth.AuthOptions) ablyMessage.message.get(PlatformConstants.TxTransportKeys.options);

        executor.execute(() -> {
            try {
                final Auth.TokenRequest tokenRequest = getAuth(ablyMessage)
                        .createTokenRequest(tokenParams, options);
                 result.success(tokenRequest);
            } catch (AblyException e) {
                 result.error(String.valueOf(e.errorInfo.code), e.errorInfo.message, e);
            }
        });
    }

    public void clientId(MethodCall methodCall, MethodChannel.Result result) {
        String clientId = getAuth((AblyFlutterMessage) methodCall.arguments).clientId;
        result.success(clientId);
    }
}
