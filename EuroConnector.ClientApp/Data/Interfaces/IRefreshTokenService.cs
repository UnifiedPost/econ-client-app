namespace EuroConnector.ClientApp.Data.Interfaces
{
    public interface IRefreshTokenService
    {
        Task TryRefreshToken();
    }
}