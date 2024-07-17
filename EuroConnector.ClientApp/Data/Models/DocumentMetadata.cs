namespace EuroConnector.ClientApp.Data.Models
{
    public class DocumentMetadata
    {
        public string DocumentId { get; set; }
        public string DocumentNo { get; set; }
        public string DocumentStandard { get; set; }
        public string DocumentType { get; set; }
        public string SenderEndpointId { get; set; }
        public string SenderName { get; set; }
        public string SenderEntityCode { get; set; }
        public string SenderVatNumber { get; set; }
        public string RecipientEndpointId { get; set; }
        public string RecipientName { get; set; }
        public string RecipientEntityCode { get; set; }
        public string RecipientVatNumber { get; set; }
        public string PeppolMessageId { get; set; }
        public string DocumentReference { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public string Status { get; set; }
        public string StatusNotes { get; set; }
        public string FolderName { get; set; }
        public IEnumerable<MetadataField> CustomFields { get; set; } = [];
    }

    public class DocumentMetadataList
    {
        public IEnumerable<DocumentMetadata> Documents { get; set; }
    }

    public class MetadataField
    {
        public string Field { get; set; }
        public string Value { get; set; }
    }
}
