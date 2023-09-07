using EuroConnector.ClientApp.Data.Entities;

namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface IVersionService
    {
        Task<ApiVersion> GetApiVersion();
    }
}