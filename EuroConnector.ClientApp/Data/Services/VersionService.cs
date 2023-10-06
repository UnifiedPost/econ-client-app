using EuroConnector.ClientApp.Data.Models;
using EuroConnector.ClientApp.Data.Interfaces;
using System.Net.Http.Json;
using Blazored.LocalStorage;

namespace EuroConnector.ClientApp.Data.Services
{
    public class VersionService : IVersionService
	{
		private readonly HttpClient _httpClient;
		private readonly ILocalStorageService _localStorage;

		public VersionService(HttpClient httpClient, ILocalStorageService localStorage)
		{
			_httpClient = httpClient;
			_localStorage = localStorage;
		}

		public async Task<ApiVersion> GetApiVersion()
		{
			var apiUrl = await _localStorage.GetItemAsync<string>("apiUrl");
			if (string.IsNullOrEmpty(apiUrl)) return new ApiVersion
			{
				Version = "Error",
				ReleaseDate = null,
			};

			var result = await _httpClient.GetFromJsonAsync<ApiVersion>($"{apiUrl}public/v1/extensions/version");

			return result;
		}
	}
}
