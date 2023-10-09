using Blazored.LocalStorage;
using EuroConnector.ClientApp.Data.Interfaces;
using System.Timers;

namespace EuroConnector.ClientApp.Providers
{
    public class TimerProvider
    {
        private readonly IDocumentService _documentService;

        public System.Timers.Timer Timer { get; private set; }

        public TimerProvider(IDocumentService documentService)
        {
            _documentService = documentService;
        }

        public void SetTimer(int minutes)
        {
            Timer = new System.Timers.Timer(minutes * 60 * 1000);
            Timer.Elapsed += OnTimedEvent;
            Timer.AutoReset = true;
            Timer.Enabled = true;
        }

        public void DisposeTimer()
        {
            Timer.Dispose();
        }

        private async void OnTimedEvent(object source, ElapsedEventArgs e)
        {
            await _documentService.SendDocuments();
        }
    }
}
