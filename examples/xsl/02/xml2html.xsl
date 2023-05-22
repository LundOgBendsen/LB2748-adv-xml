<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <html>
            <body>
                <h2>Roden</h2>
                 <i>
                     <xsl:apply-templates/>
                 </i>
             </body>
        </html>
    </xsl:template>

    <xsl:template match="minZoo">
        <h2>kbh zoo</h2>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="minZoo/dyr">
        <h2>Dyr</h2>
        Art: <xsl:value-of select="art"/>
        Navn: <xsl:value-of select="navn"/>
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="bur">
        <h3>Bur</h3>
        No: <xsl:value-of select="@no"/>
        Type: <xsl:value-of select="@type"/>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="dyr">
        <p>Dyr</p>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="art">
        Art: <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="navn">
        Navn: <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="bygning">
        <h2>Bygning</h2>
        No: <xsl:value-of select="@no"/>
        <xsl:apply-templates/>
    </xsl:template>


</xsl:stylesheet>