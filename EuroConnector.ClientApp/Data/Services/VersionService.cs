using EuroConnector.ClientApp.Data.Interfaces;

namespace EuroConnector.ClientApp.Data.Services
{
    public class VersionService : IVersionService
	{
		private readonly HttpClient _httpClient;

		public VersionService(HttpClient httpClient)
		{
			_httpClient = httpClient;
		}

		public async Task<string> GetApiVersion()
		{
			var result = await _httpClient.GetStringAsync("public/version");

			return result;
		}
	}
}
