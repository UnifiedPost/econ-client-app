using EuroConnector.ClientApp.Data.Models;

namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface ISetupService
    {
        Task Login(LoginSettings properties);
        void Logout();
        LoginSettings GetLoginSettings();
        void ApplyOutboxSettings(OutboxSettings settings);
        void ApplyInboxSettings(string path);
        OutboxSettings GetOutboxSettings();
        void ClearSettings(IEnumerable<string> keysToClear);
        Task RefreshToken();
        void SetDefaultDirectories();
    }
}