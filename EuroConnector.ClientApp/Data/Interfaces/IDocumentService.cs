using EuroConnector.ClientApp.Data.Models;

namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface IDocumentService
    {
        Task SendDocuments();
        Task<ReceivedDocuments> ReceiveDocumentList();
        Task<DownloadedDocument> DownloadDocument(Guid id);
        Task<DocumentMetadataList> ViewDocumentMetadata(Guid id);
        Task ChangeReceivedDocumentStatus(Guid id);
    }
}