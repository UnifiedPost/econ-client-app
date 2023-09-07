using Microsoft.AspNetCore.Components.Authorization;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace EuroConnector.ClientApp.Providers
{
    public class AuthenticationProvider : AuthenticationStateProvider
    {
        public override async Task<AuthenticationState> GetAuthenticationStateAsync()
        {
            return await Task.FromResult(new AuthenticationState(AnonymousUser));
        }

        private ClaimsPrincipal AnonymousUser => new(new ClaimsIdentity(Array.Empty<Claim>()));

        private ClaimsPrincipal FakedUser
        {
            get
            {
                var claims = new[]
                {
                    new Claim(ClaimTypes.Name, "FakedUser"),
                    new Claim(ClaimTypes.Role, "User"),
                };
                var identity = new ClaimsIdentity(claims, "faked");
                return new ClaimsPrincipal(identity);
            }
        }

        private ClaimsPrincipal FakedAdmin
        {
            get
            {
                var claims = new[]
                {
                    new Claim(ClaimTypes.Name, "FakedAdmin"),
                    new Claim(ClaimTypes.Role, "Admin"),
                };
                var identity = new ClaimsIdentity(claims, "faked");
                return new ClaimsPrincipal(identity);
            }
        }

        public void FakedSignIn()
        {
            var result = Task.FromResult(new AuthenticationState(FakedUser));
            NotifyAuthenticationStateChanged(result);
        }

        public void FakedAdminSignIn()
        {
            var result = Task.FromResult(new AuthenticationState(FakedAdmin));
            NotifyAuthenticationStateChanged(result);
        }

        public void SignIn(string accessToken)
        {
            var jwt = new JwtSecurityTokenHandler().ReadJwtToken(accessToken);
            var identity = new ClaimsIdentity(jwt.Claims, "user");
            var principal = new ClaimsPrincipal(identity);
            NotifyAuthenticationStateChanged(Task.FromResult(new AuthenticationState(principal)));
        }

        public void SignOut()
        {
            var result = Task.FromResult(new AuthenticationState(AnonymousUser));
            NotifyAuthenticationStateChanged(result);
        }
    }
}
