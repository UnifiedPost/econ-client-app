namespace EuroConnector.ClientApp.Data.Models
{
    public class DocumentSendRequest
    {
        public string DocumentStandard { get; set; } = "BIS3";
        public byte[] DocumentContent { get; set; }
    }
}
