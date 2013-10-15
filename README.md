# GAPlugin

> Google Analytics plugin for iOS, Android and Windows Phone 7&8. This allows you to post usage information to your Google Analytics account.

## Preparation:
Before you can begin collecting metrics data, you need to set up a GoogleAnalytics Mobile App account so you can view them. When you do so, you will obtain an app tracking id which we'll use during session initialization. Start by going to the [Google Analytics](http://www.google.com/analytics/features/mobile-app-analytics.html) site and click on the **Create an Account** button. Once signed in, click on the **Admin** button and the **+ New Account** button under the **Accounts** tab. At the top of the resulting tab, select the **App** button in answer to the **What would you like to track?** query. Fill out the form as appropriate. Complete instructions can be found [here](http://www.google.com/analytics/features/mobile-app-analytics.html).

## Installation:

This plugin is based on [plugman](https://github.com/apache/cordova-plugman). to install it to your app,
simply execute plugman as follows;

	plugman --platform [PLATFORM] --project [TARGET-PATH] --plugin [PLUGIN-PATH]

	where
		[PLATFORM] = ios or android
		[TARGET-PATH] = path to folder containing your phonegap project
		[PLUGIN-PATH] = path to folder containing this plugin
		
For additional info, take a look at the [Plugman Documentation](https://github.com/apache/cordova-plugman/blob/master/README.md)

The Windows Phone Plugins use the NuGet Package 'GoogleAnalyticsSDK' from Tim Greenfield.
To compile your project you either have to install this package through the Solution NuGet Package Manager or manually reference his dll's.
They are provided in folder: src\wp8\packages. 
For more information on this package see: https://googleanalyticssdk.codeplex.com/

## Usage
The plugin creates the object `window.plugins.gaPlugin

After onDeviceReady, create a local var and startup the plugin like so;

	var gaPlugin;

	function onDeviceReady() {
		gaPlugin = window.plugins.gaPlugin;
		gaPlugin.init(successHandler, errorHandler, "UA-12345678-1", 10);
	}

To get things rolling you need to call init() when your device ready function fires.
Init takes 4 arguments;
	1)	success - a function that will be called on success
	2)	fail - a function that will be called on error.
	3)	id - Your Google Analytics account ID of the form; UA-XXXXXXXX-X
		This is the account ID you were given when you signed up.
	4)	period - An integer containing the minimum number of seconds
		between upload of metrics. When metics are logged, they are enqued
		and are sent out in batches based on this value. You'll want to
		avoid setting this value too low, to limit the overhead of sending data.

Example:
	
	gaPlugin.init(successHandler, errorHandler, "UA-12345678-1", 10);
	
To track an event, call (oddly enough) trackEvent().
trackEvent takes 6 arguments;

	1)	resultHandler - a function that will be called on success
	2)	errorHandler - a function that will be called on error.
	3)	category - This is the type of event you are sending such as "Button", "Menu", etc.
	4)	eventAction - This is the type of event you are sending such as "Click", "Select". etc.
	5)	eventLabel - A label that describes the event such as Button title or Menu Item name.
	6)	eventValue - An application defined integer value that can mean whatever you want it to mean.
	
Example:
	
	gaPlugin.trackEvent( nativePluginResultHandler, nativePluginErrorHandler, "Button", "Click", "event only", 1);

TrackEvent covers most of what you need, but there may be cases where you want to pass arbitrary data.
setVariable() lets you pass values by index (Up to 20, on free accounts).
For free accounts, each variable is given an index from 1 - 20. Reusing an existing index simply overwrites
the previous value. Passing an index out of range fails silently, with no data sent. The variables will be sent ONLY for the next trackEvent or trackPage, after which those indexes will be available for reuse.
setVariable() accepts 4 arguments;

	1)	resultHandler - a function that will be called on success
	2)	errorHandler - a function that will be called on error.
	3)	index - the numerical index representing one of your variable slots (1-20).
	4)	value - Arbitrary string data associated with the index.

Example:

	gaPlugin.setVariable( nativePluginResultHandler, nativePluginErrorHandler, 1, "Purple");
	
####Important:
Variable values are assigned to what Google calls Custom Dimensions in the dashboard. Prior to calling setVariable() in your client for a particular index, you need to create a slot in the GA dashboard. When you do so, you will be able to assign a name for the dimension, its index, and its scope. More info on creating Custom Dimensions can be found [here](https://support.google.com/analytics/answer/2709829?hl=en&ref_topic=2709827).	
The next event or page view you send after setVariable will contain your variable at Custom Dimension specified by the index value you passed in the setVariable call. This [Example](https://github.com/phonegap-build/GAPlugin/blob/master/Example/index.html) app shows how you might use that next event to specify a label for the variable you just set.
	
In addition to events and variables, you can also log page visits with trackPage(). Unlike variables, however, page hits do not require a subsequent call to trackEvent() as they are considered unique events in and of themselves.
trackPage() takes 3 arguments;

	1)	resultHandler - a function that will be called on success
	2)	errorHandler - a function that will be called on error.
	3)	url - The url of the page hit you are logging.

Example:

	gaPlugin.trackPage( nativePluginResultHandler, nativePluginErrorHandler, "some.url.com");
	
Finally, when your app shuts down, you'll want to cleanup after yourself by calling exit();
exit() accepts 2 arguments;

	1)	resultHandler - a function that will be called on success
	2)	errorHandler - a function that will be called on error.
Example:

	gaPlugin.exit(nativePluginResultHandler, nativePluginErrorHandler);
	
This package includes an Example folder containing an index.html file showing how all of this fits together.
Note that the contents of Examples does not get installed anywhere by pluginstall. Its just there to provide a usage example.

## More Info
	
GAPlugin includes libraries from Google Analytics SDK for iOS and for Android.
Use of those libraries is subject to [Google Analytics Terms of Service](http://www.google.com/analytics/terms/us.html)
	
Also take a look at [Google Analytics Developer Guides](https://developers.google.com/analytics/devguides/)

## License ##

The MIT License

Copyright (c) 2012 Bob Easterday, Adobe Systems

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.