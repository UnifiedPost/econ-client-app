using EuroConnector.ClientApp.Data.Models;

namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface ISetupService
    {
        Task ApplySettings(SetupProperties properties);
        Task ClearSettings();
        Task RefreshToken();
    }
}