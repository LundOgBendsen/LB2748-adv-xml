<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:o="http://lundogbendsen.dk/schemas/2021/08/02/persons">
    <xsl:output method="xml" />
    <xsl:strip-space elements="*"/>

    <xsl:template match="o:email">
        <!--make an address element with street and city as xml attributes-->
        <xsl:element name="mail">
            <xsl:attribute name="value">
                <xsl:value-of select="o:localPart"/>
                <xsl:text>@</xsl:text>
                <xsl:value-of select="o:domain"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
