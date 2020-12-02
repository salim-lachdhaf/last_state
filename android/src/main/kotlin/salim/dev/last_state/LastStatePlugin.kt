package salim.dev.last_state

import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** LastStatePlugin */
class LastStatePlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityPluginBinding.OnSaveInstanceStateListener {
    private lateinit var channel: MethodChannel
    private var activityPluginBinding: ActivityPluginBinding? = null
        set(value) {
            field?.removeOnSaveStateListener(this)
            field = value
            value?.addOnSaveStateListener(this)
        }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "last_state")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val activity = activityPluginBinding?.activity
                ?: throw IllegalStateException("Not attached to activity")

        when (call.method) {
          "getState" -> {
            val state = StateRegistry.getState(activity)
            result.success(state)
          }
          "setState" -> {
            val state: Map<String, Any?>? = call.argument("state")
            StateRegistry.setState(activity, state)
            result.success(StateRegistry.getState(activity))
          }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding?.activity?.let {
            StateRegistry.clear(it)
        }
        activityPluginBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityPluginBinding = null
    }

    override fun onRestoreInstanceState(bundle: Bundle?) {
        StateRegistry.onRestoreInstanceState(activityPluginBinding!!.activity, bundle)
    }

    override fun onSaveInstanceState(bundle: Bundle) {
        StateRegistry.onSaveInstanceState(activityPluginBinding!!.activity, bundle)
    }
}
