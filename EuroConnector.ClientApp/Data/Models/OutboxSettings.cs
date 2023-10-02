namespace EuroConnector.ClientApp.Data.Models
{
    public class OutboxSettings
    {
        public string OutboxPath { get; set; }
        public string SentPath { get; set; }
        public string FailedPath { get; set; }
    }
}
