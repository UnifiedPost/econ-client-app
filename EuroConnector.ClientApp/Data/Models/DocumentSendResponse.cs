namespace EuroConnector.ClientApp.Data.Models
{
    public class DocumentSendResponse
    {
        public List<DocumentSendInfo> Documents { get; set; }
    }

    public class DocumentSendInfo
    {
        public string DocumentId { get; set; }
        public string DocumentStandard { get; set; }
        public string DocumentType { get; set; }
        public string Status { get; set; }
        public string FolderName { get; set; }
    }
}
