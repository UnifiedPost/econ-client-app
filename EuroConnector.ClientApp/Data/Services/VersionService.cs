using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using System.Net.Http.Json;
using System.Reflection;

namespace EuroConnector.ClientApp.Data.Services
{
    public class VersionService : IVersionService
    {
        private readonly HttpClient _httpClient;

        public VersionService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<ApiVersion> GetApiVersion()
        {
            var apiUrl = Preferences.Get("apiUrl", string.Empty, Assembly.GetExecutingAssembly().Location);
            if (string.IsNullOrEmpty(apiUrl)) return new ApiVersion
            {
                Version = "Error",
                ReleaseDate = null,
            };

            var result = await _httpClient.GetFromJsonAsync<ApiVersion>($"{apiUrl}public/v1/extensions/version");

            return result;
        }
    }
}
