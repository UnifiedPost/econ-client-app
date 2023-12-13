using EuroConnector.ClientApp.Data.Models;
using Serilog;
using System.Text.Json;

namespace EuroConnector.ClientApp.Helpers
{
    public static class ResponseHelper
    {
        public static async Task<string> ProcessFailedRequest(HttpResponseMessage response, ILogger logger, string message = null)
        {
            string logMessage;
            try
            {
                var json = await response.Content.ReadAsStringAsync();
                var error = JsonSerializer.Deserialize<Error>(json);

                logMessage = $"{(string.IsNullOrEmpty(message) ? message + "\n" : "")}Trace ID: {error.TraceId}\n{error.StatusCode} - {error.Message}";

                logger.Error(logMessage.Replace("\n", " - ") + "\nResponseData:\n{ResponseJson}", json);
            }
            catch (Exception)
            {
                logMessage = $"{(int)response.StatusCode} - {response.ReasonPhrase}";
                logger.Error(logMessage);
            }

            return logMessage;
        }
    }
}
