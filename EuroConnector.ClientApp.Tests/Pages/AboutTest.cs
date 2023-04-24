using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Pages;
using Moq;

namespace EuroConnector.ClientApp.Tests.Pages
{
    public class AboutTest
    {
        private readonly Mock<IVersionService> _versionServiceMock = new();

        [Fact]
        public void RendersSuccessfully()
        {
            // Arrange
            using var ctx = new TestContext();
            _versionServiceMock.Setup(x => x.GetApiVersion()).ReturnsAsync("1.0.0");
            ctx.Services.AddSingleton(_versionServiceMock.Object);

            // Act
            var component = ctx.RenderComponent<About>();

            // Assert
            Assert.Equal("API Version: 1.0.0", component.Find("#api-version").TextContent);
        }
    }
}
