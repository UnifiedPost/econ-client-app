using EuroConnector.ClientApp.Data.Models;
using System.Text;
using System.Xml.Serialization;

namespace EuroConnector.ClientApp.Helpers
{
    public class InvoiceResponseHelper
    {
        public static string CreateInvoiceResponse(DocumentMetadata document, string responseCode, string description)
        {
            var invoiceResponse = new ApplicationResponse
            {
                CustomizationId = "urn:fdc:peppol.eu:poacc:trns:invoice_response:3",
                ProfileId = "urn:fdc:peppol.eu:poacc:bis:invoice_response:3",
                Id = $"{document.DocumentNo}{responseCode}{DateTime.Now:yyyyMMddHHmmss}",
                IssueDate = DateTime.Now.ToString("yyyy-MM-dd"),
                SenderParty = new()
                {
                    EndpointId = new()
                    {
                        SchemeId = "0196",
                        Value = document.RecipientEndpointId,
                    },
                    PartyLegalEntity = new()
                    {
                        RegistrationName = document.RecipientName,
                    }
                },
                ReceiverParty = new()
                {
                    EndpointId = new()
                    {
                        SchemeId = "0196",
                        Value = document.SenderEndpointId,
                    },
                    PartyLegalEntity = new()
                    {
                        RegistrationName = document.SenderName,
                    }
                },
                DocumentResponse = new()
                {
                    Response = new()
                    {
                        ResponseCode = responseCode,
                        Status = string.IsNullOrEmpty(description) ? null : new()
                        {
                            StatusReasonCode = new()
                            {
                                ListId = "OPStatusReason",
                                Value = "REF",
                            },
                            StatusReason = description,
                        }
                    },
                    DocumentReference = new()
                    {
                        Id = document.DocumentNo,
                        DocumentTypeCode = document.DocumentType == "Invoice" ? "380" : "381",
                    }
                }
            };

            var ns = new XmlSerializerNamespaces();
            ns.Add("cac", "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2");
            ns.Add("cbc", "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2");
            var serializer = new XmlSerializer(typeof(ApplicationResponse), "urn:oasis:names:specification:ubl:schema:xsd:ApplicationResponse-2");

            using var textWriter = new Utf8StringWriter();
            serializer.Serialize(textWriter, invoiceResponse, ns);

            return textWriter.ToString();
        }

        public static IEnumerable<ResponseCode> GetResponseCodes()
        {
            return new List<ResponseCode>()
            {
                new ResponseCode() { Code = "AB", Label = "(AB) Acknowledged" },
                new ResponseCode() { Code = "IP", Label = "(IP) In Progress" },
                new ResponseCode() { Code = "UQ", Label = "(UQ) Under Query" },
                new ResponseCode() { Code = "CA", Label = "(CA) Conditionally Accepted" },
                new ResponseCode() { Code = "AP", Label = "(AP) Accepted" },
                new ResponseCode() { Code = "RE", Label = "(RE) Rejected" },
                new ResponseCode() { Code = "PD", Label = "(PD) Paid" },
            };
        }
    }

    public struct ResponseCode
    {
        public string Code;
        public string Label;
    }
}
