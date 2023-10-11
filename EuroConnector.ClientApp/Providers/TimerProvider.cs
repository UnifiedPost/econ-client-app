using Blazored.LocalStorage;
using EuroConnector.ClientApp.Data.Interfaces;
using System.Timers;

namespace EuroConnector.ClientApp.Providers
{
    public class TimerProvider
    {
        public System.Timers.Timer Timer { get; private set; }

        public TimerProvider()
        {
            Timer = new System.Timers.Timer();
        }

        public void SetTimer(int minutes)
        {
            Timer.Interval = minutes * 60 * 1000;
            Timer.AutoReset = true;
            Timer.Enabled = true;
        }

        public void DisposeTimer()
        {
            Timer.Dispose();
        }
    }
}
