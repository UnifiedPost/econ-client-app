using EuroConnector.ClientApp.Data.Models;

namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface IVersionService
    {
        Task<ApiVersion> GetApiVersion();
    }
}