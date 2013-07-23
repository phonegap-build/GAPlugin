(function(){
    var cordovaRef = window.PhoneGap || window.Cordova || window.cordova;

    function GAPlugin() { }

    // initialize google analytics with an account ID and the min number of seconds between posting
    //
    // id = the GA account ID of the form 'UA-00000000-0'
    // period = the minimum interval for transmitting tracking events if any exist in the queue
    // debug = Should GA set to debug mode? true/false
    GAPlugin.prototype.init = function(success, fail, id, period, debug) {
        debug = debug || false;
        return cordovaRef.exec(success, fail, 'GAPlugin', 'initGA', [id, period, debug]);
    };

    // log an event
    //
    // category = The event category. This parameter is required to be non-empty.
    // eventAction = The event action. This parameter is required to be non-empty.
    // eventLabel = The event label. This parameter may be a blank string to indicate no label.
    // eventValue = The event value. This parameter may be -1 to indicate no value.
    GAPlugin.prototype.trackEvent = function(success, fail, category, eventAction, eventLabel, eventValue) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'trackEvent', [category, eventAction, eventLabel, eventValue]);
    };


    // log a page view
    //
    // pageURL = the URL of the page view
    GAPlugin.prototype.trackPage = function(success, fail, pageURL) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'trackPage', [pageURL]);
    };

    // Set a custom variable. The variable set is included with
    // the next event only. If there is an existing custom variable at the specified
    // index, it will be overwritten by this one.
    //
    // value = the value of the variable you are logging
    // index = the numerical index of the dimension to which this variable will be assigned (1 - 20)
    //  Standard accounts support up to 20 custom dimensions.
    GAPlugin.prototype.setVariable = function(success, fail, index, value) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'setVariable', [index, value]);
    };
    
    // Set a custom dimension. The variable set is included with
    // the next event only. If there is an existing custom dimension at the specified
    // index, it will be overwritten by this one.
    //
    // value = the value of the dimension you are logging
    // index = the numerical index of the dimension to which this variable will be assigned (1 - 20)
    //  Standard accounts support up to 20 custom dimensions.
    GAPlugin.prototype.setDimension = function (success, fail, index, value) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'setDimension', [index, value]);
    };
    
    // Set a custom metric. The variable set is included with
    // the next event only. If there is an existing custom metric at the specified
    // index, it will be overwritten by this one.
    //
    // value = the value of the metric you are logging
    // index = the numerical index of the metric to which this variable will be assigned (1 - 20)
    //  Standard accounts support up to 20 custom metrics.
    GAPlugin.prototype.setMetric = function (success, fail, index, value) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'setMetric', [index, value]);
    };


    GAPlugin.prototype.exit = function(success, fail) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'exitGA', []);
    };
    
    /**
     * GA Ecommerce Transaction tracking
     * 
     * @param {type} success
     * @param {type} fail
     * @param {type} transId    Unique transaction id
     * @param {type} orderTotal Order total
     * @param {type} items      JSON array
     * @param {type} currency   Currency string
     * <pre>
     * [{sku: <string>, name: <string>, price: <number>, quantity: <number>, category:<string>}]
     * </pre>
     * @returns {@exp;cordovaRef@call;exec}
     * 
     * @author Gihan S <gihanshp@gmail.com>
     */
    GAPlugin.prototype.trackTransaction = function(success, fail, transId, orderTotal, items, currency) {
        return cordovaRef.exec(success, fail, 'GAPlugin', 'trackTransaction', [transId, orderTotal, currency, items]);
    };
 
    if (cordovaRef)
    {
        cordovaRef.addConstructor(function() {
            if(!window.plugins) {
                window.plugins = {};
            }
            if(!window.plugins.gaPlugin) {
                window.plugins.gaPlugin = new GAPlugin();
            }
        });
    }
})(); /* End of Temporary Scope. */
