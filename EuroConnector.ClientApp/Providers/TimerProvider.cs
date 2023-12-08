using System.Timers;

namespace EuroConnector.ClientApp.Providers
{
    public class TimerProvider
    {
        public System.Timers.Timer Timer { get; private set; }

        public TimerProvider()
        {
            CreateTimer();
        }

        public void SetTimer(int minutes)
        {
            try
            {
                Timer.Interval = minutes * 60 * 1000;
                Timer.AutoReset = true;
                Timer.Enabled = true;
            }
            catch (ObjectDisposedException)
            {
                CreateTimer();
                SetTimer(minutes);
            }
        }

        public void DisposeTimer()
        {
            Timer.Dispose();
        }

        private void CreateTimer()
        {
            Timer = new System.Timers.Timer();
        }
    }
}
