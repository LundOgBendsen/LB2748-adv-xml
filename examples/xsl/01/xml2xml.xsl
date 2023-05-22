<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <items>
           <xsl:apply-templates/> <!-- process child elements using matching templates-->
        </items>
    </xsl:template>


    <!-- show how to convert a nested element structure to one element with attributes -->
    <xsl:template match="CD"> <!-- match CD elements-->
                <xsl:element name="item"> <!--create element <item> -->
                    <xsl:attribute name="type">  <!-- create type='cd' attribute-->
                        <xsl:value-of select="'cd'"/>
                    </xsl:attribute>
                    <xsl:attribute name="title"> <!-- create title='actual title' attribute-->
                        <xsl:value-of select="TITLE"/>
                    </xsl:attribute>
                    <xsl:attribute name="author"> <!-- create author='actual artist' attribute-->
                        <xsl:value-of select="ARTIST"/>
                    </xsl:attribute>
                </xsl:element>
    </xsl:template>
</xsl:stylesheet>