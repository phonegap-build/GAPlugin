/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
	
	//Instance Variables
	gaPlugin: null,
		
	// Application Constructor
	initialize: function() {
		this.bindEvents();
	},
	// Bind Event Listeners
	//
	// Bind any events that are required on startup. Common events are:
	// 'load', 'deviceready', 'offline', and 'online'.
	bindEvents: function() {
		document.addEventListener('deviceready', this.onDeviceReady, false);
	},
	
	// deviceready Event Handler
	//
	// The scope of 'this' is the event. In order to call the 'receivedEvent'
	// function, we must explicity call 'app.receivedEvent(...);'
	onDeviceReady: function() {
		app.receivedEvent('deviceready');
		
		gaPlugin = window.plugins.gaPlugin;
	},
	
	// Update DOM on a Received Event
	receivedEvent: function(id) {
		var parentElement = document.getElementById(id);
		var listeningElement = parentElement.querySelector('.listening');
		var receivedElement = parentElement.querySelector('.received');

		listeningElement.setAttribute('style', 'display:none;');
		receivedElement.setAttribute('style', 'display:block;');

		app.log('Received Event: ' + id);
	},
	
	initializeGA: function(){
		// Note: A request for permission is REQUIRED by google. You probably want to do this just once, though, and remember the answer for subsequent runs.
		var permissionOk = window.confirm("Do you allow GAPlugin to collect usage data? No personal or user identifiable data will be collected.");
		
		if(permissionOk){
			//Retrive the tracking ID from the application
			var trackingID = document.getElementById("trackingID").value || "";
			gaPlugin.init(app.nativePluginResultHandler, app.nativePluginErrorHandler, trackingID, 10);
		}
	},
	
	// Called when GAPlugin initializes properly.
	nativePluginResultHandler: function(result) {
		app.log('nativePluginResultHandler: '+result);
	},
	
	// Called when GAPlugin doesn't initialize properly.
	nativePluginErrorHandler: function(error) {
		app.log('nativePluginErrorHandler: '+error);
	},
	
	trackEvent: function() {
		// Track an event. The call uses parameters:
		// 1)  resultHandler - a function that will be called on success
		// 2)  errorHandler - a function that will be called on error.
		// 3)  category - This is the type of event you are sending such as "Button", "Menu", etc.
		// 4)  eventAction - This is the type of event you are sending such as "Click", "Select". etc.
		// 5)  eventLabel - A label that describes the event such as Button title or Menu Item name.
		// 6)  eventValue - An application defined integer value that can mean whatever you want it to mean.
		gaPlugin.trackEvent(app.nativePluginResultHandler, app.nativePluginErrorHandler, "Button", "Click", "event only", 1);
	},
	
	trackEventWithVariable: function() {
		// Set a dimension based on index and value. Make sure you have added a dimension in the GA dashboard to the
		// default property for the passed in index, and your desired scope. GA allows up to 20 dimensions for a free account
		gaPlugin.setVariable(app.nativePluginResultHandler, app.nativePluginErrorHandler, 1, "Purple");
		// Dimensions are are passed to the next event sent to GA. go ahead and fire off an event with the label (key) of your choice
		// In this example, the label for custom dimension 1 will show up in the dashboard as "favoriteColor". This is much more efficient
		// than the old custom variable method introduced in V1, (plus you get 20 free dimensions vs 5 free custom variables)
		gaPlugin.trackEvent(app.nativePluginResultHandler, app.nativePluginErrorHandler, "event with variable", "set variable", "favoriteColor", 1);
	},
	
	trackPage: function() {
		gaPlugin.trackPage(app.nativePluginResultHandler, app.nativePluginErrorHandler, "some.url.com");
	},
	
	toggleRandomUUID: function(){
		gaPlugin.randomUuid = !gaPlugin.randomUuid;
		this.value = "Toggle randomUUID: " + gaPlugin.randomUuid;
	},
	
	// Cleanup
	unloadGAPlugin: function() {
		gaPlugin.exit(app.nativePluginResultHandler, app.nativePluginErrorHandler);
	},
	
	log: function(message){
		if(console)
			console.log(message);
		var logDiv = document.getElementById("log");
		logDiv.innerHTML = "<p>" + message + "</p>" + logDiv.innerHTML;
	}
};
