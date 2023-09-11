using EuroConnector.ClientApp.Data.Interfaces;
using Toolbelt.Blazor;

namespace EuroConnector.ClientApp.Data.Services
{
	public class HttpInterceptorService
	{
		private readonly HttpClientInterceptor _interceptor;
		private readonly IRefreshTokenService _refreshTokenService;

		public HttpInterceptorService(HttpClientInterceptor interceptor, IRefreshTokenService refreshTokenService)
		{
			_interceptor = interceptor;
			_refreshTokenService = refreshTokenService;
		}

		public void RegisterEvent() => _interceptor.BeforeSendAsync += InterceptBeforeHttpAsync;

		public async Task InterceptBeforeHttpAsync(object sender, HttpClientInterceptorEventArgs e)
		{
			var absPath = e.Request.RequestUri.AbsolutePath;

			if (!absPath.Contains("token"))
			{
				await _refreshTokenService.TryRefreshToken();
			}
		}
	}
}
