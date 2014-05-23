package com.adobe.plugins;

//import com.google.analytics.tracking.android.*;
import android.util.Log;
import com.google.android.gms.common.*;
import com.google.android.gms.analytics.*;
import com.phonegap.helloworld.R;
import org.apache.cordova.CordovaPlugin;          // modificato da org.apache.cordova.CordovaPlugin a org.apache.cordova.api.CordovaPlugin
import org.apache.cordova.CallbackContext;          // modificato org.apache.cordova.CallbackContext a org.apache.cordova.api.CallbackContext
import org.json.JSONArray;
import org.json.JSONException;

public class GAPlugin extends CordovaPlugin {
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callback) throws JSONException{
        GoogleAnalytics ga = GoogleAnalytics.getInstance(cordova.getActivity());
        Tracker tracker=ga.newTracker("UA-44301016-1");

        if (action.equals("initGA")) {
            try {
                tracker = ga.newTracker(args.getString(0));
                ga.setLocalDispatchPeriod(args.getInt(1));
                callback.success("initGA - id = " + args.getString(0) + "; interval = " + args.getInt(1) + " seconds");
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("exitGA")) {
            try {
                /*GAServiceManager.getInstance().dispatch(); */
                ga.dispatchLocalHits();

                callback.success("exitGA");
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("trackEvent")) {
            try {
                /*tracker.sendEvent(args.getString(0), args.getString(1), args.getString(2), args.getLong(3));  */
                tracker.send(new HitBuilders.EventBuilder()
                                .setCategory(args.getString(0))
                                .setAction(args.getString(1))
                                .setLabel(args.getString(2))
                                .setValue(args.getLong(3))
                                //.setValue(args.getString(3))
                                .build());
                        //MapBuilder.createEvent(args.getString(0), args.getString(1), args.getString(2), args.getLong(3)).build());
                callback.success("trackEvent - category = " + args.getString(0) + "; action = " + args.getString(1) + "; label = " + args.getString(2) + "; value = " + args.getInt(3));
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        } else if (action.equals("trackPage")) {
            try {
                /*tracker.sendView(args.getString(0));*/
                //tracker.setPage(args.getString(0));
                tracker.setScreenName(args.getString(0));
                tracker.send(new HitBuilders.AppViewBuilder().build());

                        //MapBuilder.createAppView().set(Fields.SCREEN_NAME,args.getString(0)).build());
                callback.success("trackPage - url = " + args.getString(0));
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        } /*else if (action.equals("setVariable")) {
            try {
                *//*tracker.setCustomDimension(args.getInt(0), args.getString(1));*//*
                // tracker.set(Fields.customDimension(args.getInt(0)), args.getString(1));
                tracker.send(new HitBuilders.AppViewBuilder()
                                .setCustomMetric(args.getInt(0), args.getLong(1))
                                .build()
                );

                callback.success("setVariable passed - index = " + args.getString(0) + "; value = " + args.getString(1));
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        }*/
        else if (action.equals("setDimension")) {
            try {
                /*tracker.setCustomDimension(args.getInt(0), args.getString(1));*/
                tracker.send(new HitBuilders.AppViewBuilder()
                                .setCustomDimension(args.getInt(0), args.getString(1))
                                .build()
                );
                callback.success("setDimension passed - index = " + args.getInt(0) + "; value = " + args.getString(1));
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        }
        else if (action.equals("setMetric")) {
            try {
                /*tracker.setCustomMetric(args.getInt(0), args.getLong(1));*/
                tracker.send(new HitBuilders.AppViewBuilder()
                                .setCustomMetric(args.getInt(0), args.getLong(1))
                                .build()
                );
                callback.success("setVariable passed - index = " + args.getInt(2) + "; key = " + args.getString(0) + "; value = " + args.getString(1));
                return true;
            } catch (final Exception e) {
                callback.error(e.getMessage());
            }
        }
        else if (action.equals("trackSocial")){
            try{
                tracker.send(new HitBuilders.SocialBuilder().setNetwork(args.getString(0))
                                                            .setAction(args.getString(1))
                                                            .setTarget(args.getString(2))
                                                            .build());
                callback.success("trackSocial - Network = " + args.getString(0) + "; action = " + args.getString(1) + "; target = " + args.getString(2));
            } catch(final Exception e){
                callback.error(e.getMessage());
            }
        }
        else if (action.equals("trackEcommerceTransaction")){
            try{
                tracker.send(new HitBuilders.TransactionBuilder().setTransactionId(args.getString(0))
                        .setAffiliation(args.getString(1))
                        .setRevenue(args.getDouble(2))
                        .setTax(args.getDouble(3))
                        .setShipping(args.getDouble(4))
                        .setCurrencyCode(args.getString(5))
                        .build());

                callback.success("trackSocial - Transaction ID = "+ args.getString(0) +
                                 " Affiliation "+args.getString(1) +
                                 " Revenue " + args.getDouble(2)+
                                 " Tax " +   args.getDouble(3)+
                                 " Shipping " + args.getDouble(4)+
                                 " Currency code " + args.getString(5)
                                );

            } catch(final Exception e){
                callback.error(e.getMessage());
            }
        }
        else if (action.equals("trackEcommerceItem")){
            try{
                tracker.send(new HitBuilders.ItemBuilder().setTransactionId(args.getString(0))          // (String) Transaction ID
                        .setName(args.getString(1))          // (String) Product name
                        .setSku(args.getString(2))          // (String) Product SKU
                        .setCategory(args.getString(3))          // (String) Product category
                        .setPrice(args.getDouble(4))          // (Double) Product price
                        .setQuantity(args.getLong(5))            // (Long) Product quantity
                        .setCurrencyCode(args.getString(6))           // (String) Currency code
                        .build());

                callback.success("trackSocial - Transaction ID = "+ args.getString(0) +
                                 " Name "+args.getString(1) +
                                 " SKU " + args.getString(2)+
                                 " Category " +   args.getString(3)+
                                 " Price " + args.getDouble(4)+
                                 " Quantity " + args.getString(5) +
                                 " Currency code "+args.getString(6)
                                );
            } catch(final Exception e){
                callback.error(e.getMessage());
            }
        }

        return false;
    }
}
