using EuroConnector.ClientApp.Data.Services;
using Moq;
using Moq.Protected;
using System.Net;

namespace EuroConnector.ClientApp.Tests.Services
{
    public class VersionServiceTest
    {
        private readonly Mock<HttpMessageHandler> _handlerMock = new();

        [Fact]
        public async Task GetApiVersion_ShouldReturnVersionString()
        {
            // Arrange
            var apiResponse = new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent("1.0.0"),
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
            Assert.Equal("1.0.0", version);
        }
    }
}
