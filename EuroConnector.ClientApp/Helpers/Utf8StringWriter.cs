using System.Text;

namespace EuroConnector.ClientApp.Helpers
{
    public class Utf8StringWriter : StringWriter
    {
        public override Encoding Encoding => Encoding.UTF8;
    }
}
