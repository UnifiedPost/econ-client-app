namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface IVersionService
    {
        Task<string> GetApiVersion();
    }
}