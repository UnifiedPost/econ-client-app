using EuroConnector.ClientApp.Data.Models;

namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface IDocumentService
    {
        Task SendDocuments();
        Task CheckProcessingDocumentStatus();
        Task<ReceivedDocuments> ReceiveDocumentList();
        Task<DownloadedDocument> DownloadDocument(string id);
        Task<HttpResponseMessage> ViewDocumentMetadata(string id);
        Task ChangeReceivedDocumentStatus(string id);
    }
}