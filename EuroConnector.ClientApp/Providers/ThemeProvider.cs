using MudBlazor;

namespace EuroConnector.ClientApp.Providers
{
	public class ThemeProvider
	{
		public MudTheme Theme { get; set; }

		public ThemeProvider()
		{
			Theme = new()
			{
				Palette = new PaletteLight()
				{
					Primary = new MudBlazor.Utilities.MudColor("#322b78"),
					Secondary = new MudBlazor.Utilities.MudColor("#50e2d0"),
					PrimaryContrastText = new MudBlazor.Utilities.MudColor("#ffffff"),
					SecondaryContrastText = new MudBlazor.Utilities.MudColor("#ffffff"),
					TextPrimary = new MudBlazor.Utilities.MudColor("#000000"),
				},
			};
		}
	}
}
