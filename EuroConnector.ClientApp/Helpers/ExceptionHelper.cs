using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EuroConnector.ClientApp.Helpers
{
    public class ExceptionHelper
    {
        public static Exception GetInnerException(Exception ex)
        {
            while (ex.InnerException is not null)
            {
                ex = ex.InnerException;
            }

            return ex;
        }
    }
}
