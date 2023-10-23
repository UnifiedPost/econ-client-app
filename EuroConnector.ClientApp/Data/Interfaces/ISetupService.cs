using EuroConnector.ClientApp.Data.Models;

namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface ISetupService
    {
        Task Login(LoginSettings properties);
        Task Logout();
        Task<LoginSettings> GetLoginSettings();
        Task ApplyOutboxSettings(OutboxSettings settings);
        Task<OutboxSettings> GetOutboxSettings();
        Task ClearSettings(IEnumerable<string> keysToClear);
        Task RefreshToken();
    }
}