using System.Timers;

namespace EuroConnector.ClientApp.Providers
{
    public class BackgroundProvider : IDisposable
    {
        public event EventHandler EventExecuted;

        private System.Timers.Timer _timer;
        private bool _running;

        public void StartExecuting()
        {
            if (!_running)
            {
                _timer = new System.Timers.Timer();
                _timer.Interval = 60 * 1000;
                _timer.Elapsed += HandleTimer;
                _timer.AutoReset = true;
                _timer.Enabled = true;

                _running = true;
            }
        }

        public void Dispose()
        {
            if (_running)
            {
                _timer.Dispose();
            }
        }

        private void HandleTimer(object source, ElapsedEventArgs e)
        {
            OnEventExecuted();
        }

        private void OnEventExecuted()
        {
            EventExecuted?.Invoke(this, EventArgs.Empty);
        }
    }
}
