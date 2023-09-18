using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Providers;
using System.Security.Claims;

namespace EuroConnector.ClientApp.Data.Services
{
    public class RefreshTokenService : IRefreshTokenService
	{
		private readonly AuthenticationProvider _authenticationProvider;
		private readonly ISetupService _setupService;

		public RefreshTokenService(AuthenticationProvider authenticationProvider, ISetupService setupService)
		{
			_authenticationProvider = authenticationProvider;
			_setupService = setupService;
		}

		public async Task TryRefreshToken()
		{
			var authState = await _authenticationProvider.GetAuthenticationStateAsync();

			try
			{
				var exp = authState.User.FindFirst("exp").Value;
				var expTime = DateTimeOffset.FromUnixTimeSeconds(Convert.ToInt64(exp));

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
