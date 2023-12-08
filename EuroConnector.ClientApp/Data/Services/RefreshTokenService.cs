using EuroConnector.ClientApp.Data.Interfaces;
using Serilog;
using System.Reflection;

namespace EuroConnector.ClientApp.Data.Services
{
    public class RefreshTokenService : IRefreshTokenService
    {
        private readonly ISetupService _setupService;

        public RefreshTokenService(ISetupService setupService)
        {
            _setupService = setupService;
        }

        public async Task TryRefreshToken()
        {
            try
            {
                var expTime = Preferences.Get("accessExpiration", new DateTime(), Assembly.GetExecutingAssembly().Location);

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
