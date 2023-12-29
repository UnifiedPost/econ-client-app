using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using Serilog;
using System.Reflection;
using System.Text.Json;
using XsltTransformer;

namespace EuroConnector.ClientApp.Data.Services
{
    public class TransformationService : ITransformationService
    {
        private readonly IXsltTransformer _xsltTransformer;
        private readonly ILogger _logger;

        public TransformationService(IXsltTransformer xsltTransformer)
        {
            _xsltTransformer = xsltTransformer;
        }

        public void Transform()
        {
            var transformationsStr = Preferences.Get("transformations", string.Empty, Assembly.GetExecutingAssembly().Location);

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
                    _logger.Information("Transforming file {Filename}", file.Name);

                    try
                    {
                        var xml = File.ReadAllText(file.FullName);
                        var result = _xsltTransformer.Transform(xslt, xml);

                        File.WriteAllText(Path.Combine(transformation.DestinationPath, file.Name), result);
                    }
                    catch (Exception ex)
                    {
                        _logger.Error(ex, "An error occured while transforming {Filename} with {Xslt}", file.Name, transformation.XsltName);
                    }
                }
            }
        }
    }
}
