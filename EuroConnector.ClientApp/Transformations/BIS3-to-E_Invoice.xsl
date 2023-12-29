<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon" exclude-result-prefixes="xsi cbc cac fitek" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:fitek="java:oc.tools.Validators">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
	<!--<xsl:variable name="prefix">BEA</xsl:variable>-->
	<xsl:param name="prefix"/>
	<xsl:param name="copyAttachment" select="'false'"/>
	<!--<xsl:param name="copyAttachment" select="'true'"/>-->
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="local-name(/*)='emk_SS_klALG'">
				<xsl:apply-templates select="emk_SS_klALG/emk_ALG"/>
			</xsl:when>
			<xsl:when test="local-name(/*)='Invoice' or local-name(/*)='CreditNote'">
				<xsl:call-template name="E_Invoice"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="emk_ALG">
		<xsl:call-template name="E_Invoice"/>
	</xsl:template>
	<xsl:template name="E_Invoice">
		<E_Invoice xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="itella_e-invoice.xsd">
			<xsl:call-template name="Header"/>
			<xsl:apply-templates select="*:Invoice"/>
			<xsl:apply-templates select="*:CreditNote"/>
			<xsl:call-template name="Footer"/>
		</E_Invoice>
	</xsl:template>
	<xsl:template name="Header">
		<Header>
			<Date>
				<xsl:value-of select="substring(string(current-date()),1,10)"/>
			</Date>
			<FileId>
			<xsl:choose>
				<xsl:when test="//cbc:UUID"><xsl:value-of select="//cbc:UUID"/></xsl:when>
				<xsl:when test="node()/cbc:ID"><xsl:value-of select="substring(node()/cbc:ID,1,20)"/></xsl:when>
			</xsl:choose>
			</FileId>
			<Version>1.2</Version>
			<ReceiverId/>
			<ContractId/>
			<PayeeAccountNumber/>
		</Header>
	</xsl:template>
	<xsl:template name="Footer">
		<Footer>
			<TotalNumberInvoices>
				<xsl:value-of select="count(*:Invoice)+count(*:CreditNote)"/>
			</TotalNumberInvoices>
			<TotalAmount>
				<xsl:value-of select="format-number(sum(*:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount)+sum(*:CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount),'############0.00')"/>
			</TotalAmount>
		</Footer>
	</xsl:template>
	<xsl:template match="*:Invoice">
		<Invoice>
			<xsl:attribute name="invoiceId"><xsl:value-of select="./cbc:ID"/></xsl:attribute>
			<xsl:attribute name="serviceId"><xsl:value-of select="../emk_BLOKK/emk_OID"/></xsl:attribute>
			<xsl:attribute name="regNumber"><xsl:choose><xsl:when test="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID)"><xsl:value-of select="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID)"/></xsl:when><xsl:when test="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID)"><xsl:value-of select="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID)"/></xsl:when></xsl:choose></xsl:attribute>
			<xsl:attribute name="sellerRegnumber"><xsl:choose><xsl:when test="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID)"><xsl:value-of select="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID)"/></xsl:when><xsl:when test="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID)"><xsl:value-of select="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID)"/></xsl:when></xsl:choose></xsl:attribute>
			<xsl:attribute name="languageId">
				<xsl:choose>
					<xsl:when test="lower-case(cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)='ee'">
						<xsl:value-of select="'et'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="lower-case(cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>			
			<xsl:if test="normalize-space(../emk_BLOKK)">
				<xsl:call-template name="emk_fields"/>
				<xsl:if test="$prefix='MPD'">
					<xsl:call-template name="MPDF_dfc_BLOKK"/>
				</xsl:if>
				<xsl:if test="$prefix='BEA'">
					<xsl:call-template name="BEA_dfc_BLOKK"/>
				</xsl:if>
			</xsl:if>
			<InvoiceParties>
				<xsl:apply-templates select="cac:AccountingSupplierParty/cac:Party"/>
				<xsl:apply-templates select="cac:AccountingCustomerParty/cac:Party"/>
				<xsl:apply-templates select="cac:Delivery"/>
			</InvoiceParties>
			<xsl:call-template name="create_InvoiceInformation"/>
			<xsl:call-template name="create_InvoiceSumGroup"/>
			<InvoiceItem>
				<xsl:for-each-group select="cac:InvoiceLine" group-by="cac:Item/cac:AdditionalItemProperty[cbc:Name='InvoiceItemGroupId']/cbc:Value">
					<InvoiceItemGroup>
						<xsl:attribute name="groupId" select="current-grouping-key()"/>
						<xsl:apply-templates select="current-group()"/>
					</InvoiceItemGroup>	
				</xsl:for-each-group>
			
				<xsl:if test="cac:InvoiceLine[not(cac:Item/cac:AdditionalItemProperty[cbc:Name='InvoiceItemGroupId']/cbc:Value)] or cac:AllowanceCharge">
					<InvoiceItemGroup>
						<xsl:apply-templates select="cac:InvoiceLine[not(cac:Item/cac:AdditionalItemProperty[cbc:Name='InvoiceItemGroupId']/cbc:Value)]"/>
						<xsl:apply-templates select="cac:AllowanceCharge"/>
					</InvoiceItemGroup>
				</xsl:if>
			</InvoiceItem>
			<xsl:call-template name="createAdditionalAttachments"/>
			<xsl:call-template name="create_AttachmentFile"/>
			<xsl:call-template name="create_PaymentInfo"/>
			<xsl:apply-templates select="*[local-name()='TechnicalData']"/>
		</Invoice>
	</xsl:template>
	<xsl:template match="*:CreditNote">
		<Invoice>
			<xsl:attribute name="invoiceId"><xsl:value-of select="./cbc:ID"/></xsl:attribute>
			<xsl:attribute name="serviceId"><xsl:value-of select="../emk_BLOKK/emk_OID"/></xsl:attribute>
			<xsl:attribute name="regNumber"><xsl:choose><xsl:when test="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID)"><xsl:value-of select="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID)"/></xsl:when><xsl:when test="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID)"><xsl:value-of select="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID)"/></xsl:when></xsl:choose></xsl:attribute>
			<xsl:attribute name="sellerRegnumber"><xsl:choose><xsl:when test="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID)"><xsl:value-of select="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID)"/></xsl:when><xsl:when test="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID)"><xsl:value-of select="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID)"/></xsl:when></xsl:choose></xsl:attribute>
			<xsl:attribute name="languageId">
				<xsl:choose>
					<xsl:when test="lower-case(cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)='ee'">
						<xsl:value-of select="'et'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="lower-case(cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:if test="normalize-space(../emk_BLOKK)">
				<xsl:call-template name="emk_fields"/>
				<xsl:if test="$prefix='MPD'">
					<xsl:call-template name="MPDF_dfc_BLOKK"/>
				</xsl:if>
				<xsl:if test="$prefix='BEA'">
					<xsl:call-template name="BEA_dfc_BLOKK"/>
				</xsl:if>
			</xsl:if>
			<InvoiceParties>
				<xsl:apply-templates select="cac:AccountingSupplierParty/cac:Party"/>
				<xsl:apply-templates select="cac:AccountingCustomerParty/cac:Party"/>
			</InvoiceParties>
			<xsl:call-template name="create_InvoiceInformation"/>
			<xsl:call-template name="create_InvoiceSumGroup"/>
			<InvoiceItem>
				<xsl:for-each-group select="cac:CreditNoteLine" group-by="cac:Item/cac:AdditionalItemProperty[cbc:Name='InvoiceItemGroupId']/cbc:Value">
					<InvoiceItemGroup>
						<xsl:attribute name="groupId" select="current-grouping-key()"/>
						<xsl:apply-templates select="current-group()"/>
					</InvoiceItemGroup>	
				</xsl:for-each-group>
			
				<xsl:if test="cac:CreditNoteLine[not(cac:Item/cac:AdditionalItemProperty[cbc:Name='InvoiceItemGroupId']/cbc:Value)] or cac:AllowanceCharge">
					<InvoiceItemGroup>
						<xsl:apply-templates select="cac:CreditNoteLine[not(cac:Item/cac:AdditionalItemProperty[cbc:Name='InvoiceItemGroupId']/cbc:Value)]"/>
						<xsl:apply-templates select="cac:AllowanceCharge"/>
					</InvoiceItemGroup>
				</xsl:if>			
			</InvoiceItem>
			<xsl:call-template name="createAdditionalAttachments"/>
			<xsl:call-template name="create_AttachmentFile"/>
			<xsl:call-template name="create_PaymentInfo"/>
		</Invoice>
	</xsl:template>
	<xsl:template name="emk_fields">
		<emk_BLOKK>
			<emk_OID>
				<xsl:value-of select="../emk_BLOKK/emk_OID"/>
			</emk_OID>
			<emk_Doc_type>
				<xsl:value-of select="../emk_BLOKK/emk_Doc_type"/>
			</emk_Doc_type>
			<emk_Payee_ID>
				<xsl:value-of select="../emk_BLOKK/emk_Payee_ID"/>
			</emk_Payee_ID>
			<emk_AdrINX>
				<xsl:value-of select="../emk_BLOKK/emk_AdrINX"/>
			</emk_AdrINX>
			<emk_ElepTyyp>
				<xsl:value-of select="../emk_BLOKK/emk_ElepTyyp"/>
			</emk_ElepTyyp>
			<emk_ElepNimi>
				<xsl:value-of select="../emk_BLOKK/emk_ElepNimi"/>
			</emk_ElepNimi>
			<emk_ElepAdrType>
				<xsl:value-of select="../emk_BLOKK/emk_ElepAdrType"/>
			</emk_ElepAdrType>
			<emk_ElepAdr>
				<xsl:value-of select="../emk_BLOKK/emk_ElepAdr"/>
			</emk_ElepAdr>
			<emk_OwnerIK>
				<xsl:value-of select="../emk_BLOKK/emk_OwnerIK"/>
			</emk_OwnerIK>
			<emk_XFC_Proxy_id>
				<xsl:value-of select="../emk_BLOKK/emk_XFC_Proxy_id"/>
			</emk_XFC_Proxy_id>
			<emk_infoSTRING>
				<xsl:value-of select="concat(../emk_BLOKK/emk_infoSTRING,'printAdr=PayerParty/MailAddress#')"/>
			</emk_infoSTRING>
			<emk_pankSTRING>
				<xsl:value-of select="../emk_BLOKK/emk_pankSTRING"/>
			</emk_pankSTRING>
			<emk_GlobInvID>
				<xsl:value-of select="../emk_BLOKK/emk_GlobInvID"/>
			</emk_GlobInvID>
			<emk_TOS>
				<xsl:value-of select="../emk_BLOKK/emk_TOS"/>
			</emk_TOS>
			<emk_Packet>
				<xsl:value-of select="../emk_BLOKK/emk_Packet"/>
			</emk_Packet>
			<emk_Imagefile>
				<!--<xsl:value-of select="concat(*:TechnicalData/*:PdfFile,'#',*:TechnicalData/*:StartPage,'#',*:TechnicalData/*:EndPage)"/>-->
				<xsl:choose>
					<xsl:when test="*:TechnicalData/*:PdfFile!=''">
						<xsl:value-of select="concat(*:TechnicalData/*:PdfFile,'#',*:TechnicalData/*:StartPage,'#',*:TechnicalData/*:EndPage)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="''"/>
					</xsl:otherwise>
				</xsl:choose>
			</emk_Imagefile>
		</emk_BLOKK>
	</xsl:template>
	<!--  MPDF-->
	<xsl:template name="MPDF_dfc_BLOKK">
		<dfc_BLOKK>
			<dfc_Field>DFC_BEGINRECORDS</dfc_Field>
			<dfc_Field>DFC_NUMFIELDS:16</dfc_Field>
			<dfc_Field>DFC_DOCTYPENAME:"MPDFInvoice"</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_SYSTEMID:&quot;',../emk_BLOKK/emk_Payee_ID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_PRN:&quot;',PRN,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_InvoiceNumber:&quot;',cbc:ID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_Payer:&quot;',cac:PartyName/cbc:Name,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_Amount:&quot;',cac:LegalMonetaryTotal/cbc:PayableAmount,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_InvoiceDate:&quot;',cbc:IssueDate,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:choose>
					<xsl:when test="normalize-space(cbc:DueDate)">
						<xsl:value-of select="concat('DFC_DueDate:&quot;',cbc:DueDate,'&quot;')"/>
					</xsl:when>
					<xsl:when test="normalize-space(cac:PaymentMeans/cbc:PaymentDueDate)">
						<xsl:value-of select="concat('DFC_DueDate:&quot;',cac:PaymentMeans/cbc:PaymentDueDate,'&quot;')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('DFC_DueDate:&quot;',cbc:IssueDate,'&quot;')"/>
					</xsl:otherwise>
				</xsl:choose>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_PayerUtilityNumber:&quot;',../emk_BLOKK/emk_OID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_CurrencyCode:&quot;',cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_GlobInvID:&quot;',../emk_BLOKK/emk_GlobInvID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_MPDFInvoiceNumber:&quot;',cbc:ID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_EBillCode:&quot;',../emk_BLOKK/emk_ElepTyyp,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_EBill:&quot;',../emk_BLOKK/emk_ElepNimi,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_EBillAdr:&quot;',../emk_BLOKK/emk_ElepAdr,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_OwnerIk:&quot;',../emk_BLOKK/emk_OwnerIK,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_Email:&quot;',../emk_BLOKK/emk_ElepAdr,'&quot;')"/>
			</dfc_Field>
		</dfc_BLOKK>
	</xsl:template>
	<!--  BEA-->
	<xsl:template name="BEA_dfc_BLOKK">
		<dfc_BLOKK>
			<dfc_Field>DFC_BEGINRECORDS</dfc_Field>
			<dfc_Field>DFC_NUMFIELDS:21</dfc_Field>
			<dfc_Field>DFC_DOCTYPENAME:B2BInvoice</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_SYSTEMID:&quot;',../emk_BLOKK/emk_Payee_ID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_InvoiceNumber:&quot;',cbc:ID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_B2BInvoiceNumber:&quot;',cbc:ID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_CurrencyCode:&quot;',cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_Amount:&quot;',cac:LegalMonetaryTotal/cbc:PayableAmount,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_InvoiceDate:&quot;',cbc:IssueDate,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:choose>
					<xsl:when test="normalize-space(cbc:DueDate)">
						<xsl:value-of select="concat('DFC_DueDate:&quot;',cbc:DueDate,'&quot;')"/>
					</xsl:when>
					<xsl:when test="normalize-space(cac:PaymentMeans/cbc:PaymentDueDate)">
						<xsl:value-of select="concat('DFC_DueDate:&quot;',cac:PaymentMeans/cbc:PaymentDueDate,'&quot;')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('DFC_DueDate:&quot;',cbc:IssueDate,'&quot;')"/>
					</xsl:otherwise>
				</xsl:choose>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_PayerUtilityNumber:&quot;',../emk_BLOKK/emk_OID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_PRN:&quot;','&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_GlobInvID:&quot;',../emk_BLOKK/emk_GlobInvID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_AdrINX:&quot;',../emk_BLOKK/emk_AdrINX,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_TypeOfSource:&quot;',../emk_BLOKK/emk_TOS,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_ProxyID:&quot;',../emk_BLOKK/emk_XFC_Proxy_id,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_OwnerIk:&quot;',../emk_BLOKK/emk_OwnerIK,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_EBillCode:&quot;',../emk_BLOKK/emk_ElepTyyp,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_EBill:&quot;',../emk_BLOKK/emk_ElepNimi,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_EBillAdr:&quot;',../emk_BLOKK/emk_ElepAdr,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_EBillAdrType:&quot;',../emk_BLOKK/emk_ElepAdrType,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_SuppAccount:&quot;',cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cbc:ID,'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:value-of select="concat('DFC_SuppVATNumber:&quot;',(cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID)[0],'&quot;')"/>
			</dfc_Field>
			<dfc_Field>
				<xsl:choose>
					<xsl:when test="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID)">
						<xsl:value-of select="concat('DFC_SuppRegCode:&quot;',cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID,'&quot;')"/>
					</xsl:when>
					<xsl:when test="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID)">
						<xsl:value-of select="concat('DFC_SuppRegCode:&quot;',cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID,'&quot;')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>DFC_SuppRegCode:&quot;&quot;</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</dfc_Field>
		</dfc_BLOKK>
	</xsl:template>
	<xsl:template match="cac:AccountingSupplierParty/cac:Party">
		<SellerParty>
			<xsl:if test="cac:PartyIdentification/cbc:ID">
				<xsl:choose>
					<xsl:when test="contains(upper-case(cac:PartyIdentification[1]/cbc:ID/@schemeID),'GLN')">
						<GLN>
							<xsl:value-of select="cac:PartyIdentification[1]/cbc:ID"/>
						</GLN>
					</xsl:when>
					<xsl:otherwise>
						<UniqueCode>
							<xsl:value-of select="substring(cac:PartyIdentification[1]/cbc:ID,1,20)"/>
						</UniqueCode>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<Name>
			<xsl:choose>
				<xsl:when test="normalize-space(cac:PartyName/cbc:Name)"><xsl:value-of select="cac:PartyName/cbc:Name"/></xsl:when>
				<xsl:when test="normalize-space(cac:PartyLegalEntity/cbc:RegistrationName)"><xsl:value-of select="cac:PartyLegalEntity/cbc:RegistrationName"/></xsl:when>
			</xsl:choose>
			</Name>
			<xsl:choose>
				<xsl:when test="normalize-space(cac:PartyLegalEntity/cbc:CompanyID)">
					<RegNumber>
						<xsl:value-of select="normalize-space(cac:PartyLegalEntity/cbc:CompanyID)"/>
					</RegNumber>
				</xsl:when>
				<xsl:when test="normalize-space(cac:PartyIdentification/cbc:ID)">
					<RegNumber>
						<xsl:value-of select="normalize-space(cac:PartyIdentification/cbc:ID)"/>
					</RegNumber>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="normalize-space(cac:PartyTaxScheme[cac:TaxScheme/cbc:ID='VAT']/cbc:CompanyID)">
					<VATRegNumber>
						<xsl:value-of select="normalize-space(cac:PartyTaxScheme[cac:TaxScheme/cbc:ID='VAT']/cbc:CompanyID)"/>
					</VATRegNumber>
				</xsl:when>
				<xsl:when test="contains(upper-case(cbc:EndpointID/@schemeID),'VAT')">
					<VATRegNumber>
						<xsl:value-of select="cbc:EndpointID"/>
					</VATRegNumber>
				</xsl:when>
			</xsl:choose>
			<ContactData>
				<xsl:if test="normalize-space(cac:Contact/cbc:Name)">
					<ContactName>
						<xsl:value-of select="cac:Contact/cbc:Name"/>
					</ContactName>
				</xsl:if>
				<xsl:if test="normalize-space(cac:Contact/cbc:ElectronicMail)">
					<E-mailAddress>
						<xsl:value-of select="cac:Contact/cbc:ElectronicMail"/>
					</E-mailAddress>
				</xsl:if>
				<LegalAddress>
					<PostalAddress1>
						<xsl:value-of select="cac:PostalAddress/cbc:StreetName"/>
					</PostalAddress1>
					<xsl:if test="normalize-space(cac:PostalAddress/cbc:AdditionalStreetName)">
						<PostalAddress2>
							<xsl:value-of select="cac:PostalAddress/cbc:AdditionalStreetName"/>
						</PostalAddress2>
					</xsl:if>
					<City>
						<xsl:value-of select="cac:PostalAddress/cbc:CityName"/>
					</City>
					<PostalCode>
						<xsl:value-of select="substring(cac:PostalAddress/cbc:PostalZone,1,10)"/>
					</PostalCode>
					<xsl:if test="cac:PostalAddress/cac:Country/cbc:IdentificationCode">
						<Country>
							<xsl:value-of select="cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
						</Country>
					</xsl:if>
				</LegalAddress>
			</ContactData>
			<xsl:for-each select="../../cac:PaymentMeans">
				<!--<xsl:if test="cac:PayeeFinancialAccount/cbc:ID[@schemeID='IBAN']">-->
					<xsl:if test="normalize-space(replace(cac:PayeeFinancialAccount/cbc:ID,'\[\]',''))">
						<AccountInfo>
							<AccountNumber>
								<xsl:call-template name="fixBankAccount">
									<xsl:with-param name="AccountNumber">
										<xsl:value-of select="cac:PayeeFinancialAccount/cbc:ID"/>
									</xsl:with-param>
								</xsl:call-template>
							</AccountNumber>
							<xsl:if test="normalize-space(replace(cac:PayeeFinancialAccount/cbc:ID[@schemeID='IBAN'],'\[\]',''))">
								<IBAN>
									<xsl:value-of select="cac:PayeeFinancialAccount/cbc:ID[@schemeID='IBAN']"/>
								</IBAN>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="normalize-space(replace(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cac:FinancialInstitution/cbc:ID[@schemeID='BIC'],'\[\]',''))">
									<BIC>
										<xsl:value-of select="cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cac:FinancialInstitution/cbc:ID[@schemeID='BIC']"/>
									</BIC>
								</xsl:when>
								<xsl:when test="normalize-space(replace(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID,'\[\]',''))">
									<BIC>
										<xsl:value-of select="cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID"/>
									</BIC>
								</xsl:when>
							</xsl:choose>
						</AccountInfo>
					</xsl:if>
			</xsl:for-each>
		</SellerParty>
	</xsl:template>
	<xsl:template match="cac:AccountingCustomerParty/cac:Party">
		<BuyerParty>
			<xsl:if test="cac:PartyIdentification/cbc:ID">
				<xsl:choose>
					<xsl:when test="contains(upper-case(cac:PartyIdentification/cbc:ID/@schemeID),'GLN')">
						<GLN>
							<xsl:value-of select="cac:PartyIdentification/cbc:ID"/>
						</GLN>
					</xsl:when>
					<xsl:otherwise>
						<UniqueCode>
							<xsl:value-of select="substring(cac:PartyIdentification/cbc:ID,1,20)"/>
						</UniqueCode>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<Name>
			<xsl:choose>
				<xsl:when test="normalize-space(cac:PartyName/cbc:Name)"><xsl:value-of select="cac:PartyName/cbc:Name"/></xsl:when>
				<xsl:when test="normalize-space(cac:PartyLegalEntity/cbc:RegistrationName)"><xsl:value-of select="cac:PartyLegalEntity/cbc:RegistrationName"/></xsl:when>			
			</xsl:choose>
			</Name>
			<xsl:choose>
				<xsl:when test="normalize-space(cac:PartyLegalEntity/cbc:CompanyID)">
					<RegNumber>
						<xsl:value-of select="normalize-space(cac:PartyLegalEntity/cbc:CompanyID)"/>
					</RegNumber>
				</xsl:when>
				<xsl:when test="normalize-space(cac:PartyIdentification/cbc:ID)">
					<RegNumber>
						<xsl:value-of select="normalize-space(cac:PartyIdentification/cbc:ID)"/>
					</RegNumber>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="cac:PartyTaxScheme/cac:TaxScheme/cbc:ID='VAT'">
					<VATRegNumber>
						<xsl:value-of select="normalize-space(cac:PartyTaxScheme[cac:TaxScheme/cbc:ID='VAT']/cbc:CompanyID)"/>
					</VATRegNumber>
				</xsl:when>
				<xsl:when test="contains(upper-case(cbc:EndpointID/@schemeID),'VAT')">
					<VATRegNumber>
						<xsl:value-of select="cbc:EndpointID"/>
					</VATRegNumber>
				</xsl:when>
			</xsl:choose>
			<ContactData>
				<xsl:if test="normalize-space(cac:Contact/cbc:Name)">
					<ContactName>
						<xsl:value-of select="cac:Contact/cbc:Name"/>
					</ContactName>
				</xsl:if>
				<xsl:if test="normalize-space(cac:Contact/cbc:ElectronicMail)">
					<E-mailAddress>
						<xsl:value-of select="cac:Contact/cbc:ElectronicMail"/>
					</E-mailAddress>
				</xsl:if>
				<LegalAddress>
					<PostalAddress1>
						<xsl:value-of select="cac:PostalAddress/cbc:StreetName"/>
					</PostalAddress1>
					<xsl:if test="normalize-space(cac:PostalAddress/cbc:AdditionalStreetName)">
						<PostalAddress2>
							<xsl:value-of select="cac:PostalAddress/cbc:AdditionalStreetName"/>
						</PostalAddress2>
					</xsl:if>
					<City>
						<xsl:value-of select="cac:PostalAddress/cbc:CityName"/>
					</City>
					<PostalCode>
						<xsl:value-of select="substring(cac:PostalAddress/cbc:PostalZone,1,10)"/>
					</PostalCode>
					<xsl:if test="cac:PostalAddress/cac:Country/cbc:IdentificationCode">
						<Country>
							<xsl:value-of select="cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
						</Country>
					</xsl:if>
				</LegalAddress>
			</ContactData>
		</BuyerParty>
	</xsl:template>
	<xsl:template match="cac:Delivery">
		<DeliveryParty>		
			<Name>
				<xsl:choose>
					<xsl:when test="normalize-space(cac:DeliveryParty/cac:PartyName/cbc:Name)"><xsl:value-of select="cac:DeliveryParty/cac:PartyName/cbc:Name"/></xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="../cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name"/>
					</xsl:otherwise>
				</xsl:choose>	
			</Name>
			<xsl:if test="normalize-space(cac:DeliveryLocation/cbc:ID)">
				<RegNumber>
					<xsl:value-of select="normalize-space(cac:DeliveryLocation/cbc:ID)"/>
				</RegNumber>
			</xsl:if>
			<xsl:if test="cac:DeliveryLocation/cac:Address">
				<ContactData>
					<LegalAddress>
						<PostalAddress1>
							<xsl:value-of select="cac:DeliveryLocation/cac:Address/cbc:StreetName"/>
						</PostalAddress1>
						<xsl:if test="normalize-space(cac:DeliveryLocation/cac:Address/cbc:AdditionalStreetName)">
							<PostalAddress2>
								<xsl:value-of select="cac:DeliveryLocation/cac:Address/cbc:AdditionalStreetName"/>
							</PostalAddress2>
						</xsl:if>
						<xsl:if test="cac:DeliveryLocation/cac:Address/cbc:CityName">
							<City>
								<xsl:value-of select="cac:DeliveryLocation/cac:Address/cbc:CityName"/>
							</City>
						</xsl:if>
						<xsl:if test="cac:DeliveryLocation/cac:Address/cbc:PostalZone">
							<PostalCode>
								<xsl:value-of select="substring(cac:DeliveryLocation/cac:Address/cbc:PostalZone,1,10)"/>
							</PostalCode>
						</xsl:if>
						<xsl:if test="cac:DeliveryLocation/cac:Address/cac:Country/cbc:IdentificationCode">
							<Country>
								<xsl:value-of select="cac:DeliveryLocation/cac:Address/cac:Country/cbc:IdentificationCode"/>
							</Country>
						</xsl:if>
					</LegalAddress>
				</ContactData>
			</xsl:if>
		</DeliveryParty>
	</xsl:template>
	<xsl:template name="create_InvoiceInformation">
		<InvoiceInformation>
			<Type>
				<xsl:attribute name="type">
					<xsl:choose>
						<xsl:when test="cbc:CreditNoteTypeCode = '381' or cbc:CreditNoteTypeCode = '396' or cbc:CreditNoteTypeCode = '532' or cbc:CreditNoteTypeCode = '81' or cbc:CreditNoteTypeCode= '83' or cbc:InvoiceTypeCode='381'">CRE</xsl:when>
						<xsl:otherwise>DEB</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</Type>
			<xsl:if test="cac:OrderReference/cbc:ID">
				<ContractNumber>
					<xsl:value-of select="substring(cac:OrderReference/cbc:ID,1,100)"/>
				</ContractNumber>
			</xsl:if>
			<DocumentName>
				<xsl:choose>
					<xsl:when test="cbc:InvoiceTypeCode='80'">Debit note related to goods or services</xsl:when>
					<xsl:when test="cbc:InvoiceTypeCode='82'">Metered services invoice</xsl:when>
					<xsl:when test="cbc:InvoiceTypeCode='84'">Debit note related to financial adjustments</xsl:when>
					<xsl:when test="cbc:InvoiceTypeCode='380'">Commercial invoice</xsl:when>
					<xsl:when test="cbc:InvoiceTypeCode='383'">Debit note</xsl:when>
					<xsl:when test="cbc:InvoiceTypeCode='386'">Prepayment invoice</xsl:when>
					<xsl:when test="cbc:InvoiceTypeCode='393'">Factored invoice</xsl:when>
					<xsl:when test="cbc:InvoiceTypeCode='395'">Consignment invoice</xsl:when>
					<xsl:when test="cbc:InvoiceTypeCode='575'">Insurer's invoice</xsl:when>
					<xsl:when test="cbc:InvoiceTypeCode='623'">Forwarder's invoice</xsl:when>
					<xsl:when test="cbc:InvoiceTypeCode='780'">Freight invoice</xsl:when>
					<xsl:when test="cbc:CreditNoteTypeCode='81'">Credit note related to goods or services</xsl:when>
					<xsl:when test="cbc:CreditNoteTypeCode='83'">Credit note related to financial adjustments</xsl:when>
					<xsl:when test="cbc:CreditNoteTypeCode='381'">Credit note</xsl:when>
					<xsl:when test="cbc:InvoiceTypeCode='381'">Credit note</xsl:when>
					<xsl:when test="cbc:CreditNoteTypeCode='396'">Factored credit note</xsl:when>
					<xsl:when test="cbc:CreditNoteTypeCode='532'">Forwarder’s credit note</xsl:when>
					<xsl:otherwise>Invoice</xsl:otherwise>
				</xsl:choose>
			</DocumentName>
			<InvoiceNumber>
				<xsl:value-of select="cbc:ID"/>
			</InvoiceNumber>
			<xsl:if test="cbc:BuyerReference">
				<InvoiceContentCode>
					<xsl:value-of select="substring(cbc:BuyerReference,1,20)"/>
				</InvoiceContentCode>
			</xsl:if>
			<xsl:variable name="refno">
				<xsl:choose>
					<xsl:when test="cac:PaymentMeans[1]/cbc:PaymentID">
						<xsl:if test="fitek:ValidateReferenceNo(cac:PaymentMeans[1]/cbc:PaymentID,cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cbc:id)">
							<xsl:value-of select="cac:PaymentMeans[1]/cbc:PaymentID"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="cac:PaymentMeans[1]/cbc:InstructionID">
						<xsl:if test="fitek:ValidateReferenceNo(cac:PaymentMeans[1]/cbc:InstructionID,cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cbc:id)">
							<xsl:value-of select="cac:PaymentMeans[1]/cbc:InstructionID"/>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="normalize-space($refno)">
				<PaymentReferenceNumber>
					<xsl:value-of select="$refno"/>
				</PaymentReferenceNumber>
			</xsl:if>
			<xsl:if test="normalize-space(cac:PaymentMeans[1]/cbc:PaymentMeansCode) or normalize-space(cac:PaymentMeans[1]/cbc:PaymentMeansCode/@name)">
				<PaymentMethod>
					<xsl:value-of select="cac:PaymentMeans[1]/cbc:PaymentMeansCode"/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select="cac:PaymentMeans[1]/cbc:PaymentMeansCode/@name"/>
				</PaymentMethod>
			</xsl:if>			
			
			<InvoiceDate>
				<xsl:value-of select="cbc:IssueDate"/>
			</InvoiceDate>
			<xsl:choose>
				<xsl:when test="normalize-space(cbc:DueDate)">
					<DueDate>
						<xsl:value-of select="cbc:DueDate"/>
					</DueDate>
				</xsl:when>
				<xsl:when test="normalize-space(cac:PaymentMeans/cbc:PaymentDueDate)">
					<DueDate>
						<xsl:value-of select="cac:PaymentMeans/cbc:PaymentDueDate"/>
					</DueDate>
				</xsl:when>
			</xsl:choose>
			<xsl:if test="cac:PaymentTerms/cbc:Note">
				<PaymentTerm>
					<xsl:value-of select="substring(cac:PaymentTerms/cbc:Note,1,100)"/>
				</PaymentTerm>
			</xsl:if>
			<xsl:if test="cac:InvoicePeriod">
				<Period>
					<StartDate>
						<xsl:value-of select="cac:InvoicePeriod/cbc:StartDate"/>
					</StartDate>
					<EndDate>
						<xsl:value-of select="cac:InvoicePeriod/cbc:EndDate"/>
					</EndDate>
				</Period>
			</xsl:if>
			<xsl:if test="normalize-space(cac:PaymentMeans[1]/cbc:InstructionID)">
				<Extension>
					<InformationName>InstructionID</InformationName>
					<InformationContent>
						<xsl:value-of select="cac:PaymentMeans[1]/cbc:InstructionID"/>
					</InformationContent>
				</Extension>
			</xsl:if>
			<xsl:if test="normalize-space(string-join(cbc:Note))">
				<Extension extensionId="InvNote">
					<InformationContent>
						<xsl:value-of select="normalize-space(substring(string-join(cbc:Note, ' '),1,500))"/>
					</InformationContent>
				</Extension>			
			</xsl:if>
		</InvoiceInformation>
	</xsl:template>
	<xsl:template name="create_InvoiceSumGroup">
		<InvoiceSumGroup>
			<xsl:if test="cac:LegalMonetaryTotal/cbc:PrepaidAmount">
				<Balance>
					<BalanceEnd>
						<xsl:value-of select="cac:LegalMonetaryTotal/cbc:PrepaidAmount"/>
					</BalanceEnd>
				</Balance>
			</xsl:if>
			<InvoiceSum>
					<xsl:value-of select="format-number(cac:LegalMonetaryTotal/cbc:LineExtensionAmount + 
					sum(cac:AllowanceCharge[cbc:ChargeIndicator='true']/cbc:Amount) -
					sum(cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount),'#######0.00')"/>
			</InvoiceSum>
			<!--<InvoiceSum>
				<xsl:value-of select="cac:LegalMonetaryTotal/cbc:LineExtensionAmount"/>
			</InvoiceSum>
			<xsl:for-each select="cac:AllowanceCharge">
				<xsl:if test="normalize-space(cbc:Amount)">
					<Addition>
						<xsl:choose>
							<xsl:when test="cbc:ChargeIndicator='false'">
								<xsl:attribute name="addCode" select="'DSC'"/>
							</xsl:when>
							<xsl:when test="cbc:ChargeIndicator='true'">
								<xsl:attribute name="addCode" select="'CHR'"/>
							</xsl:when>
						</xsl:choose>
						<AddContent>
							<xsl:value-of select="cbc:AllowanceChargeReason"/>
						</AddContent>
						<xsl:if test="normalize-space(cac:TaxCategory/cbc:Percent)">
							<AddRate>
								<xsl:value-of select="cac:TaxCategory/cbc:Percent"/>
							</AddRate>
						</xsl:if>
						<AddSum>
							<xsl:value-of select="format-number(cbc:Amount,'#######0.00')"/>
						</AddSum>					
					</Addition>
				</xsl:if>
			</xsl:for-each>-->						
			<xsl:if test="cac:LegalMonetaryTotal/cbc:PayableRoundingAmount">
				<Rounding>
					<xsl:value-of select="cac:LegalMonetaryTotal/cbc:PayableRoundingAmount"/>
				</Rounding>
			</xsl:if>
			<xsl:for-each select="cac:TaxTotal[1]/cac:TaxSubtotal">
				<VAT>
					<xsl:attribute name="vatId">
						<xsl:choose>
							<xsl:when test="contains(' E K O',concat(' ',cac:TaxCategory/cbc:ID))">
								<xsl:text>TAXEX</xsl:text>
							</xsl:when>
						<xsl:otherwise>
							<xsl:text>TAX</xsl:text>
						</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<SumBeforeVAT>
						<xsl:value-of select="cbc:TaxableAmount"/>
					</SumBeforeVAT>
					<VATRate>
						<xsl:choose>
							<xsl:when test="cac:TaxCategory/cbc:ID='O'">0</xsl:when>
							<xsl:otherwise><xsl:value-of select="cac:TaxCategory/cbc:Percent"/></xsl:otherwise>
						</xsl:choose>
					</VATRate>
					<VATSum>
						<xsl:value-of select="cbc:TaxAmount"/>
					</VATSum>
					<xsl:if test="normalize-space(cac:TaxCategory/cbc:TaxExemptionReason) and contains(' E K O',concat(' ',cac:TaxCategory/cbc:ID))">
						<Reference extensionId="VATNote">
							<InformationContent><xsl:value-of select="cac:TaxCategory/cbc:TaxExemptionReason"/></InformationContent>
						</Reference>
					</xsl:if>
				</VAT>
			</xsl:for-each>			
			<xsl:if test="normalize-space(cac:TaxTotal[1]/cbc:TaxAmount)">
				<TotalVATSum>
					<xsl:value-of select="cac:TaxTotal[1]/cbc:TaxAmount"/>
				</TotalVATSum>	
			</xsl:if>	
			<TotalSum>
				<xsl:value-of select="cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount"/>
			</TotalSum>
			<xsl:if test="not(cbc:CreditNoteTypeCode)">
				<TotalToPay>
					<xsl:value-of select="cac:LegalMonetaryTotal/cbc:PayableAmount"/>
				</TotalToPay>
			</xsl:if>
			<Currency>
				<xsl:value-of select="cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID"/>
			</Currency>
		</InvoiceSumGroup>
	</xsl:template>
	<xsl:template match="cac:InvoiceLine">
		<ItemEntry>
			<RowNo>
				<xsl:value-of select="cbc:ID"/>
			</RowNo>
			<xsl:if test="cac:Item/cac:SellersItemIdentification/cbc:ID !=''">
				<SellerProductId>
					<xsl:value-of select="substring(cac:Item/cac:SellersItemIdentification/cbc:ID,1,20)"/>
				</SellerProductId>
			</xsl:if>
			<xsl:if test="cac:Item/cac:BuyersItemIdentification/cbc:ID !=''">
				<BuyerProductId>
					<xsl:value-of select="substring(cac:Item/cac:BuyersItemIdentification/cbc:ID,1,20)"/>
				</BuyerProductId>
			</xsl:if>
			<Description>
				<xsl:choose>
					<xsl:when test="normalize-space(cac:Item/cbc:Description) and normalize-space(cac:Item/cbc:Name) and normalize-space(cac:Item/cbc:Description)!=normalize-space(cac:Item/cbc:Name)">
						<xsl:value-of select="substring(normalize-space(concat(cac:Item/cbc:Name,', ',cac:Item/cbc:Description)),1,500)"/>
					</xsl:when>
					<xsl:when test="normalize-space(cac:Item/cbc:Description)">
						<xsl:value-of select="substring(cac:Item/cbc:Description,1,500)"/>
					</xsl:when>
					<xsl:when test="normalize-space(cac:Item/cbc:Name)">
						<xsl:value-of select="substring(cac:Item/cbc:Name,1,500)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Teenus/Toode</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</Description>

			<xsl:if test="normalize-space(cbc:Note)">
				<ItemReserve  extensionId="ARTICLE_DESCRIPTIONS">
					<InformationContent>
						<xsl:value-of select="substring(cbc:Note,1,500)"/>
					</InformationContent>
				</ItemReserve>	
			</xsl:if>
					
			<ItemDetailInfo>
				<ItemUnit>
					<xsl:choose>
						<xsl:when test="cac:Price/cbc:BaseQuantity/@unitCode">
							<xsl:call-template name="unitCode">
								<xsl:with-param name="unitCode" select="cac:Price/cbc:BaseQuantity/@unitCode"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="cbc:InvoicedQuantity/@unitCode">
							<xsl:call-template name="unitCode">
								<xsl:with-param name="unitCode" select="cbc:InvoicedQuantity/@unitCode"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>tk2</xsl:otherwise>
					</xsl:choose>
				</ItemUnit>
				<ItemAmount>
					<xsl:value-of select="cbc:InvoicedQuantity"/>
				</ItemAmount>
				<ItemPrice>
					<xsl:choose>
						<xsl:when test="cac:Price/cbc:BaseQuantity">
							<xsl:value-of select="format-number((cac:Price/cbc:PriceAmount) div number (cac:Price/cbc:BaseQuantity),'############0.00##')"/>
						</xsl:when>
						<xsl:when test="cac:Price/cbc:PriceAmount">
							<xsl:value-of select="cac:Price/cbc:PriceAmount"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="cbc:LineExtensionAmount"/>
						</xsl:otherwise>
					</xsl:choose>
				</ItemPrice>
			</ItemDetailInfo>
			<!--		<ItemSum>
		<xsl:choose>
		<xsl:when test="cac:Price/cbc:BaseQuantity"><xsl:value-of select="format-number(((number(cbc:InvoicedQuantity) * (number(cac:Price/cbc:PriceAmount) div number(cac:Price/cbc:BaseQuantity)) + cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount + cac:AllowanceCharge[cbc:ChargeIndicator='true']/cbc:Amount)),'#######0.00')"/></xsl:when>
		<xsl:otherwise><xsl:value-of select="format-number(((number(cbc:InvoicedQuantity) * number(cac:Price/cbc:PriceAmount) + cac:AllowanceCharge[cbc:ChargeIndicator='false']/cbc:Amount + cac:AllowanceCharge[cbc:ChargeIndicator='true']/cbc:Amount)) ,'#######0.00')"/></xsl:otherwise>
		</xsl:choose>		
		</ItemSum>-->
			<xsl:for-each select="cac:AllowanceCharge">
				<Addition>
					<xsl:attribute name="addCode"><!--<xsl:text>DSC</xsl:text>--><xsl:choose><xsl:when test="cbc:ChargeIndicator='true'">CHR</xsl:when><xsl:otherwise>DSC</xsl:otherwise></xsl:choose></xsl:attribute>
					<AddContent>
						<xsl:value-of select="cbc:AllowanceChargeReason"/>
						<xsl:if test="not(cbc:AllowanceChargeReason)">Allowance</xsl:if>
					</AddContent>
					<xsl:if test="cbc:MultiplierFactorNumeric">
						<AddRate>
							<xsl:value-of select="cbc:MultiplierFactorNumeric"/>
						</AddRate>
					</xsl:if>
					<xsl:if test="cbc:Amount">
						<AddSum>
							<xsl:value-of select="cbc:Amount"/>
						</AddSum>
					</xsl:if>
				</Addition>
			</xsl:for-each>
			<xsl:if test="cbc:LineExtensionAmount and cac:Item/cac:ClassifiedTaxCategory/cbc:Percent">
				<VAT>
				<xsl:attribute name="vatId">
						<xsl:choose>
							<xsl:when test="contains(' E K O',concat(' ',cac:Item/cac:ClassifiedTaxCategory/cbc:ID))">
								<xsl:text>TAXEX</xsl:text>
							</xsl:when>
						<xsl:otherwise>
							<xsl:text>TAX</xsl:text>
						</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<SumBeforeVAT>
						<xsl:value-of select="cbc:LineExtensionAmount"/>
					</SumBeforeVAT>
					<VATRate>
						<xsl:value-of select="cac:Item/cac:ClassifiedTaxCategory/cbc:Percent"/>
					</VATRate>
					<VATSum>
						<xsl:value-of select="format-number(number(cbc:LineExtensionAmount) * (number(cac:Item/cac:ClassifiedTaxCategory/cbc:Percent) div 100),'#######0.00')"/>
					</VATSum>
				</VAT>
				<ItemTotal>
					<xsl:value-of select="format-number(number(cbc:LineExtensionAmount) + number(cbc:LineExtensionAmount) * (number(cac:Item/cac:ClassifiedTaxCategory/cbc:Percent) div 100),'#######0.00')"/>
				</ItemTotal>
			</xsl:if>
		</ItemEntry>
	</xsl:template>
	<xsl:template match="cac:CreditNoteLine">
		<ItemEntry>
			<RowNo>
				<xsl:value-of select="cbc:ID"/>
			</RowNo>
			<xsl:if test="cac:Item/cac:SellersItemIdentification/cbc:ID">
				<SellerProductId>
					<xsl:value-of select="cac:Item/cac:SellersItemIdentification/cbc:ID"/>
				</SellerProductId>
			</xsl:if>
			<xsl:if test="cac:Item/cac:BuyersItemIdentification/cbc:ID">
				<BuyerProductId>
					<xsl:value-of select="cac:Item/cac:BuyersItemIdentification/cbc:ID"/>
				</BuyerProductId>
			</xsl:if>
			<Description>
				<xsl:choose>
					<xsl:when test="normalize-space(cac:Item/cbc:Description)">
						<xsl:value-of select="substring(cac:Item/cbc:Description,1,500)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring(cac:Item/cbc:Name,1,500)"/>
					</xsl:otherwise>
				</xsl:choose>
			</Description>
			<ItemDetailInfo>
				<xsl:if test="cac:Price/cbc:BaseQuantity/@unitCode">
					<ItemUnit>
						<xsl:value-of select="cac:Price/cbc:BaseQuantity/@unitCode"/>
					</ItemUnit>
				</xsl:if>
				<ItemAmount>
					<xsl:value-of select="cbc:CreditedQuantity"/>
				</ItemAmount>
				<ItemPrice>
					<xsl:choose>
						<xsl:when test="cac:Price/cbc:BaseQuantity">
							<xsl:value-of select="format-number((cac:Price/cbc:PriceAmount) div number (cac:Price/cbc:BaseQuantity),'############0.00')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="cac:Price/cbc:PriceAmount"/>
						</xsl:otherwise>
					</xsl:choose>
				</ItemPrice>
			</ItemDetailInfo>
			<xsl:for-each select="cac:AllowanceCharge">
				<Addition>
					<xsl:attribute name="addCode"><!--<xsl:text>DSC</xsl:text>--><xsl:choose><xsl:when test="cbc:ChargeIndicator='true'">CHR</xsl:when><xsl:otherwise>DSC</xsl:otherwise></xsl:choose></xsl:attribute>
					<AddContent>
						<xsl:value-of select="cbc:AllowanceChargeReason"/>
						<xsl:if test="not(cbc:AllowanceChargeReason)">Charge</xsl:if>
					</AddContent>
					<xsl:if test="cbc:MultiplierFactorNumeric">
						<AddRate>
							<xsl:value-of select="cbc:MultiplierFactorNumeric"/>
						</AddRate>
					</xsl:if>
					<xsl:if test="cbc:Amount">
						<AddSum>
							<xsl:value-of select="cbc:Amount"/>
						</AddSum>
					</xsl:if>
				</Addition>
			</xsl:for-each>
			<xsl:if test="cbc:LineExtensionAmount and cac:Item/cac:ClassifiedTaxCategory/cbc:Percent">
				<VAT>
					<SumBeforeVAT>
						<xsl:value-of select="cbc:LineExtensionAmount"/>
					</SumBeforeVAT>
					<VATRate>
						<xsl:value-of select="cac:Item/cac:ClassifiedTaxCategory/cbc:Percent"/>
					</VATRate>
					<VATSum>
						<xsl:value-of select="format-number(number(cbc:LineExtensionAmount) * (number(cac:Item/cac:ClassifiedTaxCategory/cbc:Percent) div 100),'#######0.00')"/>
					</VATSum>
				</VAT>
				<ItemTotal>
					<xsl:value-of select="format-number(number(cbc:LineExtensionAmount) + number(cbc:LineExtensionAmount) * (number(cac:Item/cac:ClassifiedTaxCategory/cbc:Percent) div 100),'#######0.00')"/>
				</ItemTotal>
			</xsl:if>
		</ItemEntry>
	</xsl:template>
	<xsl:template match="cac:AllowanceCharge">
	<xsl:variable name="sign">
		<xsl:if test="cbc:ChargeIndicator='false'">
			<xsl:text>-</xsl:text>
		</xsl:if>
	</xsl:variable>
	<xsl:if test="number(cbc:Amount)!=0">
		<ItemEntry>
			<RowNo>
				<xsl:value-of select="max(../cac:InvoiceLine/cbc:ID/number(replace(replace(., ',', '.'), ' ', ''))) + position()"/>		
				<!--<xsl:value-of select="max(../cac:InvoiceLine/cbc:ID) + position()"/>		-->
			</RowNo>
			<Description>
				<xsl:value-of select="substring(cbc:AllowanceChargeReason,1,500)"/>
			</Description>
			<ItemDetailInfo>
				<ItemUnit>
						<xsl:text>tk</xsl:text>
				</ItemUnit>
				<ItemAmount>
					<xsl:value-of select="$sign"/>
					<xsl:text>1</xsl:text>
				</ItemAmount>
				<ItemPrice>
							<xsl:value-of select="format-number(cbc:Amount,'#######0.00')"/>
				</ItemPrice>
			</ItemDetailInfo>

			<xsl:if test="cac:TaxCategory/cbc:Percent">
				<VAT>
					<SumBeforeVAT>
					<xsl:value-of select="$sign"/>
						<xsl:value-of select="format-number(cbc:Amount,'#######0.00')"/>
					</SumBeforeVAT>
					<VATRate>
						<xsl:value-of select="format-number(cac:TaxCategory/cbc:Percent,'#######0.0')"/>
					</VATRate>
					<VATSum>
					<xsl:value-of select="$sign"/>
						<xsl:value-of select="format-number(cbc:Amount * cac:TaxCategory/cbc:Percent div 100,'#######0.00')"/>
					</VATSum>
				</VAT>
				<ItemTotal>
				<xsl:value-of select="$sign"/>
					<xsl:value-of select="format-number(cbc:Amount * cac:TaxCategory/cbc:Percent div 100 + cbc:Amount,'#######0.00')"/>
				</ItemTotal>
			</xsl:if>
		</ItemEntry>
		</xsl:if>
	</xsl:template>
	<xsl:template name="create_PaymentInfo">
		<PaymentInfo>
			<Currency>
				<xsl:value-of select="cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID"/>
			</Currency>
			<xsl:variable name="refno">
				<xsl:choose>
					<xsl:when test="cac:PaymentMeans[1]/cbc:PaymentID">
						<xsl:if test="fitek:ValidateReferenceNo(cac:PaymentMeans[1]/cbc:PaymentID,cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cbc:ID)">
							<xsl:value-of select="cac:PaymentMeans[1]/cbc:PaymentID"/>
						</xsl:if>
					</xsl:when>
					<xsl:when test="cac:PaymentMeans[1]/cbc:InstructionID">
						<xsl:if test="fitek:ValidateReferenceNo(cac:PaymentMeans[1]/cbc:InstructionID,cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cbc:ID)">
							<xsl:value-of select="cac:PaymentMeans[1]/cbc:InstructionID"/>
						</xsl:if>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="normalize-space($refno)">
				<PaymentRefId>
					<xsl:value-of select="cac:PaymentMeans[1]/cbc:PaymentID"/>
				</PaymentRefId>
			</xsl:if>
			<PaymentDescription>
				<xsl:value-of select="concat('Arve number ',cbc:ID)"/>
				<xsl:choose>
					<xsl:when test="not(normalize-space($refno)) and normalize-space(cac:PaymentMeans[1]/cbc:PaymentID) ">
						<xsl:value-of select="concat(' Reference. ',cac:PaymentMeans[1]/cbc:PaymentID)"/>
					</xsl:when>
					<xsl:when test="not(normalize-space($refno)) and normalize-space(cac:PaymentMeans[1]/cbc:InstructionID) ">
						<xsl:value-of select="concat(' Reference. ',cac:PaymentMeans[1]/cbc:InstructionID)"/>
					</xsl:when>
				</xsl:choose>
			</PaymentDescription>
			<Payable>
				<xsl:choose>
					<xsl:when test="contains(name(.),'CreditNote')">NO</xsl:when>
					<xsl:otherwise>YES</xsl:otherwise>
				</xsl:choose>
			</Payable>
			<xsl:choose>
				<xsl:when test="normalize-space(cbc:DueDate)">
					<PayDueDate>
						<xsl:value-of select="cbc:DueDate"/>
					</PayDueDate>
				</xsl:when>
				<xsl:when test="normalize-space(cac:PaymentMeans/cbc:PaymentDueDate)">
					<PayDueDate>
						<xsl:value-of select="cac:PaymentMeans/cbc:PaymentDueDate"/>
					</PayDueDate>
				</xsl:when>
			</xsl:choose>
			<PaymentTotalSum>
				<xsl:choose>
					<xsl:when test="contains(name(.),'CreditNote')">0.00</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="cac:LegalMonetaryTotal/cbc:PayableAmount"/>
					</xsl:otherwise>
				</xsl:choose>
			</PaymentTotalSum>
			<PayerName>
				<xsl:choose>
					<xsl:when test="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name)"><xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name"/></xsl:when>
					<xsl:when test="normalize-space(cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName)"><xsl:value-of select="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/></xsl:when>			
				</xsl:choose>
			</PayerName>
			<PaymentId>
				<xsl:value-of select="cbc:ID"/>
			</PaymentId>
			<PayToAccount>
					<xsl:call-template name="fixBankAccount">
						<xsl:with-param name="AccountNumber">
							<xsl:value-of select="cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cbc:ID"/>
						</xsl:with-param>
					</xsl:call-template>						
			</PayToAccount>
			<PayToName>
				<xsl:choose>
					<xsl:when test="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name)"><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name"/></xsl:when>
					<xsl:when test="normalize-space(cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName)"><xsl:value-of select="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/></xsl:when>
				</xsl:choose>
			</PayToName>
			<xsl:if test="cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cbc:ID[@schemeID='IBAN']/cac:FinancialInstitutionBranch/cbc:ID or cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID">
				<PayToBIC>
					<xsl:choose>
						<xsl:when test="cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cbc:ID[@schemeID='IBAN']/cac:FinancialInstitutionBranch/cbc:ID">
							<xsl:value-of select="cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cbc:ID[@schemeID='IBAN']/cac:FinancialInstitutionBranch/cbc:ID"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID"/>
						</xsl:otherwise>
					</xsl:choose>
					<!--<xsl:value-of select="cac:PaymentMeans[1]/cac:PayeeFinancialAccount/cbc:ID[@schemeID='IBAN']/cac:FinancialInstitutionBranch/cbc:ID"/>-->
				</PayToBIC>
			</xsl:if>
		</PaymentInfo>
	</xsl:template>
	<xsl:template name="createAdditionalAttachments">
		<xsl:if test="$copyAttachment='true'">
			<xsl:for-each select="cac:AdditionalDocumentReference[cbc:DocumentDescription!='Commercial invoice']/cac:Attachment/cbc:EmbeddedDocumentBinaryObject">
			<xsl:choose>
			<xsl:when test="position()=1 and @mimeCode='application/pdf' and count(../../../cac:AdditionalDocumentReference[cbc:DocumentDescription='Commercial invoice']/cac:Attachment/cbc:EmbeddedDocumentBinaryObject)=0"/>
			<xsl:otherwise>
				<AdditionalInformation>
					<xsl:attribute name="extensionId" select="concat(substring-after(@mimeCode,'/'),'_base64')"/>
					<InformationContent></InformationContent>
					<CustomContent>						
						<FileData>
							<xsl:if test="normalize-space(@filename)"></xsl:if>
								<FileName>
									<xsl:value-of select="@filename"/>
								</FileName>
							<FileBase64> 
								<xsl:value-of select="."/>
							</FileBase64>
						</FileData>
					</CustomContent>
				</AdditionalInformation>
				</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>	
	<xsl:template name="create_AttachmentFile">
		<xsl:if test="$copyAttachment='true'">
			<xsl:choose>
				<xsl:when test="cac:AdditionalDocumentReference[cbc:DocumentDescription='Commercial invoice']/cac:Attachment/cbc:EmbeddedDocumentBinaryObject[@mimeCode='application/pdf']">
					<xsl:for-each select="(cac:AdditionalDocumentReference[cbc:DocumentDescription='Commercial invoice']/cac:Attachment/cbc:EmbeddedDocumentBinaryObject[@mimeCode='application/pdf'])[1]">
						<AttachmentFile>
							<xsl:if test="normalize-space(@filename)">
								<FileName>
									<xsl:value-of select="@filename"/>
								</FileName>
							</xsl:if>
						<FileBase64>
							<xsl:value-of select="."/>
						</FileBase64>
					</AttachmentFile>
				</xsl:for-each>
				</xsl:when>
				<xsl:when test="cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject[@mimeCode='application/pdf']">
					<xsl:for-each select="(cac:AdditionalDocumentReference/cac:Attachment/cbc:EmbeddedDocumentBinaryObject[@mimeCode='application/pdf'])[1]">					
					<AttachmentFile>
					<xsl:if test="normalize-space(@filename)">
						<FileName>
							<xsl:value-of select="@filename"/>
						</FileName>
						</xsl:if>
						<FileBase64>
							<xsl:value-of select="."/>
						</FileBase64>
					</AttachmentFile>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<xsl:template name="pankSTRINGvalue">
		<xsl:param name="id"/>
		<xsl:param name="findFrom"/>
		<xsl:variable name="bos">
			<xsl:value-of select="substring-after($findFrom,$id)"/>
		</xsl:variable>
		<xsl:value-of select="substring-before($bos,'#')"/>
	</xsl:template>
	<xsl:template name="unitCode">
		<xsl:param name="unitCode"/>
		<xsl:value-of>
			<xsl:choose>
				<xsl:when test="$unitCode='C62'">
					<xsl:text>tk</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$unitCode"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:value-of>
	</xsl:template>
	<xsl:template match="*[local-name()='TechnicalData']">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@* | node()"/>
		</xsl:element>
	</xsl:template>
	<!-- template to copy attributes -->
	<xsl:template match="@*">
		<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
	<!-- template to copy the rest of the nodes -->
	<xsl:template match="*">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates select="@* | node()"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="fixBankAccount">
		<xsl:param name="AccountNumber"/>
		<xsl:value-of select="translate($AccountNumber,' )(][','')"/>
	</xsl:template>	
	
	
</xsl:stylesheet>
