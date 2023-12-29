<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:ubl="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:fitek="java:oc.tools.Validators" exclude-result-prefixes="fitek">
	<xsl:output version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="uniqId"/>
	<xsl:template match="/">
		<xsl:apply-templates select="E_Invoice"/>
	</xsl:template>
	<xsl:template match="E_Invoice">
		<xsl:for-each select="Invoice">
			<xsl:choose>
				<xsl:when test="InvoiceInformation/Type/@type='CRE'">
					<CreditNote xmlns="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2">
						<!--xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
				xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
				xmlns="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2">-->
						<xsl:call-template name="XMLBody"/>
					</CreditNote>
				</xsl:when>
				<xsl:otherwise>
					<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">
						<!--<cbc:UBLVersionID>2.1</cbc:UBLVersionID>-->
						<!-- xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
				xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
				xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">-->
						<xsl:call-template name="XMLBody"/>
					</Invoice>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="XMLBody">
		<xsl:variable name="LineNote">
			<xsl:choose>
				<xsl:when test="InvoiceInformation/Type/@type='CRE'">
					<xsl:text>cac:CreditNoteLine</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>cac:InvoiceLine</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<cbc:CustomizationID>
			<xsl:text>urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0</xsl:text>
		</cbc:CustomizationID>
		<cbc:ProfileID>urn:fdc:peppol.eu:2017:poacc:billing:01:1.0</cbc:ProfileID>
		<cbc:ID>
			<xsl:value-of select="InvoiceInformation/InvoiceNumber"/>
		</cbc:ID>
		<!--<cbc:UUID>
			<xsl:choose>
				<xsl:when test="normalize-space($uniqId)">
					<xsl:value-of select="$uniqId"/>
				</xsl:when>
				<xsl:when test="normalize-space(@invoiceGlobUniqId)">
					<xsl:value-of select="@invoiceGlobUniqId"/>
				</xsl:when>
				<xsl:when test="normalize-space(@invoiceId)">
					<xsl:value-of select="@invoiceId"/>
				</xsl:when>
			</xsl:choose>
		</cbc:UUID>-->
		<cbc:IssueDate>
			<xsl:value-of select="InvoiceInformation/InvoiceDate"/>
		</cbc:IssueDate>
		<xsl:if test="InvoiceInformation/Type/@type='DEB'">
			<cbc:DueDate>
				<xsl:choose>
					<xsl:when test="InvoiceInformation/DueDate">
						<xsl:value-of select="InvoiceInformation/DueDate"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="InvoiceInformation/InvoiceDate"/>
					</xsl:otherwise>
				</xsl:choose>
			</cbc:DueDate>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="InvoiceInformation/Type/@type='CRE'">
				<cbc:CreditNoteTypeCode>
					<xsl:text>381</xsl:text>
				</cbc:CreditNoteTypeCode>
			</xsl:when>
			<xsl:otherwise>
				<cbc:InvoiceTypeCode>
					<xsl:text>380</xsl:text>
				</cbc:InvoiceTypeCode>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="normalize-space(InvoiceInformation/Extension[@extensionId='InvNote']/InformationContent)">
			<cbc:Note>
				<xsl:value-of select="InvoiceInformation/Extension[@extensionId='InvNote']/InformationContent"/>
			</cbc:Note>
		</xsl:if>
		<cbc:DocumentCurrencyCode>
			<xsl:value-of select="PaymentInfo/Currency"/>
		</cbc:DocumentCurrencyCode>
		<xsl:if test="normalize-space(InvoiceInformation/InvoiceContentCode)">
			<cbc:AccountingCost>
				<xsl:value-of select="InvoiceInformation/InvoiceContentCode"/>
			</cbc:AccountingCost>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="normalize-space(InvoiceParties/BuyerParty/UniqueCode)">
				<cbc:BuyerReference>
					<xsl:value-of select="InvoiceParties/BuyerParty/UniqueCode"/>
				</cbc:BuyerReference>
			</xsl:when>
			<xsl:when test="normalize-space(InvoiceParties/BuyerParty/RegNumber)">
				<cbc:BuyerReference>
					<xsl:value-of select="InvoiceParties/BuyerParty/RegNumber"/>
				</cbc:BuyerReference>
			</xsl:when>
			<xsl:when test="normalize-space(emk_BLOKK/emk_OwnerIK)">
				<cbc:BuyerReference>
					<xsl:value-of select="emk_BLOKK/emk_OwnerIK"/>
				</cbc:BuyerReference>
			</xsl:when>
			<xsl:when test="normalize-space(replace(InvoiceParties/BuyerParty/VATRegNumber,'-',''))">
				<cbc:BuyerReference>
					<xsl:value-of select="InvoiceParties/BuyerParty/VATRegNumber"/>
				</cbc:BuyerReference>
			</xsl:when>
			<xsl:when test="not(InvoiceInformation/Extension[@extensionId='Lading']/InformationContent) and not(InvoiceInformation/Extension[@extensionId='PurchaseOrder']/InformationContent)">
				<cac:OrderReference>
					<cbc:ID>NO REFERENCE</cbc:ID>
				</cac:OrderReference>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="normalize-space(InvoiceInformation/InvoiceContentText)">
				<cac:OrderReference>
					<cbc:ID>
						<xsl:value-of select="InvoiceInformation/InvoiceContentText"/>
					</cbc:ID>
				</cac:OrderReference>
			</xsl:when>
			<xsl:when test="normalize-space(InvoiceInformation/Extension[@extensionId='Lading']/InformationContent)">
				<cac:OrderReference>
					<cbc:ID>
						<xsl:value-of select="InvoiceInformation/Extension[@extensionId='Shipment']/InformationContent"/>
					</cbc:ID>
					<cbc:SalesOrderID>
						<xsl:value-of select="InvoiceInformation/Extension[@extensionId='Lading']/InformationContent"/>
					</cbc:SalesOrderID>
				</cac:OrderReference>
			</xsl:when>
			<xsl:when test="normalize-space(InvoiceInformation/Extension[@extensionId='PurchaseOrder']/InformationContent)">
				<cac:OrderReference>
					<cbc:ID>
						<xsl:value-of select="InvoiceInformation/Extension[@extensionId='PurchaseOrder']/InformationContent"/>
					</cbc:ID>
					<cbc:SalesOrderID>
						<xsl:value-of select="InvoiceInformation/Extension[@extensionId='PurchaseOrder']/InformationContent"/>
					</cbc:SalesOrderID>
				</cac:OrderReference>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="InvoiceInformation/Type/@type='CRE' and normalize-space(InvoiceInformation/Type/SourceInvoice)">
			<cac:BillingReference>
				<cac:InvoiceDocumentReference>
					<cbc:ID>
						<xsl:value-of select="InvoiceInformation/Type/SourceInvoice"/>
					</cbc:ID>
				</cac:InvoiceDocumentReference>
			</cac:BillingReference>
		</xsl:if>
		
		<xsl:if test="normalize-space(InvoiceInformation/ContractNumber)">
			<cac:ContractDocumentReference>
				<cbc:ID>
					<xsl:value-of select="InvoiceInformation/ContractNumber"/>
				</cbc:ID>
			</cac:ContractDocumentReference>
		</xsl:if>
		<xsl:variable name="pdfFileId">
			<xsl:choose>
				<xsl:when test="normalize-space(InvoiceInformation/InvoiceNumber)">
					<xsl:if test="normalize-space(InvoiceParties/SellerParty/RegNumber)">
						<xsl:value-of select="translate(InvoiceParties/SellerParty/RegNumber,' \?:/','')"/>
						<xsl:text>.</xsl:text>
					</xsl:if>
					<xsl:value-of select="translate(normalize-space(InvoiceInformation/InvoiceDate),' \?:/-','')"/>
					<xsl:text>.</xsl:text>
					<xsl:value-of select="translate(InvoiceInformation/InvoiceNumber,' \?:/','')"/>
				</xsl:when>
				<xsl:when test="normalize-space(@invoiceGlobUniqId)">
					<xsl:value-of select="@invoiceGlobUniqId"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space(AdditionalInformation[@extensionId='invoicePDFFormat']/CustomContent/file)">
				<cac:AdditionalDocumentReference>
					<cbc:ID>
						<xsl:value-of select="$pdfFileId"/>
					</cbc:ID>
					<cbc:DocumentDescription>Commercial invoice</cbc:DocumentDescription>
					<cac:Attachment>
						<cbc:EmbeddedDocumentBinaryObject mimeCode="application/pdf">
							<xsl:attribute name="filename"><xsl:value-of select="concat($pdfFileId,'.pdf')"/></xsl:attribute>
							<xsl:value-of select="AdditionalInformation[@extensionId='invoicePDFFormat']/CustomContent/file"/>
						</cbc:EmbeddedDocumentBinaryObject>
					</cac:Attachment>
				</cac:AdditionalDocumentReference>
			</xsl:when>
			<xsl:when test="normalize-space(AttachmentFile/FileBase64)">
				<cac:AdditionalDocumentReference>
					<cbc:ID>
						<xsl:value-of select="$pdfFileId"/>
					</cbc:ID>
					<cbc:DocumentDescription>Commercial invoice</cbc:DocumentDescription>
					<cac:Attachment>
						<cbc:EmbeddedDocumentBinaryObject mimeCode="application/pdf">
							<xsl:attribute name="filename"><xsl:choose><xsl:when test="normalize-space(AttachmentFile/FileName)"><xsl:value-of select="translate(AttachmentFile/FileName,' \?:/','')"/></xsl:when><xsl:otherwise><xsl:value-of select="concat($pdfFileId,'.pdf')"/></xsl:otherwise></xsl:choose></xsl:attribute>
							<xsl:value-of select="AttachmentFile/FileBase64"/>
						</cbc:EmbeddedDocumentBinaryObject>
					</cac:Attachment>
				</cac:AdditionalDocumentReference>
			</xsl:when>
		</xsl:choose>
		<cac:AccountingSupplierParty>
			<xsl:variable name="supplierSchema">
				<xsl:call-template name="getSchemaID">
					<xsl:with-param name="input" select="replace(InvoiceParties/SellerParty/VATRegNumber,'-','')"/>
				</xsl:call-template>
			</xsl:variable>
			<cac:Party>
				<xsl:choose>
					<xsl:when test="normalize-space(InvoiceParties/SellerParty/RegNumber) and ($supplierSchema='0191' or $supplierSchema='0037')">
						<cbc:EndpointID>
							<xsl:attribute name="schemeID"><xsl:value-of select="$supplierSchema"/></xsl:attribute>
							<xsl:value-of select="replace(InvoiceParties/SellerParty/RegNumber,'-','')"/>
						</cbc:EndpointID>
						<cac:PartyIdentification>
							<cbc:ID>
								<xsl:attribute name="schemeID"><xsl:value-of select="$supplierSchema"/></xsl:attribute>
								<xsl:value-of select="replace(InvoiceParties/SellerParty/RegNumber,'-','')"/>
							</cbc:ID>
						</cac:PartyIdentification>
					</xsl:when>
					<xsl:when test="normalize-space(replace(InvoiceParties/SellerParty/VATRegNumber,'-',''))">
						<cbc:EndpointID>
							<xsl:attribute name="schemeID"><xsl:value-of select="$supplierSchema"/></xsl:attribute>
							<xsl:value-of select="InvoiceParties/SellerParty/VATRegNumber"/>
						</cbc:EndpointID>
						<cac:PartyIdentification>
							<cbc:ID>
								<!--<xsl:attribute name="schemeID"><xsl:value-of select="$supplierSchema"/></xsl:attribute>-->
								<xsl:value-of select="InvoiceParties/SellerParty/VATRegNumber"/>
							</cbc:ID>
						</cac:PartyIdentification>
					</xsl:when>
				</xsl:choose>
				<cac:PartyName>
					<cbc:Name>
						<xsl:value-of select="InvoiceParties/SellerParty/Name"/>
					</cbc:Name>
				</cac:PartyName>
				<cac:PostalAddress>
					<xsl:if test="normalize-space(InvoiceParties/SellerParty/ContactData/LegalAddress/PostalAddress1)">
						<cbc:StreetName>
							<xsl:value-of select="InvoiceParties/SellerParty/ContactData/LegalAddress/PostalAddress1"/>
						</cbc:StreetName>
					</xsl:if>
					<xsl:if test="normalize-space(InvoiceParties/SellerParty/ContactData/LegalAddress/City)">
						<cbc:CityName>
							<xsl:value-of select="InvoiceParties/SellerParty/ContactData/LegalAddress/City"/>
						</cbc:CityName>
					</xsl:if>
					<xsl:if test="normalize-space(InvoiceParties/SellerParty/ContactData/LegalAddress/PostalCode)">
						<cbc:PostalZone>
							<xsl:value-of select="InvoiceParties/SellerParty/ContactData/LegalAddress/PostalCode"/>
						</cbc:PostalZone>
					</xsl:if>
					<cac:Country>
						<cbc:IdentificationCode>
							<xsl:choose>
								<xsl:when test="string-length(InvoiceParties/SellerParty/ContactData/LegalAddress/Country)=2">
									<xsl:value-of select="InvoiceParties/SellerParty/ContactData/LegalAddress/Country"/>
								</xsl:when>
								<xsl:when test="normalize-space(replace(InvoiceParties/SellerParty/VATRegNumber,'-',''))">
									<xsl:value-of select="substring(normalize-space(InvoiceParties/SellerParty/VATRegNumber),1,2)"/>
								</xsl:when>
								<xsl:otherwise>EE</xsl:otherwise>
							</xsl:choose>
						</cbc:IdentificationCode>
					</cac:Country>
				</cac:PostalAddress>
				<cac:PartyTaxScheme>
					<xsl:if test="normalize-space(replace(InvoiceParties/SellerParty/VATRegNumber,'-',''))">
						<xsl:choose>
							<xsl:when test="InvoiceSumGroup/VAT[@vatId='NOTTAX' or @vatId='TAXEX']">
								<xsl:if test="count(InvoiceSumGroup/VAT[@vatId='NOTTAX' or @vatId='TAXEX'])!=count(InvoiceSumGroup/VAT) and abs(sum(InvoiceSumGroup/VAT[@vatId='TAX']/VATSum))&gt;0">
									<cbc:CompanyID>
										<xsl:value-of select="InvoiceParties/SellerParty/VATRegNumber"/>
									</cbc:CompanyID>
								</xsl:if>
							</xsl:when>
							<xsl:when test="not(InvoiceSumGroup/VAT) and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT)=0">
								<cbc:CompanyID>
									<xsl:value-of select="InvoiceParties/SellerParty/VATRegNumber"/>
								</cbc:CompanyID>
							</xsl:when>
							<xsl:when test="not(InvoiceSumGroup/VAT/@vatId) and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[@vatId='NOTTAX' or @vatId='TAXEX'])=count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT) and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[@vatId='NOTTAX' or @vatId='TAXEX'])>0">
							</xsl:when>
							<xsl:otherwise>
								<cbc:CompanyID>
									<xsl:value-of select="InvoiceParties/SellerParty/VATRegNumber"/>
								</cbc:CompanyID>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<cac:TaxScheme>
						<cbc:ID>VAT</cbc:ID>
					</cac:TaxScheme>
				</cac:PartyTaxScheme>
				<cac:PartyLegalEntity>
					<cbc:RegistrationName>
						<xsl:value-of select="InvoiceParties/SellerParty/Name"/>
					</cbc:RegistrationName>
					<xsl:if test="normalize-space(InvoiceParties/SellerParty/RegNumber)">
						<xsl:choose>
							<xsl:when test="normalize-space(InvoiceParties/BuyerParty/RegNumber) and $supplierSchema='9955'">
								<cbc:CompanyID>
									<xsl:choose>
										<xsl:when test="starts-with(InvoiceParties/SellerParty/RegNumber,'SE') ">
											<!--<xsl:attribute name="schemeID">
													<xsl:value-of select="$supplierSchema"/>
												</xsl:attribute>-->
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="schemeID"><xsl:text>0007</xsl:text></xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:value-of select="replace(InvoiceParties/SellerParty/RegNumber,'-','')"/>
								</cbc:CompanyID>
							</xsl:when>
							<xsl:otherwise>
								<cbc:CompanyID>
									<xsl:value-of select="InvoiceParties/SellerParty/RegNumber"/>
								</cbc:CompanyID>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</cac:PartyLegalEntity>
				<xsl:if test="normalize-space(InvoiceParties/SellerParty/ContactData/E-mailAddress) or normalize-space(InvoiceParties/SellerParty/ContactData/ContactName)">
					<cac:Contact>
						<xsl:if test="normalize-space(InvoiceParties/SellerParty/ContactData/ContactName)">
							<cbc:Name>
								<xsl:value-of select="InvoiceParties/SellerParty/ContactData/ContactName"/>
							</cbc:Name>
						</xsl:if>
						<xsl:if test="normalize-space(InvoiceParties/SellerParty/ContactData/E-mailAddress)">
							<cbc:ElectronicMail>
								<xsl:value-of select="InvoiceParties/SellerParty/ContactData/E-mailAddress"/>
							</cbc:ElectronicMail>
						</xsl:if>
					</cac:Contact>
				</xsl:if>
			</cac:Party>
		</cac:AccountingSupplierParty>
		<cac:AccountingCustomerParty>
			<xsl:variable name="companySchema">
				<xsl:if test="normalize-space(replace(InvoiceParties/BuyerParty/VATRegNumber,'-',''))">
					<xsl:call-template name="getSchemaID">
						<xsl:with-param name="input" select="InvoiceParties/BuyerParty/VATRegNumber"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:variable>
			<cac:Party>
				<cbc:EndpointID>
					<xsl:choose>
						<xsl:when test="emk_BLOKK/emk_AdrInx='PEPPOL'">
							<xsl:attribute name="schemeID"><xsl:value-of select="substring-before(emk_BLOKK/emk_ElepAdr,':')"/></xsl:attribute>
							<xsl:value-of select="substring-after(emk_BLOKK/emk_ElepAdr,':')"/>
						</xsl:when>
						<xsl:when test="@channelId='PEPPOL'">
							<xsl:attribute name="schemeID"><xsl:value-of select="substring-before(@channelAddress,':')"/></xsl:attribute>
							<xsl:value-of select="substring-after(@channelAddress,':')"/>
						</xsl:when>
						<xsl:when test="contains(emk_BLOKK/emk_ElepAdr,':')">
							<xsl:attribute name="schemeID"><xsl:value-of select="substring-before(emk_BLOKK/emk_ElepAdr,':')"/></xsl:attribute>
							<xsl:value-of select="substring-after(emk_BLOKK/emk_ElepAdr,':')"/>
						</xsl:when>
						<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' and starts-with(emk_BLOKK/emk_ElepAdr,'0037')">
							<xsl:attribute name="schemeID">0216</xsl:attribute>
							<!--<xsl:value-of select="substring-after(emk_BLOKK/emk_ElepAdr,'0037')"/>-->
							<xsl:value-of select="emk_BLOKK/emk_ElepAdr"/>
						</xsl:when>
						<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' and starts-with(emk_BLOKK/emk_ElepAdr,'TE')">
							<xsl:attribute name="schemeID">0215</xsl:attribute>
							<xsl:value-of select="emk_BLOKK/emk_ElepAdr"/>
						</xsl:when>
						<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' and starts-with(emk_BLOKK/emk_ElepAdr,'FI')">
							<xsl:attribute name="schemeID">0213</xsl:attribute>
							<xsl:value-of select="emk_BLOKK/emk_ElepAdr"/>
						</xsl:when>
						<xsl:when test="starts-with(emk_BLOKK/emk_ElepAdr,'EE')">
							<xsl:attribute name="schemeID">9931</xsl:attribute>
							<xsl:value-of select="emk_BLOKK/emk_ElepAdr"/>
						</xsl:when>
						<xsl:when test="normalize-space(InvoiceParties/BuyerParty/RegNumber) and ($companySchema='0191' or $companySchema='0037')">
							<xsl:attribute name="schemeID"><xsl:value-of select="$companySchema"/></xsl:attribute>
							<xsl:value-of select="replace(InvoiceParties/BuyerParty/RegNumber,'-','')"/>
						</xsl:when>
						<xsl:when test="normalize-space(emk_BLOKK/emk_OwnerIK)">
							<xsl:attribute name="schemeID">0191</xsl:attribute>
							<xsl:value-of select="emk_BLOKK/emk_OwnerIK"/>
						</xsl:when>
						<xsl:when test="normalize-space(replace(InvoiceParties/BuyerParty/VATRegNumber,'-',''))">
							<xsl:attribute name="schemeID"><xsl:value-of select="$companySchema"/></xsl:attribute>
							<xsl:value-of select="InvoiceParties/BuyerParty/VATRegNumber"/>
						</xsl:when>
					</xsl:choose>
				</cbc:EndpointID>
				<xsl:if test="normalize-space(InvoiceParties/BuyerParty/RegNumber) or normalize-space(emk_BLOKK/emk_OwnerIK) or normalize-space(replace(InvoiceParties/BuyerParty/VATRegNumber,'-',''))">
					<cac:PartyIdentification>
						<cbc:ID>
							<xsl:choose>
								<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' and contains(emk_BLOKK/emk_ElepAdr,':')">
									<xsl:if test="not(starts-with(emk_BLOKK/emk_ElepAdr,'9931'))">
										<xsl:attribute name="schemeID"><xsl:value-of select="substring-before(emk_BLOKK/emk_ElepAdr,':')"/></xsl:attribute>
									</xsl:if>
									<xsl:value-of select="substring-after(emk_BLOKK/emk_ElepAdr,':')"/>
								</xsl:when>
								<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' and starts-with(emk_BLOKK/emk_ElepAdr,'0037')">
									<xsl:attribute name="schemeID">0037</xsl:attribute>
									<xsl:value-of select="substring-after(emk_BLOKK/emk_ElepAdr,'0037')"/>
								</xsl:when>
								<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' and starts-with(emk_BLOKK/emk_ElepAdr,'TE')">
									<xsl:attribute name="schemeID">0215</xsl:attribute>
									<xsl:value-of select="emk_BLOKK/emk_ElepAdr"/>
								</xsl:when>
								<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' and starts-with(emk_BLOKK/emk_ElepAdr,'FI')">
									<xsl:attribute name="schemeID">0213</xsl:attribute>
									<xsl:value-of select="emk_BLOKK/emk_ElepAdr"/>
								</xsl:when>
								<xsl:when test="normalize-space(InvoiceParties/BuyerParty/RegNumber)">
									<xsl:value-of select="InvoiceParties/BuyerParty/RegNumber"/>
								</xsl:when>
								<xsl:when test="normalize-space(emk_BLOKK/emk_OwnerIK)">
									<xsl:value-of select="emk_BLOKK/emk_OwnerIK"/>
								</xsl:when>
								<xsl:otherwise>
									<!--<xsl:attribute name="schemeID"><xsl:value-of select="$companySchema"/></xsl:attribute>-->
									<xsl:value-of select="InvoiceParties/BuyerParty/VATRegNumber"/>
								</xsl:otherwise>
							</xsl:choose>
						</cbc:ID>
					</cac:PartyIdentification>
				</xsl:if>
				<cac:PartyName>
					<cbc:Name>
						<xsl:value-of select="InvoiceParties/BuyerParty/Name"/>
					</cbc:Name>
				</cac:PartyName>
				<cac:PostalAddress>
					<xsl:if test="normalize-space(InvoiceParties/BuyerParty/ContactData/LegalAddress/PostalAddress1)">
						<cbc:StreetName>
							<xsl:value-of select="InvoiceParties/BuyerParty/ContactData/LegalAddress/PostalAddress1"/>
						</cbc:StreetName>
					</xsl:if>
					<xsl:if test="normalize-space(InvoiceParties/BuyerParty/ContactData/LegalAddress/City)">
						<cbc:CityName>
							<xsl:value-of select="InvoiceParties/BuyerParty/ContactData/LegalAddress/City"/>
						</cbc:CityName>
					</xsl:if>
					<xsl:if test="normalize-space(InvoiceParties/BuyerParty/ContactData/LegalAddress/PostalCode)">
						<cbc:PostalZone>
							<xsl:value-of select="InvoiceParties/BuyerParty/ContactData/LegalAddress/PostalCode"/>
						</cbc:PostalZone>
					</xsl:if>
					<cac:Country>
						<cbc:IdentificationCode>
							<xsl:choose>
								<xsl:when test="string-length(InvoiceParties/BuyerParty/ContactData/LegalAddress/Country)=2">
									<xsl:value-of select="InvoiceParties/BuyerParty/ContactData/LegalAddress/Country"/>
								</xsl:when>
								<xsl:when test="normalize-space(replace(InvoiceParties/BuyerParty/VATRegNumber,'-',''))">
									<xsl:value-of select="substring(normalize-space(InvoiceParties/BuyerParty/VATRegNumber),1,2)"/>
								</xsl:when>
								<xsl:otherwise>EE</xsl:otherwise>
							</xsl:choose>
						</cbc:IdentificationCode>
					</cac:Country>
				</cac:PostalAddress>
				<cac:PartyTaxScheme>
					<xsl:if test="normalize-space(replace(InvoiceParties/BuyerParty/VATRegNumber,'-',''))">
						<xsl:choose>
							<xsl:when test="InvoiceSumGroup/VAT[@vatId='NOTTAX' or @vatId='TAXEX']">
								<xsl:if test="count(InvoiceSumGroup/VAT[@vatId='NOTTAX' or @vatId='TAXEX'])!=count(InvoiceSumGroup/VAT) and abs(sum(InvoiceSumGroup/VAT[@vatId='TAX']/VATSum))&gt;0">
									<cbc:CompanyID>
										<xsl:value-of select="InvoiceParties/BuyerParty/VATRegNumber"/>
									</cbc:CompanyID>
								</xsl:if>
							</xsl:when>
							<xsl:when test="not(InvoiceSumGroup/VAT/@vatId) and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[@vatId='NOTTAX' or @vatId='TAXEX'])=count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT)">
							</xsl:when>
							<xsl:when test="sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/@VATRate)=0 and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[@vatId='TAX'])=0 and not(normalize-space(InvoiceParties/SellerParty/VATRegNumber))"></xsl:when>	
							<xsl:otherwise>
								<cbc:CompanyID>
									<xsl:value-of select="InvoiceParties/BuyerParty/VATRegNumber"/>
								</cbc:CompanyID>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<cac:TaxScheme>
						<cbc:ID>VAT</cbc:ID>
					</cac:TaxScheme>
				</cac:PartyTaxScheme>
				<cac:PartyLegalEntity>
					<cbc:RegistrationName>
						<xsl:value-of select="InvoiceParties/BuyerParty/Name"/>
					</cbc:RegistrationName>
					<xsl:choose>
						<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' and contains(emk_BLOKK/emk_ElepAdr,':')">
							<cbc:CompanyID>
								<xsl:if test="not(starts-with(emk_BLOKK/emk_ElepAdr,'9931'))">
									<xsl:attribute name="schemeID"><xsl:value-of select="substring-before(emk_BLOKK/emk_ElepAdr,':')"/></xsl:attribute>
								</xsl:if>
								<xsl:value-of select="substring-after(emk_BLOKK/emk_ElepAdr,':')"/>
							</cbc:CompanyID>
						</xsl:when>
						<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' and starts-with(emk_BLOKK/emk_ElepAdr,'0037')">
							<cbc:CompanyID>
								<xsl:attribute name="schemeID">0037</xsl:attribute>
								<xsl:value-of select="substring-after(emk_BLOKK/emk_ElepAdr,'0037')"/>
							</cbc:CompanyID>
						</xsl:when>
						<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' and starts-with(emk_BLOKK/emk_ElepAdr,'TE')">
							<cbc:CompanyID>
								<xsl:attribute name="schemeID">0215</xsl:attribute>
								<xsl:value-of select="emk_BLOKK/emk_ElepAdr"/>
							</cbc:CompanyID>
						</xsl:when>
						<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' and starts-with(emk_BLOKK/emk_ElepAdr,'FI')">
							<cbc:CompanyID>
								<xsl:attribute name="schemeID">0213</xsl:attribute>
								<xsl:value-of select="emk_BLOKK/emk_ElepAdr"/>
							</cbc:CompanyID>
						</xsl:when>
						<xsl:when test="normalize-space(InvoiceParties/BuyerParty/RegNumber) and ($companySchema='0191' or $companySchema='0037')">
							<cbc:CompanyID>
								<xsl:attribute name="schemeID"><xsl:value-of select="$companySchema"/></xsl:attribute>
								<xsl:value-of select="replace(InvoiceParties/BuyerParty/RegNumber,'-','')"/>
							</cbc:CompanyID>
						</xsl:when>
						<xsl:when test="normalize-space(InvoiceParties/BuyerParty/RegNumber) and $companySchema='9955'">
							<cbc:CompanyID>
								<xsl:choose>
									<xsl:when test="starts-with(InvoiceParties/BuyerParty/RegNumber,'SE') ">
										<!--<xsl:attribute name="schemeID">
												<xsl:value-of select="$companySchema"/>
											</xsl:attribute>-->
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="schemeID"><xsl:text>0007</xsl:text></xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:value-of select="replace(InvoiceParties/BuyerParty/RegNumber,'-','')"/>
							</cbc:CompanyID>
						</xsl:when>
						<xsl:when test="normalize-space(emk_BLOKK/emk_OwnerIK)">
							<cbc:CompanyID>
								<xsl:attribute name="schemeID">0191</xsl:attribute>
								<xsl:value-of select="emk_BLOKK/emk_OwnerIK"/>
							</cbc:CompanyID>
						</xsl:when>
					</xsl:choose>
				</cac:PartyLegalEntity>
				<xsl:if test="normalize-space(InvoiceParties/BuyerParty/ContactData/E-mailAddress) or normalize-space(InvoiceParties/BuyerParty/ContactData/ContactName)">
					<cac:Contact>
						<xsl:if test="normalize-space(InvoiceParties/BuyerParty/ContactData/ContactName)">
							<cbc:Name>
								<xsl:value-of select="InvoiceParties/BuyerParty/ContactData/ContactName"/>
							</cbc:Name>
						</xsl:if>
						<xsl:if test="normalize-space(InvoiceParties/BuyerParty/ContactData/E-mailAddress)">
							<cbc:ElectronicMail>
								<xsl:value-of select="InvoiceParties/BuyerParty/ContactData/E-mailAddress"/>
							</cbc:ElectronicMail>
						</xsl:if>
					</cac:Contact>
				</xsl:if>
			</cac:Party>
		</cac:AccountingCustomerParty>
		<xsl:if test="normalize-space(InvoiceParties/DeliveryParty)">
			<cac:Delivery>
				<xsl:if test="InvoiceParties/DeliveryParty/RegNumber or InvoiceParties/DeliveryParty/ContactData/LegalAddress">
					<cac:DeliveryLocation>
						<xsl:if test="normalize-space(InvoiceParties/DeliveryParty/RegNumber)">
							<cbc:ID>
								<xsl:value-of select="InvoiceParties/DeliveryParty/RegNumber"/>
							</cbc:ID>
						</xsl:if>
						<xsl:if test="InvoiceParties/DeliveryParty/ContactData/LegalAddress">
							<cac:Address>
								<cbc:StreetName>
									<xsl:value-of select="InvoiceParties/DeliveryParty/ContactData/LegalAddress/PostalAddress1"/>
								</cbc:StreetName>
								<xsl:if test="normalize-space(InvoiceParties/DeliveryParty/ContactData/LegalAddress/City)">
									<cbc:CityName>
										<xsl:value-of select="InvoiceParties/DeliveryParty/ContactData/LegalAddress/City"/>
									</cbc:CityName>
								</xsl:if>
								<xsl:if test="normalize-space(InvoiceParties/DeliveryParty/ContactData/LegalAddress/PostalCode)">
									<cbc:PostalZone>
										<xsl:value-of select="InvoiceParties/DeliveryParty/ContactData/LegalAddress/PostalCode"/>
									</cbc:PostalZone>
								</xsl:if>
								<cac:Country>
									<cbc:IdentificationCode>
										<xsl:choose>
											<xsl:when test="string-length(InvoiceParties/DeliveryParty/ContactData/LegalAddress/Country)=2">
												<xsl:value-of select="InvoiceParties/DeliveryParty/ContactData/LegalAddress/Country"/>
											</xsl:when>
											<xsl:when test="normalize-space(replace(InvoiceParties/DeliveryParty/VATRegNumber,'-',''))">
												<xsl:value-of select="substring(normalize-space(InvoiceParties/DeliveryParty/VATRegNumber),1,2)"/>
											</xsl:when>
											<xsl:otherwise>EE</xsl:otherwise>
										</xsl:choose>
									</cbc:IdentificationCode>
								</cac:Country>
							</cac:Address>
						</xsl:if>
					</cac:DeliveryLocation>
				</xsl:if>
				<cac:DeliveryParty>
					<cac:PartyName>
						<cbc:Name>
							<xsl:value-of select="InvoiceParties/DeliveryParty/Name"/>
						</cbc:Name>
					</cac:PartyName>
				</cac:DeliveryParty>
			</cac:Delivery>
		</xsl:if>
		<cac:PaymentMeans>
			<cbc:PaymentMeansCode>42</cbc:PaymentMeansCode>
			<cbc:PaymentDueDate>
				<xsl:choose>
					<xsl:when test="InvoiceInformation/DueDate">
						<xsl:value-of select="InvoiceInformation/DueDate"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="InvoiceInformation/InvoiceDate"/>
					</xsl:otherwise>
				</xsl:choose>
			</cbc:PaymentDueDate>
			<xsl:choose>
				<xsl:when test="normalize-space(InvoiceParties/BuyerParty/UniqueCode)='14069679' or normalize-space(InvoiceParties/BuyerParty/RegNumber)='14069679' or normalize-space(emk_BLOKK/emk_OwnerIK)='14069679' or normalize-space(InvoiceParties/BuyerParty/VATRegNumber)='14069679'"/>
				<xsl:when test="emk_BLOKK/emk_AdrInx='9999FI' or emk_BLOKK/emk_AdrInx='tEAb'">
					<xsl:choose>
						<xsl:when test="normalize-space(InvoiceInformation/PaymentReferenceNumber) and fitek:ValidateReferenceNo(InvoiceInformation/PaymentReferenceNumber,InvoiceParties/SellerParty/AccountInfo[1]/AccountNumber)">
							<cbc:PaymentID>
								<xsl:value-of select="InvoiceInformation/PaymentReferenceNumber"/>
							</cbc:PaymentID>
						</xsl:when>
						<xsl:when test="normalize-space(PaymentInfo/PaymentRefId) and fitek:ValidateReferenceNo(PaymentInfo/PaymentRefId,InvoiceParties/SellerParty/AccountInfo[1]/AccountNumber)">
							<cbc:PaymentID>
								<xsl:value-of select="PaymentInfo/PaymentRefId"/>
							</cbc:PaymentID>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="normalize-space(InvoiceInformation/ContractNumber)">
							<cbc:PaymentID>
								<xsl:value-of select="InvoiceInformation/ContractNumber"/>
							</cbc:PaymentID>
						</xsl:when>
						<xsl:when test="normalize-space(InvoiceInformation/PaymentReferenceNumber)">
							<cbc:PaymentID>
								<xsl:value-of select="InvoiceInformation/PaymentReferenceNumber"/>
							</cbc:PaymentID>
						</xsl:when>
						<xsl:when test="normalize-space(PaymentInfo/PaymentRefId)">
							<cbc:PaymentID>
								<xsl:value-of select="PaymentInfo/PaymentRefId"/>
							</cbc:PaymentID>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="emk_BLOKK/emk_AdrInx!='MONITOR'">
								<cbc:PaymentID>
									<xsl:value-of select="InvoiceInformation/InvoiceNumber"/>
								</cbc:PaymentID>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="normalize-space(PaymentInfo/PayToAccount)">
					<cac:PayeeFinancialAccount>
						<cbc:ID>
							<xsl:value-of select="PaymentInfo/PayToAccount"/>
						</cbc:ID>
						<xsl:variable name="accountNo" select="PaymentInfo/PayToAccount"/>
						<xsl:choose>
							<xsl:when test="InvoiceParties/SellerParty/AccountInfo[AccountNumber=$accountNo][1]">
								<xsl:if test="normalize-space(InvoiceParties/SellerParty/AccountInfo[AccountNumber=$accountNo][1]/BankName)">
									<cbc:Name>
										<xsl:value-of select="InvoiceParties/SellerParty/AccountInfo[AccountNumber=$accountNo][1]/BankName"/>
									</cbc:Name>
								</xsl:if>
								<xsl:if test="normalize-space(InvoiceParties/SellerParty/AccountInfo[AccountNumber=$accountNo][1]/BIC)">
									<cac:FinancialInstitutionBranch>
										<cbc:ID>
											<xsl:value-of select="InvoiceParties/SellerParty/AccountInfo[AccountNumber=$accountNo][1]/BIC"/>
										</cbc:ID>
									</cac:FinancialInstitutionBranch>
								</xsl:if>
							</xsl:when>
							<xsl:when test="normalize-space(PaymentInfo/PayToBIC)">
								<cac:FinancialInstitutionBranch>
									<cbc:ID>
										<xsl:value-of select="PaymentInfo/PayToBIC"/>
									</cbc:ID>
								</cac:FinancialInstitutionBranch>
							</xsl:when>
						</xsl:choose>
					</cac:PayeeFinancialAccount>
				</xsl:when>
				<xsl:when test="InvoiceParties/SellerParty/AccountInfo[1]/AccountNumber">
					<cac:PayeeFinancialAccount>
						<cbc:ID>
							<xsl:value-of select="InvoiceParties/SellerParty/AccountInfo[1]/AccountNumber"/>
						</cbc:ID>
						<xsl:if test="normalize-space(InvoiceParties/SellerParty/AccountInfo[1]/BIC)">
							<cac:FinancialInstitutionBranch>
								<cbc:ID>
									<xsl:value-of select="InvoiceParties/SellerParty/AccountInfo[1]/BIC"/>
								</cbc:ID>
							</cac:FinancialInstitutionBranch>
						</xsl:if>
					</cac:PayeeFinancialAccount>
				</xsl:when>
			</xsl:choose>
		</cac:PaymentMeans>
		<xsl:if test="normalize-space(InvoiceInformation/PaymentTerm)">
			<cac:PaymentTerms>
				<cbc:Note>
					<xsl:value-of select="InvoiceInformation/PaymentTerm"/>
				</cbc:Note>
			</cac:PaymentTerms>
		</xsl:if>
		<!--xsl:for-each select="InvoiceSumGroup/Addition[@addCode='DSC']">
					<cac:AllowanceCharge>
						<cbc:ChargeIndicator>false</cbc:ChargeIndicator>
						<cbc:AllowanceChargeReason>
							<xsl:if test="normalize-space(AddRate)">
								<xsl:value-of select="format-number(AddRate,'#######0')"/>
								<xsl:text>% </xsl:text>
							</xsl:if>
							<xsl:value-of select="AddContent"/>
						</cbc:AllowanceChargeReason>
						<cbc:Amount>
							<xsl:attribute name="currencyID"><xsl:value-of select="../../PaymentInfo/Currency"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="normalize-space(AddSum)">
									<xsl:value-of select="format-number(AddSum,'#######0.00')"/>
								</xsl:when>
								<xsl:when test="normalize-space(AddRate) and normalize-space(SumBeforeVAT)">
									<xsl:value-of select="format-number(AddRate * SumBeforeVAT  div 100,'#######0.00')"/>
								</xsl:when>
								<xsl:otherwise>0.00</xsl:otherwise>
							</xsl:choose>
						</cbc:Amount>
						<cac:TaxCategory>
							 <cbc:ID>
								<xsl:choose>
									<xsl:when test="../../InvoiceSumGroup[1]/VAT[1][@vatId='TAX' or number(VATRate) &gt; 0]">S</xsl:when>
										<xsl:when test="../../InvoiceSumGroup[1]/VAT[1][@vatId='TAXEX'] or string-length(normalize-space(../../InvoiceParties/SellerParty/VATRegNumber))=0">O</xsl:when>
										<xsl:when test="number(../../InvoiceSumGroup[1]/VAT[1]/VATRate) = 0 and string-length(normalize-space(../../InvoiceParties/SellerParty/VATRegNumber))>0">Z</xsl:when>
										<xsl:when test="number(../../InvoiceSumGroup[1]/VAT[1]/VATRate) &gt; 0 and normalize-space(../../InvoiceParties/SellerParty/VATRegNumber)">S</xsl:when>
								</xsl:choose>
							 </cbc:ID> 
							 <cbc:Percent><xsl:value-of select="../../InvoiceSumGroup[1]/VAT[1]/VATRate"/></cbc:Percent>
							<cac:TaxScheme>
								<cbc:ID>VAT</cbc:ID>
							</cac:TaxScheme>
						</cac:TaxCategory>
					</cac:AllowanceCharge>
				</xsl:for-each-->
		<!--xsl:for-each select="InvoiceSumGroup/Addition[@addCode='CHR']">
					<cac:AllowanceCharge>
						<cbc:ChargeIndicator>true</cbc:ChargeIndicator>
						<cbc:AllowanceChargeReason>
							<xsl:if test="normalize-space(AddRate)">
								<xsl:value-of select="format-number(AddRate,'#######0')"/>
								<xsl:text>% </xsl:text>
							</xsl:if>
							<xsl:value-of select="AddContent"/>
						</cbc:AllowanceChargeReason>
						<cbc:Amount>
							<xsl:attribute name="currencyID"><xsl:value-of select="../../PaymentInfo/Currency"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="normalize-space(AddSum)">
									<xsl:value-of select="format-number(AddSum,'#######0.00')"/>
								</xsl:when>
								<xsl:when test="normalize-space(AddRate) and normalize-space(SumBeforeVAT)">
									<xsl:value-of select="format-number(AddRate * SumBeforeVAT  div 100,'#######0.00')"/>
								</xsl:when>
								<xsl:otherwise>0.00</xsl:otherwise>
							</xsl:choose>
						</cbc:Amount>
						<cac:TaxCategory>
							 <cbc:ID>
								<xsl:choose>
									<xsl:when test="../../InvoiceSumGroup[1]/VAT[1][@vatId='TAX' or number(VATRate) &gt; 0]">S</xsl:when>
										<xsl:when test="../../InvoiceSumGroup[1]/VAT[1][@vatId='TAXEX'] or string-length(normalize-space(../../InvoiceParties/SellerParty/VATRegNumber))=0">O</xsl:when>
										<xsl:when test="number(../../InvoiceSumGroup[1]/VAT[1]/VATRate) = 0 and string-length(normalize-space(../../InvoiceParties/SellerParty/VATRegNumber))>0">Z</xsl:when>
										<xsl:when test="number(../../InvoiceSumGroup[1]/VAT[1]/VATRate) &gt; 0 and normalize-space(../../InvoiceParties/SellerParty/VATRegNumber)">S</xsl:when>
								</xsl:choose>
							 </cbc:ID> 
							  <cbc:Percent><xsl:value-of select="../../InvoiceSumGroup[1]/VAT[1]/VATRate"/></cbc:Percent>
							<cac:TaxScheme>
								<cbc:ID>VAT</cbc:ID>
							</cac:TaxScheme>
						</cac:TaxCategory>
					</cac:AllowanceCharge>
				</xsl:for-each-->
		<cac:TaxTotal>
			<cbc:TaxAmount>
				<xsl:attribute name="currencyID"><xsl:value-of select="PaymentInfo/Currency"/></xsl:attribute>
				<xsl:choose>
					<xsl:when test="count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[normalize-space(VATRate)]/SumBeforeVAT) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)])">
						<xsl:value-of select="format-number(round(100 * sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(round(100 * xs:decimal(SumBeforeVAT)) div 100 * xs:decimal(VATRate))) div 100) div 100, '#######0.00')"/>
					</xsl:when>
					<xsl:when test="InvoiceSumGroup[1]/VAT/VATSum">
						<xsl:value-of select="format-number(sum(InvoiceSumGroup[1]/VAT/VATSum), '#######0.00')"/>
					</xsl:when>
					<xsl:when test="InvoiceSumGroup[1]/TotalVATSum">
						<xsl:value-of select="format-number(sum(sum(InvoiceSumGroup[1]/TotalVATSum)), '#######0.00')"/>
					</xsl:when>
					<xsl:otherwise>0.00</xsl:otherwise>
				</xsl:choose>
			</cbc:TaxAmount>
			<!--<xsl:for-each select="InvoiceSumGroup/VAT">-->
			<xsl:variable name="allVatId">
				<xsl:choose>
					<xsl:when test="count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[@vatId='TAXEX' or @vatId='NOTTAX']) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)])">TAXEX</xsl:when>
					<xsl:when test="count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/@vatId) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[@vatId!='TAX']) and count(InvoiceSumGroup/VAT[@vatId='TAXEX' or @vatId='NOTTAX'])=1 and count(InvoiceSumGroup/VAT[@vatId='TAX'])=0">TAXEX</xsl:when>
					<xsl:when test="sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/@VATRate)=0 and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[@vatId='TAX'])=0 and not(normalize-space(InvoiceParties/SellerParty/VATRegNumber))">TAXEX</xsl:when>					
					<xsl:otherwise>TAX</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[normalize-space(VATRate)]/SumBeforeVAT) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)])">
					<xsl:for-each-group select="InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT" group-by="number(VATRate)">
						<xsl:variable name="taxCode">
							<xsl:choose>
								<xsl:when test="@vatId='TAX' and number(VATRate) &gt; 0">S</xsl:when>
								<xsl:when test="$allVatId='TAXEX' or (string-length(normalize-space(replace(../../../../InvoiceParties/SellerParty/VATRegNumber,'-','')))=0)">O</xsl:when>
								<xsl:when test="number(VATRate) = 0 and string-length(normalize-space(replace(../../../../InvoiceParties/SellerParty/VATRegNumber,'-','')))>0">Z</xsl:when>
								<xsl:when test="number(VATRate) &gt; 0 and normalize-space(replace(../../../../InvoiceParties/SellerParty/VATRegNumber,'-',''))">S</xsl:when>
								<xsl:otherwise>Z</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<cac:TaxSubtotal>
							<cbc:TaxableAmount>
								<xsl:attribute name="currencyID"><xsl:value-of select="../../../../PaymentInfo/Currency"/></xsl:attribute>
								<xsl:choose>
									<xsl:when test="normalize-space(SumBeforeVAT)">
										<xsl:value-of select="format-number(round(100 * sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[current-grouping-key()=number(VATRate)]/(round(100 * xs:decimal(SumBeforeVAT)) div 100))) div 100, '#######0.00')"/>
									</xsl:when>
									<xsl:when test="normalize-space(../ItemSum)">
										<xsl:value-of select="format-number(sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)][VAT[current-grouping-key()=number(VATRate)]]/ItemSum), '#######0.00')"/>
									</xsl:when>
									<xsl:when test="sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[current-grouping-key()=number(VATRate)]/VATSum)!=0">
										<xsl:value-of select="format-number(sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[current-grouping-key()=number(VATRate)]/VATSum) * 100 div VATRate, '#######0.00')"/>
									</xsl:when>
									<xsl:otherwise>0.00</xsl:otherwise>
								</xsl:choose>
							</cbc:TaxableAmount>
							<cbc:TaxAmount>
								<xsl:attribute name="currencyID"><xsl:value-of select="../../../../PaymentInfo/Currency"/></xsl:attribute>
								<xsl:choose>
									<xsl:when test="normalize-space(SumBeforeVAT)">
										<xsl:value-of select="format-number(round(100 * sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[current-grouping-key()=xs:decimal(VATRate)]/(round(100 * xs:decimal(SumBeforeVAT)) div 100 * xs:decimal(VATRate))) div 100) div 100, '#######0.00')"/>
									</xsl:when>
									<xsl:otherwise>0.00</xsl:otherwise>
								</xsl:choose>
							</cbc:TaxAmount>
							<cac:TaxCategory>
								<cbc:ID>
									<xsl:value-of select="$taxCode"/>
								</cbc:ID>
								<xsl:if test="$taxCode!='O'">
									<cbc:Percent>
										<xsl:choose>
											<xsl:when test="normalize-space(VATRate)">
												<xsl:value-of select="format-number(VATRate,'#0.0')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>0.0</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</cbc:Percent>
								</xsl:if>
								<xsl:if test="$taxCode='O'">
									<cbc:TaxExemptionReasonCode>
										<xsl:text>vatex-eu-o</xsl:text>
									</cbc:TaxExemptionReasonCode>
								</xsl:if>
								<cac:TaxScheme>
									<cbc:ID>VAT</cbc:ID>
								</cac:TaxScheme>
							</cac:TaxCategory>
						</cac:TaxSubtotal>
					</xsl:for-each-group>
				</xsl:when>
				<xsl:when test="count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)][normalize-space(VAT)]/Addition)=0 and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)][normalize-space(VAT)]/VAT/VATSum)!=0 and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)][normalize-space(VAT)]/VAT/VATRate)!=0 and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)][normalize-space(VAT)]/ItemSum) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)])">
					<xsl:for-each-group select="InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT" group-by="number(VATRate)">
						<xsl:variable name="taxCode">
							<xsl:choose>
								<xsl:when test="@vatId='TAX' and number(VATRate) &gt; 0">S</xsl:when>
								<xsl:when test="$allVatId='TAXEX' or (string-length(normalize-space(replace(../../../../InvoiceParties/SellerParty/VATRegNumber,'-','')))=0)">O</xsl:when>
								<xsl:when test="number(VATRate) = 0 and string-length(normalize-space(replace(../../../../InvoiceParties/SellerParty/VATRegNumber,'-','')))>0">Z</xsl:when>
								<xsl:when test="number(VATRate) &gt; 0 and normalize-space(replace(../../../../InvoiceParties/SellerParty/VATRegNumber,'-',''))">S</xsl:when>
								<xsl:otherwise>Z</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<cac:TaxSubtotal>
							<cbc:TaxableAmount>
								<xsl:attribute name="currencyID"><xsl:value-of select="../../../../PaymentInfo/Currency"/></xsl:attribute>
								<xsl:choose>
									<xsl:when test="normalize-space(SumBeforeVAT)">
										<xsl:value-of select="format-number(sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[current-grouping-key()=number(VATRate)]/SumBeforeVAT), '#######0.00')"/>
									</xsl:when>
									<xsl:when test="normalize-space(../ItemSum)">
										<xsl:value-of select="format-number(sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)][VAT[current-grouping-key()=number(VATRate)]]/ItemSum), '#######0.00')"/>
									</xsl:when>
									<xsl:when test="sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[current-grouping-key()=number(VATRate)]/VATSum)!=0">
										<xsl:value-of select="format-number(sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[current-grouping-key()=number(VATRate)]/VATSum) * 100 div VATRate, '#######0.00')"/>
									</xsl:when>
									<xsl:otherwise>0.00</xsl:otherwise>
								</xsl:choose>
							</cbc:TaxableAmount>
							<cbc:TaxAmount>
								<xsl:attribute name="currencyID"><xsl:value-of select="../../../../PaymentInfo/Currency"/></xsl:attribute>
								<xsl:choose>
									<xsl:when test="normalize-space(SumBeforeVAT)">
										<xsl:value-of select="format-number(sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[current-grouping-key()=number(VATRate)]/(SumBeforeVAT * VAT/VATRate div 100) ), '#######0.00')"/>
									</xsl:when>
									<xsl:when test="normalize-space(../ItemSum)">
										<xsl:value-of select="format-number(sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)][VAT[current-grouping-key()=number(VATRate)]]/(ItemSum * VAT/VATRate div 100) ), '#######0.00')"/>
									</xsl:when>
									<xsl:when test="sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[current-grouping-key()=number(VATRate)]/VATSum)!=0">
										<xsl:value-of select="format-number(sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[current-grouping-key()=number(VATRate)]/(VATSum  * VATRate div 100) ) * 100 div VATRate , '#######0.00')"/>
									</xsl:when>
									<xsl:when test="normalize-space(VATSum)">
										<xsl:value-of select="format-number(sum(../../../InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[current-grouping-key()=VATRate]/VATSum), '#######0.00')"/>
									</xsl:when>
									<xsl:otherwise>0.00</xsl:otherwise>
								</xsl:choose>
							</cbc:TaxAmount>
							<cac:TaxCategory>
								<cbc:ID>
									<xsl:value-of select="$taxCode"/>
								</cbc:ID>
								<xsl:if test="$taxCode!='O'">
									<cbc:Percent>
										<xsl:choose>
											<xsl:when test="normalize-space(VATRate)">
												<xsl:value-of select="format-number(VATRate,'#0.0')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>0.0</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</cbc:Percent>
								</xsl:if>
								<xsl:if test="$taxCode='O'">
									<cbc:TaxExemptionReasonCode>
										<xsl:text>vatex-eu-o</xsl:text>
									</cbc:TaxExemptionReasonCode>
								</xsl:if>
								<cac:TaxScheme>
									<cbc:ID>VAT</cbc:ID>
								</cac:TaxScheme>
							</cac:TaxCategory>
						</cac:TaxSubtotal>
					</xsl:for-each-group>
				</xsl:when>
				<xsl:when test="count(InvoiceSumGroup/VAT)>0">
					<xsl:for-each-group select="InvoiceSumGroup/VAT" group-by="number(VATRate)">
						<xsl:variable name="taxCode">
							<xsl:choose>
								<xsl:when test="@vatId='TAX' and number(VATRate) &gt; 0">S</xsl:when>
								<xsl:when test="$allVatId='TAXEX' or (string-length(normalize-space(replace(../../InvoiceParties/SellerParty/VATRegNumber,'-','')))=0)">O</xsl:when>
								<xsl:when test="number(VATRate) = 0 and string-length(normalize-space(replace(../../InvoiceParties/SellerParty/VATRegNumber,'-','')))>0">Z</xsl:when>
								<xsl:when test="number(VATRate) &gt; 0 and normalize-space(replace(../../InvoiceParties/SellerParty/VATRegNumber,'-',''))">S</xsl:when>
								<xsl:otherwise>Z</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<cac:TaxSubtotal>
							<cbc:TaxableAmount>
								<xsl:attribute name="currencyID"><xsl:value-of select="../../PaymentInfo/Currency"/></xsl:attribute>
								<xsl:choose>
									<xsl:when test="normalize-space(SumBeforeVAT)">
										<xsl:value-of select="format-number(sum(../VAT[current-grouping-key()=VATRate]/SumBeforeVAT), '#######0.00')"/>
										<!--<xsl:value-of select="format-number(SumBeforeVAT, '#######0.00')"/>-->
									</xsl:when>
									<xsl:when test="normalize-space(../InvoiceSum)">
										<xsl:value-of select="format-number(../InvoiceSum, '#######0.00')"/>
									</xsl:when>
									<xsl:when test="sum(../VAT[current-grouping-key()=VATRate]/VATSum)!=0">
										<xsl:value-of select="format-number(sum(../VAT[current-grouping-key()=VATRate]/VATSum) * 100 div VATRate, '#######0.00')"/>
									</xsl:when>
									<xsl:when test="sum(current-grouping-key())=0 and count(../VAT)=1 and normalize-space(../TotalSum)">
									<xsl:value-of select="../TotalSum"/>
									</xsl:when>
									<xsl:otherwise>0.00</xsl:otherwise>
								</xsl:choose>
							</cbc:TaxableAmount>
							<cbc:TaxAmount>
								<xsl:attribute name="currencyID"><xsl:value-of select="../../PaymentInfo/Currency"/></xsl:attribute>
								<xsl:choose>
									<xsl:when test="normalize-space(VATSum)">
										<xsl:value-of select="format-number(sum(../VAT[current-grouping-key()=VATRate]/VATSum), '#######0.00')"/>
										<!--<xsl:value-of select="format-number(VATSum, '#######0.00')"/>-->
									</xsl:when>
									<xsl:otherwise>0.00</xsl:otherwise>
								</xsl:choose>
							</cbc:TaxAmount>
							<cac:TaxCategory>
								<cbc:ID>
									<!--<xsl:attribute name="schemeID">UNCL5305</xsl:attribute>-->
									<xsl:value-of select="$taxCode"/>
								</cbc:ID>
								<xsl:if test="$taxCode!='O'">
									<cbc:Percent>
										<xsl:choose>
											<xsl:when test="normalize-space(VATRate)">
												<xsl:value-of select="format-number(VATRate,'#0.0')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>0.0</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</cbc:Percent>
								</xsl:if>
								<xsl:if test="$taxCode='O'">
									<cbc:TaxExemptionReasonCode>
										<xsl:text>vatex-eu-o</xsl:text>
									</cbc:TaxExemptionReasonCode>
								</xsl:if>
								<cac:TaxScheme>
									<cbc:ID>VAT</cbc:ID>
								</cac:TaxScheme>
							</cac:TaxCategory>
						</cac:TaxSubtotal>
						<!--</xsl:for-each>-->
					</xsl:for-each-group>
				</xsl:when>
				<xsl:when test="normalize-space(InvoiceSumGroup[1]/TotalToPay) and normalize-space(InvoiceSumGroup[1]/InvoiceSum)">
					<xsl:if test="number(replace(InvoiceSumGroup[1]/TotalToPay,',','.')) - number(replace(InvoiceSumGroup[1]/InvoiceSum,',','.')) = 0">
						<xsl:variable name="taxCode">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(replace(InvoiceParties/SellerParty/VATRegNumber,'-','')))=0">O</xsl:when>
								<xsl:when test="string-length(normalize-space(replace(InvoiceParties/SellerParty/VATRegNumber,'-','')))>0">Z</xsl:when>
							</xsl:choose>
						</xsl:variable>
						<cac:TaxSubtotal>
							<cbc:TaxableAmount>
								<xsl:attribute name="currencyID"><xsl:value-of select="PaymentInfo/Currency"/></xsl:attribute>
								<xsl:value-of select="format-number(InvoiceSumGroup[1]/InvoiceSum, '#######0.00')"/>
							</cbc:TaxableAmount>
							<cbc:TaxAmount>
								<xsl:attribute name="currencyID"><xsl:value-of select="PaymentInfo/Currency"/></xsl:attribute>
								<xsl:text>0.00</xsl:text>
							</cbc:TaxAmount>
							<cac:TaxCategory>
								<cbc:ID>
									<xsl:value-of select="$taxCode"/>
								</cbc:ID>
								<xsl:if test="$taxCode!='O'">
									<cbc:Percent>
										<xsl:choose>
											<xsl:when test="normalize-space(VATRate)">
												<xsl:value-of select="format-number(VATRate,'#0.0')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:text>0.0</xsl:text>
											</xsl:otherwise>
										</xsl:choose>
									</cbc:Percent>
								</xsl:if>
								<xsl:if test="$taxCode='O'">
									<cbc:TaxExemptionReasonCode>
										<xsl:text>vatex-eu-o</xsl:text>
									</cbc:TaxExemptionReasonCode>
								</xsl:if>
								<cac:TaxScheme>
									<cbc:ID>VAT</cbc:ID>
								</cac:TaxScheme>
							</cac:TaxCategory>
						</cac:TaxSubtotal>
					</xsl:if>
				</xsl:when>
				<xsl:when test="normalize-space(InvoiceSumGroup[1]/TotalSum) and normalize-space(InvoiceSumGroup[1]/InvoiceSum)">
					<xsl:if test="number(replace(InvoiceSumGroup[1]/TotalSum,',','.')) - number(replace(InvoiceSumGroup[1]/InvoiceSum,',','.')) = 0">
						<xsl:variable name="taxCode">
							<xsl:choose>
								<xsl:when test="string-length(normalize-space(replace(InvoiceParties/SellerParty/VATRegNumber,'-','')))=0">O</xsl:when>
								<xsl:when test="string-length(normalize-space(replace(InvoiceParties/SellerParty/VATRegNumber,'-','')))>0">Z</xsl:when>
							</xsl:choose>
						</xsl:variable>
						<cac:TaxSubtotal>
							<cbc:TaxableAmount>
								<xsl:attribute name="currencyID"><xsl:value-of select="PaymentInfo/Currency"/></xsl:attribute>
								<xsl:value-of select="format-number(InvoiceSumGroup[1]/InvoiceSum, '#######0.00')"/>
							</cbc:TaxableAmount>
							<cbc:TaxAmount>
								<xsl:attribute name="currencyID"><xsl:value-of select="PaymentInfo/Currency"/></xsl:attribute>
								<xsl:text>0.00</xsl:text>
							</cbc:TaxAmount>
							<cac:TaxCategory>
								<cbc:ID>
									<xsl:value-of select="$taxCode"/>
								</cbc:ID>
								<xsl:if test="$taxCode!='O'">
									<cbc:Percent>
										<xsl:choose>
											<xsl:when test="normalize-space(VATRate)">
												<xsl:value-of select="format-number(VATRate,'#0.0')"/>
											</xsl:when>
											<xsl:otherwise>0.00</xsl:otherwise>
										</xsl:choose>
									</cbc:Percent>
								</xsl:if>
								<xsl:if test="$taxCode='O'">
									<cbc:TaxExemptionReasonCode>
										<xsl:text>vatex-eu-o</xsl:text>
									</cbc:TaxExemptionReasonCode>
								</xsl:if>
								<cac:TaxScheme>
									<cbc:ID>VAT</cbc:ID>
								</cac:TaxScheme>
							</cac:TaxCategory>
						</cac:TaxSubtotal>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</cac:TaxTotal>
		<cac:LegalMonetaryTotal>
			<cbc:LineExtensionAmount>
				<xsl:attribute name="currencyID"><xsl:value-of select="PaymentInfo/Currency"/></xsl:attribute>
				<xsl:choose>
					<xsl:when test="InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/SumBeforeVAT and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/SumBeforeVAT) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)])">
						<xsl:value-of select="format-number(round(100 *sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(round(100 * xs:decimal(SumBeforeVAT)) div 100))) div 100,'#######0.00')"/>
					</xsl:when>
					<xsl:when test="InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/ItemSum and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/ItemSum) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)])">
						<xsl:value-of select="format-number(sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/ItemSum) + abs(sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/Addition[@addCode='CHR']/AddSum)) - abs(sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/Addition[@addCode='DSC']/AddSum)) ,'#######0.00')"/>
					</xsl:when>
					<xsl:when test="normalize-space(InvoiceSumGroup[1]/InvoiceSum)">
						<xsl:value-of select="format-number(round(100 * xs:decimal(InvoiceSumGroup[1]/InvoiceSum)) div 100,'#######0.00')"/>
					</xsl:when>
					<xsl:when test="InvoiceSumGroup[1]/VAT/SumBeforeVAT[normalize-space(.)]">
						<xsl:value-of select="format-number(sum(InvoiceSumGroup[1]/VAT/SumBeforeVAT),'#######0.00')"/>
					</xsl:when>
					<xsl:when test="normalize-space(InvoiceSumGroup[1]/TotalSum)">
						<xsl:value-of select="format-number(InvoiceSumGroup[1]/TotalSum,'#######0.00')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(PaymentInfo/PaymentTotalSum,'#######0.00')"/>
					</xsl:otherwise>
				</xsl:choose>
			</cbc:LineExtensionAmount>
			<cbc:TaxExclusiveAmount>
				<xsl:attribute name="currencyID"><xsl:value-of select="PaymentInfo/Currency"/></xsl:attribute>
				<xsl:choose>
					<xsl:when test="InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/SumBeforeVAT and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/SumBeforeVAT) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)])">
						<xsl:value-of select="format-number(round(100 * sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(round(100 * xs:decimal(SumBeforeVAT)) div 100))) div 100,'#######0.00')"/>
					</xsl:when>
					<xsl:when test="InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/ItemSum and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/ItemSum) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)])">
						<xsl:value-of select="format-number(sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/ItemSum) + abs(sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/Addition[@addCode='CHR']/AddSum)) - abs(sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/Addition[@addCode='DSC']/AddSum)),'#######0.00')"/>
					</xsl:when>
					<xsl:when test="InvoiceSumGroup[1]/VAT/SumBeforeVAT">
						<xsl:value-of select="format-number(sum(InvoiceSumGroup[1]/VAT/SumBeforeVAT),'#######0.00')"/>
					</xsl:when>
					<xsl:when test="InvoiceSumGroup[1]/TotalSum">
						<xsl:value-of select="format-number(InvoiceSumGroup[1]/TotalSum,'#######0.00')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(PaymentInfo/PaymentTotalSum,'#######0.00')"/>
					</xsl:otherwise>
				</xsl:choose>
			</cbc:TaxExclusiveAmount>
			<cbc:TaxInclusiveAmount>
				<xsl:attribute name="currencyID"><xsl:value-of select="PaymentInfo/Currency"/></xsl:attribute>
				<xsl:choose>
					<xsl:when test="count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[normalize-space(VATRate)]/SumBeforeVAT) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)])">
						<xsl:value-of select="format-number(round(100 * (sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(round(100 * xs:decimal(SumBeforeVAT)) div 100 * xs:decimal(VATRate) div 100)) + sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(round(100 * xs:decimal(SumBeforeVAT)) div 100)))) div 100,'#######0.00')"/>
					</xsl:when>
					<!--					<xsl:when test="InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/SumAfterVAT and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/SumAfterVAT) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)])">
						<xsl:value-of select="format-number(sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/SumAfterVAT),'#######0.00')"/><xsl:text>TaxInclusiveAmount_test1</xsl:text>
					</xsl:when>-->
					<xsl:when test="InvoiceSumGroup[1]/TotalSum">
						<xsl:value-of select="format-number(InvoiceSumGroup[1]/TotalSum,'#######0.00')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(PaymentInfo/PaymentTotalSum,'#######0.00')"/>
					</xsl:otherwise>
				</xsl:choose>
			</cbc:TaxInclusiveAmount>
			<cbc:PrepaidAmount>
				<xsl:attribute name="currencyID"><xsl:value-of select="PaymentInfo/Currency"/></xsl:attribute>
					<xsl:choose>
							<xsl:when test="InvoiceInformation/Type/@type='CRE' and normalize-space(InvoiceSumGroup[1]/TotalSum) and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[normalize-space(VATRate)]/SumBeforeVAT) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]) and number(replace(InvoiceSumGroup[1]/TotalSum,',','.')) - (sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(xs:decimal(format-number(SumBeforeVAT,'#######0.00'))*VATRate div 100))+sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(xs:decimal(format-number(SumBeforeVAT,'#######0.00'))))) !=0">
								<xsl:value-of select="format-number(round(100 * (sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(round(100 * xs:decimal(SumBeforeVAT)) div 100 * xs:decimal(VATRate) div 100)) + sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(round(100 * xs:decimal(SumBeforeVAT)) div 100)))) div 100 - xs:decimal(replace(InvoiceSumGroup[1]/TotalSum,',','.')),'#######0.00')"/>
							</xsl:when>
							<xsl:when test="InvoiceInformation/Type/@type='CRE' and normalize-space(InvoiceSumGroup[1]/TotalToPay)  and normalize-space(InvoiceSumGroup[1]/TotalSum) and number(InvoiceSumGroup[1]/TotalToPay)=0">
								<xsl:text>0.00</xsl:text>
							</xsl:when>
					<xsl:when test="normalize-space(InvoiceSumGroup[1]/TotalToPay) and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[normalize-space(VATRate)]/SumBeforeVAT) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]) and number(replace(InvoiceSumGroup[1]/TotalToPay,',','.')) - (sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(xs:decimal(format-number(SumBeforeVAT,'#######0.00'))*VATRate div 100))+sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(xs:decimal(format-number(SumBeforeVAT,'#######0.00'))))) !=0">
						<xsl:value-of select="format-number(round(100 * (sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(round(100 * xs:decimal(SumBeforeVAT)) div 100 * xs:decimal(VATRate) div 100)) + sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(round(100 * xs:decimal(SumBeforeVAT)) div 100)))) div 100 - xs:decimal(replace(InvoiceSumGroup[1]/TotalToPay,',','.')),'#######0.00')"/>
					</xsl:when>
					<xsl:when test="not(InvoiceSumGroup[1]/TotalToPay) and normalize-space(PaymentInfo/PaymentTotalSum) and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[normalize-space(VATRate)]/SumBeforeVAT) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]) and number(replace(PaymentInfo/PaymentTotalSum,',','.')) - (sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(xs:decimal(format-number(SumBeforeVAT,'#######0.00'))*VATRate div 100))+sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(xs:decimal(format-number(SumBeforeVAT,'#######0.00'))))) !=0">
						<xsl:value-of select="format-number(round(100 * (sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(round(100 * xs:decimal(SumBeforeVAT)) div 100 * xs:decimal(VATRate) div 100)) + sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(round(100 * xs:decimal(SumBeforeVAT)) div 100)))) div 100 - xs:decimal(replace(PaymentInfo/PaymentTotalSum,',','.')),'#######0.00')"/>
					</xsl:when>
					<xsl:when test="not(InvoiceSumGroup[1]/TotalToPay) and count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[normalize-space(VATRate)]/SumBeforeVAT) = count(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]) and normalize-space(InvoiceSumGroup[1]/TotalSum) and number(replace(InvoiceSumGroup[1]/TotalSum,',','.')) - (sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(xs:decimal(format-number(SumBeforeVAT,'#######0.00'))*VATRate div 100))+sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(xs:decimal(format-number(SumBeforeVAT,'#######0.00'))))) !=0">
						<xsl:value-of select="format-number((sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(xs:decimal(format-number(SumBeforeVAT,'#######0.00'))*VATRate div 100))+sum(InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/(xs:decimal(format-number(SumBeforeVAT,'#######0.00'))))) - number(InvoiceSumGroup[1]/TotalSum) ,'#######0.00') "/>
					</xsl:when>
					<xsl:when test="normalize-space(InvoiceSumGroup[1]/TotalToPay) and normalize-space(InvoiceSumGroup[1]/TotalSum) and number(replace(InvoiceSumGroup[1]/TotalToPay,',','.')) - number(InvoiceSumGroup[1]/TotalSum) !=0">
							<xsl:value-of select="format-number(number(replace(InvoiceSumGroup[1]/TotalSum,',','.')) - number(replace(InvoiceSumGroup[1]/TotalToPay,',','.')) ,'#######0.00') "/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>0.00</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</cbc:PrepaidAmount>
			<cbc:PayableRoundingAmount>
				<xsl:attribute name="currencyID"><xsl:value-of select="PaymentInfo/Currency"/></xsl:attribute>
				<!--				<xsl:choose>
					<xsl:when test="normalize-space(InvoiceSumGroup[1]/Rounding)">
						<xsl:value-of select="format-number(number(InvoiceSumGroup[1]/Rounding),'#######0.00')"/>
					</xsl:when>
					<xsl:when test=""></xsl:when>
					<xsl:otherwise>-->
				<xsl:text>0.00</xsl:text>
				<!--					</xsl:otherwise>
				</xsl:choose>-->
			</cbc:PayableRoundingAmount>
			<cbc:PayableAmount>
				<xsl:attribute name="currencyID"><xsl:value-of select="PaymentInfo/Currency"/></xsl:attribute>
				<!--<xsl:value-of select="format-number(PaymentInfo/PaymentTotalSum,'#######0.00')"/>-->
				<xsl:choose>
					<xsl:when test="(InvoiceInformation/Type/@type='CRE' and (not(InvoiceSumGroup[1]/Rounding) or number(InvoiceSumGroup[1]/Rounding)=0) and InvoiceSumGroup[1]/TotalSum)">
						<xsl:value-of select="format-number(InvoiceSumGroup[1]/TotalSum,'#######0.00')"/>
					</xsl:when>
					<xsl:when test="(InvoiceInformation/Type/@type='CRE' and InvoiceSumGroup[1]/Rounding and InvoiceSumGroup[1]/TotalSum and InvoiceSumGroup[1]/TotalToPay)">
						<xsl:choose>
							<xsl:when test="number(InvoiceSumGroup[1]/TotalToPay)=0"><xsl:value-of select="format-number(InvoiceSumGroup[1]/TotalSum,'#######0.00')"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="format-number(number(translate(InvoiceSumGroup[1]/TotalToPay,',','.')),'#######0.00')"/></xsl:otherwise>
						</xsl:choose>	
					</xsl:when>
					<xsl:when test="InvoiceSumGroup[1]/TotalToPay">
						<xsl:value-of select="format-number(number(translate(InvoiceSumGroup[1]/TotalToPay,',','.')),'#######0.00')"/>
					</xsl:when>
					<xsl:when test="PaymentInfo/PaymentTotalSum">
						<xsl:value-of select="format-number(PaymentInfo/PaymentTotalSum,'#######0.00')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(InvoiceSumGroup[1]/TotalSum,'#######0.00')"/>
					</xsl:otherwise>
				</xsl:choose>
			</cbc:PayableAmount>
		</cac:LegalMonetaryTotal>
		<xsl:for-each select="InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)][normalize-space(ItemSum) or normalize-space(ItemTotal) or normalize-space(VAT)]">
			<!--<cac:InvoiceLine>-->
			<xsl:variable name="itemPrice">
				<xsl:choose>
					<xsl:when test="normalize-space(ItemDetailInfo[1]/ItemPrice)">
						<xsl:value-of select="format-number(ItemDetailInfo[1]/ItemPrice,'#######0.00##')"/>
					</xsl:when>
					<xsl:when test="normalize-space(ItemSum)">
						<xsl:value-of select="format-number(ItemSum,'#######0.00##')"/>
					</xsl:when>
					<xsl:when test="normalize-space(VAT/SumBeforeVAT)">
						<xsl:value-of select="format-number(VAT/SumBeforeVAT,'#######0.00##')"/>
					</xsl:when>
					<xsl:when test="normalize-space(ItemTotal)">
						<xsl:value-of select="format-number(ItemTotal,'#######0.00##')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>0.00</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="itemPriceSign">
				<xsl:choose>
					<xsl:when test="$itemPrice &lt; 0">-1</xsl:when>
					<xsl:when test="../../../InvoiceInformation/Type/@type='DEB' and normalize-space(ItemTotal) and number(ItemTotal) &lt; 0">-1</xsl:when>
					<xsl:when test="../../../InvoiceInformation/Type/@type='DEB' and normalize-space(ItemSum) and number(ItemSum) &lt; 0">-1</xsl:when>
					<xsl:when test="../../../InvoiceInformation/Type/@type='DEB' and normalize-space(VAT/SumBeforeVAT) and number(VAT/SumBeforeVAT) &lt; 0">-1</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="rowAmount">
				<xsl:choose>
					<xsl:when test="VAT/SumBeforeVAT">
						<xsl:value-of select="format-number(round(100 * VAT/SumBeforeVAT) div 100,'#######0.00')"/>
					</xsl:when>
					<xsl:when test="ItemSum">
						<xsl:value-of select="format-number(ItemSum + abs(sum(Addition[@addCode='CHR']/AddSum)) - abs(sum(Addition[@addCode='DSC']/AddSum)),'#######0.00') "/>
					</xsl:when>
					<xsl:when test="ItemTotal">
						<xsl:value-of select="format-number(ItemTotal,'#######0.00')"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:element name="{$LineNote}">
				<cbc:ID>
					<xsl:value-of select="position()"/>
				</cbc:ID>
				<xsl:if test="../../../emk_BLOKK/emk_AdrInx='PAGERO'">
					<xsl:if test="normalize-space(CustomerRef)">
						<cbc:Note>
							<xsl:value-of select="CustomerRef"/>
						</cbc:Note>
					</xsl:if>
				</xsl:if>
				<xsl:if test="../../../InvoiceInformation/Type/@type='DEB'">
					<cbc:InvoicedQuantity>
						<xsl:attribute name="unitCode">EA</xsl:attribute>
						<xsl:choose>
							<xsl:when test="normalize-space(ItemDetailInfo[1]/ItemAmount) and normalize-space(ItemDetailInfo[1]/ItemPrice)">
								<xsl:value-of select="format-number($itemPriceSign * abs(ItemDetailInfo[1]/ItemAmount),'#######0.00##')"/>
							</xsl:when>
							<xsl:when test="$rowAmount = 0">0.00</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="format-number($itemPriceSign * 1,'#######0.00##')"/>
							</xsl:otherwise>
						</xsl:choose>
					</cbc:InvoicedQuantity>
				</xsl:if>
				<xsl:if test="../../../InvoiceInformation/Type/@type='CRE'">
					<cbc:CreditedQuantity>
						<xsl:attribute name="unitCode">EA</xsl:attribute>
						<xsl:choose>
							<xsl:when test="normalize-space(ItemDetailInfo[1]/ItemAmount)">
								<xsl:value-of select="format-number($itemPriceSign * ItemDetailInfo[1]/ItemAmount,'#######0.00##')"/>
							</xsl:when>
							<xsl:when test="$rowAmount = 0">0.00</xsl:when>
							<xsl:otherwise>
								<xsl:text>-1.00</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</cbc:CreditedQuantity>
				</xsl:if>
				<cbc:LineExtensionAmount>
					<xsl:attribute name="currencyID"><xsl:value-of select="../../../PaymentInfo/Currency"/></xsl:attribute>
					<xsl:value-of select="$rowAmount"/>
				</cbc:LineExtensionAmount>
				<xsl:for-each select="Accounting/JournalEntry">
					<cbc:AccountingCost>
						<xsl:if test="normalize-space(GeneralLedger)">
							<xsl:text>GeneralLedger:</xsl:text>
							<xsl:value-of select="GeneralLedger"/>
							<xsl:text>;</xsl:text>
						</xsl:if>
						<xsl:for-each select="CostObjective/*">
							<xsl:choose>
								<xsl:when test="name(.)='_VatCode' or name(.)='AccountingDate' or name(.)='PurchaseLedger' "/>
								<xsl:otherwise>
									<xsl:if test="normalize-space(.)">
										<xsl:value-of select="name(.)"/>
										<xsl:text>:</xsl:text>
										<xsl:value-of select="."/>
										<xsl:text>;</xsl:text>
									</xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</cbc:AccountingCost>
				</xsl:for-each>
				<xsl:if test="normalize-space(../../../InvoiceInformation/Extension[@extensionId='PurchaseOrder']/InformationContent) or normalize-space(CustomerRef)">
					<cac:OrderLineReference>
						<xsl:choose>
							<xsl:when test="normalize-space(../../../InvoiceInformation/Extension[@extensionId='PurchaseOrder']/InformationContent)">
								<cbc:LineID>
									<xsl:value-of select="../../../InvoiceInformation/Extension[@extensionId='PurchaseOrder']/InformationContent"/>
								</cbc:LineID>
							</xsl:when>
							<xsl:when test="normalize-space(CustomerRef)">
								<cbc:LineID>
									<xsl:value-of select="position()"/>
								</cbc:LineID>
								<cac:OrderReference>
									<cbc:ID>1</cbc:ID>
									<cbc:SalesOrderID>
										<xsl:value-of select="CustomerRef"/>
									</cbc:SalesOrderID>
								</cac:OrderReference>
							</xsl:when>
						</xsl:choose>
					</cac:OrderLineReference>
				</xsl:if>
				<!--				<xsl:if test="VAT/VATSum">
				<cac:TaxTotal>
					<cbc:TaxAmount>
					<xsl:attribute name="currencyID"><xsl:value-of select="../../../PaymentInfo/Currency"/></xsl:attribute><xsl:value-of select="VAT/VATSum"/></cbc:TaxAmount>
				</cac:TaxTotal>
				</xsl:if>-->
				<xsl:for-each select="Addition[@addCode='DSC']">
					<cac:AllowanceCharge>
						<cbc:ChargeIndicator>false</cbc:ChargeIndicator>
						<cbc:AllowanceChargeReason>
							<xsl:if test="normalize-space(AddRate)">
								<xsl:value-of select="format-number(AddRate,'#######0')"/>
								<xsl:text>% </xsl:text>
							</xsl:if>
							<xsl:value-of select="AddContent"/>
						</cbc:AllowanceChargeReason>
						<cbc:Amount>
							<xsl:attribute name="currencyID"><xsl:value-of select="../../../../PaymentInfo/Currency"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="normalize-space(AddSum)">
									<xsl:if test="../../../../InvoiceInformation/Type/@type='CRE' and ../ItemDetailInfo[1]/ItemAmount&lt;0">
										<xsl:text>-</xsl:text>
									</xsl:if>
									<xsl:value-of select="format-number(abs(AddSum),'#######0.00')"/>
								</xsl:when>
								<xsl:when test="normalize-space(AddRate) and normalize-space(../ItemDetailInfo[1]/ItemAmount) and normalize-space(../ItemDetailInfo[1]/ItemPrice)">
									<xsl:value-of select="format-number(AddRate * ../ItemDetailInfo[1]/ItemAmount * ../ItemDetailInfo[1]/ItemPrice  div 100,'#######0.00')"/>
								</xsl:when>
								<xsl:otherwise>0.00</xsl:otherwise>
							</xsl:choose>
						</cbc:Amount>
					</cac:AllowanceCharge>
				</xsl:for-each>
				<xsl:for-each select="Addition[@addCode='CHR']">
					<cac:AllowanceCharge>
						<cbc:ChargeIndicator>true</cbc:ChargeIndicator>
						<cbc:AllowanceChargeReason>
							<xsl:if test="normalize-space(AddRate)">
								<xsl:value-of select="format-number(AddRate,'#######0')"/>
								<xsl:text>% </xsl:text>
							</xsl:if>
							<xsl:value-of select="AddContent"/>
						</cbc:AllowanceChargeReason>
						<cbc:Amount>
							<xsl:attribute name="currencyID"><xsl:value-of select="../../../../PaymentInfo/Currency"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="normalize-space(AddSum)">
									<xsl:value-of select="format-number(abs(AddSum),'#######0.00')"/>
								</xsl:when>
								<xsl:when test="normalize-space(AddRate) and normalize-space(../ItemDetailInfo[1]/ItemAmount) and normalize-space(../ItemDetailInfo[1]/ItemPrice)">
									<xsl:value-of select="format-number(AddRate * ../ItemDetailInfo[1]/ItemAmount * ../ItemDetailInfo[1]/ItemPrice  div 100,'#######0.00')"/>
								</xsl:when>
								<xsl:otherwise>0.00</xsl:otherwise>
							</xsl:choose>
						</cbc:Amount>
					</cac:AllowanceCharge>
				</xsl:for-each>
				<cac:Item>
					<!--<cbc:Description><xsl:value-of select="Description"/></cbc:Description>-->
					<cbc:Name>
						<xsl:value-of select="Description"/>
					</cbc:Name>
					<xsl:if test="normalize-space(SellerProductId)">
						<cac:SellersItemIdentification>
							<cbc:ID>
								<xsl:value-of select="SellerProductId"/>
							</cbc:ID>
						</cac:SellersItemIdentification>
					</xsl:if>
					
					<xsl:if test="normalize-space(EAN)">
						<cac:CommodityClassification>
						<cbc:ItemClassificationCode listID='EN'>
								<xsl:value-of select="EAN"/>
						</cbc:ItemClassificationCode>
						</cac:CommodityClassification>
					</xsl:if>					
					
					<xsl:variable name="taxCode">
						<xsl:choose>
							<xsl:when test="VAT/@vatId='TAX' and number(VAT/VATRate) &gt; 0">S</xsl:when>
							<xsl:when test="count(../../../InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[@vatId='TAXEX' or @vatId='NOTTAX'])=count(../../../InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]) or ( string-length(normalize-space(replace(../../../InvoiceParties/SellerParty/VATRegNumber,'-','')))=0)">O</xsl:when>
							<xsl:when test="number(VAT/VATRate) = 0 and string-length(normalize-space(replace(../../../InvoiceParties/SellerParty/VATRegNumber,'-','')))>0">Z</xsl:when>
							<xsl:when test="number(VAT/VATRate) &gt; 0 and normalize-space(replace(../../../InvoiceParties/SellerParty/VATRegNumber,'-',''))">S</xsl:when>
							<xsl:when test="../../../InvoiceSumGroup/VAT[1]/@vatId='TAX' and number(../../../InvoiceSumGroup/VAT[1]/VATRate) &gt; 0">S</xsl:when>
							<xsl:when test="count(../../../InvoiceSumGroup/VAT[@vatId='TAXEX' or @vatId='NOTTAX'])=count(../../../InvoiceSumGroup/VAT) and string-length(normalize-space(replace(../../../InvoiceParties/SellerParty/VATRegNumber,'-','')))=0">O</xsl:when>
							<xsl:when test="count(../../../InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT/@vatId) = count(../../../InvoiceItem/InvoiceItemGroup/ItemEntry[not(@printLevel)]/VAT[@vatId!='TAX']) and count(../../../InvoiceSumGroup/VAT[@vatId='TAXEX' or @vatId='NOTTAX'])=1 and count(../../../InvoiceSumGroup/VAT[@vatId='TAX'])=0">O</xsl:when>
							<xsl:when test="count(../../../InvoiceSumGroup/VAT[@vatId='TAXEX' or @vatId='NOTTAX'])=count(../../../InvoiceSumGroup/VAT) and string-length(normalize-space(replace(../../../InvoiceParties/SellerParty/VATRegNumber,'-','')))>0">Z</xsl:when>
							<xsl:when test="number(../../../InvoiceSumGroup/VAT[1]/VATRate) = 0 and string-length(normalize-space(replace(../../../InvoiceParties/SellerParty/VATRegNumber,'-','')))>0">Z</xsl:when>
							<xsl:when test="number(../../../InvoiceSumGroup/VAT[1]/VATRate) &gt; 0 and normalize-space(replace(../../../InvoiceParties/SellerParty/VATRegNumber,'-',''))">S</xsl:when>
							<xsl:otherwise>Z</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!--<xsl:if test="VAT/VATRate">-->
					<cac:ClassifiedTaxCategory>
						<cbc:ID>
							<xsl:value-of select="$taxCode"/>
						</cbc:ID>
						<xsl:if test="$taxCode!='O'">
							<cbc:Percent>
								<xsl:choose>
									<xsl:when test="normalize-space(VAT/VATRate)">
										<xsl:value-of select="format-number(VAT/VATRate,'#0.0')"/>
									</xsl:when>
									<xsl:when test="normalize-space(../../../InvoiceSumGroup/VAT[1]/VATRate)">
										<xsl:value-of select="format-number(../../../InvoiceSumGroup/VAT[1]/VATRate,'#0.0')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>0.00</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</cbc:Percent>
						</xsl:if>
						<cac:TaxScheme>
							<cbc:ID>VAT</cbc:ID>
						</cac:TaxScheme>
					</cac:ClassifiedTaxCategory>
					<xsl:if test="../@groupId">
					<cac:AdditionalItemProperty>
						<cbc:Name>InvoiceItemGroupId</cbc:Name>
						<cbc:Value><xsl:value-of select="../@groupId"/></cbc:Value>
					</cac:AdditionalItemProperty>
					</xsl:if>
					<!--</xsl:if>-->
				</cac:Item>
				<cac:Price>
					<cbc:PriceAmount>
						<xsl:attribute name="currencyID"><xsl:value-of select="../../../PaymentInfo/Currency"/></xsl:attribute>
						<xsl:value-of select="replace($itemPrice,'-','')"/>
					</cbc:PriceAmount>
					<cbc:BaseQuantity>
						<xsl:attribute name="unitCode">EA</xsl:attribute>
						<xsl:text>1</xsl:text>
					</cbc:BaseQuantity>
				</cac:Price>
				<!--</cac:InvoiceLine>-->
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="getSchemaID">
		<xsl:param name="input"/>
		<xsl:variable name="countryCode" select="substring($input,1,2)"/>
		<xsl:choose>
			<xsl:when test="$countryCode='EE'">
				<xsl:value-of select="'0191'"/>
			</xsl:when>
			<xsl:when test="$countryCode='FI'">
				<xsl:value-of select="'0037'"/>
			</xsl:when>
			<xsl:when test="$countryCode='PL'">
				<xsl:value-of select="'9945'"/>
			</xsl:when>
			<xsl:when test="$countryCode='SE'">
				<xsl:value-of select="'9955'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>0191</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
