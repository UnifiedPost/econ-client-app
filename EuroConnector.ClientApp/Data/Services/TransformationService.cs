using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Data.Models;
using EuroConnector.ClientApp.Extensions;
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

        public TransformationService(IXsltTransformer xsltTransformer, ILogger logger)
        {
            _xsltTransformer = xsltTransformer;
            _logger = logger;
        }

        public void Transform()
        {
            var transformationsStr = Preferences.Get("transformations", string.Empty, Assembly.GetExecutingAssembly().Location);
            var failedPath = Preferences.Get("failedPath", "C:\\Data\\EuroConnector\\Failed", Assembly.GetExecutingAssembly().Location);

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

                    try
                    {
                        var xml = File.ReadAllText(file.FullName);
                        var result = _xsltTransformer.Transform(xslt, xml);

                        File.WriteAllText(Path.Combine(transformation.DestinationPath, file.Name), result);
                    }
                    catch (Exception ex)
                    {
                        _logger.Error(ex, "An error occured while transforming {Filename} with {Xslt}", file.Name, transformation.XsltName);
                        file.SafeMoveTo(Path.Combine(failedPath, file.Name));
                        File.WriteAllText(Path.Combine(failedPath, $"{file.Name}.txt"), ex.Message);
                    }
                }
            }
        }
    }
}
