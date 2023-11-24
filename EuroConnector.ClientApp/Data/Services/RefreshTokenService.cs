using Blazored.LocalStorage;
using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Helpers;
using Serilog;

namespace EuroConnector.ClientApp.Data.Services
{
    public class RefreshTokenService : IRefreshTokenService
    {
        private readonly ILocalStorageService _localStorage;
        private readonly ISetupService _setupService;
        private readonly ILogger _logger;

        public RefreshTokenService(ILocalStorageService localStorage, ISetupService setupService, ILogger logger)
        {
            _localStorage = localStorage;
            _setupService = setupService;
            _logger = logger;
        }

        public async Task TryRefreshToken()
        {
            try
            {
                var expTime = await _localStorage.GetItemAsync<DateTime>("accessExpiration");

                var diff = expTime.ToUniversalTime() - DateTime.UtcNow;
                if (diff.TotalMinutes <= 2) await _setupService.RefreshToken();
            }
            catch (Exception)
            {
                await _setupService.ClearSettings(new[] { "accessToken", "accessExpiration", "refreshToken", "refreshExpiration" });
            }
        }
    }
}
