using CommunityToolkit.Maui;
using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Services;
using EuroConnector.ClientApp.Providers;
using Microsoft.AspNetCore.Components.Authorization;
using MudBlazor;
using MudBlazor.Services;
using Serilog;
using System.Reflection;
using Toolbelt.Blazor.Extensions.DependencyInjection;
using XsltTransformer;

namespace EuroConnector.ClientApp;

public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var appPath = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

        Log.Logger = new LoggerConfiguration()
            .MinimumLevel.Verbose()
            .MinimumLevel.Override("Microsoft", Serilog.Events.LogEventLevel.Fatal)
            .MinimumLevel.Override("MudBlazor", Serilog.Events.LogEventLevel.Warning)
            .Enrich.FromLogContext()
            .WriteTo.File(Path.Combine(appPath, "logs", "log-.txt"), rollingInterval: RollingInterval.Day, shared: true)
            .CreateLogger();

        var builder = MauiApp.CreateBuilder();
        builder
            .UseMauiApp<App>()
            .UseMauiCommunityToolkit()
            .ConfigureFonts(fonts =>
            {
                fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
            })
            .Logging.AddSerilog(Log.Logger, dispose: true);

        builder.Services.AddMauiBlazorWebView();
#if DEBUG
        builder.Services.AddBlazorWebViewDeveloperTools();
#endif

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
            config.SnackbarConfiguration.ClearAfterNavigation = true;
            config.SnackbarConfiguration.MaxDisplayedSnackbars = 3;
        });

        builder.Services.AddScoped(sp =>
        {
            var httpClient = new HttpClient().EnableIntercept(sp);

            httpClient.DefaultRequestHeaders.Add("Client-App-Version", "1.3.0 beta");

            return httpClient;
        });

        builder.Services.AddScoped<AuthenticationProvider>();
        builder.Services.AddScoped<AuthenticationStateProvider>(provider => provider.GetService<AuthenticationProvider>());
        builder.Services.AddAuthorizationCore();

        builder.Services.AddScoped<ThemeProvider>();

        builder.Services.AddSingleton<TimerProvider>();
        builder.Services.AddSingleton<TransformationsTimerProvider>();
        builder.Services.AddSingleton<BackgroundProvider>();

        builder.Services.AddScoped<IVersionService, VersionService>();
        builder.Services.AddScoped<ISetupService, SetupService>();
        builder.Services.AddScoped<IDocumentService, DocumentService>();
        builder.Services.AddScoped<ITransformationService, TransformationService>();
        builder.Services.AddScoped<IRefreshTokenService, RefreshTokenService>();
        builder.Services.AddScoped<IXsltTransformer, XsltTransformer.XsltTransformer>();
        builder.Services.AddScoped<HttpInterceptorService>();

        builder.Services.AddSingleton(Log.Logger);

        builder.Services.AddHttpClientInterceptor();

        Log.Information("EuroConnector Client Starting");

        return builder.Build();
    }
}
