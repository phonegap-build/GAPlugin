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
    uuid: function(success, fail, args, env) {
        var result = new PluginResult(args, env);
        if (args && args.value) {
            try {
                ga.gauuid = JSON.parse(decodeURIComponent(args.value));
                result.ok(ga.gauuid, false);
            } catch (e) {
                result.error(e, false);
            }
        } else
            result.ok(ga.gauuid, false);
    },

    gaAccount: function(success, fail, args, env) {
        var result = new PluginResult(args, env);
        if (args && args.value) {
            try {
                ga.accountIdentifier = JSON.parse(decodeURIComponent(args.value));
                result.noResult(false);
            } catch (e) {
                result.error(e, false);
            }
        } else
            result.ok(ga.accountIdentifier, false);
    },

    appName: function(success, fail, args, env) {
        var result = new PluginResult(args, env);
        if (args && args.value) {
            try {
                ga.appName = JSON.parse(decodeURIComponent(args.value));
                result.noResult(false);
            } catch (e) {
                result.error(e, false);
            }
        } else
            result.ok(ga.appName, false);
    },

    lastPayload: function(success, fail, args, env) {
        var result = new PluginResult(args, env);
        if (args && args.value)
            result.error("Cannot set lastPayload property", false);
        else
            try {
                result.ok(ga.getLastPayload(), false);
            } catch (e) {
                result.error(e, false);
            }
    },

    useQueue: function(success, fail, args, env) {
        var result = new PluginResult(args, env);
        if (args && args.value) {
            try {
                ga.useQueue = JSON.parse(decodeURIComponent(args.value));
                result.noResult(false);
            } catch (e) {
                result.error(e, false);
            }
        } else
            result.ok(ga.useQueue, false);
    },

    getDelay: function(success, fail, args, env) {
        var result = new PluginResult(args, env);
        result.ok(ga.getDelay(), false);
    },

    randomUuid: function(success, fail, args, env) {
        var result = new PluginResult(args, env);
        if (args && args.value) {
            try {
                ga.useRandomUUID = JSON.parse(decodeURIComponent(args.value));
                result.noResult(false);
            } catch (e) {
                result.error(e, false);
            }
        } else
            result.ok(ga.useRandomUUID, false);
    },

    // All-in-one function setting up account, uuid and appName
    initGA: function(success, fail, args, env) {
        var result = new PluginResult(args, env);
        try {
            if (!args || !args[0])
                throw "GA account number is required";

            ga.accountIdentifier = JSON.parse(decodeURIComponent(args[0]));
            // Init storage, use GA Account as unique ID for storage
            storage.init(ga.accountIdentifier);

            if (args.length > 1)
                ga.period = JSON.parse(decodeURIComponent(args[1]));
            // A random UUID is set, when the UUID is first accessed
            result.ok("GA initialized", false);
        } catch (e) {
            result.error(e, false);
        }
    },

    trackPage: function(success, fail, args, env) {
        module.exports.trackAll(success, fail, args, env, "pageview");
    },

    trackEvent: function(success, fail, args, env) {
        module.exports.trackAll(success, fail, args, env, "event");
    },

    trackAll: function(success, fail, args, env, sTrackType) {
        var result = new PluginResult(args, env);
        try {
            if (!args || !args[0])
                throw "Need track type argument";
            ga.processTracking(sTrackType, args);
            result.ok("Finished " + sTrackType + " tracking", false);
        } catch (e) {
            result.error(sTrackType + " tracking error: " + e, false);
        }
    },

    setVariable: function(success, fail, args, env) {
        var result = new PluginResult(args, env);
        try {
            if (!args || !args[0] || !args[1])
                throw "Index and value of custom dimension are required";
            var dimensionIndex = JSON.parse(decodeURIComponent(args[0]));
            var dimensionValue = JSON.parse(decodeURIComponent(args[1]));
            ga.setCustomDimensions(dimensionIndex, dimensionValue);
            result.ok("Custom dimension set", false);
        } catch (e) {
            result.error(e, false);
        }
    },

    exitGA: function(success, fail, args, env) {
        var result = new PluginResult(args, env);
        try {
            ga.checkQueue();
            result.ok("GA exited successfully", false);
        } catch (e) {
            result.error(e, false);
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
        bAccountSet = false,
        bRandomUuid = false,
        bSendBusy = false,
        bUseQueue = false,
        bCustomDimension = false;

    var DEFAULT_DELAY = 500,
        MAX_TIMEOUT_DELAY = 10000, // max ms to retry timeouted request
        MAX_NETWORK_DELAY = 300000, // max ms to retry checking for active connection
        timeout_delay = DEFAULT_DELAY,
        network_delay = DEFAULT_DELAY;

    //***********************************
    // Functions for setting properties
    //***********************************
    Object.defineProperty(this, 'accountIdentifier', {
        get: function() {
            return m_account;
        },
        set: function(value) {
            // UA-xxxxxxxx-x
            if (!value.match(/^UA-\d{8}-\d$/))
                throw "Invalid GA account, should be in the format UA-xxxxxxxx-x";

            m_account = value;
            bAccountSet = true;
        }
    });

    Object.defineProperty(this, 'appname', {
        get: function() {
            return m_appName;
        },
        set: function(value) {
            if (!value)
                throw "AppName cannot be empty";
            m_appName = value;
        }
    });

    Object.defineProperty(this, 'period', {
        get: function() {
            return DEFAULT_DELAY;
        },
        set: function(value) {
            if (!value)
                throw "Need value for period";
            // Convert value from s to ms
            DEFAULT_DELAY = value * 1000;
        }
    });

    Object.defineProperty(this, 'gauuid', {
        get: function() {
            if (!m_uuid) {
                // if uuid provided is empty, attempt to load from storage
                // If no storage uuid, create one with random
                m_uuid = storage.loadData('uuid');

                if (!m_uuid) {
                    m_uuid = randomizeUUID();
                    storage.saveData('uuid', m_uuid);
                }
            }
            return m_uuid;
        },
        set: function(value) {
            if (!value)
                throw "Need value for UUID";
            m_uuid = value;
            storage.saveData('uuid', m_uuid);
        }
    });

    this.setCustomDimensions = function(index, value) {
        if (typeof index !== "undefined" && value) {
            // Set custom dimension for next function call
            // index is the index of the custom dimension in user's GA account
            m_customDimension = "&cd" + index + "=" + value;
            bCustomDimension = true;
        }
        return m_customDimension;
    };

    Object.defineProperty(this, 'useQueue', {
        get: function() {
            return bUseQueue;
        },
        set: function(value) {
            if (!value)
                throw "Need value for UUID";
            bUseQueue = value == "true";
        }
    });

    this.getLastPayload = function() {
        return m_lastPayload;
    };

    Object.defineProperty(this, 'randomUUID', {
        get: function() {
            return bRandomUuid;
        },
        set: function(value) {
            if (!value)
                throw "Need true or false value for setting randomUUID";
            bRandomUuid = value == "true";
        }
    });

    //***********************************
    // Utilities
    //***********************************

    // oArgs = json arg object
    // sParam = name of GA parameter
    // sKey = key to the value of sParam in oArgs
    var getParameter = function(oArgs, sParam, sKey) {
        var output = JSON.parse(decodeURIComponent(oArgs[sKey]));
        // All optional parameters, if not supplied by user, is set to "" in client.js
        if (output)
            output = "&" + sParam + "=" + output;
        return output;
    };

    // Return a randomly generated UUID
    var randomizeUUID = function() {
        //Version4(random) UUID:
        //xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx where x is any hexadecimal digit and y is one of 8, 9, A, or B
        //012345678901234567890123456789012345 - index
        function _p8(split) {
            var p = (Math.random().toString(16) + "000000000").substr(2, 8);
            return split ? "-" + p.substr(0, 4) + "-" + p.substr(4, 4) : p;
        }
        var ret = _p8() + _p8(true) + _p8(true) + _p8();
        ret = ret.substr(0, 14) + "4" + ret.substr(15);
        var ch = ret.charAt(19);
        if ('8' != ch && '9' != ch && 'a' != ch && 'b' != ch)
            ret = ret.substr(0, 19) + "a" + ret.substr(20);
        return ret;
    };

    // Return true if has active connection (not neccessarily has internet connectivity)
    var isConnectedToNetwork = function() {
        try {
            // Return true if the activeConnection object is not undefined
            return !!window.qnx.webplatform.device.activeConnection;
        } catch (e) {
            return false;
        }
    };


    //***********************************
    // Core functions
    //***********************************

    // Main interface to process tracking requests
    // Return error if any
    this.processTracking = function(trackType, args) {
        if (bRandomUuid)
            this.gauuid = randomizeUUID();

        if (!bAccountSet)
            throw "Need GA account number";

        if (!this.gauuid)
            throw "UUID not set. Set 'randomUuid' to true to auto-generate";

        // Removed app name because client file does not take it as an argument
        var optionString = "v=1&tid=" + m_account + "&cid=" + this.gauuid;

        switch (trackType) {
            case "pageview":
                var parser = document.createElement('a');
                parser.href = JSON.parse(decodeURIComponent(args[0]));
                optionString += "&t=pageview";
                optionString += "&dh=" + parser.hostname;
                optionString += "&dp=" + parser.pathname;
                break;

            case "event":
				console.log(args);
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
                optionString += getParameter(args, "cu", "tCurr");
                break;

            case "item":
                optionString += "&t=item";
                optionString += getParameter(args, "ti", "tID");
                optionString += getParameter(args, "in", "iName");
                optionString += getParameter(args, "ip", "iPrice");
                optionString += getParameter(args, "iq", "iQuant");
                break;

            default:
                throw "Invalid track type";
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
            storage.enqueuePayload(optionString);
            // If send is already busy, all enqueued will be sent, no need to re-trigger send
            // but that may mean no active network and connection timed-out
            if (bSendBusy)
                throw "Network busy";
            else {
                bSendBusy = true;
                sendData(optionString);
            }
        } else
            sendData(optionString);
    };

    this.getDelay = function() {
        return "Network: " + network_delay + "; Timeout: " + timeout_delay;
    };

    // Actual http POST function, return error if any
    var sendData = function(sPayload) {
        bSendBusy = true;
        // If Not using queue, attempt POST immediately once only
        // If Using Queue, send and re-send til timeout, and dequeue once sent successfully

        if (!sPayload)
            throw "No payload data to send";

        // Check for active connection
        network_delay = DEFAULT_DELAY;
        if (!isConnectedToNetwork()) {
            if (bUseQueue) {
                // Using queue, re-test for connection
                if (network_delay < MAX_NETWORK_DELAY)
                    network_delay *= 2;

                setTimeout(function() {
                    sendData(sPayload);
                }, network_delay);
                return;
            } else
                throw "No network connection";
        }

        // Send
        if (XMLHttpRequest && sPayload) {
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4) {
                    if (xhr.status == 200 && bUseQueue) {
                        // ok, success no timeout
                        // Using queue: done & remove this payload from queue
                        storage.dequeuePayload();
                        timeout_delay = DEFAULT_DELAY;
                        bSendBusy = false;
                        this.checkQueue();
                    } else if (bUseQueue) {
                        // timed-out    
                        // Using queue, re-send
                        if (timeout_delay < MAX_TIMEOUT_DELAY)
                            timeout_delay *= 2;
                        setTimeout(function() {
                            sendData(sPayload);
                        }, timeout_delay);
                        return;
                    }
                }
            };
            xhr.open("POST", "http://www.google-analytics.com/collect", true);
            xhr.send(sPayload);
        }
    };

    // Trigger send if any data in queue
    this.checkQueue = function() {
        var sPayload = storage.peekPayload();
        if (!bSendBusy && sPayload) {
            bSendBusy = true;
            sendData(sPayload);
        }
    };

    return this;
})();

//Storage module
var storage = (function() {

    // root of storage structure
    var gaStorage = {},
        error = "Storage not initialized yet.",
        DEFAULT_NAME = "bb10googleanalyticsplugin_",
        storagename;
    // A list specific for storing payloads of http post request to GA
    gaStorage.arrPayloads = [];
    var arrPayloads = gaStorage.arrPayloads;

    // Storage needed to be init with a unique ID, since technically multiple apps 
    // can be using the plugin at the same time.
    this.init = function(id) {
        // At start up, retrieve previous instance of storage if any
        // If none, create one. Use JSON to convert storage structure into pure string.
        if (!id)
            throw "Required unique ID to initialize storage.";
        else {
            storagename = DEFAULT_NAME + id;

            if (window.localStorage) {
                var oldStorage = window.localStorage.getItem(storagename);
                if (oldStorage) {
                    gaStorage = JSON.parse(oldStorage);
                    // retrieve old arrPayloads
                    arrPayloads = gaStorage.arrPayloads;
                } else
                    saveGAStorage();
            } else
                throw "LocalStorage not supported.";
        }
        error = "";
    };
    // Always keep the most updated gaStorage both in memeory and in web storage

    // save & load for any arbitrary key:value pair
    this.saveData = function(key, value) {
        if (error)
            throw error;
        gaStorage[key] = value;
        saveGAStorage();
    };

    this.loadData = function(key) {
        if (error)
            throw error;
        return gaStorage[key] || "";
    };

    // save & load for payloads data only, use queue
    this.enqueuePayload = function(sPayload) {
        if (error)
            return error;
        arrPayloads[arrPayloads.length] = sPayload;
        saveGAStorage();
    };

    // load
    this.dequeuePayload = function() {
        if (error)
            throw error;
        else if (arrPayloads.length === 0)
            throw "The queue is empty";
        var value = arrPayloads.shift();
        saveGAStorage();
        return value;
    };

    // return first item in storage arr
    this.peekPayload = function() {
        if (error)
            throw error;
        else if (arrPayloads.length === 0)
            throw "The queue is empty";
        return arrPayloads[0];
    };

    var saveGAStorage = function() {
        window.localStorage.setItem(storagename, JSON.stringify(gaStorage));
    };

    return this;
})();