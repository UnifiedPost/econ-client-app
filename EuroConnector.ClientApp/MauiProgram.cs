using Blazored.LocalStorage;
using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Services;
using EuroConnector.ClientApp.Providers;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.Extensions.Configuration;
using MudBlazor;
using MudBlazor.Services;
using System.Reflection;
using Toolbelt.Blazor.Extensions.DependencyInjection;

namespace EuroConnector.ClientApp;

public static class MauiProgram
{
	public static MauiApp CreateMauiApp()
	{
		var builder = MauiApp.CreateBuilder();
		builder
			.UseMauiApp<App>()
			.ConfigureFonts(fonts =>
			{
				fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
			});

		var config = new ConfigurationBuilder().AddJsonFile("appsettings.json").Build();
		builder.Configuration.AddConfiguration(config);

		builder.Services.AddMauiBlazorWebView();
#if DEBUG
		builder.Services.AddBlazorWebViewDeveloperTools();
#endif

		builder.Services.AddBlazoredLocalStorage();

		builder.Services.AddMudServices(config =>
		{
			config.SnackbarConfiguration.PositionClass = Defaults.Classes.Position.BottomLeft;

			config.SnackbarConfiguration.PreventDuplicates = false;
			config.SnackbarConfiguration.NewestOnTop = false;
			config.SnackbarConfiguration.ShowCloseIcon = true;
			config.SnackbarConfiguration.VisibleStateDuration = 7500;
			config.SnackbarConfiguration.ShowTransitionDuration = 150;
			config.SnackbarConfiguration.HideTransitionDuration = 150;
			config.SnackbarConfiguration.SnackbarVariant = Variant.Filled;
		});

		builder.Services.AddScoped(sp => new HttpClient().EnableIntercept(sp));

		builder.Services.AddScoped<AuthenticationProvider>();
		builder.Services.AddScoped<AuthenticationStateProvider>(provider => provider.GetService<AuthenticationProvider>());
		builder.Services.AddAuthorizationCore();

		builder.Services.AddScoped<ThemeProvider>();

		builder.Services.AddScoped<IVersionService, VersionService>();
		builder.Services.AddScoped<ISetupService, SetupService>();
		builder.Services.AddScoped<IRefreshTokenService, RefreshTokenService>();
		builder.Services.AddScoped<HttpInterceptorService>();

		builder.Services.AddHttpClientInterceptor();

		return builder.Build();
	}
}
