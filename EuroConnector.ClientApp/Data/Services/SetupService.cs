using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using EuroConnector.ClientApp.Extensions;
using EuroConnector.ClientApp.Helpers;
using EuroConnector.ClientApp.Providers;
using Serilog;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Reflection;

namespace EuroConnector.ClientApp.Data.Services
{
    public class SetupService : ISetupService
    {
        private readonly AuthenticationProvider _authenticationProvider;
        private readonly HttpClient _httpClient;
        private readonly ILogger _logger;

        public SetupService(
            AuthenticationProvider authenticationProvider,
            HttpClient httpClient,
            ILogger logger)
        {
            _authenticationProvider = authenticationProvider;
            _httpClient = httpClient;
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
            SetTokens(responseData);

            Preferences.Set("username", properties.UserName, Assembly.GetExecutingAssembly().Location);
            Preferences.Set("apiUrl", properties.ApiUrl, Assembly.GetExecutingAssembly().Location);

            _authenticationProvider.SignIn(responseData.AccessToken);
        }

        public LoginSettings GetLoginSettings()
        {
            var username = Preferences.Get("username", string.Empty, Assembly.GetExecutingAssembly().Location);
            var apiUrl = Preferences.Get("apiUrl", string.Empty, Assembly.GetExecutingAssembly().Location);

            return new()
            {
                UserName = username,
                ApiUrl = apiUrl,
            };
        }

        public void Logout()
        {
            ClearSettings(new[] { "accessToken", "refreshToken", "username" });
            _authenticationProvider.SignOut();
        }

        public void ClearSettings(IEnumerable<string> keysToClear)
        {
            if (keysToClear is null)
            {
                Preferences.Clear(Assembly.GetExecutingAssembly().Location);
                _authenticationProvider.SignOut();

                return;
            }

            foreach (var key in keysToClear)
            {
                Preferences.Remove(key, Assembly.GetExecutingAssembly().Location);
            }
        }

        public void ApplyPathsSettings(PathsSettings settings)
        {
            var success = true;

            success = success && SetPath(settings.OutboxPath, "outboxPath");
            success = success && SetPath(settings.OutboxSpoolPath, "outboxSpoolPath");
            success = success && SetPath(settings.InboxPath, "inboxPath");
            success = success && SetPath(settings.FailedPath, "failedPath");

            if (!success)
                throw new Exception("At least one path was invalid. Check logs for more information.");

            var processingPath = Path.Combine(settings.OutboxPath, "processing");
            var processingDir = new DirectoryInfo(processingPath);
            if (!processingDir.Exists) processingDir.Create();
        }

        public PathsSettings GetPathsSettings()
        {
            var outboxPath = Preferences.Get("outboxPath", "C:\\Data\\EuroConnector\\Outbox", Assembly.GetExecutingAssembly().Location);
            var outboxSpoolPath = Preferences.Get("outboxSpoolPath", "C:\\Data\\EuroConnector\\OutboxSpool", Assembly.GetExecutingAssembly().Location);
            var inboxPath = Preferences.Get("inboxPath", "C:\\Data\\EuroConnector\\Inbox", Assembly.GetExecutingAssembly().Location);
            var failedPath = Preferences.Get("failedPath", "C:\\Data\\EuroConnector\\Failed", Assembly.GetExecutingAssembly().Location);

            return new()
            {
                OutboxPath = outboxPath,
                OutboxSpoolPath = outboxSpoolPath,
                InboxPath = inboxPath,
                FailedPath = failedPath,
            };
        }

        public async Task RefreshToken()
        {
            var refreshToken = Preferences.Get("refreshToken", string.Empty, Assembly.GetExecutingAssembly().Location);
            var apiUrl = Preferences.Get("apiUrl", string.Empty, Assembly.GetExecutingAssembly().Location);

            using var requestMessage = new HttpRequestMessage(HttpMethod.Get, $"{apiUrl}public/v1/authorization/token-refresh");
            requestMessage.Headers.Authorization = new AuthenticationHeaderValue("Bearer", refreshToken);

            var response = await _httpClient.SendAsync(requestMessage);

            if (!response.IsSuccessStatusCode)
            {
                _authenticationProvider.SignOut();
                throw new Exception(response.ReasonPhrase);
            }

            var responseData = await response.Content.ReadFromJsonAsync<TokenResponse>();
            SetTokens(responseData);

            _authenticationProvider.SignIn(responseData.AccessToken);
        }

        public void SetDefaultDirectories()
        {
            SetDefaultDirectory("outboxPath", "C:\\Data\\EuroConnector\\Outbox");
            SetDefaultDirectory("outboxSpoolPath", "C:\\Data\\EuroConnector\\OutboxSpool");
            SetDefaultDirectory("inboxPath", "C:\\Data\\EuroConnector\\Inbox");
            SetDefaultDirectory("failedPath", "C:\\Data\\EuroConnector\\Failed");
        }

        private void SetTokens(TokenResponse tokenResponse)
        {
            Preferences.Set("accessToken", tokenResponse.AccessToken, Assembly.GetExecutingAssembly().Location);
            Preferences.Set("accessExpiration", tokenResponse.AccessTokenExpiresUtc.ToUniversalTime(), Assembly.GetExecutingAssembly().Location);
            Preferences.Set("refreshToken", tokenResponse.RefreshToken, Assembly.GetExecutingAssembly().Location);
            Preferences.Set("refreshExpiration", tokenResponse.RefreshTokenExpiresUtc.ToUniversalTime(), Assembly.GetExecutingAssembly().Location);

            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("bearer", tokenResponse.AccessToken);
        }

        private bool SetPath(string path, string localStorageVariable)
        {
            if (path.IsValidPath())
            {
                var dir = new DirectoryInfo(path);
                if (!dir.Exists) dir.Create();

                Preferences.Set(localStorageVariable, path, Assembly.GetExecutingAssembly().Location);

                return true;
            }

            _logger.Warning("Could not set {Variable} because the path {Path} is invalid.", localStorageVariable, path);
            return false;
        }

        private void SetDefaultDirectory(string localStorageVariable, string defaultPath)
        {
            var path = Preferences.Get(localStorageVariable, string.Empty, Assembly.GetExecutingAssembly().Location);
            if (!string.IsNullOrEmpty(path)) return;

            var dir = new DirectoryInfo(defaultPath);
            if (!dir.Exists) dir.Create();
            Preferences.Set(localStorageVariable, defaultPath, Assembly.GetExecutingAssembly().Location);
        }
    }
}
