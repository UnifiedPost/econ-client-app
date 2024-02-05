using System.Text.Json;
using System.Text.Json.Serialization;

namespace EuroConnector.ClientApp.Data.Models
{
    public class RequestBody
    {
        public string ToJsonString()
        {
            var serializerOptions = new JsonSerializerOptions()
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
            };

            var json = JsonSerializer.Serialize(this, GetType(), serializerOptions);

            return json;
        }
    }
}
