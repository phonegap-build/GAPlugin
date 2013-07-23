package com.adobe.plugins;

import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONObject;

import com.google.analytics.tracking.android.GAServiceManager;
import com.google.analytics.tracking.android.GoogleAnalytics;
import com.google.analytics.tracking.android.Tracker;
import com.google.analytics.tracking.android.Transaction;
import com.google.analytics.tracking.android.Transaction.*;

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
				
				// set debug mode
				if(args.getBoolean(2)){
					ga.setDebug(true);
				}
				
				callback.success("initGA - id = " + args.getString(0) + "; interval = " + args.getInt(1) + " seconds; "+" isDebugEnabled = "+ga.isDebugEnabled());
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
		} else if (action.equals("trackEvent")) {
			try {
				tracker.sendEvent(args.getString(0), args.getString(1), args.getString(2), args.getLong(3));
				callback.success("trackEvent - category = " + args.getString(0) + "; action = " + args.getString(1) + "; label = " + args.getString(2) + "; value = " + args.getInt(3));
				return true;
			} catch (final Exception e) {
				callback.error(e.getMessage());
			}
		} else if (action.equals("trackPage")) {
			try {
				tracker.sendView(args.getString(0));
				callback.success("trackPage - url = " + args.getString(0));
				return true;
			} catch (final Exception e) {
				callback.error(e.getMessage());
			}
		} else if (action.equals("setVariable")) {
			try {
				tracker.setCustomDimension(args.getInt(0), args.getString(1));
				callback.success("setVariable passed - index = " + args.getInt(0) + "; value = " + args.getString(1));
				return true;
			} catch (final Exception e) {
				callback.error(e.getMessage());
			}
		}
		else if (action.equals("setDimension")) {
			try {
				tracker.setCustomDimension(args.getInt(0), args.getString(1));
				callback.success("setDimension passed - index = " + args.getInt(0) + "; value = " + args.getString(1));
				return true;
			} catch (final Exception e) {
				callback.error(e.getMessage());
			}
		}
		else if (action.equals("setMetric")) {
			try {
				tracker.setCustomMetric(args.getInt(0), args.getLong(1));
				callback.success("setMetric passed - index = " + args.getInt(2) + "; key = " + args.getString(0) + "; value = " + args.getString(1));
				return true;
			} catch (final Exception e) {
				callback.error(e.getMessage());
			}
		}
		else if (action.equals("trackTransaction")) {
			try {
				Transaction trans = new Transaction.Builder(
						args.getString(0), 
						args.getLong(1)
				)
				.setShippingCostInMicros(0)
				.setCurrencyCode(args.getString(2))
				.build();
				
				JSONArray items = args.getJSONArray(3);
				
				for(int i=0; i<items.length(); i++){
					JSONObject item = items.getJSONObject(i);
					trans.addItem(new Item.Builder(
							item.getString("sku"), 
							item.getString("name"), 
							item.getLong("price"), 
							item.getLong("quantity"))
					.setProductCategory(item.getString("category"))
					.build());
				}
				tracker.sendTransaction(trans);
				
				callback.success("trackTransaction - transactionId = " + args.getString(0) + "; orderTotal = " + args.getLong(1) + "; items = " + args.getJSONArray(2).toString());
				return true;
			} catch (final Exception e) {
				callback.error(e.getMessage());
			}
		}

		return false;
	}
}

