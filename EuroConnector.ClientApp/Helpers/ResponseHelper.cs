using EuroConnector.ClientApp.Data.Models;
using Serilog;
using MudBlazor;
using System.Text.Json;

namespace EuroConnector.ClientApp.Helpers
{
    public static class ResponseHelper
    {
        public static async Task<string> ProcessFailedRequest(HttpResponseMessage response, ILogger logger, string message = null)
        {
            var json = await response.Content.ReadAsStringAsync();
            var error = JsonSerializer.Deserialize<Error>(json);

            var logMessage = $"{(string.IsNullOrEmpty(message) ? message + "\n" : "")}Trace ID: {error.TraceId}\n{error.Message}";

            logger.Error(logMessage.Replace("\n", " - "));

            return logMessage;
        }
    }
}
