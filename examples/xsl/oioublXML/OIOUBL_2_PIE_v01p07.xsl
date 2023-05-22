<?xml version="1.0" encoding="UTF-8"?>

<!--
******************************************************************************************************************

		OIOUBL Stylesheet	

		title= OIOUBL_2_PIE_v01p07.xsl	
		replaces= OIOUBL_2_PIE_v01p06.xsl	
		publisher= "IT og Telestyrelsen"
		creator= "Finn Christensen"
		created= 2007-06-20
		modified= 2008-04-23
		issued= 2008-04-23
		conformsTo= OIOUBL stylesheet package
		description= "This document is produced as part of the OIOUBL stylesheet package"
		rights= "It can be used following the Common Creative Licence"
		
		all terms derived from http://dublincore.org/documents/dcmi-terms/

		For more information, see www.oioubl.dk	or email oioubl@itst.dk
		
******************************************************************************************************************
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl  = "http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi  = "http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:ns   = "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
	xmlns:cac  = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
	xmlns:cbc  = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
	xmlns:ccts = "urn:oasis:names:specification:ubl:schema:xsd:CoreComponentParameters-2"
	xmlns:sdt  = "urn:oasis:names:specification:ubl:schema:xsd:SpecializedDatatypes-2"
	xmlns:udt  = "urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"
	xmlns:xs   = "http://www.w3.org/2001/XMLSchema"
	xmlns      = "http://rep.oio.dk/ubl/xml/schemas/0p71/pie/"
	xmlns:com  = "http://rep.oio.dk/ubl/xml/schemas/0p71/common/" 
	xmlns:main = "http://rep.oio.dk/ubl/xml/schemas/0p71/maindoc/"
                                                                 exclude-result-prefixes="ns cac cbc ccts sdt udt xs">

	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<xsl:strip-space elements="*" />

     	<xsl:template match="/">
		<xsl:apply-templates/>
     	</xsl:template>

	<xsl:template match="*">
		<Fejl>
			<Fejltekst>Fatal fejl: Dokumenttypen supporteres ikke! Dette stylesheet kan alene konvertere en OIOUBL-2.01 Invoice.</Fejltekst>
			<Input><xsl:value-of select="."/></Input>
		</Fejl>
	</xsl:template>

	<xsl:template match="/ns:Invoice">

		<!-- Faste parametre (disse kan/skal tilpasses inden brug af sylesheetet) -->
		<xsl:variable name="CountryCode"		select="'DK'"/>
		<xsl:variable name="DefaultItemSchemeID"	select="'n/a'"/>
		<xsl:variable name="UseDefaultItemSchemeID"	select="'true'"/>
		<xsl:variable name="DeliveryPartyMapping"	select="'1'"/>
		<xsl:variable name="DefaultUnitCode"		select="'PCE'"/>
		<xsl:variable name="UseDefaultUnitCode"		select="'false'"/>
		<!-- Slut faste parametre -->

		<!-- Betingede parametre -->
		<xsl:variable name="Linjespecificeret">
			<xsl:choose>
				<xsl:when test="count(cac:InvoiceLine/cac:OrderLineReference/cac:OrderReference) &gt; 0">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Forudbetalt">
			<xsl:choose>
				<xsl:when test="count(cac:LegalMonetaryTotal/cbc:PrepaidAmount) &gt; 0">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Globale variable -->
		<xsl:variable name="CurrencyCode"	select="cbc:DocumentCurrencyCode"/>
		<xsl:variable name="InvoiceDate"	select="cbc:IssueDate"/>
		<xsl:variable name="AccountCode"	select="cbc:AccountingCost"/>


		<!-- Start på PIE -->
		<Invoice>
			<xsl:attribute name="xsi:schemaLocation">http://rep.oio.dk/ubl/xml/schemas/0p71/pie/ http://rep.oio.dk/ubl/xml/schemas/0p71/pie/pieStrict.xsd</xsl:attribute>

			<com:ID><xsl:value-of select="cbc:ID"/></com:ID>
			<com:IssueDate><xsl:value-of select="cbc:IssueDate"/></com:IssueDate>
			<com:TypeCode>PIE</com:TypeCode>
			<main:InvoiceCurrencyCode><xsl:value-of select="cbc:DocumentCurrencyCode"/></main:InvoiceCurrencyCode>

			<!-- Note -->
			<xsl:call-template name="Note">
			</xsl:call-template>

			<!-- EncodedDocument -->

			<!-- BuyersReferenceID -->
			<xsl:call-template name="BuyersReferenceID">
				<xsl:with-param name="Linjespecificeret" select="$Linjespecificeret"/>
			</xsl:call-template>

			<!-- ReferencedOrder -->
			<xsl:call-template name="ReferencedOrder">
				<xsl:with-param name="Linjespecificeret" select="$Linjespecificeret"/>
			</xsl:call-template>

			<!-- BuyerParty (Fakturering) -->
			<xsl:apply-templates select="cac:AccountingCustomerParty">
				<xsl:with-param name="AccountCode" select="$AccountCode"/>
				<xsl:with-param name="CountryCode" select="$CountryCode"/>
			</xsl:apply-templates>

			<!-- BuyerParty (Juridisk) -->
			<xsl:apply-templates select="cac:BuyerCustomerParty">
				<xsl:with-param name="AccountCode" select="''"/>
				<xsl:with-param name="CountryCode" select="$CountryCode"/>
				<xsl:with-param name="DeliveryPartyMapping" select="$DeliveryPartyMapping"/>
			</xsl:apply-templates>

			<!-- DestinationParty -->
			<xsl:apply-templates select="cac:Delivery[1]">
				<xsl:with-param name="CountryCode" select="$CountryCode"/>
				<xsl:with-param name="DeliveryPartyMapping" select="$DeliveryPartyMapping"/>
			</xsl:apply-templates>

			<!-- SellerParty -->
			<xsl:apply-templates select="cac:AccountingSupplierParty">
				<xsl:with-param name="CountryCode" select="$CountryCode"/>
			</xsl:apply-templates>

			<!-- PaymentMeans -->
			<xsl:apply-templates select="cac:PaymentMeans[1]">
			</xsl:apply-templates>

			<!-- PaymentTerms -->
			<xsl:apply-templates select="cac:PaymentTerms[1]">
			</xsl:apply-templates>

			<!-- AllowanceCharge -->
			<xsl:call-template name="AllowanceCharge">
				<xsl:with-param name="Forudbetalt" select="$Forudbetalt"/>
			</xsl:call-template>

			<!-- TaxTotal template -->
			<xsl:call-template name="TaxTotal">
				<xsl:with-param name="Forudbetalt" select="$Forudbetalt"/>
			</xsl:call-template>

			<!-- LegalTotals -->
			<xsl:apply-templates select="cac:LegalMonetaryTotal">
			</xsl:apply-templates>

			<!-- InvoiceLine -->
			<xsl:apply-templates select="cac:InvoiceLine">
				<xsl:with-param name="DefaultItemSchemeID" select="$DefaultItemSchemeID"/>
				<xsl:with-param name="UseDefaultItemSchemeID" select="$UseDefaultItemSchemeID"/>
				<xsl:with-param name="Linjespecificeret" select="$Linjespecificeret"/>
				<xsl:with-param name="DefaultUnitCode" select="$DefaultUnitCode"/>
				<xsl:with-param name="UseDefaultUnitCode" select="$UseDefaultUnitCode"/>
			</xsl:apply-templates>

			<!-- ValidatedSignature -->
			<xsl:apply-templates select="cac:Signature[1]">
			</xsl:apply-templates>

			<!-- ExtensibleContent -->
		</Invoice>
	</xsl:template>


	<!-- .............................. -->
	<!--           Templates            -->
	<!-- .............................. -->

	<!-- Note template -->
	<xsl:template name="Note">
		<xsl:variable name="t1"	select="cbc:Note[1]"/>
		<xsl:variable name="t2"	select="cbc:InvoiceTypeCode"/>
		<xsl:variable name="t3"	select="cac:PaymentTerms/cbc:Note"/>
		<xsl:choose>
			<xsl:when test="string($t3)">
				<xsl:choose>
					<xsl:when test="string($t1)">
						<com:Note><xsl:value-of select="$t1"/>, (Note til betalingsbetingelserne: <xsl:value-of select="$t3"/>)</com:Note>
					</xsl:when>
					<xsl:otherwise>
						<com:Note>Note til betalingsbetingelserne: <xsl:value-of select="$t3"/></com:Note>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$t2 = '325'">
						<xsl:choose>
							<xsl:when test="string($t1)">
								<com:Note><xsl:value-of select="$t1"/>, (Bemærk: der er tale om en PROFORMA faktura!)</com:Note>
							</xsl:when>
							<xsl:otherwise>
								<com:Note>Bemærk: der er tale om en PROFORMA faktura!</com:Note>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="string($t1)">
						<com:Note><xsl:value-of select="$t1"/></com:Note>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- BuyersReferenceID template -->
	<xsl:template name="BuyersReferenceID">
		<xsl:param name="Linjespecificeret"/>
		<xsl:variable name="t1"	select="cac:AccountingCustomerParty/cac:Party/cbc:EndpointID"/>
		<xsl:variable name="t2"	select="cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID"/>
		<xsl:variable name="t3">
			<xsl:choose>
				<xsl:when test="$t2 = 'EAN'"><xsl:value-of select="$t1"/></xsl:when>
				<xsl:when test="$t2 = 'GLN'"><xsl:value-of select="$t1"/></xsl:when>
				<xsl:when test="$t2 = 'DK:CVR'"><xsl:value-of select="substring($t1, 3)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$t1"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t4">
			<xsl:choose>
				<xsl:when test="$t2 = 'EAN'">EAN</xsl:when>
				<xsl:when test="$t2 = 'GLN'">EAN</xsl:when>
				<xsl:when test="$t2 = 'DK:CVR'">CVR</xsl:when>
				<xsl:otherwise><xsl:value-of select="$t2"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<com:BuyersReferenceID schemeID="{$t4}"><xsl:value-of select="$t3"/></com:BuyersReferenceID>
	</xsl:template>


	<!-- ReferencedOrder template -->
	<xsl:template name="ReferencedOrder">
		<xsl:param name="Linjespecificeret"/>
		<xsl:variable name="t1"	select="cac:OrderReference/cbc:ID"/>
		<xsl:variable name="t2"	select="cac:OrderReference/cbc:SalesOrderID"/>
		<xsl:variable name="t3"	select="cac:OrderReference/cbc:IssueDate"/>
		<xsl:variable name="t4"	select="cbc:IssueDate"/>
		<xsl:variable name="t5">
			<xsl:choose>
				<xsl:when test="$Linjespecificeret = 'true'">Linjespecificeret</xsl:when>
				<xsl:when test="$Linjespecificeret != 'true' and string($t1)"><xsl:value-of select="$t1"/></xsl:when>
				<xsl:otherwise>n/a</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t6">
			<xsl:choose>
				<xsl:when test="string($t3)"><xsl:value-of select="$t3"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$t4"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<com:ReferencedOrder>
			<com:BuyersOrderID><xsl:value-of select="$t5"/></com:BuyersOrderID>
			<xsl:if test="string($t2)"><com:SellersOrderID><xsl:value-of select="$t2"/></com:SellersOrderID></xsl:if>
			<com:IssueDate><xsl:value-of select="$t6"/></com:IssueDate>
		</com:ReferencedOrder>
	</xsl:template>


	<!--  AccountingCustomerParty template -->
	<xsl:template match="cac:AccountingCustomerParty">
		<xsl:param name="AccountCode"/>
		<xsl:param name="CountryCode"/>
		<!--  Brug enten PartyIdentification eller PartyLegalEntity  -->
		<xsl:variable name="t1">
			<xsl:choose>
				<xsl:when test="count(cac:Party/cac:PartyIdentification) = 0"><xsl:value-of select="cac:Party/cac:PartyLegalEntity/cbc:CompanyID"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="cac:Party/cac:PartyIdentification[1]/cbc:ID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t2">
			<xsl:choose>
				<xsl:when test="count(cac:Party/cac:PartyIdentification) = 0"><xsl:value-of select="cac:Party/cac:PartyLegalEntity/cbc:CompanyID/@schemeID"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="cac:Party/cac:PartyIdentification[1]/cbc:ID/@schemeID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--  Konverter til OIOXML format  -->
		<xsl:variable name="t3">
			<xsl:choose>
				<xsl:when test="$t2 = 'EAN'">EAN</xsl:when>
				<xsl:when test="$t2 = 'GLN'">EAN</xsl:when>
				<xsl:when test="$t2 = 'DK:CVR'">CVR</xsl:when>
				<xsl:when test="$t2 = 'DK:SE'">SE</xsl:when>
				<xsl:otherwise><xsl:value-of select="$t2"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t4">
			<xsl:choose>
				<xsl:when test="$t2 = 'DK:CVR'"><xsl:value-of select="substring($t1, 3)"/></xsl:when>
				<xsl:when test="$t2 = 'DK:SE'"><xsl:value-of select="substring($t1, 3)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$t1"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<com:BuyerParty>
			<com:ID schemeID="{$t3}"><xsl:value-of select="$t4"/></com:ID>
			<xsl:if test="string($AccountCode)"><com:AccountCode><xsl:value-of select="$AccountCode"/></com:AccountCode></xsl:if>
			<xsl:if test="count(cac:Party/cac:PartyName) &gt; 0">
				<xsl:call-template name="PartyName"><xsl:with-param name="p1" select="cac:Party/cac:PartyName[1]/cbc:Name"/></xsl:call-template>
			</xsl:if>
			<xsl:if test="string(cac:Party/cac:PostalAddress)">
				<xsl:call-template name="Address">
					<xsl:with-param name="p1" select="'Fakturering'"/>
					<xsl:with-param name="p2" select="cac:Party/cac:PostalAddress/cbc:StreetName"/>
					<xsl:with-param name="p3" select="cac:Party/cac:PostalAddress/cbc:AdditionalStreetName"/>
					<xsl:with-param name="p4" select="cac:Party/cac:PostalAddress/cbc:BuildingNumber"/>
					<xsl:with-param name="p5" select="cac:Party/cac:PostalAddress/cbc:InhouseMail"/>
					<xsl:with-param name="p6" select="cac:Party/cac:PostalAddress/cbc:CityName"/>
					<xsl:with-param name="p7" select="cac:Party/cac:PostalAddress/cbc:PostalZone"/>
					<xsl:with-param name="p8" select="cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
					<xsl:with-param name="CountryCode" select="$CountryCode"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="string(cac:Party/cac:Contact)">
				<com:BuyerContact>	
					<xsl:call-template name="Contact">
						<xsl:with-param name="p1" select="cac:Party/cac:Contact/cbc:ID"/>
						<xsl:with-param name="p2" select="cac:Party/cac:Contact/cbc:Name"/>
						<xsl:with-param name="p3" select="cac:Party/cac:Contact/cbc:Telephone"/>
						<xsl:with-param name="p4" select="cac:Party/cac:Contact/cbc:Telefax"/>
						<xsl:with-param name="p5" select="cac:Party/cac:Contact/cbc:ElectronicMail"/>
					</xsl:call-template>
				</com:BuyerContact>	
			</xsl:if>
		</com:BuyerParty>
	</xsl:template>


	<!--  BuyerCustomerParty template -->
	<xsl:template match="cac:BuyerCustomerParty">
		<xsl:param name="AccountCode"/>
		<xsl:param name="CountryCode"/>
		<xsl:param name="DeliveryPartyMapping"/>
		<xsl:if test="$DeliveryPartyMapping != '2'">
			<!--  Brug enten PartyIdentification eller PartyLegalEntity  -->
			<xsl:variable name="t1">
				<xsl:choose>
					<xsl:when test="count(cac:Party/cac:PartyIdentification) = 0"><xsl:value-of select="cac:Party/cac:PartyLegalEntity/cbc:CompanyID"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="cac:Party/cac:PartyIdentification[1]/cbc:ID"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="t2">
				<xsl:choose>
					<xsl:when test="count(cac:Party/cac:PartyIdentification) = 0"><xsl:value-of select="cac:Party/cac:PartyLegalEntity/cbc:CompanyID/@schemeID"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="cac:Party/cac:PartyIdentification[1]/cbc:ID/@schemeID"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!--  Konverter til OIOXML format  -->
			<xsl:variable name="t3">
				<xsl:choose>
					<xsl:when test="$t2 = 'EAN'">EAN</xsl:when>
					<xsl:when test="$t2 = 'GLN'">EAN</xsl:when>
					<xsl:when test="$t2 = 'DK:CVR'">CVR</xsl:when>
					<xsl:when test="$t2 = 'DK:SE'">SE</xsl:when>
					<xsl:otherwise><xsl:value-of select="$t2"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="t4">
				<xsl:choose>
					<xsl:when test="$t2 = 'DK:CVR'"><xsl:value-of select="substring($t1, 3)"/></xsl:when>
					<xsl:when test="$t2 = 'DK:SE'"><xsl:value-of select="substring($t1, 3)"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$t1"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<com:BuyerParty>
				<com:ID schemeID="{$t3}"><xsl:value-of select="$t4"/></com:ID>
				<xsl:if test="string($AccountCode)"><com:AccountCode><xsl:value-of select="$AccountCode"/></com:AccountCode></xsl:if>
				<xsl:if test="count(cac:Party/cac:PartyName) &gt; 0">
					<xsl:call-template name="PartyName"><xsl:with-param name="p1" select="cac:Party/cac:PartyName[1]/cbc:Name"/></xsl:call-template>
				</xsl:if>
				<xsl:if test="string(cac:Party/cac:PostalAddress)">
					<xsl:call-template name="Address">
						<xsl:with-param name="p1" select="'Juridisk'"/>
						<xsl:with-param name="p2" select="cac:Party/cac:PostalAddress/cbc:StreetName"/>
						<xsl:with-param name="p3" select="cac:Party/cac:PostalAddress/cbc:AdditionalStreetName"/>
						<xsl:with-param name="p4" select="cac:Party/cac:PostalAddress/cbc:BuildingNumber"/>
						<xsl:with-param name="p5" select="cac:Party/cac:PostalAddress/cbc:InhouseMail"/>
						<xsl:with-param name="p6" select="cac:Party/cac:PostalAddress/cbc:CityName"/>
						<xsl:with-param name="p7" select="cac:Party/cac:PostalAddress/cbc:PostalZone"/>
						<xsl:with-param name="p8" select="cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
						<xsl:with-param name="CountryCode" select="$CountryCode"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="string(cac:Party/cac:Contact)">
					<com:BuyerContact>	
						<xsl:call-template name="Contact">
							<xsl:with-param name="p1" select="cac:Party/cac:Contact/cbc:ID"/>
							<xsl:with-param name="p2" select="cac:Party/cac:Contact/cbc:Name"/>
							<xsl:with-param name="p3" select="cac:Party/cac:Contact/cbc:Telephone"/>
							<xsl:with-param name="p4" select="cac:Party/cac:Contact/cbc:Telefax"/>
							<xsl:with-param name="p5" select="cac:Party/cac:Contact/cbc:ElectronicMail"/>
						</xsl:call-template>
					</com:BuyerContact>	
				</xsl:if>
			</com:BuyerParty>
		</xsl:if>
	</xsl:template>


	<!-- DestinationParty template -->
	<xsl:template match="cac:Delivery">
		<xsl:param name="CountryCode"/>
		<xsl:param name="DeliveryPartyMapping"/>
		<!--  Brug enten PartyIdentification eller PartyLegalEntity  -->
		<xsl:variable name="t2">
			<xsl:choose>
				<xsl:when test="count(cac:DeliveryParty/cac:PartyIdentification) = 0"><xsl:value-of select="cac:DeliveryParty/cac:PartyLegalEntity/cbc:CompanyID"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="cac:DeliveryParty/cac:PartyIdentification[1]/cbc:ID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t3">
			<xsl:choose>
				<xsl:when test="count(cac:DeliveryParty/cac:PartyIdentification) = 0"><xsl:value-of select="cac:DeliveryParty/cac:PartyLegalEntity/cbc:CompanyID/@schemeID"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="cac:DeliveryParty/cac:PartyIdentification[1]/cbc:ID/@schemeID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--  Konverter til OIOXML format  -->
		<xsl:variable name="t4">
			<xsl:choose>
				<xsl:when test="$t3 = 'EAN'">EAN</xsl:when>
				<xsl:when test="$t3 = 'GLN'">EAN</xsl:when>
				<xsl:when test="$t3 = 'DK:CVR'">CVR</xsl:when>
				<xsl:when test="$t3 = 'DK:SE'">SE</xsl:when>
				<xsl:otherwise><xsl:value-of select="$t3"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t5">
			<xsl:choose>
				<xsl:when test="$t3 = 'DK:CVR'"><xsl:value-of select="substring($t2, 3)"/></xsl:when>
				<xsl:when test="$t3 = 'DK:SE'"><xsl:value-of select="substring($t2, 3)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$t2"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- DeliveryLocation -->
		<xsl:if test="count(cac:DeliveryLocation/cac:Address) &gt; 0">
			<xsl:variable name="t1">
				<xsl:choose>
					<xsl:when test="string(cac:DeliveryLocation/cbc:ID)"><xsl:value-of select="cac:DeliveryLocation/cbc:ID"/></xsl:when>
					<xsl:otherwise>n/a</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<com:DestinationParty>
				<com:ID schemeID="n/a">n/a</com:ID>
				<xsl:if test="string(cac:DeliveryLocation/cac:Address)">
					<xsl:call-template name="Address">
						<xsl:with-param name="p1" select="$t1"/>
						<xsl:with-param name="p2" select="cac:DeliveryLocation/cac:Address/cbc:StreetName"/>
						<xsl:with-param name="p3" select="cac:DeliveryLocation/cac:Address/cbc:AdditionalStreetName"/>
						<xsl:with-param name="p4" select="cac:DeliveryLocation/cac:Address/cbc:BuildingNumber"/>
						<xsl:with-param name="p5" select="cac:DeliveryLocation/cac:Address/cbc:InhouseMail"/>
						<xsl:with-param name="p6" select="cac:DeliveryLocation/cac:Address/cbc:CityName"/>
						<xsl:with-param name="p7" select="cac:DeliveryLocation/cac:Address/cbc:PostalZone"/>
						<xsl:with-param name="p8" select="cac:DeliveryLocation/cac:Address/cac:Country/cbc:IdentificationCode"/>
						<xsl:with-param name="CountryCode" select="$CountryCode"/>
					</xsl:call-template>
				</xsl:if>
			</com:DestinationParty>
		</xsl:if>
		<!-- DeliveryParty (type 1 mapning) -->
		<xsl:if test="count(cac:DeliveryParty) &gt; 0 and $DeliveryPartyMapping = '1' and count(cac:DeliveryLocation/cac:Address) = 0">
			<com:DestinationParty>
				<com:ID schemeID="{$t4}"><xsl:value-of select="$t5"/></com:ID>
				<xsl:if test="count(cac:DeliveryParty/cac:PartyName) &gt; 0">
					<xsl:call-template name="PartyName"><xsl:with-param name="p1" select="cac:DeliveryParty/cac:PartyName[1]/cbc:Name"/></xsl:call-template>
				</xsl:if>
				<xsl:if test="string(cac:DeliveryParty/cac:Contact)">
					<com:Contact>	
						<xsl:call-template name="Contact">
							<xsl:with-param name="p1" select="cac:DeliveryParty/cac:Contact/cbc:ID"/>
							<xsl:with-param name="p2" select="cac:DeliveryParty/cac:Contact/cbc:Name"/>
							<xsl:with-param name="p3" select="cac:DeliveryParty/cac:Contact/cbc:Telephone"/>
							<xsl:with-param name="p4" select="cac:DeliveryParty/cac:Contact/cbc:Telefax"/>
							<xsl:with-param name="p5" select="cac:DeliveryParty/cac:Contact/cbc:ElectronicMail"/>
						</xsl:call-template>
					</com:Contact>	
				</xsl:if>
				<xsl:if test="string(cac:DeliveryParty/cac:PostalAddress)">
					<xsl:call-template name="Address">
						<xsl:with-param name="p1" select="cac:DeliveryParty/cac:PostalAddress/cbc:ID"/>
						<xsl:with-param name="p2" select="cac:DeliveryParty/cac:PostalAddress/cbc:StreetName"/>
						<xsl:with-param name="p3" select="cac:DeliveryParty/cac:PostalAddress/cbc:AdditionalStreetName"/>
						<xsl:with-param name="p4" select="cac:DeliveryParty/cac:PostalAddress/cbc:BuildingNumber"/>
						<xsl:with-param name="p5" select="cac:DeliveryParty/cac:PostalAddress/cbc:InhouseMail"/>
						<xsl:with-param name="p6" select="cac:DeliveryParty/cac:PostalAddress/cbc:CityName"/>
						<xsl:with-param name="p7" select="cac:DeliveryParty/cac:PostalAddress/cbc:PostalZone"/>
						<xsl:with-param name="p8" select="cac:DeliveryParty/cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
						<xsl:with-param name="CountryCode" select="$CountryCode"/>
					</xsl:call-template>
				</xsl:if>
			</com:DestinationParty>
		</xsl:if>
		<!-- DeliveryParty (type 2 mapning) -->
		<xsl:if test="count(cac:DeliveryParty) &gt; 0 and $DeliveryPartyMapping = '2' and count(cac:DeliveryLocation/cac:Address) = 0">
			<com:BuyerParty>
				<com:ID schemeID="{$t4}"><xsl:value-of select="$t5"/></com:ID>
				<xsl:if test="count(cac:DeliveryParty/cac:PartyName) &gt; 0">
					<xsl:call-template name="PartyName"><xsl:with-param name="p1" select="cac:DeliveryParty/cac:PartyName[1]/cbc:Name"/></xsl:call-template>
				</xsl:if>
				<xsl:if test="string(cac:DeliveryParty/cac:PostalAddress)">
					<xsl:call-template name="Address">
						<xsl:with-param name="p1" select="'Juridisk'"/>
						<xsl:with-param name="p2" select="cac:DeliveryParty/cac:PostalAddress/cbc:StreetName"/>
						<xsl:with-param name="p3" select="cac:DeliveryParty/cac:PostalAddress/cbc:AdditionalStreetName"/>
						<xsl:with-param name="p4" select="cac:DeliveryParty/cac:PostalAddress/cbc:BuildingNumber"/>
						<xsl:with-param name="p5" select="cac:DeliveryParty/cac:PostalAddress/cbc:InhouseMail"/>
						<xsl:with-param name="p6" select="cac:DeliveryParty/cac:PostalAddress/cbc:CityName"/>
						<xsl:with-param name="p7" select="cac:DeliveryParty/cac:PostalAddress/cbc:PostalZone"/>
						<xsl:with-param name="p8" select="cac:DeliveryParty/cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
						<xsl:with-param name="CountryCode" select="$CountryCode"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="string(cac:DeliveryParty/cac:Contact)">
					<com:BuyerContact>	
						<xsl:call-template name="Contact">
							<xsl:with-param name="p1" select="cac:DeliveryParty/cac:Contact/cbc:ID"/>
							<xsl:with-param name="p2" select="cac:DeliveryParty/cac:Contact/cbc:Name"/>
							<xsl:with-param name="p3" select="cac:DeliveryParty/cac:Contact/cbc:Telephone"/>
							<xsl:with-param name="p4" select="cac:DeliveryParty/cac:Contact/cbc:Telefax"/>
							<xsl:with-param name="p5" select="cac:DeliveryParty/cac:Contact/cbc:ElectronicMail"/>
						</xsl:call-template>
					</com:BuyerContact>	
				</xsl:if>
			</com:BuyerParty>
		</xsl:if>
	</xsl:template>


	<!--  AccountingSupplierParty template -->
	<xsl:template match="cac:AccountingSupplierParty">
		<xsl:param name="CountryCode"/>
		<!--  Brug enten PartyIdentification eller PartyLegalEntity  -->
		<xsl:variable name="t1">
			<xsl:choose>
				<xsl:when test="count(cac:Party/cac:PartyIdentification) = 0"><xsl:value-of select="cac:Party/cac:PartyLegalEntity/cbc:CompanyID"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="cac:Party/cac:PartyIdentification[1]/cbc:ID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t2">
			<xsl:choose>
				<xsl:when test="count(cac:Party/cac:PartyIdentification) = 0"><xsl:value-of select="cac:Party/cac:PartyLegalEntity/cbc:CompanyID/@schemeID"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="cac:Party/cac:PartyIdentification[1]/cbc:ID/@schemeID"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--  Konverter til OIOXML format  -->
		<xsl:variable name="t3">
			<xsl:choose>
				<xsl:when test="$t2 = 'EAN'">EAN</xsl:when>
				<xsl:when test="$t2 = 'GLN'">EAN</xsl:when>
				<xsl:when test="$t2 = 'DK:CVR'">CVR</xsl:when>
				<xsl:when test="$t2 = 'DK:SE'">SE</xsl:when>
				<xsl:when test="$t2 = 'DK:CPR'">CPR</xsl:when>
				<xsl:otherwise><xsl:value-of select="$t2"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t4">
			<xsl:choose>
				<xsl:when test="$t2 = 'DK:CVR'"><xsl:value-of select="substring($t1, 3)"/></xsl:when>
				<xsl:when test="$t2 = 'DK:SE'"><xsl:value-of select="substring($t1, 3)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$t1"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<com:SellerParty>
			<com:ID schemeID="{$t3}"><xsl:value-of select="$t4"/></com:ID>
			<xsl:if test="count(cac:Party/cac:PartyName) &gt; 0">
				<xsl:call-template name="PartyName"><xsl:with-param name="p1" select="cac:Party/cac:PartyName[1]/cbc:Name"/></xsl:call-template>
			</xsl:if>
			<!--  Betaling  -->
			<xsl:if test="string(cac:Party/cac:PostalAddress)">
				<xsl:call-template name="Address">
					<xsl:with-param name="p1" select="'Betaling'"/>
					<xsl:with-param name="p2" select="cac:Party/cac:PostalAddress/cbc:StreetName"/>
					<xsl:with-param name="p3" select="cac:Party/cac:PostalAddress/cbc:AdditionalStreetName"/>
					<xsl:with-param name="p4" select="cac:Party/cac:PostalAddress/cbc:BuildingNumber"/>
					<xsl:with-param name="p5" select="cac:Party/cac:PostalAddress/cbc:InhouseMail"/>
					<xsl:with-param name="p6" select="cac:Party/cac:PostalAddress/cbc:CityName"/>
					<xsl:with-param name="p7" select="cac:Party/cac:PostalAddress/cbc:PostalZone"/>
					<xsl:with-param name="p8" select="cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
					<xsl:with-param name="CountryCode" select="$CountryCode"/>
				</xsl:call-template>
			</xsl:if>
			<!--  Vareafsendelse (SellerSupplierParty)  -->
			<xsl:if test="count(../cac:SellerSupplierParty) &gt; 0">
				<xsl:call-template name="Address">
					<xsl:with-param name="p1" select="'Vareafsendelse'"/>
					<xsl:with-param name="p2" select="../cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName"/>
					<xsl:with-param name="p3" select="../cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:AdditionalStreetName"/>
					<xsl:with-param name="p4" select="../cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:BuildingNumber"/>
					<xsl:with-param name="p5" select="../cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:InhouseMail"/>
					<xsl:with-param name="p6" select="../cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName"/>
					<xsl:with-param name="p7" select="../cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone"/>
					<xsl:with-param name="p8" select="../cac:SellerSupplierParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode"/>
					<xsl:with-param name="CountryCode" select="$CountryCode"/>
				</xsl:call-template>
			</xsl:if>
			<com:PartyTaxScheme>	
				<xsl:call-template name="PartyTaxScheme">
					<xsl:with-param name="p1" select="cac:Party/cac:PartyLegalEntity/cbc:CompanyID"/>
					<xsl:with-param name="p2" select="cac:Party/cac:PartyLegalEntity/cbc:CompanyID/@schemeID"/>
				</xsl:call-template>
			</com:PartyTaxScheme>	
			<xsl:if test="string(cac:Party/cac:Contact)">
				<com:OrderContact>	
					<xsl:call-template name="Contact">
						<xsl:with-param name="p1" select="cac:Party/cac:Contact/cbc:ID"/>
						<xsl:with-param name="p2" select="cac:Party/cac:Contact/cbc:Name"/>
						<xsl:with-param name="p3" select="cac:Party/cac:Contact/cbc:Telephone"/>
						<xsl:with-param name="p4" select="cac:Party/cac:Contact/cbc:Telefax"/>
						<xsl:with-param name="p5" select="cac:Party/cac:Contact/cbc:ElectronicMail"/>
					</xsl:call-template>
				</com:OrderContact>	
			</xsl:if>
		</com:SellerParty>
	</xsl:template>


	<!-- PaymentMeans template -->
	<xsl:template match="cac:PaymentMeans">
		<xsl:variable name="t1"	select="cbc:PaymentMeansCode"/>
		<xsl:variable name="t2"	select="cbc:PaymentChannelCode"/>
		<xsl:choose>
			<xsl:when test="$t1 = '10'">
				<xsl:call-template name="PaymentMeansCode10"/>
			</xsl:when>
			<xsl:when test="$t1 = '20'">
				<xsl:call-template name="PaymentMeansCode20"/>
			</xsl:when>
			<xsl:when test="$t1 = '31' and $t2 = 'IBAN'">
				<xsl:call-template name="PaymentMeansCode31a"/>
			</xsl:when>
			<xsl:when test="$t1 = '31' and $t2 = 'ZZZ'">
				<xsl:call-template name="PaymentMeansCode31b"/>
			</xsl:when>
			<xsl:when test="$t1 = '42'">
				<xsl:call-template name="PaymentMeansCode42"/>
			</xsl:when>
			<xsl:when test="$t1 = '49'">
				<xsl:call-template name="PaymentMeansCode49"/>
			</xsl:when>
			<xsl:when test="$t1 = '50'">
				<xsl:call-template name="PaymentMeansCode50"/>
			</xsl:when>
			<xsl:when test="$t1 = '93'">
				<xsl:call-template name="PaymentMeansCode93"/>
			</xsl:when>
			<xsl:when test="$t1 = '97' and $t2 = 'DK:NEMKONTO'">
				<xsl:call-template name="PaymentMeansCode97a"/>
			</xsl:when>
			<xsl:when test="$t1 = '97'">
				<xsl:call-template name="PaymentMeansCode97b"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="PaymentMeansCode97b"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- PaymentTerms template -->
	<xsl:template match="cac:PaymentTerms">
		<xsl:variable name="t1"	select="cbc:Amount/@currencyID"/>
		<xsl:if test="count(cac:SettlementPeriod) &gt; 0 or count(cac:PenaltyPeriod) &gt; 0">
			<com:PaymentTerms>	
				<com:ID>SPECIFIC</com:ID>
				<com:RateAmount currencyID="{$t1}"><xsl:value-of select="cbc:Amount"/></com:RateAmount>
				<xsl:if test="string(cbc:SettlementDiscountPercent)"><com:SettlementDiscountRateNumeric><xsl:value-of select="cbc:SettlementDiscountPercent"/>0</com:SettlementDiscountRateNumeric></xsl:if>
				<xsl:if test="string(cbc:PenaltySurchargePercent)"><com:PenaltySurchargeRateNumeric><xsl:value-of select="cbc:PenaltySurchargePercent"/>0</com:PenaltySurchargeRateNumeric></xsl:if>
				<xsl:if test="count(cac:SettlementPeriod) &gt; 0">
					<com:SettlementPeriod>
						<com:EndDateTimeDate><xsl:value-of select="cac:SettlementPeriod/cbc:EndDate"/></com:EndDateTimeDate>
					</com:SettlementPeriod>
				</xsl:if>
				<xsl:if test="count(cac:PenaltyPeriod) &gt; 0">
					<com:PenaltyPeriod>
						<com:StartDateTime><xsl:value-of select="cac:PenaltyPeriod/cbc:StartDate"/>T00:00:00+01:00</com:StartDateTime>
					</com:PenaltyPeriod>
				</xsl:if>
			</com:PaymentTerms>	
		</xsl:if>
	</xsl:template>


	<!-- AllowanceCharge template -->
	<xsl:template name="AllowanceCharge">
		<xsl:param name="Forudbetalt"/>
		<!-- Selekter TAXTotal instanser med pligtkode != 63 -->
		<xsl:apply-templates select="cac:TaxTotal[cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:ID != '63']" mode="afgift">
		</xsl:apply-templates>
		<!-- Selekter cac:AllowanceCharge instanser -->
		<xsl:apply-templates select="cac:AllowanceCharge">
		</xsl:apply-templates>
		<!-- Håndter evt. forudbetalt beløb -->
		<xsl:if test="$Forudbetalt = 'true'">
			<xsl:call-template name="PrepaidAmountAllowance"/>
		</xsl:if>
	</xsl:template>


	<!-- TaxTotal template -->
	<xsl:template name="TaxTotal">
		<xsl:param name="Forudbetalt"/>
		<!-- Selekter instans med pligtkode = 63 -->
		<xsl:apply-templates select="cac:TaxTotal[cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:ID = '63']" mode="skat">
			<xsl:with-param name="Forudbetalt" select="$Forudbetalt"/>
		</xsl:apply-templates>
	</xsl:template>


	<!-- LegalTotals template -->
	<xsl:template match="cac:LegalMonetaryTotal">
		<xsl:variable name="t1"	select="cbc:LineExtensionAmount"/>
		<xsl:variable name="t2"	select="cbc:LineExtensionAmount/@currencyID"/>
		<xsl:variable name="t3"	select="cbc:PayableAmount"/>
		<com:LegalTotals>	
			<com:LineExtensionTotalAmount currencyID="{$t2}"><xsl:value-of select="$t1"/></com:LineExtensionTotalAmount>
			<com:ToBePaidTotalAmount currencyID="{$t2}"><xsl:value-of select="$t3"/></com:ToBePaidTotalAmount>
		</com:LegalTotals>	
	</xsl:template>


	<!-- Fakturalinje template -->
	<xsl:template match="cac:InvoiceLine">
		<xsl:param name="DefaultItemSchemeID"/>
		<xsl:param name="UseDefaultItemSchemeID"/>
		<xsl:param name="Linjespecificeret"/>
		<xsl:param name="DefaultUnitCode"/>
		<xsl:param name="UseDefaultUnitCode"/>
		<xsl:variable name="t1"	select="cbc:LineExtensionAmount"/>
		<xsl:variable name="t2"	select="cbc:InvoicedQuantity/@unitCode"/>
		<xsl:variable name="t3"	select="cbc:InvoicedQuantity"/>
		<xsl:variable name="t4"	select="cbc:LineExtensionAmount/@currencyID"/>
		<xsl:variable name="t5"	select="cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cbc:ID"/>
		<xsl:variable name="t6"	select="/ns:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyName"/>
		<xsl:variable name="t7"	select="/ns:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID/@schemeID"/>
		<xsl:variable name="t8"	select="/ns:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID"/>
		<com:InvoiceLine>
			<com:ID><xsl:value-of select="cbc:ID"/></com:ID>
			<xsl:call-template name="UnitCode">
				<xsl:with-param name="p1" select="'invqu'"/>
				<xsl:with-param name="p2" select="$t2"/> 
				<xsl:with-param name="p3" select="$t3"/>
				<xsl:with-param name="DefaultUnitCode" select="$DefaultUnitCode"/>
				<xsl:with-param name="UseDefaultUnitCode" select="$UseDefaultUnitCode"/>
			</xsl:call-template>
			<com:LineExtensionAmount currencyID="{$t4}"><xsl:value-of select="$t1"/></com:LineExtensionAmount>
			<xsl:choose>
				<xsl:when test="$t5 = 'ReverseCharge'">
					<com:Note><xsl:value-of select="cbc:Note"/> REVERSECHARGE, <xsl:value-of select="$t6"/>, <xsl:value-of select="$t7"/>: <xsl:value-of select="$t8"/></com:Note>
				</xsl:when>
				<xsl:when test="string(cbc:Note)">
					<com:Note><xsl:value-of select="cbc:Note"/></com:Note>
				</xsl:when>
			</xsl:choose>
			<!-- ReferencedOrderLine -->
			<xsl:if test="$Linjespecificeret = 'true'">
				<xsl:call-template name="ReferencedOrderLine">
				</xsl:call-template>
			</xsl:if>
			<!-- AllowanceCharge -->
			<xsl:apply-templates select="cac:TaxTotal[cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:ID != '63']" mode="afgift">
			</xsl:apply-templates>
			<xsl:apply-templates select="cac:AllowanceCharge">
			</xsl:apply-templates>
			<!-- Item -->
			<xsl:apply-templates select="cac:Item">
				<xsl:with-param name="DefaultItemSchemeID" select="$DefaultItemSchemeID"/>
				<xsl:with-param name="UseDefaultItemSchemeID" select="$UseDefaultItemSchemeID"/>
			</xsl:apply-templates>
			<!-- Price -->
			<xsl:apply-templates select="cac:Price">
				<xsl:with-param name="DefaultUnitCode" select="$DefaultUnitCode"/>
				<xsl:with-param name="UseDefaultUnitCode" select="$UseDefaultUnitCode"/>
			</xsl:apply-templates>
		</com:InvoiceLine>
	</xsl:template>


	<!-- Signature template -->
	<xsl:template match="cac:Signature">
		<com:ValidatedSignature>	
			<com:SignatureID><xsl:value-of select="cbc:ID"/></com:SignatureID>
			<xsl:if test="string(cbc:ValidatorID)"><com:ValidatorID><xsl:value-of select="cbc:ValidatorID"/></com:ValidatorID></xsl:if>
			<com:ValidationDateTime><xsl:value-of select="cbc:ValidationDate"/>T<xsl:value-of select="cbc:ValidationTime"/></com:ValidationDateTime>
			<com:Signature><xsl:value-of select="cac:DigitalSignatureAttachment/cbc:EmbeddedDocumentBinaryObject"/></com:Signature>
		</com:ValidatedSignature>	
	</xsl:template>


	<!-- .............................. -->
	<!--   Utility Templates            -->
	<!-- .............................. -->

	<!-- PartyName template -->
	<xsl:template name="PartyName">
		<xsl:param name="p1"/>
		<com:PartyName>
			<com:Name><xsl:value-of select="$p1"/></com:Name>
		</com:PartyName>
	</xsl:template>


	<!-- PartyTaxScheme template -->
	<xsl:template name="PartyTaxScheme">
		<xsl:param name="p1"/>
		<xsl:param name="p2"/>
		<!--  Konverter til OIOXML format  -->
		<xsl:variable name="t1">
			<xsl:choose>
				<xsl:when test="$p2 = 'DK:SE'">SE</xsl:when>
				<xsl:when test="$p2 = 'DK:CVR'">CVR</xsl:when>
				<xsl:when test="$p2 = 'DK:CPR'">CPR</xsl:when>
				<xsl:otherwise><xsl:value-of select="$p2"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t2">
			<xsl:choose>
				<xsl:when test="$p2 = 'DK:SE'"><xsl:value-of select="substring($p1, 3)"/></xsl:when>
				<xsl:when test="$p2 = 'DK:CVR'"><xsl:value-of select="substring($p1, 3)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$p1"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<com:CompanyTaxID schemeID="{$t1}"><xsl:value-of select="$t2"/></com:CompanyTaxID>
	</xsl:template>


	<!-- Address template -->
	<xsl:template name="Address">
		<xsl:param name="p1"/>
		<xsl:param name="p2"/>
		<xsl:param name="p3"/>
		<xsl:param name="p4"/>
		<xsl:param name="p5"/>
		<xsl:param name="p6"/>
		<xsl:param name="p7"/>
		<xsl:param name="p8"/>
		<xsl:param name="CountryCode"/>
		<xsl:variable name="t1">
       			<xsl:choose>
				<xsl:when test="string($p8)"><xsl:value-of select="$p8"/></xsl:when>
	  			<xsl:otherwise><xsl:value-of select="$CountryCode"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t2">
       			<xsl:choose>
				<xsl:when test="string($p1)"><xsl:value-of select="$p1"/></xsl:when>
	  			<xsl:otherwise>n/a</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<com:Address>
			<com:ID><xsl:value-of select="$t2"/></com:ID>
			<xsl:if test="string($p2)"><com:Street><xsl:value-of select="$p2"/></com:Street></xsl:if>
			<xsl:if test="string($p3)"><com:AdditionalStreet><xsl:value-of select="$p3"/></com:AdditionalStreet></xsl:if>
			<xsl:if test="string($p4)"><com:HouseNumber><xsl:value-of select="$p4"/></com:HouseNumber></xsl:if>
			<xsl:if test="string($p5)"><com:InhouseMail><xsl:value-of select="$p5"/></com:InhouseMail></xsl:if>
			<xsl:if test="string($p6)"><com:CityName><xsl:value-of select="$p6"/></com:CityName></xsl:if>
			<xsl:if test="string($p7)"><com:PostalZone><xsl:value-of select="$p7"/></com:PostalZone></xsl:if>
			<com:Country>
				<com:Code><xsl:value-of select="$t1"/></com:Code>
			</com:Country>
		</com:Address>
	</xsl:template>


	<!-- Contact template -->
	<xsl:template name="Contact">
		<xsl:param name="p1"/>
		<xsl:param name="p2"/>
		<xsl:param name="p3"/>
		<xsl:param name="p4"/>
		<xsl:param name="p5"/>
		<xsl:if test="string($p1)"><com:ID><xsl:value-of select="$p1"/></com:ID></xsl:if>
		<xsl:if test="string($p2)"><com:Name><xsl:value-of select="$p2"/></com:Name></xsl:if>
		<xsl:if test="string($p3)"><com:Phone><xsl:value-of select="$p3"/></com:Phone></xsl:if>
		<xsl:if test="string($p4)"><com:Fax><xsl:value-of select="$p4"/></com:Fax></xsl:if>
		<xsl:if test="string($p5)"><com:E-Mail><xsl:value-of select="$p5"/></com:E-Mail></xsl:if>
	</xsl:template>


	<!-- PaymentMeansCode10 template (Kontant) -->
	<xsl:template name="PaymentMeansCode10">
		<!-- <com:PaymentMeans>	-->
			<!-- <com:TypeCodeID>null</com:TypeCodeID> -->
			<!-- <com:PaymentDueDate><xsl:value-of select="cbc:PaymentDueDate"/></com:PaymentDueDate> -->
			<!-- <com:PaymentChannelCode>Nemkonto</com:PaymentChannelCode> -->
		<!-- </com:PaymentMeans> -->	
	</xsl:template>


	<!-- PaymentMeansCode20 template (Check) -->
	<xsl:template name="PaymentMeansCode20">
		<!-- <com:PaymentMeans>	-->
			<!-- <com:TypeCodeID>null</com:TypeCodeID> -->
			<!-- <com:PaymentDueDate><xsl:value-of select="cbc:PaymentDueDate"/></com:PaymentDueDate> -->
			<!-- <com:PaymentChannelCode>Nemkonto</com:PaymentChannelCode> -->
		<!-- </com:PaymentMeans> -->	
	</xsl:template>


	<!-- PaymentMeansCode31a template (International kontooverførsel (EU/EØS land)) -->
	<xsl:template name="PaymentMeansCode31a">
		<com:PaymentMeans>	
			<com:TypeCodeID>null</com:TypeCodeID>
			<xsl:if test="string(cbc:PaymentDueDate)"><com:PaymentDueDate><xsl:value-of select="cbc:PaymentDueDate"/></com:PaymentDueDate></xsl:if>
			<com:PaymentChannelCode>KONTOOVERFØRSEL</com:PaymentChannelCode>
			<com:PayeeFinancialAccount>
				<com:ID><xsl:value-of select="cac:PayeeFinancialAccount/cbc:ID"/></com:ID>
				<com:TypeCode>IBAN</com:TypeCode>
				<com:FiBranch>
					<com:ID>null</com:ID>
					<com:FinancialInstitution>
						<xsl:if test="string(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cac:FinancialInstitution/cbc:ID)"><com:ID><xsl:value-of select="cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cac:FinancialInstitution/cbc:ID"/></com:ID></xsl:if>
						<xsl:if test="string(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cac:FinancialInstitution/cbc:Name)"><com:Name><xsl:value-of select="cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cac:FinancialInstitution/cbc:Name"/></com:Name></xsl:if>
					</com:FinancialInstitution>
				</com:FiBranch>
			</com:PayeeFinancialAccount>
			<xsl:if test="string(cac:PayerFinancialAccount/cbc:PaymentNote) or string(cac:PayeeFinancialAccount/cbc:PaymentNote) ">
				<com:PaymentAdvice>
					<com:AccountToAccount>
						<!-- Obs: payer og payee tolkes forskelligt i de to verdener -->
						<xsl:if test="string(cac:PayeeFinancialAccount/cbc:PaymentNote)"><com:PayerNote><xsl:value-of select="cac:PayeeFinancialAccount/cbc:PaymentNote"/></com:PayerNote></xsl:if>
						<xsl:if test="string(cac:PayerFinancialAccount/cbc:PaymentNote)"><com:PayeeNote><xsl:value-of select="cac:PayerFinancialAccount/cbc:PaymentNote"/></com:PayeeNote></xsl:if>
					</com:AccountToAccount>
				</com:PaymentAdvice>
			</xsl:if>
		</com:PaymentMeans>	
	</xsl:template>


	<!-- PaymentMeansCode31b template (International kontooverførsel (ikke EU/EØS land)) -->
	<xsl:template name="PaymentMeansCode31b">
		<com:PaymentMeans>	
			<com:TypeCodeID>null</com:TypeCodeID>
			<xsl:if test="string(cbc:PaymentDueDate)"><com:PaymentDueDate><xsl:value-of select="cbc:PaymentDueDate"/></com:PaymentDueDate></xsl:if>
			<com:PaymentChannelCode>KONTOOVERFØRSEL</com:PaymentChannelCode>
			<com:PayeeFinancialAccount>
				<com:ID><xsl:value-of select="cac:PayeeFinancialAccount/cbc:ID"/></com:ID>
				<com:TypeCode>null</com:TypeCode>
				<com:FiBranch>
					<com:ID><xsl:value-of select="cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID"/></com:ID>
					<com:FinancialInstitution>
						<com:ID><xsl:value-of select="cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID"/></com:ID>
						<xsl:if test="string(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:Name)"><com:Name><xsl:value-of select="cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:Name"/></com:Name></xsl:if>
					</com:FinancialInstitution>
				</com:FiBranch>
			</com:PayeeFinancialAccount>
			<xsl:if test="string(cac:PayerFinancialAccount/cbc:PaymentNote) or string(cac:PayeeFinancialAccount/cbc:PaymentNote) ">
				<com:PaymentAdvice>
					<com:AccountToAccount>
						<!-- Obs: payer og payee tolkes forskelligt i de to verdener -->
						<xsl:if test="string(cac:PayeeFinancialAccount/cbc:PaymentNote)"><com:PayerNote><xsl:value-of select="cac:PayeeFinancialAccount/cbc:PaymentNote"/></com:PayerNote></xsl:if>
						<xsl:if test="string(cac:PayerFinancialAccount/cbc:PaymentNote)"><com:PayeeNote><xsl:value-of select="cac:PayerFinancialAccount/cbc:PaymentNote"/></com:PayeeNote></xsl:if>
					</com:AccountToAccount>
				</com:PaymentAdvice>
			</xsl:if>
		</com:PaymentMeans>	
	</xsl:template>


	<!-- PaymentMeansCode42 template (Indenlandsk kontooverførsel) -->
	<xsl:template name="PaymentMeansCode42">
		<com:PaymentMeans>	
			<com:TypeCodeID>null</com:TypeCodeID>
			<xsl:if test="string(cbc:PaymentDueDate)"><com:PaymentDueDate><xsl:value-of select="cbc:PaymentDueDate"/></com:PaymentDueDate></xsl:if>
			<com:PaymentChannelCode>KONTOOVERFØRSEL</com:PaymentChannelCode>
			<com:PayeeFinancialAccount>
				<com:ID><xsl:value-of select="cac:PayeeFinancialAccount/cbc:ID"/></com:ID>
				<com:TypeCode>BANK</com:TypeCode>
				<com:FiBranch>
					<com:ID><xsl:value-of select="cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID"/></com:ID>
					<com:FinancialInstitution>
						<com:ID>null</com:ID>
						<xsl:if test="string(cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:Name)"><com:Name><xsl:value-of select="cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:Name"/></com:Name></xsl:if>
					</com:FinancialInstitution>
				</com:FiBranch>
			</com:PayeeFinancialAccount>
			<xsl:if test="string(cac:PayerFinancialAccount/cbc:PaymentNote) or string(cac:PayeeFinancialAccount/cbc:PaymentNote)">
				<com:PaymentAdvice>
					<com:AccountToAccount>
						<!-- Obs: payer og payee tolkes forskelligt i de to verdener -->
						<xsl:if test="string(cac:PayeeFinancialAccount/cbc:PaymentNote)"><com:PayerNote><xsl:value-of select="cac:PayeeFinancialAccount/cbc:PaymentNote"/></com:PayerNote></xsl:if>
						<xsl:if test="string(cac:PayerFinancialAccount/cbc:PaymentNote)"><com:PayeeNote><xsl:value-of select="cac:PayerFinancialAccount/cbc:PaymentNote"/></com:PayeeNote></xsl:if>
					</com:AccountToAccount>
				</com:PaymentAdvice>
			</xsl:if>
		</com:PaymentMeans>	
	</xsl:template>


	<!-- PaymentMeansCode49 template (Betalings- eller leverandørservice) -->
	<xsl:template name="PaymentMeansCode49">
		<com:PaymentMeans>	
			<com:TypeCodeID>null</com:TypeCodeID>
			<xsl:if test="string(cbc:PaymentDueDate)"><com:PaymentDueDate><xsl:value-of select="cbc:PaymentDueDate"/></com:PaymentDueDate></xsl:if>
			<com:PaymentChannelCode>DIRECT DEBET</com:PaymentChannelCode>
			<xsl:if test="string(cbc:InstructionID)"><com:JointPaymentID><xsl:value-of select="cbc:InstructionID"/></com:JointPaymentID></xsl:if>
			<com:PayeeFinancialAccount>
				<com:ID>null</com:ID>
				<com:TypeCode>BANK</com:TypeCode>
				<com:FiBranch>
					<com:ID>null</com:ID>
					<com:FinancialInstitution>
						<com:ID>null</com:ID>
					</com:FinancialInstitution>
				</com:FiBranch>
			</com:PayeeFinancialAccount>
		</com:PaymentMeans>	
	</xsl:template>


	<!-- PaymentMeansCode50 template (Giro) -->
	<xsl:template name="PaymentMeansCode50">
		<com:PaymentMeans>	
			<com:TypeCodeID><xsl:value-of select="cbc:PaymentID"/></com:TypeCodeID>
			<xsl:if test="string(cbc:PaymentDueDate)"><com:PaymentDueDate><xsl:value-of select="cbc:PaymentDueDate"/></com:PaymentDueDate></xsl:if>
			<com:PaymentChannelCode>INDBETALINGSKORT</com:PaymentChannelCode>
			<xsl:if test="string(cbc:InstructionID)"><com:PaymentID><xsl:value-of select="cbc:InstructionID"/></com:PaymentID></xsl:if>
			<com:PayeeFinancialAccount>
				<com:ID><xsl:value-of select="cac:PayeeFinancialAccount/cbc:ID"/></com:ID>
				<com:TypeCode>GIRO</com:TypeCode>
				<com:FiBranch>
					<com:ID>null</com:ID>
					<com:FinancialInstitution>
						<com:ID>null</com:ID>
					</com:FinancialInstitution>
				</com:FiBranch>
			</com:PayeeFinancialAccount>
			<xsl:if test="string(cbc:InstructionNote)">
				<com:PaymentAdvice>
					<com:LongAdvice><xsl:value-of select="cbc:InstructionNote"/></com:LongAdvice>
				</com:PaymentAdvice>
			</xsl:if>
		</com:PaymentMeans>	
	</xsl:template>


	<!-- PaymentMeansCode93 template (FIK) -->
	<xsl:template name="PaymentMeansCode93">
		<com:PaymentMeans>	
			<com:TypeCodeID><xsl:value-of select="cbc:PaymentID"/></com:TypeCodeID>
			<xsl:if test="string(cbc:PaymentDueDate)"><com:PaymentDueDate><xsl:value-of select="cbc:PaymentDueDate"/></com:PaymentDueDate></xsl:if>
			<com:PaymentChannelCode>INDBETALINGSKORT</com:PaymentChannelCode>
			<xsl:if test="string(cbc:InstructionID)"><com:PaymentID><xsl:value-of select="cbc:InstructionID"/></com:PaymentID></xsl:if>
			<xsl:if test="string(cac:CreditAccount/cbc:AccountID)"><com:JointPaymentID><xsl:value-of select="cac:CreditAccount/cbc:AccountID"/></com:JointPaymentID></xsl:if>
			<com:PayeeFinancialAccount>
				<com:ID>null</com:ID>
				<com:TypeCode>FIK</com:TypeCode>
				<com:FiBranch>
					<com:ID>null</com:ID>
					<com:FinancialInstitution>
						<com:ID>null</com:ID>
					</com:FinancialInstitution>
				</com:FiBranch>
			</com:PayeeFinancialAccount>
			<xsl:if test="string(cbc:InstructionNote)">
				<com:PaymentAdvice>
					<com:LongAdvice><xsl:value-of select="cbc:InstructionNote"/></com:LongAdvice>
				</com:PaymentAdvice>
			</xsl:if>
		</com:PaymentMeans>	
	</xsl:template>


	<!-- PaymentMeansCode97a template (Nemkonto) -->
	<xsl:template name="PaymentMeansCode97a">
		<!-- <com:PaymentMeans>	-->
			<!-- <com:TypeCodeID>null</com:TypeCodeID> -->
			<!-- <com:PaymentDueDate><xsl:value-of select="cbc:PaymentDueDate"/></com:PaymentDueDate> -->
			<!-- <com:PaymentChannelCode>Nemkonto</com:PaymentChannelCode> -->
		<!-- </com:PaymentMeans> -->	
	</xsl:template>


	<!-- PaymentMeansCode97b template (Bilateralt aftalt) -->
	<xsl:template name="PaymentMeansCode97b">
		<!-- <com:PaymentMeans>	-->
			<!-- <com:TypeCodeID>null</com:TypeCodeID> -->
			<!-- <com:PaymentDueDate><xsl:value-of select="cbc:PaymentDueDate"/></com:PaymentDueDate> -->
			<!-- <com:PaymentChannelCode>Nemkonto</com:PaymentChannelCode> -->
		<!-- </com:PaymentMeans> -->	
	</xsl:template>


	<!-- TaxTotal template (match) mode = skat -->
	<xsl:template match="cac:TaxTotal" mode="skat">
		<xsl:param name="Forudbetalt"/>
		<xsl:choose>
			<xsl:when test="$Forudbetalt = 'true' and count(cac:TaxSubtotal[cac:TaxCategory/cbc:ID = 'ZeroRated']) = 0">
				<xsl:call-template name="PrepaidAmountTax"/>
			</xsl:when>
			<xsl:when test="$Forudbetalt = 'true' and count(cac:TaxSubtotal[cac:TaxCategory/cbc:ID = 'ZeroRated']) = 1">
				<xsl:call-template name="PrepaidAmountTaxSum"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="StandardTax"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- TaxTotal template (match) mode = afgift -->
	<xsl:template match="cac:TaxTotal" mode = "afgift">
		<xsl:variable name="t1"	select="cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:Name"/>
		<xsl:variable name="t2"	select="cbc:TaxAmount"/>
		<xsl:variable name="t3"	select="cbc:TaxAmount/@currencyID"/>
		<xsl:variable name="t4"	select="cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode"/>
		<xsl:variable name="t5">
			<xsl:choose>
				<xsl:when test="$t4 = 'StandardRated'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<com:AllowanceCharge>	
			<com:ID>Afgift</com:ID>
			<com:ChargeIndicator><xsl:value-of select="$t5"/></com:ChargeIndicator>
			<com:MultiplierReasonCode><xsl:value-of select="$t1"/></com:MultiplierReasonCode>
			<!-- <com:MultiplierFactorQuantity unitCode="Pct." unitCodeListAgencyID="n/a">2</com:MultiplierFactorQuantity> -->
			<com:AllowanceChargeAmount currencyID="{$t3}"><xsl:value-of select="$t2"/></com:AllowanceChargeAmount>
			<!-- <com:BuyersReferenceID></com:BuyersReferenceID> -->
		</com:AllowanceCharge>	
	</xsl:template>


	<!-- AllowanceCharge template (match) -->
	<xsl:template match="cac:AllowanceCharge">
		<xsl:variable name="t1"	select="cbc:AllowanceChargeReason"/>
		<xsl:variable name="t2"	select="cbc:Amount"/>
		<xsl:variable name="t3"	select="cbc:Amount/@currencyID"/>
		<xsl:variable name="t4"	select="cbc:ChargeIndicator"/>
		<xsl:variable name="t5">
			<xsl:choose>
				<xsl:when test="$t4 = 'false'">Rabat</xsl:when>
				<xsl:otherwise>Gebyr</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t6"	select="cac:TaxCategory/cbc:ID"/>
		<xsl:variable name="t7">
			<xsl:choose>
				<xsl:when test="$t6 = 'StandardRated'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<com:AllowanceCharge>	
			<com:ID><xsl:value-of select="$t5"/></com:ID>
			<com:ChargeIndicator><xsl:value-of select="$t7"/></com:ChargeIndicator>
			<com:MultiplierReasonCode><xsl:value-of select="$t1"/></com:MultiplierReasonCode>
			<!-- <com:MultiplierFactorQuantity unitCode="Pct." unitCodeListAgencyID="n/a">2</com:MultiplierFactorQuantity> -->
			<com:AllowanceChargeAmount currencyID="{$t3}"><xsl:value-of select="$t2"/></com:AllowanceChargeAmount>
			<!-- <com:BuyersReferenceID></com:BuyersReferenceID> -->
		</com:AllowanceCharge>	
	</xsl:template>


	<!-- PrepaidAmountAllowance template -->
	<xsl:template name="PrepaidAmountAllowance">
		<xsl:variable name="t1"	select="cac:LegalMonetaryTotal/cbc:PrepaidAmount"/>
		<xsl:variable name="t2"	select="cac:LegalMonetaryTotal/cbc:PrepaidAmount/@currencyID"/>
		<com:AllowanceCharge>	
			<com:ID>Rabat</com:ID>
			<com:ChargeIndicator>false</com:ChargeIndicator>
			<com:MultiplierReasonCode>Forudbetalt beløb</com:MultiplierReasonCode>
			<com:AllowanceChargeAmount currencyID="{$t2}"><xsl:value-of select="$t1"/></com:AllowanceChargeAmount>
		</com:AllowanceCharge>	
	</xsl:template>


	<!-- StandardTax template -->
	<xsl:template name="StandardTax">
		<xsl:variable name="t1"	select="cbc:TaxAmount"/>
		<xsl:variable name="t2"	select="cbc:TaxAmount/@currencyID"/>
		<!-- Der kan være en instans med og uden moms -->
		<xsl:for-each select="cac:TaxSubtotal">
			<xsl:if test = "cac:TaxCategory/cbc:ID = 'ZeroRated' or cac:TaxCategory/cbc:ID = 'ReverseCharge'">
				<com:TaxTotal>	
					<com:TaxTypeCode>ZERO-RATED</com:TaxTypeCode>
					<com:TaxAmounts>
						<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="cbc:TaxableAmount"/></com:TaxableAmount>
						<com:TaxAmount currencyID="{$t2}">0.00</com:TaxAmount>
					</com:TaxAmounts>
					<com:CategoryTotal>
						<com:RateCategoryCodeID>ZERO-RATED</com:RateCategoryCodeID>
						<com:RatePercentNumeric>00</com:RatePercentNumeric>
						<com:TaxAmounts>
							<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="cbc:TaxableAmount"/></com:TaxableAmount>
							<com:TaxAmount currencyID="{$t2}">0.00</com:TaxAmount>
						</com:TaxAmounts>
					</com:CategoryTotal>
				</com:TaxTotal>	
			</xsl:if>
			<xsl:if test = "cac:TaxCategory/cbc:ID = 'StandardRated'">
				<com:TaxTotal>	
					<com:TaxTypeCode>VAT</com:TaxTypeCode>
					<com:TaxAmounts>
						<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="cbc:TaxableAmount"/></com:TaxableAmount>
						<com:TaxAmount currencyID="{$t2}"><xsl:value-of select="cbc:TaxAmount"/></com:TaxAmount>
					</com:TaxAmounts>
					<com:CategoryTotal>
						<com:RateCategoryCodeID>VAT</com:RateCategoryCodeID>
						<com:RatePercentNumeric>25</com:RatePercentNumeric>
						<com:TaxAmounts>
							<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="cbc:TaxableAmount"/></com:TaxableAmount>
							<com:TaxAmount currencyID="{$t2}"><xsl:value-of select="cbc:TaxAmount"/></com:TaxAmount>
						</com:TaxAmounts>
					</com:CategoryTotal>
				</com:TaxTotal>	
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- PrepaidAmountTax template -->
	<xsl:template name="PrepaidAmountTax">
		<xsl:variable name="t1"	select="cbc:TaxAmount"/>
		<xsl:variable name="t2"	select="cbc:TaxAmount/@currencyID"/>
		<xsl:variable name="t3"	select="../cac:LegalMonetaryTotal/cbc:PrepaidAmount"/>
		<com:TaxTotal>	
			<com:TaxTypeCode>ZERO-RATED</com:TaxTypeCode>
			<com:TaxAmounts>
				<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="$t3"/></com:TaxableAmount>
				<com:TaxAmount currencyID="{$t2}">0.00</com:TaxAmount>
			</com:TaxAmounts>
			<com:CategoryTotal>
				<com:RateCategoryCodeID>ZERO-RATED</com:RateCategoryCodeID>
				<com:RatePercentNumeric>00</com:RatePercentNumeric>
				<com:TaxAmounts>
					<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="$t3"/></com:TaxableAmount>
					<com:TaxAmount currencyID="{$t2}">0.00</com:TaxAmount>
				</com:TaxAmounts>
			</com:CategoryTotal>
		</com:TaxTotal>	
		<xsl:if test = "cac:TaxSubtotal/cac:TaxCategory/cbc:ID = 'StandardRated'">
			<com:TaxTotal>	
				<com:TaxTypeCode>VAT</com:TaxTypeCode>
				<com:TaxAmounts>
					<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="cac:TaxSubtotal/cbc:TaxableAmount"/></com:TaxableAmount>
					<com:TaxAmount currencyID="{$t2}"><xsl:value-of select="cac:TaxSubtotal/cbc:TaxAmount"/></com:TaxAmount>
				</com:TaxAmounts>
				<com:CategoryTotal>
					<com:RateCategoryCodeID>VAT</com:RateCategoryCodeID>
					<com:RatePercentNumeric>25</com:RatePercentNumeric>
					<com:TaxAmounts>
						<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="cac:TaxSubtotal/cbc:TaxableAmount"/></com:TaxableAmount>
						<com:TaxAmount currencyID="{$t2}"><xsl:value-of select="cac:TaxSubtotal/cbc:TaxAmount"/></com:TaxAmount>
					</com:TaxAmounts>
				</com:CategoryTotal>
			</com:TaxTotal>	
		</xsl:if>
	</xsl:template>


	<!-- PrepaidAmountTaxSum template -->
	<xsl:template name="PrepaidAmountTaxSum">
		<xsl:variable name="t1"	select="cbc:TaxAmount"/>
		<xsl:variable name="t2"	select="cbc:TaxAmount/@currencyID"/>
		<xsl:variable name="t3"	select="../cac:LegalMonetaryTotal/cbc:PrepaidAmount"/>
		<!-- Der kan være en instans med og uden moms -->
		<xsl:for-each select="cac:TaxSubtotal">
			<xsl:if test = "cac:TaxCategory/cbc:ID = 'ZeroRated' or cac:TaxCategory/cbc:ID = 'ReverseCharge'">
				<com:TaxTotal>	
					<com:TaxTypeCode>ZERO-RATED</com:TaxTypeCode>
					<com:TaxAmounts>
						<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="$t3 + cbc:TaxableAmount"/></com:TaxableAmount>
						<com:TaxAmount currencyID="{$t2}">0.00</com:TaxAmount>
					</com:TaxAmounts>
					<com:CategoryTotal>
						<com:RateCategoryCodeID>ZERO-RATED</com:RateCategoryCodeID>
						<com:RatePercentNumeric>00</com:RatePercentNumeric>
						<com:TaxAmounts>
							<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="$t3 + cbc:TaxableAmount"/></com:TaxableAmount>
							<com:TaxAmount currencyID="{$t2}">0.00</com:TaxAmount>
						</com:TaxAmounts>
					</com:CategoryTotal>
				</com:TaxTotal>	
			</xsl:if>
			<xsl:if test = "cac:TaxCategory/cbc:ID = 'StandardRated'">
				<com:TaxTotal>	
					<com:TaxTypeCode>VAT</com:TaxTypeCode>
					<com:TaxAmounts>
						<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="cbc:TaxableAmount"/></com:TaxableAmount>
						<com:TaxAmount currencyID="{$t2}"><xsl:value-of select="cbc:TaxAmount"/></com:TaxAmount>
					</com:TaxAmounts>
					<com:CategoryTotal>
						<com:RateCategoryCodeID>VAT</com:RateCategoryCodeID>
						<com:RatePercentNumeric>25</com:RatePercentNumeric>
						<com:TaxAmounts>
							<com:TaxableAmount currencyID="{$t2}"><xsl:value-of select="cbc:TaxableAmount"/></com:TaxableAmount>
							<com:TaxAmount currencyID="{$t2}"><xsl:value-of select="cbc:TaxAmount"/></com:TaxAmount>
						</com:TaxAmounts>
					</com:CategoryTotal>
				</com:TaxTotal>	
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- ReferencedOrderLine template -->
	<xsl:template name="ReferencedOrderLine">
		<!-- Vi har en "linjebaseret" faktura! -->
		<xsl:variable name="t1"	select="cac:OrderLineReference/cac:OrderReference/cbc:ID"/>
		<xsl:variable name="t2"	select="cac:OrderLineReference/cac:OrderReference/cbc:SalesOrderID"/>
		<xsl:variable name="t3">
			<xsl:choose>
				<xsl:when test="string($t2)"><xsl:value-of select="$t2"/></xsl:when>
				<xsl:otherwise>n/a</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<com:ReferencedOrderLine>
			<com:BuyersID><xsl:value-of select="$t1"/></com:BuyersID>
			<com:SellersID><xsl:value-of select="$t3"/></com:SellersID>
			<!-- Destinationparty -->
			<!-- Item (mandatory) -->
			<com:Item>
				<com:ID schemeID="n/a">n/a</com:ID>
			</com:Item>
			<!-- DeliveryRequirement (mandatory) -->
			<com:DeliveryRequirement>
				<com:ID>Deliverydate</com:ID>
			</com:DeliveryRequirement>
			<!-- Allowancecharge -->
		</com:ReferencedOrderLine>
	</xsl:template>


	<!-- Item template (match) -->
	<xsl:template match="cac:Item">
		<xsl:param name="DefaultItemSchemeID"/>
		<xsl:param name="UseDefaultItemSchemeID"/>
		<xsl:variable name="t1"	select="cac:SellersItemIdentification/cbc:ID"/>
		<xsl:variable name="t2"	select="cac:SellersItemIdentification/cbc:ID/@schemeAgencyID"/>
		<xsl:variable name="t3"	select="cac:SellersItemIdentification/cbc:ID/@schemeID"/>
		<xsl:variable name="t4">
			<xsl:choose>
				<xsl:when test="$t3 = 'GTIN' or $t3 = 'EAN'">EAN-13</xsl:when>
				<xsl:when test="not(string($t3))">n/a</xsl:when>
				<xsl:otherwise><xsl:value-of select="$t3"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="t10">
			<xsl:choose>
				<xsl:when test="string($t1)"><xsl:value-of select="$t1"/></xsl:when>
				<xsl:otherwise>n/a</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<com:Item>
			<com:ID schemeID="{$t4}"><xsl:value-of select="$t10"/></com:ID>
			<com:Description><xsl:value-of select="cbc:Name"/></com:Description>
			<xsl:apply-templates select="cac:BuyersItemIdentification">
				<xsl:with-param name="DefaultItemSchemeID" select="$DefaultItemSchemeID"/>
				<xsl:with-param name="UseDefaultItemSchemeID" select="$UseDefaultItemSchemeID"/>
			</xsl:apply-templates>
			<xsl:if test="count(cac:SellersItemIdentification) &gt; 0">
				<com:SellersItemIdentification>	
					<com:ID schemeID="{$t4}"><xsl:value-of select="$t10"/></com:ID>
				</com:SellersItemIdentification>	
			</xsl:if>
			<xsl:apply-templates select="cac:ManufacturersItemIdentification">
				<xsl:with-param name="DefaultItemSchemeID" select="$DefaultItemSchemeID"/>
				<xsl:with-param name="UseDefaultItemSchemeID" select="$UseDefaultItemSchemeID"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="cac:StandardItemIdentification">
				<xsl:with-param name="DefaultItemSchemeID" select="$DefaultItemSchemeID"/>
				<xsl:with-param name="UseDefaultItemSchemeID" select="$UseDefaultItemSchemeID"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="cac:CatalogueItemIdentification">
				<xsl:with-param name="DefaultItemSchemeID" select="$DefaultItemSchemeID"/>
				<xsl:with-param name="UseDefaultItemSchemeID" select="$UseDefaultItemSchemeID"/>
			</xsl:apply-templates>

			<!-- ReferencedCatalogue (haves ej) -->

			<xsl:if test="count(cac:CommodityClassification) &gt; 0">
				<xsl:variable name="t5"	select="cac:CommodityClassification/cbc:ItemClassificationCode"/>
				<xsl:variable name="t6"	select="cac:CommodityClassification/cbc:ItemClassificationCode/@listAgencyID"/>
				<xsl:variable name="t7"	select="cac:CommodityClassification/cbc:ItemClassificationCode/@listID"/>
				<xsl:variable name="t8"	select="cac:CommodityClassification/cbc:ItemClassificationCode/@listVersionID"/>
				<xsl:variable name="t9">
					<xsl:choose>
						<xsl:when test="string($t8)"><xsl:value-of select="$t8"/></xsl:when>
						<xsl:otherwise>n/a</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<com:CommodityClassification>	
					<com:CommodityCode listAgencyID="{$t6}" listID="{$t7}" listVersionID="{$t9}"><xsl:value-of select="$t5"/></com:CommodityCode>
				</com:CommodityClassification>	
			</xsl:if>

			<!-- Tax (indsættes kun hvis momsfri vare) -->
			<xsl:if test="../cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cbc:ID = 'ZeroRated'">
				<com:Tax>
					<com:RateCategoryCodeID>ZERO-RATED</com:RateCategoryCodeID>
					<com:TypeCode>ZERO-RATED</com:TypeCode>
					<com:RatePercentNumeric>00</com:RatePercentNumeric>
				</com:Tax>
			</xsl:if>
		</com:Item>
	</xsl:template>


	<!-- Price template (match) -->
	<xsl:template match="cac:Price">
		<xsl:param name="DefaultUnitCode"/>
		<xsl:param name="UseDefaultUnitCode"/>
		<xsl:variable name="t1"	select="cbc:PriceAmount"/>
		<xsl:variable name="t2"	select="cbc:PriceAmount/@currencyID"/>
		<xsl:variable name="t3"	select="cbc:BaseQuantity"/>
		<xsl:variable name="t4"	select="cbc:BaseQuantity/@unitCode"/>
		<xsl:variable name="t6"	select="cbc:OrderableUnitFactorRate"/>
		<!-- Koriger hvis OrderableUnitFactorRate er angivet? -->
		<com:BasePrice>
			<com:PriceAmount currencyID="{$t2}"><xsl:value-of select="$t1"/></com:PriceAmount>
			<xsl:call-template name="UnitCode">
				<xsl:with-param name="p1" select="'price'"/>
				<xsl:with-param name="p2" select="$t4"/> 
				<xsl:with-param name="p3" select="$t3"/>
				<xsl:with-param name="DefaultUnitCode" select="$DefaultUnitCode"/>
				<xsl:with-param name="UseDefaultUnitCode" select="$UseDefaultUnitCode"/>
			</xsl:call-template>
		</com:BasePrice>
	</xsl:template>


	<!-- BuyersItemIdentification template -->
	<xsl:template match="cac:BuyersItemIdentification">
		<xsl:param name="DefaultItemSchemeID"/>
		<xsl:param name="UseDefaultItemSchemeID"/>
		<com:BuyersItemIdentification>
			<xsl:call-template name="ItemScheme">
				<xsl:with-param name="DefaultItemSchemeID" select="$DefaultItemSchemeID"/>
				<xsl:with-param name="UseDefaultItemSchemeID" select="$UseDefaultItemSchemeID"/>
			</xsl:call-template>
		</com:BuyersItemIdentification>
	</xsl:template>


	<!-- ManufacturersItemIdentification template -->
	<xsl:template match="cac:ManufacturersItemIdentification">
		<xsl:param name="DefaultItemSchemeID"/>
		<xsl:param name="UseDefaultItemSchemeID"/>
		<com:ManufacturersItemIdentification>
			<xsl:call-template name="ItemScheme">
				<xsl:with-param name="DefaultItemSchemeID" select="$DefaultItemSchemeID"/>
				<xsl:with-param name="UseDefaultItemSchemeID" select="$UseDefaultItemSchemeID"/>
			</xsl:call-template>
		</com:ManufacturersItemIdentification>
	</xsl:template>


	<!-- StandardItemIdentification template -->
	<xsl:template match="cac:StandardItemIdentification">
		<xsl:param name="DefaultItemSchemeID"/>
		<xsl:param name="UseDefaultItemSchemeID"/>
		<com:StandardItemIdentification>
			<xsl:call-template name="ItemScheme">
				<xsl:with-param name="DefaultItemSchemeID" select="$DefaultItemSchemeID"/>
				<xsl:with-param name="UseDefaultItemSchemeID" select="$UseDefaultItemSchemeID"/>
			</xsl:call-template>
		</com:StandardItemIdentification>
	</xsl:template>


	<!-- CatalogueItemIdentification template -->
	<xsl:template match="cac:CatalogueItemIdentification">
		<xsl:param name="DefaultItemSchemeID"/>
		<xsl:param name="UseDefaultItemSchemeID"/>
		<com:CatalogueItemIdentification>
			<xsl:call-template name="ItemScheme">
				<xsl:with-param name="DefaultItemSchemeID" select="$DefaultItemSchemeID"/>
				<xsl:with-param name="UseDefaultItemSchemeID" select="$UseDefaultItemSchemeID"/>
			</xsl:call-template>
		</com:CatalogueItemIdentification>
	</xsl:template>


	<!-- ItemScheme template -->
	<xsl:template name="ItemScheme">
		<xsl:param name="DefaultItemSchemeID"/>
		<xsl:param name="UseDefaultItemSchemeID"/>
		<xsl:variable name="t1"	select="cbc:ID"/>
		<xsl:variable name="t2"	select="cbc:ID/@schemeID"/>
		<xsl:variable name="t4">
			<xsl:choose>
				<xsl:when test="$t2 = 'EAN' or $t2 = 'GTIN'">EAN-13</xsl:when>
				<xsl:otherwise><xsl:value-of select="$t2"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$UseDefaultItemSchemeID = 'true'">
				<xsl:variable name="t3">
					<xsl:choose>
						<xsl:when test="$t4 = 'n/a'"><xsl:value-of select="$DefaultItemSchemeID"/></xsl:when>
						<xsl:when test="string($t4)"><xsl:value-of select="$t4"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$DefaultItemSchemeID"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<com:ID schemeID="{$t3}"><xsl:value-of select="$t1"/></com:ID>
			</xsl:when>
			<xsl:otherwise>
				<com:ID schemeID="{$t4}"><xsl:value-of select="$t1"/></com:ID>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- UnitCode template -->
	<xsl:template name="UnitCode">
		<xsl:param name="p1"/>
		<xsl:param name="p2"/>
		<xsl:param name="p3"/>
		<xsl:param name="DefaultUnitCode"/>
		<xsl:param name="UseDefaultUnitCode"/>
		<xsl:variable name="t3">
			<xsl:choose>
				<xsl:when test="string($p3)"><xsl:value-of select="$p3"/></xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$UseDefaultUnitCode = 'true'">
				<xsl:variable name="t2">
					<xsl:choose>
						<xsl:when test="$p2 = 'EA'"><xsl:value-of select="$DefaultUnitCode"/></xsl:when>
						<xsl:when test="string($p2)"><xsl:value-of select="$p2"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$DefaultUnitCode"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$p1 = 'price'"><com:BaseQuantity unitCode="{$t2}" unitCodeListAgencyID="n/a"><xsl:value-of select="$t3"/></com:BaseQuantity></xsl:when>
					<xsl:when test="$p1 = 'invqu'"><com:InvoicedQuantity unitCode="{$t2}" unitCodeListAgencyID="n/a"><xsl:value-of select="$t3"/></com:InvoicedQuantity></xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$p1 = 'price'"><com:BaseQuantity unitCode="{$p2}" unitCodeListAgencyID="n/a"><xsl:value-of select="$t3"/></com:BaseQuantity></xsl:when>
					<xsl:when test="$p1 = 'invqu'"><com:InvoicedQuantity unitCode="{$p2}" unitCodeListAgencyID="n/a"><xsl:value-of select="$t3"/></com:InvoicedQuantity></xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
