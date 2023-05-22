<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <html>
            <body>
                <h2>My CD Collection</h2>
                <table border="1">
                    <tr bgcolor="#9acd32">
                        <th>Title</th>
                        <th>Artist</th>
                    </tr>
                    <xsl:apply-templates/> <!-- process child elements using matching templates-->
                </table>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="CATALOG">  <!-- match any element named CATALOG-->
        <xsl:apply-templates/> <!--process child elements, i.e. CDs-->
    </xsl:template>

    <xsl:template match="CD"> <!-- match CD elements-->
            <tr>
                <td><xsl:value-of select="TITLE"/></td>
                <td><xsl:value-of select="ARTIST"/></td>
            </tr>
    </xsl:template>

</xsl:stylesheet>