using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace EuroConnector.ClientApp.Data.Models
{
    [XmlRoot(ElementName = "ApplicationResponse")]
    public class ApplicationResponse
    {
        [XmlElement(ElementName = "CustomizationID", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2")]
        public string CustomizationId { get; set; }
        [XmlElement(ElementName = "ProfileID", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2")]
        public string ProfileId { get; set; }
        [XmlElement(ElementName = "ID", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2")]
        public string Id { get; set; }
        [XmlElement(ElementName = "IssueDate", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2")]
        public string IssueDate { get; set; }
        [XmlElement(ElementName = "SenderParty", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2")]
        public Party SenderParty { get; set; }
        [XmlElement(ElementName = "ReceiverParty", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2")]
        public Party ReceiverParty { get; set; }
        [XmlElement(ElementName = "DocumentResponse", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2")]
        public DocumentResponse DocumentResponse { get; set; }
    }

    public class Party
    {
        [XmlElement(ElementName = "EndpointID", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2")]
        public EndpointId EndpointId { get; set; }
        [XmlElement(ElementName = "PartyLegalEntity", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2")]
        public PartyLegalEntity PartyLegalEntity { get; set; }
    }

    public class EndpointId
    {
        [XmlAttribute(AttributeName = "schemeID")]
        public string SchemeId { get; set; }
        [XmlText]
        public string Value { get; set; }
    }

    public class PartyLegalEntity
    {
        [XmlElement(ElementName = "RegistrationName", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2")]
        public string RegistrationName { get; set; }
    }

    public class DocumentResponse
    {
        [XmlElement(ElementName = "Response", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2")]
        public Response Response { get; set; }
        [XmlElement(ElementName = "DocumentReference", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2")]
        public DocumentReference DocumentReference { get; set; }
    }

    public class Response
    {
        [XmlElement(ElementName = "ResponseCode", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2")]
        public string ResponseCode { get; set; }
        [XmlElement(ElementName = "Status", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2")]
        public Status Status { get; set; }
    }

    public class Status
    {
        [XmlElement(ElementName = "StatusReasonCode", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2")]
        public StatusReasonCode StatusReasonCode { get; set; }
        [XmlElement(ElementName = "StatusReason", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2")]
        public string StatusReason { get; set; }
    }

    public class StatusReasonCode
    {
        [XmlAttribute(AttributeName = "listID")]
        public string ListId { get; set; }
        [XmlText]
        public string Value { get; set; }
    }

    public class DocumentReference
    {
        [XmlElement(ElementName = "ID", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2")]
        public string Id { get; set; }
        [XmlElement(ElementName = "DocumentTypeCode", Namespace = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2")]
        public string DocumentTypeCode { get; set; }
    }
}
