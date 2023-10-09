using Blazored.LocalStorage;
using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using System.Net.Http.Json;

namespace EuroConnector.ClientApp.Data.Services
{
    public class DocumentService : IDocumentService
    {
        private readonly HttpClient _httpClient;
        private readonly ILocalStorageService _localStorage;

        public DocumentService(HttpClient httpClient, ILocalStorageService localStorage)
        {
            _httpClient = httpClient;
            _localStorage = localStorage;
        }

        public async Task SendDocuments()
        {
            var outPath = await _localStorage.GetItemAsync<string>("outboxPath");
            var sentPath = await _localStorage.GetItemAsync<string>("sendPath");
            var failedPath = await _localStorage.GetItemAsync<string>("failedPath");
            var outbox = new DirectoryInfo(outPath);
            var files = outbox.GetFiles();

            var apiUrl = await _localStorage.GetItemAsync<string>("apiUrl");

            foreach (var file in files)
            {
                var request = new DocumentSendRequest
                {
                    DocumentStandard = "BIS3",
                    DocumentContent = File.ReadAllText(file.FullName),
                };

                var response = await _httpClient.PostAsync($"{apiUrl}/api/public/v1/documents/send", JsonContent.Create(request));

                if (response.IsSuccessStatusCode)
                {
                    file.MoveTo(Path.Combine(sentPath, file.Name));
                }
                else
                {
                    file.MoveTo(Path.Combine(failedPath, file.Name));
                }
            }
        }
    }
}
