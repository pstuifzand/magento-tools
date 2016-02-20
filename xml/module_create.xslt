<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

   <xsl:param name="ModuleName" />
   <xsl:param name="UriName" />

   <!-- IdentityTransform -->
   <xsl:template match="/ | @* | node()">
         <xsl:copy>
               <xsl:apply-templates select="@* | node()" />
         </xsl:copy>
   </xsl:template>

   <xsl:template match="config/modules/MODULE_NAME">
       <xsl:element name="{$ModuleName}">
           <xsl:apply-templates select="@* | node()" />
       </xsl:element>
   </xsl:template>

</xsl:stylesheet>
