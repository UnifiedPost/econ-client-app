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
			var request = new HttpRequestMessage(HttpMethod.Get, "public/version");

			var response = await _httpClient.SendAsync(request);

			return await response.Content.ReadAsStringAsync();
		}
	}
}
