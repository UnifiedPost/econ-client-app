﻿using Blazored.LocalStorage;
using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using EuroConnector.ClientApp.Helpers;
using Serilog;
using System.Net.Http.Json;

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
            var sentPath = await _localStorage.GetItemAsync<string>("sendPath");
            var failedPath = await _localStorage.GetItemAsync<string>("failedPath");

            _logger.Information("Sending documents in the outbox location. {OutboxPath}", outPath);

            var outbox = new DirectoryInfo(outPath);
            var files = outbox.GetFiles();

            var apiUrl = await _localStorage.GetItemAsync<string>("apiUrl");

            int failed = 0;

            foreach (var file in files)
            {
                var request = new DocumentSendRequest
                {
                    DocumentStandard = "BIS3",
                    DocumentContent = File.ReadAllBytes(file.FullName),
                };

                _logger.Information("Sending document. File {FileName}.", file.Name);

                var response = await _httpClient.PostAsync($"{apiUrl}/api/public/v1/documents/send", JsonContent.Create(request));

                if (response.IsSuccessStatusCode)
                {
                    _logger.Information("File {FileName} sent successfully. Moving to {SentPath}.", file.Name, sentPath);
                    file.MoveTo(Path.Combine(sentPath, file.Name));
                }
                else
                {
                    _logger.Error("File {FileName} sending failed. Moving to {FailedPath}.", file.Name, failedPath);
                    file.MoveTo(Path.Combine(failedPath, file.Name));

                    var message = await ResponseHelper.ProcessFailedRequest(response, _logger, $"File {file.Name} sending failed.");
                    failed++;
                }
            }

            if (failed > 0) throw new Exception($"{failed} documents failed. Check the logs for more information.");
        }
    }
}
