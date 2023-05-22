<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <html>
            <head>
                <style>
                    table, th, td {
                    border: 1px solid black;
                    border-collapse: collapse;
                    }
                </style>
            </head>
            <body>
                <table>
                    <tr>
                        <td>Name</td>
                        <td>Ownership</td>
                    </tr>
                    <xsl:apply-templates select="/owners/legal-unit"/>
                </table>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="legal-unit">
        <tr>
            <td>
                <xsl:value-of select="company/name"/>
                <xsl:value-of select="@role"/><xsl:text> </xsl:text> <!-- space -->
                <xsl:value-of select="person/firstname"/><xsl:text> </xsl:text> <!-- space -->
                <xsl:value-of select="person/lastname"/>
            </td>
            <td>
                <xsl:value-of select="ownership"/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
