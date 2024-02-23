<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:ubl="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" >
	<xsl:output version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="uniqId"/>
	<xsl:param name="inputDate" select="5"/>
	<xsl:param name="numberOfDays" select="RET_DOK/I06/I08/I08_MOK_D"/>
	<xsl:param name="TotalAmount" select="0"/>
	<xsl:param name="Total_I07_SUMA" select="0"/>

	<xsl:template match="/">
		<xsl:apply-templates select="RET_DOK"/>
	</xsl:template>

	<xsl:template match="RET_DOK">
		<xsl:for-each select="I06">
<!-- *******************************************************************
Please enter the Supplier requisites as 
fixed values in the "SenderXxxxxxx" variables
************************************************************************ -->
			<xsl:variable name="SenderRegNumber" >
				<xsl:text>123456789</xsl:text>
			</xsl:variable>
			<xsl:variable name="SenderVATNumber" >
				<xsl:text>LT01234567890</xsl:text>
			</xsl:variable>
			<xsl:variable name="SenderName" >
				<xsl:text>Trys paršiukai, UAB</xsl:text>
			</xsl:variable>
			<xsl:variable name="SenderAddress" >
				<xsl:text>Miško g. 123, Giria</xsl:text>
			</xsl:variable>
			<xsl:variable name="SenderCountryCode" >
				<xsl:text>LT</xsl:text>
			</xsl:variable>
<!-- ******************************************************************* -->
			<xsl:variable name="ReceiverCountryCode" >
				<xsl:text>LT</xsl:text>
			</xsl:variable>
			<xsl:variable name="Total_I07_SUMA" select="0"/>


			<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2">
				<xsl:call-template name="XMLBody">
					<xsl:with-param name="SenderRegNumber" select="$SenderRegNumber"/>
					<xsl:with-param name="SenderVATNumber" select="$SenderVATNumber"/>
					<xsl:with-param name="SenderName" select="$SenderName"/>
					<xsl:with-param name="SenderAddress" select="$SenderAddress"/>
					<xsl:with-param name="SenderCountryCode" select="$SenderCountryCode"/>
					<xsl:with-param name="ReceiverCountryCode" select="$ReceiverCountryCode"/>
					<xsl:with-param name="Total_I07_SUMA" select="$Total_I07_SUMA"/>

				</xsl:call-template>
			</Invoice>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="XMLBody">
		<xsl:param name="SenderRegNumber"/>
		<xsl:param name="SenderVATNumber"/>
		<xsl:param name="SenderName"/>
		<xsl:param name="SenderAddress"/>
		<xsl:param name="SenderCountryCode"/>
		<xsl:param name="ReceiverCountryCode"/>
		<xsl:param name="Total_I07_SUMA"/>

		<xsl:variable name="Total_I07_SUMA">
			<xsl:value-of select="sum(I07/I07_SUMA)"/>
		</xsl:variable>



		<cbc:CustomizationID>
			<xsl:text>urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0</xsl:text>
		</cbc:CustomizationID>
		<cbc:ProfileID>urn:fdc:peppol.eu:2017:poacc:billing:01:1.0</cbc:ProfileID>
		<cbc:ID>
			<xsl:value-of select="normalize-space(I06_DOK_NR)"/>
		</cbc:ID>

		<xsl:variable name="yIDate">
			<!--____9.___account date____-->
			<xsl:value-of select="I06_OP_DATA"/>
		</xsl:variable>
		<xsl:variable name="I06_OP_DATA_Date">                                              
			<xsl:value-of select="concat(substring($yIDate,1,4),'-',substring($yIDate,6,2),'-',substring($yIDate,9,2))"/>
		</xsl:variable>


		<xsl:variable name="year" select="substring(I06_OP_DATA, 1, 4)" />
		<xsl:variable name="month" select="substring(I06_OP_DATA, 6, 2)" />
		<xsl:variable name="day" select="substring(I06_OP_DATA, 9, 2)" />
		<xsl:variable name="I06_OP_DATA_DueDate" select="xs:dateTime(concat($year, '-', $month, '-', $day, 'T00:00:00'))" />
		<cbc:IssueDate>
			<xsl:value-of select="$I06_OP_DATA_Date"/>
		</cbc:IssueDate>

		<cbc:DueDate>
			<xsl:variable name="dateWithOffset" select="xs:dateTime($I06_OP_DATA_DueDate) + xs:dayTimeDuration(concat('P', $numberOfDays, 'D'))"/>
			<xsl:value-of select="format-dateTime($dateWithOffset, '[Y0001]-[M01]-[D01]')"/>
		</cbc:DueDate>

		<cbc:InvoiceTypeCode>380</cbc:InvoiceTypeCode>
		<cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>

		<cac:AccountingSupplierParty>
			<xsl:variable name="supplierSchema">
				<xsl:call-template name="getSchemaID">
					<xsl:with-param name="input" select="$SenderCountryCode"/>
				</xsl:call-template>
			</xsl:variable>
			<cac:Party>
				<cbc:EndpointID>
					<xsl:attribute name="schemeID">
						<xsl:value-of select="$supplierSchema"/>
					</xsl:attribute>
					<xsl:value-of select="replace($SenderRegNumber,'-','')"/>
				</cbc:EndpointID>
				<cac:PartyIdentification>
					<cbc:ID>
						<xsl:attribute name="schemeID">
							<xsl:value-of select="$supplierSchema"/>
						</xsl:attribute>
						<xsl:value-of select="replace($SenderRegNumber,'-','')"/>
					</cbc:ID>
				</cac:PartyIdentification>
				<cac:PartyName>
					<cbc:Name>
						<xsl:value-of select="$SenderName" />
					</cbc:Name>
				</cac:PartyName>
				<cac:PostalAddress>
					<cbc:StreetName>
						<xsl:value-of select="$SenderAddress" />
					</cbc:StreetName>
					<cac:Country>
						<cbc:IdentificationCode>
							<xsl:value-of select="$SenderCountryCode" />
						</cbc:IdentificationCode>
					</cac:Country>
				</cac:PostalAddress>

				<xsl:if test="normalize-space($SenderVATNumber)">
					<cac:PartyTaxScheme>
						<cbc:CompanyID>
							<xsl:value-of select="$SenderVATNumber" />
						</cbc:CompanyID>
						<cac:TaxScheme>
							<cbc:ID>VAT</cbc:ID>
						</cac:TaxScheme>
					</cac:PartyTaxScheme>
				</xsl:if>

				<cac:PartyLegalEntity>
					<cbc:RegistrationName>
						<xsl:value-of select="$SenderName" />
					</cbc:RegistrationName>
					<cbc:CompanyID>
						<xsl:value-of select="$SenderRegNumber" />
					</cbc:CompanyID>
				</cac:PartyLegalEntity>
			</cac:Party>
		</cac:AccountingSupplierParty>

		<cac:AccountingCustomerParty>
			<xsl:variable name="companySchema">
				<xsl:call-template name="getSchemaID">
					<xsl:with-param name="input" select="$ReceiverCountryCode"/>
				</xsl:call-template>
			</xsl:variable>
			<cac:Party>
				<cbc:EndpointID>
					<xsl:attribute name="schemeID">
						<xsl:value-of select="$companySchema"/>
					</xsl:attribute>
					<xsl:value-of select="normalize-space(I06_KODAS_KS)"/>
				</cbc:EndpointID>
				<cac:PartyIdentification>
					<cbc:ID>
						<xsl:attribute name="schemeID">
							<xsl:value-of select="$companySchema"/>
						</xsl:attribute>
						<xsl:value-of select="normalize-space(I06_KODAS_KS)"/>
					</cbc:ID>
				</cac:PartyIdentification>
				<cac:PartyName>
					<cbc:Name>
						<xsl:value-of select="normalize-space(I06_PAV)" />
					</cbc:Name>
				</cac:PartyName>
				<cac:PostalAddress>
					<cbc:StreetName>
						<xsl:value-of select="normalize-space(I06_ADR)" />
					</cbc:StreetName>
					<cac:Country>
						<cbc:IdentificationCode>
							<xsl:value-of select="$ReceiverCountryCode" />
						</cbc:IdentificationCode>
					</cac:Country>
				</cac:PostalAddress>

				<cac:PartyLegalEntity>
					<cbc:RegistrationName>
						<xsl:value-of select="normalize-space(I06_PAV)" />
					</cbc:RegistrationName>
					<cbc:CompanyID>
						<xsl:value-of select="normalize-space(I06_KODAS_KS)" />
					</cbc:CompanyID>
				</cac:PartyLegalEntity>
			</cac:Party>
		</cac:AccountingCustomerParty>

		<xsl:variable name="totalMokestis">
			<xsl:value-of select="sum(//I07/I07_MOKESTIS_P)"/>
		</xsl:variable>
		<xsl:variable name="taxCode">
			<xsl:choose>
				<xsl:when test="normalize-space(replace(I06_KODAS_XS,'-',''))='PVM1' ">S</xsl:when>
				<xsl:when test="normalize-space(replace(I06_KODAS_XS,'-',''))='PVM21' ">S</xsl:when>
				<xsl:when test="normalize-space(replace(I06_KODAS_XS,'-',''))='PVM5' ">E</xsl:when>
				<xsl:when test="normalize-space(replace(I06_KODAS_XS,'-',''))='NEPVMOBJEKTAS' ">E</xsl:when>
				<xsl:when test="$totalMokestis=0.00">Z</xsl:when>
				<xsl:otherwise>S</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>


		<cac:TaxTotal>
			<cbc:TaxAmount currencyID="EUR">
				<xsl:value-of select="I06_SUMA_PVM" />
			</cbc:TaxAmount>
			<cac:TaxSubtotal>
				<cbc:TaxableAmount currencyID="EUR">
					<xsl:value-of select="format-number(xs:decimal(normalize-space($Total_I07_SUMA)), '0.00')" />
				</cbc:TaxableAmount>
				<cbc:TaxAmount currencyID="EUR">
					<xsl:value-of select="I06_SUMA_PVM" />
				</cbc:TaxAmount>
				<cac:TaxCategory>
					<cbc:ID>
						<xsl:value-of select="$taxCode" />
					</cbc:ID>
					<cbc:Percent>
						<xsl:value-of select="normalize-space(I07[1]/I07_MOKESTIS_P)" />
					</cbc:Percent>
					<cac:TaxScheme>
						<cbc:ID>VAT</cbc:ID>
					</cac:TaxScheme>
				</cac:TaxCategory>
			</cac:TaxSubtotal>
		</cac:TaxTotal>
		<cac:LegalMonetaryTotal>
			<cbc:LineExtensionAmount currencyID="EUR">
				<xsl:value-of select="format-number(xs:decimal(normalize-space($Total_I07_SUMA)), '0.00')" />
			</cbc:LineExtensionAmount>
			<cbc:TaxExclusiveAmount currencyID="EUR">
				<xsl:value-of select="format-number(xs:decimal(normalize-space($Total_I07_SUMA)), '0.00')" />
			</cbc:TaxExclusiveAmount>
			<cbc:TaxInclusiveAmount currencyID="EUR">
				<xsl:value-of select="I06_SUMA" />
			</cbc:TaxInclusiveAmount>
			<cbc:PayableAmount currencyID="EUR">
				<xsl:value-of select="I06_SUMA" />
			</cbc:PayableAmount>
		</cac:LegalMonetaryTotal>




		<xsl:for-each select="I07">

			<cac:InvoiceLine>    
				<cbc:ID>
					<xsl:value-of select="normalize-space(I07_EIL_NR)" />
				</cbc:ID>
				<cbc:InvoicedQuantity unitCode="H87">
					<xsl:value-of select="normalize-space(I07_KIEKIS)" />
				</cbc:InvoicedQuantity>
				<cbc:LineExtensionAmount currencyID="EUR">
					<xsl:value-of select="normalize-space(I07_SUMA)" />
				</cbc:LineExtensionAmount>
				<cac:Item>
					<cbc:Description>
						<xsl:value-of select="normalize-space(I07_PAV)" />
					</cbc:Description>
					<cbc:Name>
						<xsl:value-of select="normalize-space(I07_aprasymas2)" />
					</cbc:Name>
					<cac:ClassifiedTaxCategory>
						<cbc:Percent>
							<xsl:value-of select="normalize-space(I07_MOKESTIS_P)" />
						</cbc:Percent>
						<cac:TaxScheme>
							<cbc:ID>VAT</cbc:ID>
						</cac:TaxScheme>
					</cac:ClassifiedTaxCategory>
				</cac:Item>
				<cac:Price>
					<cbc:PriceAmount currencyID="EUR">
						<xsl:value-of select="format-number(xs:decimal(normalize-space(I07_KAINA_BE)), '0.00')" />
					</cbc:PriceAmount>
				</cac:Price>
			</cac:InvoiceLine>
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
				<xsl:text>0200</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
