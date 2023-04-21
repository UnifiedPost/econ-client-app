using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Services;
using Microsoft.Extensions.Configuration;
using MudBlazor.Services;
using System.Reflection;

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

		builder.Services.AddMudServices();

		builder.Services.AddSingleton(sp => new HttpClient { BaseAddress = new Uri(config["ApiEndpoint"]) });

		builder.Services.AddScoped<IVersionService, VersionService>();

		return builder.Build();
	}
}
