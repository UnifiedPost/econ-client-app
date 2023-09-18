using Blazored.LocalStorage;
using EuroConnector.ClientApp.Data.Interfaces;
using Microsoft.AspNetCore.Components.Authorization;
using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
using System.Security.Claims;

namespace EuroConnector.ClientApp.Providers
{
    public class AuthenticationProvider : AuthenticationStateProvider
    {
        private readonly HttpClient _httpClient;
        private readonly ILocalStorageService _localStorage;
        private readonly IRefreshTokenService _refreshTokenService;

        public AuthenticationProvider(HttpClient httpClient, ILocalStorageService localStorage)
        {
            _httpClient = httpClient;
            _localStorage = localStorage;
        }

        public override async Task<AuthenticationState> GetAuthenticationStateAsync()
        {
            return await Task.FromResult(new AuthenticationState(await CurrentUser()));
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
            var result = Task.FromResult(new AuthenticationState(ReadFromJwt(accessToken)));
            NotifyAuthenticationStateChanged(result);
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("bearer", accessToken);
        }

        public void SignOut()
        {
            var result = Task.FromResult(new AuthenticationState(AnonymousUser));
            NotifyAuthenticationStateChanged(result);
            _httpClient.DefaultRequestHeaders.Authorization = null;
        }

        private async Task<ClaimsPrincipal> CurrentUser()
        {
            var accessToken = await _localStorage.GetItemAsync<string>("accessToken");
            if (string.IsNullOrEmpty(accessToken)) return AnonymousUser;

            return ReadFromJwt(accessToken);
        }

        private ClaimsPrincipal ReadFromJwt(string accessToken)
        {
            var jwt = new JwtSecurityTokenHandler().ReadJwtToken(accessToken);
            var identity = new ClaimsIdentity(jwt.Claims, "Token");

            // Role claim type workaround
            var roleClaim = identity.FindFirst("role");
            identity.RemoveClaim(roleClaim);
            var jwtRolesValue = jwt.Claims.Where(x => x.Type == "role").Select(x => x.Value).Single();
            identity.AddClaim(new Claim(ClaimTypes.Role, jwtRolesValue));

            var principal = new ClaimsPrincipal(identity);

            return principal;
        }
    }
}
