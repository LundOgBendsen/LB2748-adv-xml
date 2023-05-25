<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!--ignore blanks -->
    <xsl:strip-space elements="*"/>
    <!--output text-->
    <xsl:output method="text"/>


    <xsl:template match="/">
        <!-- call Organisationer('  '); -->
        <xsl:apply-templates select="Organisationer">
            <xsl:with-param name="indent" select="'  '"/>
        </xsl:apply-templates>

    </xsl:template>

    <!-- declare function Organisationer(indent){...} -->
    <xsl:template match="Organisationer">
        <xsl:param name="indent" />
        <xsl:apply-templates select="Organisation">
            <xsl:with-param name="indent" select="concat($indent,'  ')"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Organisation">
        <xsl:param name="indent" />
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="Navn"/>:
        <xsl:apply-templates select="Personer">
            <xsl:with-param name="indent" select="concat($indent,'  ')"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="Organisationer">
            <xsl:with-param name="indent" select="concat($indent,'  ')"/>
        </xsl:apply-templates>

    </xsl:template>

    <xsl:template match="Person">
        <xsl:param name="indent"/>
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="Navn"/>:<xsl:value-of select="Alder"/>
        <xsl:text>
        </xsl:text>
    </xsl:template>

</xsl:stylesheet>
