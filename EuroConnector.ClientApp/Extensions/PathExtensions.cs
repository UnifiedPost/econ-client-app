using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EuroConnector.ClientApp.Extensions
{
    public static class PathExtensions
    {
        public static bool IsValidPath(this string path)
        {
            if (string.IsNullOrWhiteSpace(path)) return false;

            try
            {
                var result = Path.GetFullPath(path);
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
