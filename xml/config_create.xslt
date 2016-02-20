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

   <xsl:template match="config/global/*[self::blocks or self::models or self::helpers]/MODULE_NAME">
       <xsl:element name="{$UriName}">
           <xsl:apply-templates select="@* | node()" />
       </xsl:element>
   </xsl:template>

   <xsl:template match="config/global/blocks/MODULE_NAME/class">
       <xsl:copy><xsl:value-of select="$ModuleName" />_Block</xsl:copy>
   </xsl:template>

   <xsl:template match="config/global/models/MODULE_NAME/class">
       <xsl:copy><xsl:value-of select="$ModuleName" />_Model</xsl:copy>
   </xsl:template>

   <xsl:template match="config/global/helpers/MODULE_NAME/class">
       <xsl:copy><xsl:value-of select="$ModuleName" />_Helper</xsl:copy>
   </xsl:template>
</xsl:stylesheet>

