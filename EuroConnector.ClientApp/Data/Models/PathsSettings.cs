namespace EuroConnector.ClientApp.Data.Models
{
    public class PathsSettings
    {
        public string OutboxSpoolPath { get; set; }
        public string OutboxPath { get; set; }
        public string InboxPath { get; set; }
        public string FailedPath { get; set; }
    }
}
