using System.Xml.Linq;

namespace EuroConnector.ClientApp.Helpers
{
    public static class ContentHelper
    {
        public static bool IsXmlContent(this string content)
        {
            try
            {
                XDocument.Parse(content);

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
