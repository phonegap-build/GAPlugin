package org.apache.cordova.plugin;

import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;
import org.json.JSONArray;

import com.google.analytics.tracking.android.GAServiceManager;
import com.google.analytics.tracking.android.GoogleAnalytics;
import com.google.analytics.tracking.android.Tracker;

public class GAPlugin extends CordovaPlugin {
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callback) {
        GoogleAnalytics ga = GoogleAnalytics.getInstance(cordova.getActivity());
        Tracker tracker = ga.getDefaultTracker();

        if (action.equals("initGA")) {
            try {
                tracker = ga.getTracker(args.getString(0));
                GAServiceManager.getInstance().setDispatchPeriod(args.getInt(1));
                ga.setDefaultTracker(tracker);
                callback.success("initGA - id = " + args.getString(0) + "; interval = " + args.getInt(1) + " seconds");
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("exitGA")) {
            try {
                GAServiceManager.getInstance().dispatch();
                callback.success("exitGA");
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("sendEvent")) {
            try {
                tracker.sendEvent(args.getString(0), args.getString(1), args.getString(2), args.getLong(3));
                callback.success("sendEvent - category = " + args.getString(0) + "; action = " + args.getString(1) + "; label = " + args.getString(2) + "; value = " + args.getInt(3));
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("sendView")) {
            try {
                tracker.sendView(args.getString(0));
                callback.success("sendView - url = " + args.getString(0));
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("setCustom")) {
            try {
                tracker.setCustomDimension(args.getInt(0), args.getString(1));
                callback.success("setCustom passed - index = " + args.getInt(0) + "; value = " + args.getString(1));
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("sendTiming")) {
            try {
                tracker.sendTiming(args.getString(0), args.getInt(1), args.getString(2), args.getString(3));
                callback.success("sendTiming passed - category = " + args.getString(0) + "; time = " + args.getInt(1) + "; name = " + args.getString(2) + "; label = " + args.getString(3));
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("sendException")) {
            try {
                tracker.sendException(args.getString(0), args.getBoolean(1));
                callback.success("sendException passed");
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        }
        return false;
    }
}