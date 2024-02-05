using EuroConnector.ClientApp.Data.Models;

namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface IDocumentService
    {
        Task SendDocuments();
        Task SendInvoiceResponse(string content);
        Task<ReceivedDocuments> ReceiveDocumentList();
        Task<DocumentSearchResponse> SearchDocuments(DocumentSearchRequest request);
        Task<DownloadedDocument> DownloadDocument(string id);
        Task<HttpResponseMessage> ViewDocumentMetadata(string id);
        Task ChangeReceivedDocumentStatus(string id);
    }
}