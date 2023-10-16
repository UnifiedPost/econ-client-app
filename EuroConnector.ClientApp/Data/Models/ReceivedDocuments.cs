using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EuroConnector.ClientApp.Data.Models
{
    public class ReceivedDocuments
    {
        public List<ReceivedDocument> Documents { get; set; }
    }

    public class ReceivedDocument
    {
        public Guid DocumentId { get; set; }
        public string DocumentStandard { get; set; }
        public string DocumentType { get; set; }
        public string Status { get; set; }
        public string FolderName { get; set; }
    }
}
