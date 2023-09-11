using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EuroConnector.ClientApp.Data.Models
{
	public class TokenResponse
	{
		public string AccessToken { get; set; } = default!;
		public DateTime AccessTokenExpiresUtc { get; set; } = default!;
		public string RefreshToken { get; set; } = default!;
		public DateTime RefreshTokenExpiresUtc { get; set; } = default!;
	}
}
