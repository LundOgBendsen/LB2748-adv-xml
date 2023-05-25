<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!--ignore blanks -->
    <xsl:strip-space elements="*"/>
    <!--output text-->
    <xsl:output method="text"/>


    <xsl:template match="/">
        <xsl:apply-templates select="Organisationer"/>
    </xsl:template>

    <xsl:template match="Organisationer">
        <xsl:apply-templates select="Organisation"/>
    </xsl:template>

    <xsl:template match="Organisation">
        <xsl:value-of select="Navn"/>:
        <xsl:apply-templates select="Organisationer"/>
        <xsl:apply-templates select="Personer"/>
    </xsl:template>

    <xsl:template match="Personer">
        <xsl:apply-templates select="Person"/>
    </xsl:template>

    <xsl:template match="Person">
        <xsl:value-of select="Navn"/>:<xsl:value-of select="Alder"/>
        <xsl:text>
        </xsl:text>
    </xsl:template>
</xsl:stylesheet>
