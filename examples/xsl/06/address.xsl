<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:o="http://lundogbendsen.dk/schemas/2021/08/02/persons">
    <xsl:output method="xml" />
    <xsl:strip-space elements="*"/>

    <xsl:template match="o:address">
        <!--make an address element with street and city as xml attributes-->
        <xsl:element name="address">
            <xsl:attribute name="street">
                <xsl:value-of select="o:street"/>
            </xsl:attribute>
            <xsl:attribute name="city">
                <xsl:value-of select="o:city"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
