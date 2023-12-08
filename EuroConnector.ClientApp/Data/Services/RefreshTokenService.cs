using EuroConnector.ClientApp.Data.Interfaces;
using Serilog;

namespace EuroConnector.ClientApp.Data.Services
{
    public class RefreshTokenService : IRefreshTokenService
    {
        private readonly ISetupService _setupService;
        private readonly ILogger _logger;

        public RefreshTokenService(ISetupService setupService, ILogger logger)
        {
            _setupService = setupService;
            _logger = logger;
        }

        public async Task TryRefreshToken()
        {
            try
            {
                var expTime = Preferences.Get("accessExpiration", new DateTime());

                var diff = expTime.ToUniversalTime() - DateTime.UtcNow;
                if (diff.TotalMinutes <= 2) await _setupService.RefreshToken();
            }
            catch (Exception)
            {
                _setupService.ClearSettings(new[] { "accessToken", "accessExpiration", "refreshToken", "refreshExpiration" });
            }
        }
    }
}
