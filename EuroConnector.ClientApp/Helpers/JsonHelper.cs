using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace EuroConnector.ClientApp.Helpers
{
    public class JsonHelper
    {
        private static JsonSerializerOptions options;

        public static JsonSerializerOptions GetJsonSerializerOptions()
        {
            options ??= new JsonSerializerOptions()
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                    DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
                };

            return options;
        }
    }
}
