namespace EuroConnector.ClientApp.Data.Models
{
    public class DocumentSearchRequest : RequestBody
    {
        public string DocumentNo { get; set; }
        public string DocumentType { get; set; }
        public string SenderEndpointId { get; set; }
        public string SenderName { get; set; }
        public string SenderEntityCode { get; set; }
        public string SenderVatNumber { get; set; }
        public string RecipientEndpointId { get; set; }
        public string RecipientName { get; set; }
        public string RecipientEntityCode { get; set; }
        public string RecipientVatNumber { get; set; }
        public string DocumentReference { get; set; }
        public IEnumerable<DateTime?> CreatedBetween { get; set; }
        public IEnumerable<DateTime?> UpdatedBetween { get; set; }
        public string Status { get; set; }
        public string FolderName { get; set; }
        public int RecordsCountLimit { get; set; } = 100;
    }
}
