using System;

using WPCordovaClassLib.Cordova;
using WPCordovaClassLib.Cordova.Commands;
using WPCordovaClassLib.Cordova.JSON;

using GoogleAnalytics;


namespace Cordova.Extension.Commands
{
    public class GAPlugin : BaseCommand
    {
        Tracker tracker = EasyTracker.GetTracker();

        public void initGA(string options)
        {
            try
            {
                Console.WriteLine("initGA");
                tracker = EasyTracker.GetTracker();
                var arguments = JsonHelper.Deserialize<string[]>(options);
                var trackingID = arguments[0];
                var dispatcherTimeInSeconds = int.Parse(arguments[1]);

                tracker = AnalyticsEngine.Current.GetTracker(trackingID);
                GAServiceManager.Current.DispatchPeriod = new TimeSpan(dispatcherTimeInSeconds);
                AnalyticsEngine.Current.DefaultTracker = tracker;

                DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
                return;
            }
            catch (Exception ex)
            {
                DispatchCommandResult(new PluginResult(PluginResult.Status.ERROR, ex.Message));
                return;
            }
        }

        public void exitGA(string options)
        {
            try
            {
                Console.WriteLine("exitGA");
                GAServiceManager.Current.Dispatch();
                DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
                return;
            }
            catch (Exception ex)
            {
                DispatchCommandResult(new PluginResult(PluginResult.Status.ERROR, ex.Message));
                return;
            }
        }

        public void trackEvent(string options)
        {
            Console.WriteLine("trackEvent");

            try
            {
                var arguments = JsonHelper.Deserialize<string[]>(options);

                var category = arguments[0];
                var action = arguments[1];
                var label = arguments[2];
                var value = int.Parse(arguments[3]);

                tracker.SendEvent(category, action, label, value);
                DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
                return;
            }
            catch (Exception ex)
            {
                DispatchCommandResult(new PluginResult(PluginResult.Status.ERROR, ex.Message));
                return;
            }
        }

        public void trackPage(string options)
        {
            Console.WriteLine("trackPage");

            try
            {
                var viewName = JsonHelper.Deserialize<string>(options);
                tracker.SendView(viewName);
                DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
                return;
            }
            catch (Exception ex)
            {
                DispatchCommandResult(new PluginResult(PluginResult.Status.ERROR, ex.Message));
                return;
            }
        }

        public void setVariable(string options)
        {
            Console.WriteLine("setVariable");
            try
            {
                var arguments = JsonHelper.Deserialize<string[]>(options);
                var index = int.Parse(arguments[0]);
                var value = arguments[1];

                tracker.SetCustomDimension(index, value);

                DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
                return;
            }
            catch (Exception ex)
            {
                DispatchCommandResult(new PluginResult(PluginResult.Status.ERROR, ex.Message));
                return;
            }

        }

        public void setDimension(string options)
        {
            Console.WriteLine("setDimension");
            try
            {
                var arguments = JsonHelper.Deserialize<string[]>(options);
                var index = int.Parse(arguments[0]);
                var value = arguments[1];

                tracker.SetCustomDimension(index, value);

                DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
                return;
            }
            catch (Exception ex)
            {
                DispatchCommandResult(new PluginResult(PluginResult.Status.ERROR, ex.Message));
                return;
            }
        }

        public void setMetric(string options)
        {
            Console.WriteLine("setMetric");
            try
            {
                var arguments = JsonHelper.Deserialize<string[]>(options);
                var index = int.Parse(arguments[0]);
                var value = int.Parse(arguments[1]);

                tracker.SetCustomMetric(index, value);

                DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
                return;
            }
            catch (Exception ex)
            {
                DispatchCommandResult(new PluginResult(PluginResult.Status.ERROR, ex.Message));
                return;
            }
        }
    }
}
