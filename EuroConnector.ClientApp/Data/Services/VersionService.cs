using EuroConnector.ClientApp.Data.Entities;
using EuroConnector.ClientApp.Data.Interfaces;
using System.Net.Http.Json;

namespace EuroConnector.ClientApp.Data.Services
{
    public class VersionService : IVersionService
	{
		private readonly HttpClient _httpClient;

		public VersionService(HttpClient httpClient)
		{
			_httpClient = httpClient;
		}

		public async Task<ApiVersion> GetApiVersion()
		{
			var result = await _httpClient.GetFromJsonAsync<ApiVersion>("public/v1/extensions/version");

			return result;
		}
	}
}
