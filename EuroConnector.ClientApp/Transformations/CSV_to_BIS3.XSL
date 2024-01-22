<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
    xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
    xpath-default-namespace="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="csv-encoding" as="xs:string" select="'utf-8'"/>
    <xsl:param name="csv-uri" as="xs:string" select="'file:///C:/temp/csv/csv_invoice_template.csv'"/>
	<!-- <xsl:param name="csv-folder" as="xs:string" select="'file:///C:/Users/Dragugy1/Desktop/TESTAS/'"/> -->
	<!-- <xsl:param name="csv-file" as="xs:string" select="'*.csv'"/> --> 
	<!-- <xsl:param name="csv-uri" as="xs:string" select="concat($csv-folder, $csv-file)"/> -->

    <xsl:variable name="csv" select="unparsed-text($csv-uri, $csv-encoding)"/>
    
    <xsl:template match="/" name="csv2xml">
	
        <Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">
            
                <xsl:call-template name="XMLBody"/>
                <xsl:call-template name="XMLTaxes"/>
                <xsl:call-template name="XMLLines"/>
            
        </Invoice>
    </xsl:template>

    <xsl:template name="XMLBody">
		<xsl:for-each select="tokenize($csv, '\r?\n')[position() = 2]">
                <xsl:variable name="currentLine" select="normalize-space(.)"/>

                <!-- Split CSV line into fields -->
                <xsl:variable name="fields" select="tokenize($currentLine, ';')"/>

                <xsl:variable name="LineID" select="$fields[1]"/>
                <xsl:variable name="Description" select="$fields[2]"/>
                <xsl:variable name="Quantity" select="$fields[3]"/>
                <xsl:variable name="Price" select="$fields[4]"/>
                <xsl:variable name="Amount" select="$fields[5]"/>
                <xsl:variable name="TaxCategoryID" select="$fields[6]"/>
                <xsl:variable name="TaxRate" select="$fields[7]"/>
                <xsl:variable name="InvoiceNo" select="$fields[8]"/>
                <xsl:variable name="IssueDate" select="$fields[9]"/>
                <xsl:variable name="DueDate" select="$fields[10]"/>
                <xsl:variable name="BuyerRef" select="$fields[11]"/>
                <xsl:variable name="ContractRef" select="$fields[12]"/>
                <xsl:variable name="SenderRegNumber" select="$fields[13]"/>
                <xsl:variable name="SenderVATNumber" select="$fields[14]"/>
                <xsl:variable name="SenderName" select="$fields[15]"/>
                <xsl:variable name="SenderAddress" select="$fields[16]"/>
                <xsl:variable name="SenderCountryCode" select="$fields[17]"/>
                <xsl:variable name="ReceiverRegNumber" select="$fields[18]"/>
                <xsl:variable name="ReceiverVATNumber" select="$fields[19]"/>
                <xsl:variable name="ReceiverName" select="$fields[20]"/>
                <xsl:variable name="ReceiverAddress" select="$fields[21]"/>
                <xsl:variable name="ReceiverCountryCode" select="$fields[22]"/>

	
	
        <cbc:CustomizationID>urn:cen.eu:en16931:2017#compliant#urn:fdc:peppol.eu:2017:poacc:billing:3.0</cbc:CustomizationID>
        <cbc:ProfileID>urn:fdc:peppol.eu:2017:poacc:billing:01:1.0</cbc:ProfileID>
        <cbc:ID><xsl:value-of select="$InvoiceNo" /></cbc:ID>
        <cbc:IssueDate><xsl:value-of select="$IssueDate" /></cbc:IssueDate>
        <cbc:DueDate><xsl:value-of select="$DueDate" /></cbc:DueDate>
        <cbc:InvoiceTypeCode>380</cbc:InvoiceTypeCode>
        <cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>
		
		<xsl:if test="normalize-space($BuyerRef)">
		  <cbc:BuyerReference><xsl:value-of select="$BuyerRef" /></cbc:BuyerReference>
		</xsl:if>
		<xsl:if test="normalize-space($ContractRef)">
		  <cac:ContractDocumentReference>
			<cbc:ID><xsl:value-of select="$ContractRef" /></cbc:ID>
		  </cac:ContractDocumentReference>
		</xsl:if>
		
		<cac:AccountingSupplierParty>
		<cac:Party>
		
		
		<xsl:variable name="supplierSchema">
				<xsl:call-template name="getSchemaID">
					<xsl:with-param name="input" select="$SenderCountryCode"/>
				</xsl:call-template>
		</xsl:variable>
		
		
		  <cbc:EndpointID>
			<xsl:attribute name="schemeID"><xsl:value-of select="$supplierSchema"/></xsl:attribute>
			<xsl:value-of select="replace($SenderRegNumber,'-','')"/>
		  </cbc:EndpointID>
			<cac:PartyIdentification>
				<cbc:ID>
					<xsl:attribute name="schemeID"><xsl:value-of select="$supplierSchema"/></xsl:attribute>
					<xsl:value-of select="replace($SenderRegNumber,'-','')"/>
				</cbc:ID>
			</cac:PartyIdentification>
		  <cac:PartyName>
			<cbc:Name><xsl:value-of select="$SenderName" /></cbc:Name>
		  </cac:PartyName>
		  <cac:PostalAddress>
			<cbc:StreetName><xsl:value-of select="$SenderAddress" /></cbc:StreetName>
			<cac:Country>
			  <cbc:IdentificationCode><xsl:value-of select="$SenderCountryCode" /></cbc:IdentificationCode>
			</cac:Country>
		  </cac:PostalAddress>

		<xsl:if test="normalize-space($SenderVATNumber)">
		  <cac:PartyTaxScheme>
			<cbc:CompanyID><xsl:value-of select="$SenderVATNumber" /></cbc:CompanyID>
			<cac:TaxScheme>
			  <cbc:ID>VAT</cbc:ID>
			</cac:TaxScheme>
		  </cac:PartyTaxScheme>
		</xsl:if>

		  <cac:PartyLegalEntity>
			<cbc:RegistrationName><xsl:value-of select="$SenderName" /></cbc:RegistrationName>
			<cbc:CompanyID><xsl:value-of select="$SenderRegNumber" /></cbc:CompanyID>
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
			<xsl:attribute name="schemeID"><xsl:value-of select="$companySchema"/></xsl:attribute>
			<xsl:value-of select="replace($ReceiverRegNumber,'-','')"/>
		  </cbc:EndpointID>
			<cac:PartyIdentification>
				<cbc:ID>
					<xsl:attribute name="schemeID"><xsl:value-of select="$companySchema"/></xsl:attribute>
					<xsl:value-of select="replace($ReceiverRegNumber,'-','')"/>
				</cbc:ID>
			</cac:PartyIdentification>
      <cac:PartyName>
        <cbc:Name><xsl:value-of select="$ReceiverName" /></cbc:Name>
      </cac:PartyName>
      <cac:PostalAddress>
        <cbc:StreetName><xsl:value-of select="$ReceiverAddress" /></cbc:StreetName>
        <cac:Country>
          <cbc:IdentificationCode><xsl:value-of select="$ReceiverCountryCode" /></cbc:IdentificationCode>
        </cac:Country>
      </cac:PostalAddress>

		<xsl:if test="normalize-space($ReceiverVATNumber)">
		  <cac:PartyTaxScheme>
			<cbc:CompanyID><xsl:value-of select="$ReceiverVATNumber" /></cbc:CompanyID>
			<cac:TaxScheme>
			  <cbc:ID>VAT</cbc:ID>
			</cac:TaxScheme>
		  </cac:PartyTaxScheme>
		</xsl:if>

      <cac:PartyLegalEntity>
        <cbc:RegistrationName><xsl:value-of select="$ReceiverName" /></cbc:RegistrationName>
        <cbc:CompanyID><xsl:value-of select="$ReceiverRegNumber" /></cbc:CompanyID>
      </cac:PartyLegalEntity>
    </cac:Party>
  </cac:AccountingCustomerParty>


		
		</xsl:for-each>
    </xsl:template>
	<xsl:template name="XMLTaxes">
    <xsl:param name="currentIndex" select="2"/>
    <xsl:param name="TotalTaxAmount" select="0"/>
    <xsl:param name="TotalTaxableAmount" select="0"/>
    <xsl:param name="TotalAmount" select="0"/>
    <xsl:param name="TaxAmount" select="0"/>
    <xsl:param name="TaxCategoryID" select="0"/>
    <xsl:param name="TaxRate" select="0"/>

    <xsl:choose>
        <xsl:when test="normalize-space(tokenize($csv, '\r?\n')[$currentIndex])">

            <xsl:variable name="currentLine" select="tokenize($csv, '\r?\n')[$currentIndex]"/>
            <!-- Split CSV line into fields -->
            <xsl:variable name="fields" select="tokenize($currentLine, ';')"/>

            <xsl:variable name="Amount" select="if (normalize-space($fields[5])) then xs:decimal(translate($fields[5], ',', '.')) else 0"/>
            <xsl:variable name="TaxCategoryID" select="$fields[6]"/>
            <xsl:variable name="TaxRate" select="if (normalize-space($fields[7])) then xs:decimal(translate($fields[7], ',', '.')) else 0"/>
            <xsl:variable name="Price" select="if (normalize-space($fields[4])) then xs:decimal($fields[4]) else 0"/>

            <!-- Accumulate values -->
            <xsl:variable name="CurrentTotalAmount" select="$Amount"/>
            <xsl:variable name="CurrentTaxAmount" select="$Amount * $TaxRate"/>

            <xsl:variable name="NewTotalAmount" select="$TotalAmount + $CurrentTotalAmount"/>
            <xsl:variable name="NewTotalTaxAmount" select="$TotalTaxAmount + $CurrentTaxAmount"/>
            <xsl:variable name="NewTotalTaxableAmount" select="$TotalTaxableAmount + $CurrentTotalAmount"/>
            <xsl:variable name="TaxAmount" select="$Amount * $TaxRate"/>
			<!-- <xsl:message terminate="no">Debug: Current Index - <xsl:value-of select="$TaxRate"/></xsl:message> -->

            <!-- Recursive call -->
            <xsl:call-template name="XMLTaxes">
                <xsl:with-param name="currentIndex" select="$currentIndex + 1"/>
                <xsl:with-param name="TotalAmount" select="$NewTotalAmount"/>
                <xsl:with-param name="TotalTaxAmount" select="$NewTotalTaxAmount"/>
                <xsl:with-param name="TotalTaxableAmount" select="$NewTotalTaxableAmount"/>
                <xsl:with-param name="TaxAmount" select="$TaxAmount"/>
                <xsl:with-param name="TaxCategoryID" select="$TaxCategoryID"/>
                <xsl:with-param name="TaxRate" select="$TaxRate"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:if test="position() = last()">
                <xsl:variable name="FormattedTotalTaxAmount" select="format-number(round-half-to-even($TotalTaxAmount div 100, 2), '0.00')" />
                <cac:TaxTotal>
                    <cbc:TaxAmount currencyID="EUR"><xsl:value-of select="$FormattedTotalTaxAmount" /></cbc:TaxAmount>

                    <cac:TaxSubtotal>
                        <cbc:TaxableAmount currencyID="EUR"><xsl:value-of select="$TotalAmount" /></cbc:TaxableAmount>
                        <cbc:TaxAmount currencyID="EUR"><xsl:value-of select="$FormattedTotalTaxAmount" /></cbc:TaxAmount>
                        <cac:TaxCategory>
                            <cbc:ID><xsl:value-of select="$TaxCategoryID" /></cbc:ID>
                            <cbc:Percent><xsl:value-of select="$TaxRate" /></cbc:Percent>
                            <cac:TaxScheme>
                                <cbc:ID>VAT</cbc:ID>
                            </cac:TaxScheme>
                        </cac:TaxCategory>
                    </cac:TaxSubtotal>
                </cac:TaxTotal>
                <cac:LegalMonetaryTotal>
                    <cbc:LineExtensionAmount currencyID="EUR"><xsl:value-of select="$TotalAmount" /></cbc:LineExtensionAmount>
                    <cbc:TaxExclusiveAmount currencyID="EUR"><xsl:value-of select="$TotalAmount" /></cbc:TaxExclusiveAmount>
                    <cbc:TaxInclusiveAmount currencyID="EUR"><xsl:value-of select="round-half-to-even($TotalTaxAmount div 100, 2) + $TotalAmount" /></cbc:TaxInclusiveAmount>
                    <cbc:PayableAmount currencyID="EUR"><xsl:value-of select="round-half-to-even($TotalTaxAmount div 100, 2) + $TotalAmount" /></cbc:PayableAmount>
                </cac:LegalMonetaryTotal>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

    <xsl:template name="XMLLines">
	<xsl:for-each select="tokenize($csv, '\r?\n')[position() > 1 and string-length(normalize-space()) > 0]">
                <xsl:variable name="currentLine" select="normalize-space(.)"/>

                <!-- Split CSV line into fields -->
                <xsl:variable name="fields" select="tokenize($currentLine, ';')"/>

                <xsl:variable name="LineID" select="$fields[1]"/>
                <xsl:variable name="Description" select="$fields[2]"/>
                <!-- <xsl:variable name="Quantity" select="xs:decimal($fields[3])"/> -->
                <xsl:variable name="Quantity" select="format-number(xs:decimal(translate($fields[3], ',', '.')), '0.00')"/>
                <xsl:variable name="Price" select="format-number(xs:decimal(translate($fields[4], ',', '.')), '0.00')"/>
                <xsl:variable name="Amount" select="format-number(xs:decimal(translate($fields[5], ',', '.')), '0.00')"/>
                <xsl:variable name="TaxCategoryID" select="$fields[6]"/>
                <xsl:variable name="TaxRate" select="format-number(xs:decimal(translate($fields[7], ',', '.')), '0.00')"/>
                <xsl:variable name="InvoiceNo" select="$fields[8]"/>
                <xsl:variable name="IssueDate" select="$fields[9]"/>
                <xsl:variable name="DueDate" select="$fields[10]"/>
                <xsl:variable name="BuyerRef" select="$fields[11]"/>
                <xsl:variable name="ContractRef" select="$fields[12]"/>
                <xsl:variable name="SenderRegNumber" select="$fields[13]"/>
                <xsl:variable name="SenderVATNumber" select="$fields[14]"/>
                <xsl:variable name="SenderName" select="$fields[15]"/>
                <xsl:variable name="SenderAddress" select="$fields[16]"/>
                <xsl:variable name="SenderCountryCode" select="$fields[17]"/>
                <xsl:variable name="ReceiverRegNumber" select="$fields[18]"/>
                <xsl:variable name="ReceiverVATNumber" select="$fields[19]"/>
                <xsl:variable name="ReceiverName" select="$fields[20]"/>
                <xsl:variable name="ReceiverAddress" select="$fields[21]"/>
                <xsl:variable name="ReceiverCountryCode" select="$fields[22]"/>

        <cac:InvoiceLine>    
            <cbc:ID><xsl:value-of select="$LineID" /></cbc:ID>
            <cbc:InvoicedQuantity unitCode="H87"><xsl:value-of select="$Quantity" /></cbc:InvoicedQuantity>
            <cbc:LineExtensionAmount currencyID="EUR"><xsl:value-of select="$Amount" /></cbc:LineExtensionAmount>
            <cac:Item>
                <cbc:Description><xsl:value-of select="$Description" /></cbc:Description>
                <cbc:Name><xsl:value-of select="$Description" /></cbc:Name>
                <cac:ClassifiedTaxCategory>
                    <cbc:ID><xsl:value-of select="$TaxCategoryID" /></cbc:ID>
                    <cbc:Percent><xsl:value-of select="$TaxRate" /></cbc:Percent>
                    <cac:TaxScheme>
                        <cbc:ID>VAT</cbc:ID>
                    </cac:TaxScheme>
                </cac:ClassifiedTaxCategory>
            </cac:Item>
            <cac:Price>
                <cbc:PriceAmount currencyID="EUR"><xsl:value-of select="$Price" /></cbc:PriceAmount>
            </cac:Price>
        </cac:InvoiceLine>
		</xsl:for-each>
    </xsl:template>
	<xsl:template name="getSchemaID">
	<xsl:param name="input"/>
		<xsl:variable name="countryCode" select="$input"/>
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