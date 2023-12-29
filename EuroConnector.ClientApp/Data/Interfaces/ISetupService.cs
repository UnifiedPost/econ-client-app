using EuroConnector.ClientApp.Data.Models;

namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface ISetupService
    {
        Task Login(LoginSettings properties);
        void Logout();
        LoginSettings GetLoginSettings();
        void ApplyPathsSettings(PathsSettings settings);
        PathsSettings GetPathsSettings();
        void ClearSettings(IEnumerable<string> keysToClear);
        Task RefreshToken();
        void SetDefaultDirectories();
    }
}