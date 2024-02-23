using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using EuroConnector.ClientApp.Extensions;
using EuroConnector.ClientApp.Helpers;
using Serilog;
using System.Reflection;
using System.Text.Json;
using System.Text.RegularExpressions;
using XsltTransformer;

namespace EuroConnector.ClientApp.Data.Services
{
    public class TransformationService : ITransformationService
    {
        private readonly IXsltTransformer _xsltTransformer;
        private readonly ILogger _logger;

        public TransformationService(IXsltTransformer xsltTransformer, ILogger logger)
        {
            _xsltTransformer = xsltTransformer;
            _logger = logger;
        }

        public void Transform()
        {
            var transformationsStr = Preferences.Get("transformations", string.Empty, Assembly.GetExecutingAssembly().Location);
            var failedPath = Preferences.Get("failedPath", string.Empty, Assembly.GetExecutingAssembly().Location);

            if (string.IsNullOrEmpty(transformationsStr)) return;

            var transformations = JsonSerializer.Deserialize<List<Transformation>>(transformationsStr);

            foreach (var transformation in transformations)
            {
                _logger.Information("Transforming with {Xslt}", transformation.XsltName);
                var xslt = File.ReadAllText($"Transformations/{transformation.XsltName}");

                var sourceDir = new DirectoryInfo(transformation.SourcePath);
                var files = sourceDir.EnumerateFiles();

                foreach (var file in files)
                {
                    _logger.Information("Transforming file {Filename}", file.FullName);

                    var filename = file.FullName;
                    if (Regex.IsMatch(file.Name, @"\s+"))
                    {
                        filename = Regex.Replace(file.FullName, @"\s+", "_");
                        filename = file.SafeMoveTo(filename);
                    }

                    try
                    {
                        var xml = File.ReadAllText(filename);

                        if (!xml.IsXmlContent()) xml = $"<root>{xml}</root>";

                        var parameters = new Dictionary<string, string>();
                        if (transformation.XsltName == "CSV-to-BIS3.XSL" || filename.EndsWith("csv"))
                        {
                            parameters.Add("csv-uri", $"file:///{filename.Replace(@"\", "/")}");
                        }

                        var result = _xsltTransformer.Transform(xslt, xml, parameters);

                        File.WriteAllText(Path.Combine(transformation.DestinationPath, $"{Path.GetFileNameWithoutExtension(filename)}.xml"), result);
                        file.Delete();
                    }
                    catch (Exception ex)
                    {
                        _logger.Error(ex, "An error occured while transforming {Filename} with {Xslt}", filename, transformation.XsltName);
                        file.SafeMoveTo(Path.Combine(failedPath, filename));
                    }
                }
            }
        }
    }
}
