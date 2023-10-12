using Blazored.LocalStorage;
using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Providers;
using System.Security.Claims;

namespace EuroConnector.ClientApp.Data.Services
{
    public class RefreshTokenService : IRefreshTokenService
	{
		private readonly ILocalStorageService _localStorage;
		private readonly ISetupService _setupService;

		public RefreshTokenService(ILocalStorageService localStorage, ISetupService setupService)
		{
			_localStorage = localStorage;
			_setupService = setupService;
		}

		public async Task TryRefreshToken()
		{
			try
			{
				var expTime = await _localStorage.GetItemAsync<DateTime>("accessExpiration");

				var diff = expTime - DateTime.UtcNow;
				if (diff.TotalMinutes <= 2) await _setupService.RefreshToken();
			}
			catch (Exception)
			{
				return;
			}
		}
	}
}
