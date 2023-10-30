﻿using Blazored.LocalStorage;
using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using EuroConnector.ClientApp.Extensions;
using EuroConnector.ClientApp.Helpers;
using Serilog;
using System.Net.Http.Json;
using System.Text;

namespace EuroConnector.ClientApp.Data.Services
{
    public class DocumentService : IDocumentService
    {
        private readonly HttpClient _httpClient;
        private readonly ILocalStorageService _localStorage;
        private readonly ILogger _logger;

        public DocumentService(
            HttpClient httpClient,
            ILocalStorageService localStorage,
            ILogger logger)
        {
            _httpClient = httpClient;
            _localStorage = localStorage;
            _logger = logger;
        }

        public async Task SendDocuments()
        {
            var outPath = await _localStorage.GetItemAsync<string>("outboxPath");
            var sentPath = await _localStorage.GetItemAsync<string>("sentPath");
            var failedPath = await _localStorage.GetItemAsync<string>("failedPath");

            _logger.Information("Sending documents in the outbox location. {OutboxPath}", outPath);

            var outbox = new DirectoryInfo(outPath);
            var files = outbox.GetFiles();

            if (files is null || files.Length == 0)
            {
                _logger.Information("There are no documents in the outbox path.");
                return;
            }

            var apiUrl = await _localStorage.GetItemAsync<string>("apiUrl");

            int failed = 0;

            foreach (var file in files)
            {
                var fileContents = File.ReadAllText(file.FullName);

                var request = new DocumentSendRequest
                {
                    DocumentContent = Encoding.UTF8.GetBytes(fileContents),
                };

                _logger.Information("Sending document. File {FileName}.", file.Name);

                try
                {
                    var response = await _httpClient.PostAsync($"{apiUrl}public/v1/documents/send", JsonContent.Create(request));

                    if (response.IsSuccessStatusCode)
                    {
                        var responseJson = await response.Content.ReadAsStringAsync();
                        var responseData = await response.Content.ReadFromJsonAsync<DocumentSendResponse>();
                        var document = responseData.Documents.FirstOrDefault();
                        _logger.Information("Document ID {DocumentID}: File {FileName} sent successfully. Moving to {SentPath}. Response data:\n{ResponseJson}",
                            document.DocumentId, file.Name, sentPath, responseJson);

                        var metadata = await ViewDocumentMetadata(document.DocumentId);
                        var docMetadata = metadata.Documents.FirstOrDefault();

                        file.SaveMoveTo(Path.Combine(sentPath, $"{document.DocumentId}-{docMetadata.Status}-{file.Name}"));
                    }
                    else
                    {
                        _logger.Error("File {FileName} sending failed. Moving to {FailedPath}.", file.Name, failedPath);
                        file.SaveMoveTo(Path.Combine(failedPath, file.Name));

                        var message = await ResponseHelper.ProcessFailedRequest(response, _logger, $"File {file.Name} sending failed.");
                        failed++;
                    }
                }
                catch (Exception ex)
                {
                    _logger.Error(ex, "File {FileName} sending failed. Moving to {FailedPath}.", file.Name, failedPath);
                    file.SaveMoveTo(Path.Combine(failedPath, file.Name));
                    failed++;
                }
            }

            if (failed > 0) throw new Exception($"{failed} documents failed. Check the logs for more information.");
            _logger.Information("All documents were sent successfully.");
        }

        public async Task<ReceivedDocuments> ReceiveDocumentList()
        {
            _logger.Information("Fetching the list of received documents.");

            var apiUrl = await _localStorage.GetItemAsync<string>("apiUrl");
            var response = await _httpClient.GetAsync($"{apiUrl}public/v1/documents/received-list");

            if (!response.IsSuccessStatusCode)
            {
                var message = await ResponseHelper.ProcessFailedRequest(response, _logger);
                throw new Exception(message);
            }

            var receivedDocuments = await response.Content.ReadFromJsonAsync<ReceivedDocuments>();

            _logger.Information("Received {NumberOfDocuments} documents.", receivedDocuments.Documents.Count());
            return receivedDocuments;
        }

        public async Task<DownloadedDocument> DownloadDocument(Guid id)
        {
            _logger.Information("Downloading document ID {DocumentId}", id);

            var apiUrl = await _localStorage.GetItemAsync<string>("apiUrl");
            var response = await _httpClient.GetAsync($"{apiUrl}public/v1/documents/{id}/content");

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

        public async Task<DocumentMetadataList> ViewDocumentMetadata(Guid id)
        {
            _logger.Information("Fetching the metadata for document ID {DocumentId}", id);

            var apiUrl = await _localStorage.GetItemAsync<string>("apiUrl");
            var response = await _httpClient.GetAsync($"{apiUrl}public/v1/documents/{id}");

            if (!response.IsSuccessStatusCode)
            {
                var message = await ResponseHelper.ProcessFailedRequest(response, _logger);
                throw new Exception(message);
            }

            var documentMetadata = await response.Content.ReadFromJsonAsync<DocumentMetadataList>();
            var responseJson = await response.Content.ReadAsStringAsync();

            _logger.Information("Document ID {DocumentId} data:\n{ResponseJson}", id, responseJson);

            return documentMetadata;
        }
    }
}
