using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EuroConnector.ClientApp.Data.Models
{
    public class Transformation : ICloneable
    {
        public int Id { get; set; } = 0;
        public string XsltName { get; set; }
        public string SourcePath { get; set; }
        public string DestinationPath { get; set; }

        public object Clone()
        {
            return MemberwiseClone();
        }
    }
}
