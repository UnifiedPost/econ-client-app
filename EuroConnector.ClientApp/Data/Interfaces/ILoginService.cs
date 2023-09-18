using EuroConnector.ClientApp.Data.Models;

namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface ILoginService
    {
        Task Login(SetupProperties properties);
        Task ClearSettings();
        Task RefreshToken();
    }
}