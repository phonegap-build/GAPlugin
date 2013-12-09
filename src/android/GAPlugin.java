package com.adobe.plugins;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONObject;

import android.util.Log;

import com.google.analytics.tracking.android.GAServiceManager;
import com.google.analytics.tracking.android.GoogleAnalytics;
import com.google.analytics.tracking.android.Tracker;
import com.google.analytics.tracking.android.Transaction;
import com.google.analytics.tracking.android.Transaction.Builder;
import com.google.analytics.tracking.android.Transaction.Item;

public class GAPlugin extends CordovaPlugin {
	
	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callback) {
		Log.d("GAPlugin", "execute()");
		Log.d("GAPlugin", action);

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
				callback.success("setVariable passed - index = " + args.getInt(2) + "; key = " + args.getString(0) + "; value = " + args.getString(1));
				return true;
			} catch (final Exception e) {
				callback.error(e.getMessage());
			}
		}
		else if(action.equals("trackTransaction")){
			try {
				this.__trackTransaction(args.getJSONObject(0));
				callback.success("trackTransaction = " + args.getString(0));
				return true;
			} catch (final Exception e) {
				callback.error(e.getMessage());
			}
		}
		else if(action.equals("trackCaughtException")){
			Log.d("GAPlugin", "got action");
			try {
				this.__trackException(args.getString(0), false);
				callback.success("trackCaughtException = " + args.getString(0));
				return true;
			} catch (final Exception e) {
				callback.error(e.getMessage());
			}
		}
		return false;
	}
	
	private void __trackTransaction(JSONObject jObj){
		Builder transBuilder = new Transaction.Builder(
			jObj.getString("transactionId"),	// (String) Transaction Id, should be unique.
			jObj.getLong("orderTotal")	// (long) Order total (in micros)
		);
		transBuilder.setAffiliation(jObj.getString("affiliation"));	// (String) Affiliation
		transBuilder.setTotalTaxInMicros(jObj.getLong("totalTax"));	// (long) Total tax (in micros)
		transBuilder.setShippingCostInMicros(jObj.getLong("shippingCost"));	// (long) Total shipping cost (in micros)
		Transaction trans = transBuilder.build();
		JSONArray items = jObj.getJSONArray("items");
		for(int i = 0 ; i < items.length(); i++){	//add all the items to the transaction
			JSONObject item = items.getJSONObject(i);
			Item.Builder itemBuilder = new Item.Builder(
				item.getString("sku"),	// (String) Product SKU
				item.getString("name"),	// (String) Product name
				item.getLong("price"),	// (long) Product price (in micros)
				item.getLong("quantity")	// (long) Product quantity
			);
			itemBuilder.setProductCategory(item.getString("category"));	// (String) Product category
			trans.addItem(itemBuilder.build());
		}

		GoogleAnalytics ga = GoogleAnalytics.getInstance(cordova.getActivity());
		Tracker tracker = ga.getDefaultTracker(); 
		tracker.sendTransaction(trans); // Send the transaction
	}
	
	private void __trackException(String message, Boolean fatal){
		GoogleAnalytics ga = GoogleAnalytics.getInstance(cordova.getActivity());
		Tracker tracker = ga.getDefaultTracker(); 
		tracker.sendException(message, fatal); // Send the exception
	}
}

