<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:o="http://lundogbendsen.dk/schemas/2021/08/02/persons">
    <xsl:import href="./address.xsl"/>
    <xsl:include href="./emailaddress.xsl"/>
    <xsl:output method="xml" indent="yes"  />
    <xsl:strip-space elements="*"/>


    <xsl:template match="o:persons">
        <users>
            <xsl:apply-templates />
        </users>
    </xsl:template>

    <xsl:template match="o:person">
        <xsl:element name="user">
            <xsl:attribute name="name">
                <xsl:value-of select="o:name"/>
            </xsl:attribute>
            <xsl:apply-templates select="o:address"/>
            <xsl:apply-templates select="o:email"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
