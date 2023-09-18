using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace EuroConnector.ClientApp.Helpers
{
	public class TokenHelper
	{
		public static bool IsExpired(string token)
		{
			var jwt = new JwtSecurityTokenHandler().ReadJwtToken(token);
			var identity = new ClaimsIdentity(jwt.Claims, "Token");

			var exp = identity.FindFirst("exp").Value;
			var expTime = DateTimeOffset.FromUnixTimeSeconds(Convert.ToInt64(exp));

			return DateTime.UtcNow > expTime;
		}
	}
}
