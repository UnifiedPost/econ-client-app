using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using EuroConnector.ClientApp.Extensions;
using EuroConnector.ClientApp.Helpers;
using Serilog;
using System.Net.Http.Json;
using System.Reflection;
using System.Text;
using System.Text.Json;
using static java.awt.BufferCapabilities;

namespace EuroConnector.ClientApp.Data.Services
{
    public class DocumentService : IDocumentService
    {
        private readonly HttpClient _httpClient;
        private readonly ILogger _logger;

        public DocumentService(
            HttpClient httpClient,
            ILogger logger)
        {
            _httpClient = httpClient;
            _logger = logger;
        }

        public async Task SendDocuments()
        {
            var outPath = Preferences.Get("outboxPath", string.Empty, Assembly.GetExecutingAssembly().Location);
            var outSpoolPath = Preferences.Get("outboxSpoolPath", string.Empty, Assembly.GetExecutingAssembly().Location);

            _logger.Information("Sending documents in the outbox spool location. {OutboxSpoolPath}", outSpoolPath);

            var outboxSpool = new DirectoryInfo(outSpoolPath);
            var files = outboxSpool.EnumerateFiles();

            if (files is null || !files.Any())
            {
                _logger.Information("There are no documents in the outbox spool path.");
                return;
            }

            var apiUrl = Preferences.Get("apiUrl", string.Empty, Assembly.GetExecutingAssembly().Location);
            var requestUrl = $"{apiUrl}public/v1/documents/send";

            int failed = 0;

            foreach (var file in files)
            {
                var fileContents = File.ReadAllText(file.FullName);

                var request = new DocumentSendRequest
                {
                    DocumentContent = Encoding.UTF8.GetBytes(fileContents),
                };

                _logger.Information("Sending document. File {FileName}.", file.Name);
                _logger.Information("POST {Url}\n{Body}", requestUrl, request.ToJsonString());

                try
                {
                    var response = await _httpClient.PostAsync(requestUrl, JsonContent.Create(request));

                    bool documentFailed = !response.IsSuccessStatusCode;

                    if (response.IsSuccessStatusCode)
                    {
                        var responseJson = await response.Content.ReadAsStringAsync();
                        var responseData = await response.Content.ReadFromJsonAsync<DocumentSendResponse>();
                        var document = responseData.Documents.FirstOrDefault();
                        _logger.Information("Document ID {DocumentID}: File {FileName} sent successfully. Response data:\n{ResponseJson}",
                            document.DocumentId, file.Name, responseJson);

                        file.SafeMoveTo(Path.Combine(outPath, file.Name));
                    }
                    else
                    {
                        var error = await response.Content.ReadAsStringAsync();

                        _logger.Error("File {FileName} sending failed.\nResponse data: {ResponseJson}", file.Name, error);

                        var message = await ResponseHelper.ProcessFailedRequest(response, _logger, $"File {file.Name} sending failed.");
                        failed++;
                    }
                }
                catch (Exception ex)
                {
                    _logger.Error(ex, "File {FileName} sending failed. {Message}", file.Name, ex.Message);
                    failed++;
                }
            }

            if (failed > 0) throw new Exception($"{failed} documents failed. Check the logs for more information.");
            _logger.Information("All documents were sent successfully.");
        }

        public async Task SendInvoiceResponse(string content)
        {
            _logger.Information("Sending Invoice Response");

            var apiUrl = Preferences.Get("apiUrl", string.Empty, Assembly.GetExecutingAssembly().Location);
            var requestUrl = $"{apiUrl}public/v1/documents/send";

            var request = new DocumentSendRequest
            {
                DocumentContent = Encoding.UTF8.GetBytes(content),
            };

            _logger.Information("POST {Url}\n{Body}", requestUrl, request.ToJsonString());

            var response = await _httpClient.PostAsync(requestUrl, JsonContent.Create(request));

            bool documentFailed = !response.IsSuccessStatusCode;

            if (response.IsSuccessStatusCode)
            {
                var responseJson = await response.Content.ReadAsStringAsync();
                var responseData = await response.Content.ReadFromJsonAsync<DocumentSendResponse>();
                var document = responseData.Documents.FirstOrDefault();
                _logger.Information("Document ID {DocumentID}: Invoice Response sent successfully. Response data:\n{ResponseJson}",
                    document.DocumentId, responseJson);
            }
            else
            {
                var error = await response.Content.ReadAsStringAsync();

                _logger.Error("Invoice Response sending failed.\nResponse data: {ResponseJson}", error);

                var message = await ResponseHelper.ProcessFailedRequest(response, _logger, $"Invoice Response sending failed.");
                throw new Exception(message);
            }
        }

        public async Task<ReceivedDocuments> ReceiveDocumentList()
        {
            var apiUrl = Preferences.Get("apiUrl", string.Empty, Assembly.GetExecutingAssembly().Location);
            var requestUrl = $"{apiUrl}public/v1/documents/received-list";

            _logger.Information("Fetching the list of received documents.");
            _logger.Information("GET {Url}", requestUrl);

            var response = await _httpClient.GetAsync(requestUrl);

            if (!response.IsSuccessStatusCode)
            {
                var message = await ResponseHelper.ProcessFailedRequest(response, _logger);
                throw new Exception(message);
            }

            var receivedDocuments = await response.Content.ReadFromJsonAsync<ReceivedDocuments>();

            _logger.Information("Received {NumberOfDocuments} documents.", receivedDocuments.Documents.Count);
            return receivedDocuments;
        }

        public async Task<DocumentSearchResponse> SearchDocuments(DocumentSearchRequest request)
        {
            var apiUrl = Preferences.Get("apiUrl", string.Empty, Assembly.GetExecutingAssembly().Location);
            var requestUrl = $"{apiUrl}public/v1/documents/search";

            _logger.Information("Fetching the list of documents in {FolderName} folder.", request.FolderName);
            _logger.Information("POST {Url}\n{Body}", requestUrl, request.ToJsonString());

            var body = JsonContent.Create(request);
            var response = await _httpClient.PostAsync(requestUrl, body);

            if (!response.IsSuccessStatusCode)
            {
                var message = await ResponseHelper.ProcessFailedRequest(response, _logger);
                throw new Exception(message);
            }

            var documents = await response.Content.ReadFromJsonAsync<DocumentSearchResponse>();

            return documents;
        }

        public async Task<DownloadedDocument> DownloadDocument(string id)
        {
            var apiUrl = Preferences.Get("apiUrl", string.Empty, Assembly.GetExecutingAssembly().Location);
            var requestUrl = $"{apiUrl}public/v1/documents/{id}/content";

            _logger.Information("Downloading document ID {DocumentId}", id);
            _logger.Information("GET {Url}", requestUrl);

            var response = await _httpClient.GetAsync(requestUrl);

            if (!response.IsSuccessStatusCode)
            {
                var message = await ResponseHelper.ProcessFailedRequest(response, _logger);
                throw new Exception(message);
            }

            var downloadedDocument = await response.Content.ReadFromJsonAsync<DownloadedDocument>();
            var responseJson = await response.Content.ReadAsStringAsync();

            _logger.Information("Document ID {DocumentId} content successfully downloaded. Response data:\n{ResponseJson}", id, responseJson);
            return downloadedDocument;
        }

        public async Task<HttpResponseMessage> ViewDocumentMetadata(string id)
        {
            var apiUrl = Preferences.Get("apiUrl", string.Empty, Assembly.GetExecutingAssembly().Location);
            var requestUrl = $"{apiUrl}public/v1/documents/{id}";

            _logger.Information("Fetching the metadata for document ID {DocumentId}", id);
            _logger.Information("GET {Url}", requestUrl);

            var response = await _httpClient.GetAsync(requestUrl);

            if (!response.IsSuccessStatusCode)
            {
                var message = await ResponseHelper.ProcessFailedRequest(response, _logger);
                throw new Exception(message);
            }

            var responseJson = await response.Content.ReadAsStringAsync();

            _logger.Information("Document ID {DocumentId} data:\n{ResponseJson}", id, responseJson);

            return response;
        }

        public async Task ChangeReceivedDocumentStatus(string id)
        {
            var apiUrl = Preferences.Get("apiUrl", string.Empty, Assembly.GetExecutingAssembly().Location);
            var requestUrl = $"{apiUrl}public/v1/documents/{id}/status/Received";

            _logger.Information("Changing status for document ID {DocumentId}", id);
            _logger.Information("PUT {Url}", requestUrl);

            var response = await _httpClient.PutAsync(requestUrl, null);

            if (!response.IsSuccessStatusCode)
            {
                var message = await ResponseHelper.ProcessFailedRequest(response, _logger);
                throw new Exception(message);
            }

            var responseJson = await response.Content.ReadAsStringAsync();

            _logger.Information("Document ID {DocumentId} status change response:\n{ResponseJson}", id, responseJson);
        }

        private async Task SaveResponseToFile(string path, string content)
        {
            await File.WriteAllTextAsync(path, content);
        }
    }
}
