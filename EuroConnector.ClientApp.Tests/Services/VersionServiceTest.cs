using EuroConnector.ClientApp.Data.Entities;
using EuroConnector.ClientApp.Data.Services;
using FluentAssertions;
using Moq;
using Moq.Protected;
using System.Net;
using System.Net.Http.Json;

namespace EuroConnector.ClientApp.Tests.Services
{
    public class VersionServiceTest
    {
        private readonly Mock<HttpMessageHandler> _handlerMock = new();

        [Fact]
        public async Task GetApiVersion_WhenApiIsCalled_ShouldReturnApiVersionInformation()
        {
            // Arrange
            var apiVersion = new ApiVersion
            {
                Version = "1.0.0",
                ReleaseDate = DateTime.UtcNow,
            };

            var apiResponse = new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = JsonContent.Create(apiVersion),
            };

            _handlerMock.Protected()
                .Setup<Task<HttpResponseMessage>>(
                    "SendAsync",
                    ItExpr.IsAny<HttpRequestMessage>(),
                    ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(apiResponse);

            var httpClient = new HttpClient(_handlerMock.Object)
            {
                BaseAddress = new Uri("http://localhost:4444/api/"),
            };

            var versionService = new VersionService(httpClient);

            // Act
            var version = await versionService.GetApiVersion();

            // Assert
            version.Should().BeEquivalentTo(apiVersion);
        }
    }
}
