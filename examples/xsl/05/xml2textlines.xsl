<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:o="http://lundogbendsen.dk/schemas/2021/08/02/Owners">
    <xsl:output method="text" indent="no"  />
    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
       <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="user">
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
        <xsl:value-of select="name"/>
        <xsl:text>, </xsl:text>
        <xsl:apply-templates select="./email"/>
        <xsl:text disable-output-escaping="no">&gt;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="address">
        <xsl:value-of select="localPart"/>
        <xsl:text>@</xsl:text>
        <xsl:value-of select="domain"/>
    </xsl:template>
</xsl:stylesheet>
