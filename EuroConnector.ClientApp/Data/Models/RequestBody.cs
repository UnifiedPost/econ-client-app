using System.Text.Json;

namespace EuroConnector.ClientApp.Data.Models
{
    public class RequestBody
    {
        public string ToJsonString()
        {
            var serializerOptions = new JsonSerializerOptions()
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            };

            var json = JsonSerializer.Serialize(this, GetType(), serializerOptions);

            return json;
        }
    }
}
