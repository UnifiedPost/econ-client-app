using EuroConnector.ClientApp.Data.Entities;
using EuroConnector.ClientApp.Data.Interfaces;
using EuroConnector.ClientApp.Pages;
using EuroConnector.ClientApp.Shared;
using Moq;
using MudBlazor;
using System.Runtime.CompilerServices;

namespace EuroConnector.ClientApp.Tests.Pages
{
    public class AboutTest
    {
        private readonly Mock<IVersionService> _versionServiceMock = new();
        private readonly Mock<ISnackbar> _snackbarMock = new();

        [Fact]
        public void InitialRender_ReceivesApiVersionFromTheApi_ShouldRenderTheApiVersion()
        {
            // Arrange
            using var ctx = new TestContext();

            _versionServiceMock.Setup(x => x.GetApiVersion()).ReturnsAsync(new ApiVersion()
            {
                Version = "1.0.0",
                ReleaseDate = DateTime.UtcNow,
            });

            ctx.Services.AddSingleton(_versionServiceMock.Object);
            ctx.Services.AddSingleton(_snackbarMock.Object);

            // Act
            var errorComponent = ctx.RenderComponent<Error>();
            var component = ctx.RenderComponent<About>(parameters => parameters.AddCascadingValue(errorComponent.Instance));

            // Assert
            Assert.Equal("API Version: 1.0.0", component.Find("#api-version").TextContent);
            _snackbarMock.Verify(x => x.Add(It.IsAny<string>(), Severity.Error, null, ""), Times.Never);
        }

        [Fact]
        public void InitialRender_GetApiVersionReturnsAnError_ShouldShowANotification()
        {
            // Arrange
            using var ctx = new TestContext();

            var exceptionMessage = "Error message.";
            _versionServiceMock.Setup(x => x.GetApiVersion()).Throws(new Exception(exceptionMessage));

            ctx.Services.AddSingleton(_versionServiceMock.Object);
            ctx.Services.AddSingleton(_snackbarMock.Object);

            // Act
            var errorComponent = ctx.RenderComponent<Error>();
            var component = ctx.RenderComponent<About>(parameters => parameters.AddCascadingValue(errorComponent.Instance));

            // Assert
            _snackbarMock.Verify(x => x.Add(exceptionMessage, Severity.Error, null, ""), Times.Once);
        }
    }
}
