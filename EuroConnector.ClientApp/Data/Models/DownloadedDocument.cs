namespace EuroConnector.ClientApp.Data.Models
{
    public class DownloadedDocument
    {
        public string DocumentId { get; set; }
        public string DocumentStandard { get; set; }
        public byte[] DocumentContent { get; set; }
    }
}
