using System;

using WPCordovaClassLib.Cordova;
using WPCordovaClassLib.Cordova.Commands;
using WPCordovaClassLib.Cordova.JSON;

using GoogleAnalytics;


namespace Cordova.Extension.Commands
{
    public class GAPlugin : BaseCommand
    {
        public void initGA(string options)
        {
            try
            {
                Console.WriteLine("initGA");
                var arguments = CheckAndReturnArguments(2, options);

                if (arguments.Length == 0)
                {
                    return;
                }

                var trackingID = arguments[0];
                var dispatcherTimeInSeconds = int.Parse(arguments[1]);
                
                EasyTracker.Current.Config.TrackingId = trackingID;
                EasyTracker.Current.Config.DispatchPeriod = new TimeSpan(0, 0, dispatcherTimeInSeconds);

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
                var arguments = CheckAndReturnArguments(4, options);

                if (arguments.Length == 0)
                {
                    return;
                }

                var category = arguments[0];
                var action = arguments[1];
                var label = arguments[2];
                var value = int.Parse(arguments[3]);

                EasyTracker.GetTracker().SendEvent(category, action, label, value);
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
                var arguments = CheckAndReturnArguments(1, options);

                if (arguments.Length == 0)
                {
                    return;
                }

                EasyTracker.GetTracker().SendView(arguments[0]);
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
                var arguments = CheckAndReturnArguments(2, options);

                if (arguments.Length == 0)
                {
                    return;
                }

                var index = int.Parse(arguments[0]);
                var value = arguments[1];

                EasyTracker.GetTracker().SetCustomDimension(index, value);

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
                var arguments = CheckAndReturnArguments(2, options);

                if (arguments.Length == 0)
                {
                    return;
                }

                var index = int.Parse(arguments[0]);
                var value = arguments[1];

                EasyTracker.GetTracker().SetCustomDimension(index, value);

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
                var arguments = CheckAndReturnArguments(2, options);

                if (arguments.Length == 0)
                {
                    return;
                }

                var index = int.Parse(arguments[0]);
                var value = int.Parse(arguments[1]);

                EasyTracker.GetTracker().SetCustomMetric(index, value);

                DispatchCommandResult(new PluginResult(PluginResult.Status.OK));
                return;
            }
            catch (Exception ex)
            {
                DispatchCommandResult(new PluginResult(PluginResult.Status.ERROR, ex.Message));
                return;
            }
        }

        private string[] CheckAndReturnArguments(int numberOfArguments, string arguments)
        {
            var argumentArray = JsonHelper.Deserialize<string[]>(arguments);

            if (argumentArray.Length != numberOfArguments + 1)
            {
                DispatchCommandResult(new PluginResult(PluginResult.Status.JSON_EXCEPTION));
                return new string[] { };
            }

            return argumentArray;
        }
    }
}
