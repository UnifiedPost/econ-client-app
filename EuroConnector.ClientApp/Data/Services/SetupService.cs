using Blazored.LocalStorage;
using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using EuroConnector.ClientApp.Helpers;
using EuroConnector.ClientApp.Providers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Threading.Tasks;

namespace EuroConnector.ClientApp.Data.Services
{
    public class SetupService : ISetupService
	{
		private readonly AuthenticationProvider _authenticationProvider;
		private readonly HttpClient _httpClient;
		private readonly ILocalStorageService _localStorage;

		public SetupService(
			AuthenticationProvider authenticationProvider,
			HttpClient httpClient,
			ILocalStorageService localStorage)
		{
			_authenticationProvider = authenticationProvider;
			_httpClient = httpClient;
			_localStorage = localStorage;
		}

		public async Task ApplySettings(SetupProperties properties)
		{
			if (!properties.ApiUrl.StartsWith("http")) properties.ApiUrl = $"https://{properties.ApiUrl}";
			if (!properties.ApiUrl.EndsWith("/")) properties.ApiUrl = $"{properties.ApiUrl}/" ;
			if (!properties.ApiUrl.EndsWith("api/")) properties.ApiUrl = $"{properties.ApiUrl}api/";

			var requestBody = JsonContent.Create(new
			{
				properties.UserName,
				properties.SecretKey,
			});

			var response = await _httpClient.PostAsync($"{properties.ApiUrl}public/v1/authorization/token-create", requestBody);

			if (!response.IsSuccessStatusCode) throw new Exception(response.ReasonPhrase);

            var responseData = await response.Content.ReadFromJsonAsync<TokenResponse>();
            await SetTokens(responseData);
			await _localStorage.SetItemAsync("apiUrl", properties.ApiUrl);

            _authenticationProvider.SignIn(responseData.AccessToken);
		}

		public async Task ClearSettings()
		{
			await _localStorage.ClearAsync();
			_authenticationProvider.SignOut();
		}

		public async Task RefreshToken()
		{
			var refreshToken = await _localStorage.GetItemAsync<string>("refreshToken");
			var apiUrl = await _localStorage.GetItemAsStringAsync("apiUrl");

			using var requestMessage = new HttpRequestMessage(HttpMethod.Get, $"{apiUrl}public/v1/authorization/token-refresh");
			requestMessage.Headers.Authorization = new AuthenticationHeaderValue("bearer", refreshToken);

			var response = await _httpClient.SendAsync(requestMessage);

			if (!response.IsSuccessStatusCode) throw new Exception(response.ReasonPhrase);

			var responseData = await response.Content.ReadFromJsonAsync<TokenResponse>();
			await SetTokens(responseData);
		}

		private async Task SetTokens(TokenResponse tokenResponse)
		{
			await _localStorage.SetItemAsync("accessToken", tokenResponse.AccessToken);
			await _localStorage.SetItemAsync("refreshToken", tokenResponse.RefreshToken);
			_httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("bearer", tokenResponse.AccessToken);
		}
	}
}
