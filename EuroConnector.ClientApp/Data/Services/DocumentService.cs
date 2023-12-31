﻿using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using EuroConnector.ClientApp.Extensions;
using EuroConnector.ClientApp.Helpers;
using Serilog;
using System.Net.Http.Json;
using System.Reflection;
using System.Text;
using System.Text.Json;

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
            //var outPath = await _localStorage.GetItemAsync<string>("outboxPath");
            //var failedPath = await _localStorage.GetItemAsync<string>("failedPath");
            var outPath = Preferences.Get("outboxPath", string.Empty, Assembly.GetExecutingAssembly().Location);
            var failedPath = Preferences.Get("failedPath", string.Empty, Assembly.GetExecutingAssembly().Location);

            _logger.Information("Sending documents in the outbox location. {OutboxPath}", outPath);

            var outbox = new DirectoryInfo(outPath);
            var files = outbox.GetFiles();

            if (files is null || files.Length == 0)
            {
                _logger.Information("There are no documents in the outbox path.");
                return;
            }

            //var apiUrl = await _localStorage.GetItemAsync<string>("apiUrl");
            var apiUrl = Preferences.Get("apiUrl", string.Empty, Assembly.GetExecutingAssembly().Location);
            var requestUrl = $"{apiUrl}public/v1/documents/send";

            Dictionary<string, string> documents = new();

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
                        _logger.Information("Document ID {DocumentID}: File {FileName} submitted successfully. Moving to {ProcessingPath}. Response data:\n{ResponseJson}",
                            document.DocumentId, file.Name, Path.Combine(outPath, "processing"), responseJson);

                        var filename = file.SafeMoveTo(Path.Combine(outPath, "processing", file.Name));
                        documents.Add(filename, document.DocumentId);
                    }
                    else
                    {
                        var error = await response.Content.ReadAsStringAsync();

                        _logger.Error("File {FileName} sending failed. Moving to {FailedPath}.\nResponse data: {ResponseJson}", file.Name, failedPath, error);
                        file.SafeMoveTo(Path.Combine(failedPath, file.Name));

                        var message = await ResponseHelper.ProcessFailedRequest(response, _logger, $"File {file.Name} sending failed.");
                        failed++;
                    }
                }
                catch (Exception ex)
                {
                    _logger.Error(ex, "File {FileName} sending failed. Moving to {FailedPath}. {Message}", file.Name, failedPath, ex.Message);
                    file.SafeMoveTo(Path.Combine(failedPath, file.Name));
                    failed++;
                }
            }

            if (failed > 0) throw new Exception($"{failed} documents failed. Check the logs for more information.");
            _logger.Information("All documents were sent and moved to processing successfully.");

            Preferences.Set("processingDocuments", JsonSerializer.Serialize(documents), Assembly.GetExecutingAssembly().Location);
        }

        public async Task CheckProcessingDocumentStatus()
        {
            var outPath = Preferences.Get("outboxPath", string.Empty, Assembly.GetExecutingAssembly().Location);
            var sentPath = Preferences.Get("sentPath", string.Empty, Assembly.GetExecutingAssembly().Location);
            var failedPath = Preferences.Get("failedPath", string.Empty, Assembly.GetExecutingAssembly().Location);

            Dictionary<string, string> documents = new();
            Dictionary<string, int> tries = new();

            var documentsStr = Preferences.Get("processingDocuments", string.Empty, Assembly.GetExecutingAssembly().Location);
            if (!string.IsNullOrEmpty(documentsStr)) documents = JsonSerializer.Deserialize<Dictionary<string, string>>(documentsStr);

            var triesStr = Preferences.Get("processingTries", string.Empty, Assembly.GetExecutingAssembly().Location);
            if (!string.IsNullOrEmpty(triesStr)) tries = JsonSerializer.Deserialize<Dictionary<string, int>>(triesStr);

            tries.ToList().ForEach(x => tries[x.Key]++);

            var processingPath = Path.Combine(outPath, "processing");
            if (!Directory.Exists(processingPath)) return;

            var processingInfo = new DirectoryInfo(processingPath);
            var files = processingInfo.EnumerateFiles();

            if (!files.Any() || documents.Count == 0)
            {
                Preferences.Remove("processingDocuments", Assembly.GetExecutingAssembly().Location);
                return;
            }

            _logger.Information("Starting processing documents submitted for sending.");

            foreach (var file in files)
            {
                var filename = Path.GetFileName(file.FullName);

                try
                {
                    var dictSuccess = documents.TryGetValue(filename, out var documentId);
                    if (!dictSuccess) continue;

                    if (!tries.ContainsKey(documentId)) tries.Add(documentId, 1);

                    if (!file.Exists)
                    {
                        documents.Remove(filename);
                        tries.Remove(documentId);
                    }

                    var metadataResponse = await ViewDocumentMetadata(documentId);
                    var metadata = await metadataResponse.Content.ReadFromJsonAsync<DocumentMetadataList>();

                    var docMetadata = metadata.Documents.FirstOrDefault();

                    if (docMetadata.Status == "Error")
                    {
                        _logger.Error("Document ID {DocumentID}: File {FileName} sending failed. Error status notes: {StatusNotes}. Moving to {FailedPath}.",
                            documentId, file.Name, docMetadata.StatusNotes, failedPath);
                        var filenameAfterMoving = file.SafeMoveTo(Path.Combine(failedPath, file.Name));
                        await SaveResponseToFile(Path.Combine(failedPath, $"{Path.GetFileNameWithoutExtension(filenameAfterMoving)}.json"), await metadataResponse.Content.ReadAsStringAsync());
                        documents.Remove(filename);
                        tries.Remove(documentId);
                    }
                    else if (docMetadata.Status == "Delivered")
                    {
                        _logger.Information("Document ID {DocumentID}: File {FileName} sent successfully. Moving to {SentPath}.", documentId, file.Name, sentPath);
                        file.SafeMoveTo(Path.Combine(sentPath, $"{documentId}_{docMetadata.Status}_{file.Name}"));
                        documents.Remove(filename);
                        tries.Remove(documentId);
                    }
                    else if (tries[documentId] >= 10)
                    {
                        _logger.Error("Document ID {DocumentID}: File {FileName} sending failed. The status was not updated (status was {Status}). Moving to {FailedPath}.",
                            documentId, file.Name, docMetadata.Status, failedPath);
                        file.SafeMoveTo(Path.Combine(failedPath, file.Name));
                        documents.Remove(filename);
                        tries.Remove(documentId);
                    }
                }
                catch (KeyNotFoundException ex)
                {
                    _logger.Warning(ex, "{Filename} processing failed.", filename);
                }

                Preferences.Set("processingDocuments", JsonSerializer.Serialize(documents), Assembly.GetExecutingAssembly().Location);
                Preferences.Set("processingTries", JsonSerializer.Serialize(tries), Assembly.GetExecutingAssembly().Location);

            }
            _logger.Information("Finished processing the documents.");
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
