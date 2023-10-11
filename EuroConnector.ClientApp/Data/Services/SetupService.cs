using Blazored.LocalStorage;
using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using EuroConnector.ClientApp.Helpers;
using EuroConnector.ClientApp.Providers;
using Serilog;
using System.Net.Http.Headers;
using System.Net.Http.Json;

namespace EuroConnector.ClientApp.Data.Services
{
    public class SetupService : ISetupService
    {
        private readonly AuthenticationProvider _authenticationProvider;
        private readonly HttpClient _httpClient;
        private readonly ILocalStorageService _localStorage;
        private readonly ILogger _logger;

        public SetupService(
            AuthenticationProvider authenticationProvider,
            HttpClient httpClient,
            ILocalStorageService localStorage,
            ILogger logger)
        {
            _authenticationProvider = authenticationProvider;
            _httpClient = httpClient;
            _localStorage = localStorage;
            _logger = logger;
        }

        public async Task Login(LoginSettings properties)
        {
            if (!properties.ApiUrl.StartsWith("http")) properties.ApiUrl = $"https://{properties.ApiUrl}";
            if (!properties.ApiUrl.EndsWith("/")) properties.ApiUrl = $"{properties.ApiUrl}/";
            if (!properties.ApiUrl.EndsWith("api/")) properties.ApiUrl = $"{properties.ApiUrl}api/";

            var requestBody = JsonContent.Create(new
            {
                properties.UserName,
                properties.SecretKey,
            });

            var response = await _httpClient.PostAsync($"{properties.ApiUrl}public/v1/authorization/token-create", requestBody);

            if (!response.IsSuccessStatusCode)
            {
                var message = await ResponseHelper.ProcessFailedRequest(response, _logger, "Login failed.");
                throw new Exception(message);
            }

            var responseData = await response.Content.ReadFromJsonAsync<TokenResponse>();
            await SetTokens(responseData);
            await _localStorage.SetItemAsync("apiUrl", properties.ApiUrl);

            _authenticationProvider.SignIn(responseData.AccessToken);
        }

        public async Task Logout()
        {
            await _localStorage.RemoveItemsAsync(new List<string> { "accessToken", "refreshToken", "apiUrl" });
            _authenticationProvider.SignOut();
        }

        public async Task ClearSettings(IEnumerable<string> keysToClear)
        {
            if (keysToClear is null)
            {
                await _localStorage.ClearAsync();
                _authenticationProvider.SignOut();

                return;
            }

            await _localStorage.RemoveItemsAsync(keysToClear);
        }

        public async Task ApplyOutboxSettings(OutboxSettings settings)
        {
            await _localStorage.SetItemAsync("outboxPath", settings.OutboxPath);
            await _localStorage.SetItemAsync("sentPath", settings.SentPath);
            await _localStorage.SetItemAsync("failedPath", settings.FailedPath);
        }

        public async Task<OutboxSettings> GetOutboxSettings()
        {
            var outboxPath = await _localStorage.GetItemAsync<string>("outboxPath");
            var sentPath = await _localStorage.GetItemAsync<string>("sentPath");
            var failedPath = await _localStorage.GetItemAsync<string>("failedPath");

            return new()
            {
                OutboxPath = outboxPath,
                SentPath = sentPath,
                FailedPath = failedPath,
            };
        }

        public async Task RefreshToken()
        {
            var refreshToken = await _localStorage.GetItemAsync<string>("refreshToken");
            var apiUrl = await _localStorage.GetItemAsync<string>("apiUrl");

            using var requestMessage = new HttpRequestMessage(HttpMethod.Get, $"{apiUrl}public/v1/authorization/token-refresh");
            requestMessage.Headers.Authorization = new AuthenticationHeaderValue("bearer", refreshToken);

            var response = await _httpClient.SendAsync(requestMessage);

            if (!response.IsSuccessStatusCode) throw new Exception(response.ReasonPhrase);

            var responseData = await response.Content.ReadFromJsonAsync<TokenResponse>();
            await SetTokens(responseData);

            _authenticationProvider.SignIn(responseData.AccessToken);
        }

        private async Task SetTokens(TokenResponse tokenResponse)
        {
            await _localStorage.SetItemAsync("accessToken", tokenResponse.AccessToken);
            await _localStorage.SetItemAsync("refreshToken", tokenResponse.RefreshToken);
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("bearer", tokenResponse.AccessToken);
        }
    }
}
