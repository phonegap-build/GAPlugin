/*
* Copyright (c) 2013 BlackBerry Limited
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

var _utils = require("../../lib/utils");

module.exports = {

    // Object properties
    uuid: function (success, fail, args, env) {
        var result = new PluginResult(args, env);
        var value;
        if (args && args["value"])
        {
            value = JSON.parse(decodeURIComponent(args["value"]));
            result.ok(ga.gauuid(value), false);
        }
        else
        {
            result.ok(ga.gauuid(), false);
        }
    },

    gaAccount: function (success, fail, args, env) {
        var result = new PluginResult(args, env);
        var value;
        if (args && args["value"]) 
        {
            value = JSON.parse(decodeURIComponent(args["value"]));

            var error;
            error = ga.account(value);
            if (error) {
                result.error(error, false);
            }
            else {
                result.noResult(false);
            }
        } 
        else 
        {
            result.ok(ga.account(), false);
        }
    },

    appName: function (success, fail, args, env) {
        var result = new PluginResult(args, env);
        var value;
        if (args && args["value"]) 
        {
            value = JSON.parse(decodeURIComponent(args["value"]));
            var error;
            error = ga.appname(value);
            if (error) {
                result.error(error, false);
            }
            else {
                result.noResult(false);
            }
        } 
        else 
        {
            result.ok(ga.appname(), false);
        }
    },

    lastPayload: function (success, fail, args, env) {
        var result = new PluginResult(args, env);
        if (args && args["value"]) 
        {
            result.error("Cannot set lastPayload property", false);
        } 
        else 
        {
            result.ok(ga.lastpayload(), false);

        }
    },

    useQueue: function (success, fail, args, env) {
        var result = new PluginResult(args, env);
        var value;
        if (args && args["value"]) 
        {
            value = JSON.parse(decodeURIComponent(args["value"]));
            ga.setUseQueue(value);
            result.noResult(false);
        } 
        else 
        {
            result.ok(ga.setUseQueue(), false);
        }
    },

    getDelay: function (success, fail, args, env) {
        var result = new PluginResult(args, env);
        result.ok(ga.getDelay(), false);
    },

    randomUuid: function (success, fail, args, env) {
        var result = new PluginResult(args, env);
        var value = "";
        if (args && args["value"])
        {
            var error;
            value = JSON.parse(decodeURIComponent(args["value"]));
            error = ga.randomuuid(value);
            if (error) {
                result.error(error, false);
            }
            else {
                result.noResult(false);
            }
        }
        else
            result.ok(ga.randomuuid(), false);
    },

    // All-in-one function setting up account, uuid and appName
    initGA: function (success, fail, args, env) {
        var result = new PluginResult(args, env);
        var value, 
            error;

        if (!args || !args[0]){
            error = "GA account number is required";
        }

         if (!error) {
            value = JSON.parse(decodeURIComponent(args[0]));
            error = ga.account(value);
         }

        if (!error && args[1]) {
            value = JSON.parse(decodeURIComponent(args[1]));
            error = ga.period(value);
        }

        // Set random uuid
        error = ga.gauuid("");

        if (error) {
            result.error(error, false);
        }
        else {
            result.ok("GA initialized", false);
        }
    },

     trackPage: function (success, fail, args, env) {
         module.exports.trackAll(success, fail, args, env, "pageview");
     },

     trackEvent: function (success, fail, args, env) {
         module.exports.trackAll(success, fail, args, env, "event");
    },

    trackAll: function (success, fail, args, env, sTrackType) {
        var result = new PluginResult(args, env);
        var error;

        if (!args || !args[0]){
            error = "Need track type argument";
        }

        if (!error) {
            error = ga.processtracking(sTrackType, args);
        }

        if (error) {
            result.error(sTrackType + " tracking error: " + error, false);
        }
        else {
            result.ok("Finished " + sTrackType + " tracking", false);
        }
    },

    setVariable: function (success, fail, args, env) {
        var result = new PluginResult(args, env);
        var error,
            dimensionValue,
            dimensionIndex;

        if (!args[0] || !args[1]){
            error = "Index and value of custom dimension are required";
        }

        if (!error) {
            dimensionIndex = JSON.parse(decodeURIComponent(args[0]));
            dimensionValue = JSON.parse(decodeURIComponent(args[1]));

            error = ga.customdimension(dimensionIndex, dimensionValue);
        }

        if (error) {
            result.error(error, false);
        }
        else {
            result.ok("Custom dimension set", false);
        }
           
    },

    exitGA: function (success, fail, args, env) {
        var result = new PluginResult(args, env);
        var error;

        error = ga.checkQueue();

        if (error) {
            result.error(error, false);
        }
        else {
            result.ok("Successfully exited", false);
        }
           
    }
};

// GA module
var ga = (function() {
    var m_uuid = "",
        m_account = "", 
        m_appName = "",
        m_lastPayload = "",
        m_customDimension = "",
        m_fncbSendSuccess,
        m_fncbSendFail,
        bAccountSet = false,
        bRandomUuid = false,
        bSendBusy = false,
        bUseQueue = false; 
        bCustomDimension = false;

    var DEFAULT_DELAY = 500,
        MAX_TIMEOUT_DELAY = 10000, // max ms to retry timeouted request
        MAX_NETWORK_DELAY = 300000, // max ms to retry checking for active connection
        timeout_delay = DEFAULT_DELAY,
        network_delay = DEFAULT_DELAY;

    //***********************************
    // Functions for setting properties
    //***********************************
    var account = function(value) {
        if (undefined != value) {
            // UA-xxxxxxxx-x
            // 0123456789012 <-index
            if ((value.length != 13) || (value.substr(0,3) != "UA-") || (value.charAt(11) != '-')) {
                return "Invalid GA account, should be in the format UA-xxxxxxxx-x";
            }
            m_account = value;
            bAccountSet = true;
            // Init storage, use GA Account as unique ID for storage
            return storage.init(m_account);
        }
        else {
            return m_account;
        }
    };

    var appname = function(value) {

        if (undefined != value) {
            if (value.length == 0) {
                return "AppName cannot be empty";
            }
            m_appName = value;
            // Init storage, use app name as unique ID for storage
            // return storage.init(m_appName);
            // Init storage with account number instead
            return "";
        }
        else {
            return m_appName;
        }
    };

    var period = function(value) {

        if (undefined != value) {
            if (value.length == 0) {
                return "Need value for period";
            }
            // Convert value from s to ms
            DEFAULT_DELAY = value*1000;
            return "";
        }
        else {
            return DEFAULT_DELAY;
        }
    };

    var gauuid = function(value) {
        if (undefined != value) { 
            m_uuid = value;
            // if uuid provided is empty, attempt to load from storage
            // If no storage uuid, create one with random
            if ("" == m_uuid) {
                m_uuid = storage.loadData('uuid');
                m_uuid = storage.saveData("");
            }
            if ("" == m_uuid){
                m_uuid = randomizeUuid();
            }
            // store UUID
            return storage.saveData("uuid", m_uuid);
        }
       return m_uuid;
    };

    var customdimension = function(index, value) {

        if ( (undefined != value) && (undefined != index) ){ 
            // Set custom dimension for next function call
            m_customDimension += "&cd";
            // index is the index of the custom dimension in user's GA account
            m_customDimension += index;
            m_customDimension += "=";
            m_customDimension += value;

            bCustomDimension = true;
            return "";
        }

        return m_customDimension;
    };

    var setUseQueue = function(value) {
        if (undefined != value) {
            value = value.toLowerCase();
            if ("true" == value) {
                bUseQueue = true;
            }
            return "";
        }
        else {
            return bUseQueue;
        }
    };

    var lastpayload = function() {
        return m_lastPayload;
    };

    var randomuuid = function(value) {
        var error = "";
        if (undefined != value) {
            value = value.toLowerCase();
            switch (value) {
                case ("true"):
                    bRandomUuid = true;
                    break;
                case ("false"):
                    bRandomUuid = false;
                    break;
                default:
                    error = "True/False only for setting random UUID feature";
                    break;
            }

            return error;
        }
        else {
            return bRandomUuid;
        }
    };

    //***********************************
    // Utilities
    //***********************************

    // oArgs = json arg object
    // sParam = name of GA parameter
    // sKey = key to the value of sParam in oArgs
    var getParameter = function (oArgs, sParam, sKey) {
        var output;
        output = JSON.parse(decodeURIComponent(oArgs[sKey]));

        // All optional parameters, if not supplied by user, is set to "" in client.js
        if ("" != output)
        {
            output = "&" + sParam + "=" + output;
        }

        return output;
    };

    // Return a randomly generated UUID
    var randomizeUuid = function() {
        //Version4(random) UUID:
        //xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx where x is any hexadecimal digit and y is one of 8, 9, A, or B
        //012345678901234567890123456789012345 - index
        function _p8(split) {
            var p = (Math.random().toString(16)+"000000000").substr(2,8);
            return split? "-" + p.substr(0,4) + "-" + p.substr(4,4) : p ;
        }
        var ret = _p8() + _p8(true) + _p8(true) + _p8();
        ret = ret.substr(0,14) + "4" + ret.substr(15);
        var ch = ret.charAt(19);
        if ('8' != ch && '9' != ch && 'a' != ch && 'b' != ch)
        {
            ret = ret.substr(0,19) + "a" + ret.substr(20);
        }
        return ret;
    };

    // Return true if has active connection (not neccessarily has internet connectivity tho)
    var checkConnection = function() {
        // Doesn't matter what type of connection, just check if activeConnection exists
        try {
            if (window.qnx.webplatform.device.activeConnection) {
                return true;
            }
            else {
                return false;
            }
        }
        catch (e) {
            return false;
        }
    };
    //***********************************
    // Core functions
    //***********************************

    // Main interface to process tracking requests
    // Return error if any
    var processtracking = function (trackType, args) {
        var xmlhttp,
            optionString = "",
            error = "";

        if (bRandomUuid) {
            error = "called func"
            m_uuid = randomizeUuid();
        }

        if (!bAccountSet) {
            error = "Need GA account number";
        }

        if (!m_uuid) {
            error = "UUID not set. Set to empty string for a random UUID";
        }

        if (!error) {
            // Removed app name because client file does not take it as an argument
            optionString = "v=1&tid=" + m_account + "&cid=" + m_uuid;
            
            switch (trackType)
            {
                case "pageview":
                    var parser = document.createElement('a');
                    parser.href = JSON.parse(decodeURIComponent(args[0]));

                    optionString += "&t=pageview";
                    optionString += "&dh=";
                    optionString += parser.hostname;
                    optionString += "&dp=";
                    optionString += parser.pathname;

                    break;

                case "event":
                    optionString += "&t=event";
                    optionString += getParameter(args, "ec", 0);
                    optionString += getParameter(args, "ea", 1);
                    optionString += getParameter(args, "el", 2);
                    optionString += getParameter(args, "ev", 3);        
                    break;

                case "transaction":
                    optionString += "&t=transaction";
                    optionString += getParameter(args, "ti", "tID");
                    optionString += getParameter(args, "ta", "tAffil");
                    optionString += getParameter(args, "tr", "tRevenue");
                    optionString += getParameter(args, "ts", "tShipn");
                    optionString += getParameter(args, "tt", "tTax");
                    optionStribUseng += getParameter(args, "cu", "tCurr");
                    break;

                case "item":
                    optionString += "&t=item";
                    optionString += getParameter(args, "ti", "tID");
                    optionString += getParameter(args, "in", "iName");
                    optionString += getParameter(args, "ip", "iPrice");
                    optionString += getParameter(args, "iq", "iQuant");
                    break;

                default:
                    error = "Invalid track type";
                    break;
            }

            // Check if there is a custom dimension to append to payload
            if (bCustomDimension) {
                optionString += m_customDimension;
                bCustomDimension = false;    
            }    
        
            m_lastPayload = optionString;

            // Send immediately if not using queue.
            // Otherwise, store to queue first & then trigger send
            if (bUseQueue) {
                error = queue.enqueue(optionString);
                if (!error){
                    // If send is already busy, all enqueued will be sent, no need to re-trigger send
                    // but that may mean no active network and connection timed-out
                    if (bSendBusy) {
                        error = "Network busy";
                    }
                    else {
                        bSendBusy = true;
                        error = sendData(optionString, m_fncbSendSuccess, m_fncbSendFail);
                    }
                }
            }
            else {
                error = sendData(optionString, m_fncbSendSuccess, m_fncbSendFail);
            }
        }
        return error;
    };

    var getDelay = function () {
        return ("Network: " + network_delay + "; Timeout: " + timeout_delay);
    };

    // Actual http POST function, return error if any
    var sendData = function (sPayload, fncbSuccess, fncbFail) {
        var xhr;
        bSendBusy = true;
        // If Not using queue, attempt POST immediately once only
        // If Using Queue, send and re-send til timeout, and dequeue once sent successfully

        if (!sPayload) {
            return "No payload data to send";
        }

        // Check for active connection
        if (!checkConnection()) {
            if (fncbFail) {
                fncbFail("No network connection");
            }
            if (bUseQueue) {
                // Using queue, re-test for connection
                if (network_delay < MAX_NETWORK_DELAY) {
                    network_delay *= 2;
                }
                setTimeout(function(){sendData(sPayload, fncbSuccess, fncbFail);}, network_delay);
            }
            return "No network connection";
        }
        else {
            network_delay = DEFAULT_DELAY;
        }

        // Send
        if (XMLHttpRequest && sPayload) {
            xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4) {
                    if (xhr.status == 200) {
                        // ok, success no timeout
                        if (fncbSuccess) {
                                fncbSuccess();
                        }
                        if (bUseQueue) {
                            // Using queue: done & remove this payload from queue
                            queue.dequeue();
                            timeout_delay = DEFAULT_DELAY;
                            bSendBusy = false;
                            checkQueue();
                        }
                    }
                    else {
                        // timed-out
                        if (fncbFail) {
                            fncbFail("Connection timed-out");
                        }
                        if (bUseQueue) {                        
                            // Using queue, re-send
                            if (timeout_delay < MAX_TIMEOUT_DELAY) {
                                timeout_delay *= 2;
                            }
                            setTimeout(function(){sendData(sPayload, fncbSuccess, fncbFail);}, timeout_delay);
                        }
                    }
                }
            }

            xhr.open("POST","http://www.google-analytics.com/collect",true);
            xhr.send(sPayload);
        }
        else {
            if (fncbFail) {
                fncbFail("No XMLHttpRequest");
            }
        }
        return "";
    };

    // Trigger send if any data in queue
    var checkQueue = function() {
        var sPayload;
        sPayload = queue.top();
        if (!bSendBusy && sPayload) {
            bSendBusy = true;
            sendData(sPayload, m_fncbSendSuccess, m_fncbSendFail);
        }
    };

    // export
    return {
        account: account,
        appname: appname,
        period: period,
        gauuid: gauuid,
        lastpayload: lastpayload,
        customdimension: customdimension,
        randomuuid: randomuuid,
        processtracking: processtracking,
        setUseQueue: setUseQueue,
        getDelay: getDelay,
        checkQueue: checkQueue
    };

})();

// Queue module for storing payload
// An interface to the Storage module
var queue = (function() {
    var enqueue = function(data) {
        var error = "";
        error = storage.pushPayload(data);
        return error;
    };

    // Return dequeued data
    var dequeue = function() {
        var value = "";
        value = storage.popPayload();
        return value;
    };

    // Return top item on queue, does not dequeue
    // Return empty string if nothing on queue
    var top = function() {
        var value = "";
        value = storage.topPayload();
        return value;
    };

    return {
        enqueue: enqueue,
        dequeue: dequeue,
        top: top
    };

})();

//Storage module
var storage = (function() {
    // root of storage structure
    var gaStorage = {},
        error = "Storage not initialized yet.",
        DEFAULT_NAME = "bb10googleanalyticsplugin_",
        storagename;
    // A list specific for storing payloads of http post request to GA
    gaStorage["arrPayloads"] = [];
    var arrPayloads = gaStorage["arrPayloads"];

    // Storage needed to be init with a unique ID, since technically multiple apps 
    // can be using the plugin at the same time.
    var init = function(id) {
        // At start up, retrieve previous instance of storage if any
        // If none, create one. Use JSON to convert storage structure into pure string.
        if (id) {
            storagename = DEFAULT_NAME + id;
            error = "";
        }
        else {
            return "Required unique ID to initialize storage.";
        }

        if (window.localStorage) {
            var oldStorage = window.localStorage.getItem(storagename);
            if (oldStorage) {
                gaStorage = JSON.parse(oldStorage);
                // retrieve old arrPayloads
                arrPayloads = gaStorage["arrPayloads"];
            }
            else {
                window.localStorage.setItem(storagename, JSON.stringify(gaStorage));
            }
            error = "";
        }
        else {
            error = "LocalStorage not supported.";
        }
        return error;
    };
    // Always keep the most updated gaStorage both in memeory and in web storage

    // save & load for any arbitrary key:value pair
    var saveData = function(key, value) {
        if (error) {
            return error;
        }
        gaStorage[key] = value;
        window.localStorage.setItem(storagename, JSON.stringify(gaStorage));
        return "";
    };

    var loadData = function(key) {
        if (error) {
            return "";
        }
        return (gaStorage[key] || "");
    };

    // save & load for payloads data only, use queue
    var pushPayload = function(sPayload) {
        if (error) {
            return error;
        }
        arrPayloads[arrPayloads.length] = sPayload;
        window.localStorage.setItem(storagename, JSON.stringify(gaStorage));
        return "";
    };

    // load
    var popPayload = function() {
        if (error || (arrPayloads.length == 0)) {
            return "";
        }
        var value = arrPayloads.shift();
        window.localStorage.setItem(storagename, JSON.stringify(gaStorage));
        return value;
    };

    // return first item in storage arr
    var topPayload = function() {
        if (error || (arrPayloads.length == 0)) {
            return "";
        }
        return arrPayloads[0];
    };

    return {
        init: init,
        saveData: saveData,
        loadData: loadData,
        pushPayload: pushPayload,
        popPayload: popPayload,
        topPayload: topPayload
    };
})();
