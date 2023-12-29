namespace EuroConnector.ClientApp.Data.Models
{
    public class PathsSettings
    {
        public string OutboxPath { get; set; }
        public string SentPath { get; set; }
        public string FailedPath { get; set; }
        public string InboxPath { get; set; }
    }
}
