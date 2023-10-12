using Blazored.LocalStorage;
using Microsoft.AspNetCore.Components.Authorization;
using System.Net.Http.Headers;
using System.Security.Claims;

namespace EuroConnector.ClientApp.Providers
{
	public class AuthenticationProvider : AuthenticationStateProvider
	{
		private readonly HttpClient _httpClient;
		private readonly ILocalStorageService _localStorage;

		public AuthenticationProvider(HttpClient httpClient, ILocalStorageService localStorage)
		{
			_httpClient = httpClient;
			_localStorage = localStorage;
		}

		public override async Task<AuthenticationState> GetAuthenticationStateAsync()
		{
			return await Task.FromResult(new AuthenticationState(await CurrentUser()));
		}

		private ClaimsPrincipal AnonymousUser => new(new ClaimsIdentity(Array.Empty<Claim>()));

		private ClaimsPrincipal UserPrincipal
		{
			get
			{
				var claims = new[]
				{
					new Claim(ClaimTypes.Name, "User"),
					new Claim(ClaimTypes.Role, "User"),
				};
				var identity = new ClaimsIdentity(claims, "Token");
				return new ClaimsPrincipal(identity);
			}
		}

		public void SignIn(string accessToken)
		{
			var result = Task.FromResult(new AuthenticationState(UserPrincipal));
			NotifyAuthenticationStateChanged(result);
			_httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("bearer", accessToken);
		}

		public void SignOut()
		{
			var result = Task.FromResult(new AuthenticationState(AnonymousUser));
			NotifyAuthenticationStateChanged(result);
			_httpClient.DefaultRequestHeaders.Authorization = null;
		}

		private async Task<ClaimsPrincipal> CurrentUser()
		{
			var accessToken = await _localStorage.GetItemAsync<string>("accessToken");
			if (string.IsNullOrEmpty(accessToken)) return AnonymousUser;

			return UserPrincipal;
		}
	}
}
