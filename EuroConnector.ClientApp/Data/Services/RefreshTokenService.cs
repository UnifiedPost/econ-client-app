using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Providers;

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

			var exp = authState.User.FindFirst(x => x.Type.Equals("exp")).Value;
			var expTime = DateTimeOffset.FromUnixTimeMilliseconds(Convert.ToInt64(exp));

			var diff = expTime - DateTime.UtcNow;
			if (diff.TotalMinutes <= 10) await _setupService.RefreshToken();
		}
	}
}
