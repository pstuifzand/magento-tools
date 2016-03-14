<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

   <xsl:output indent="yes" />

   <xsl:param name="class_name" />
   <xsl:param name="method_name" />

   <!-- IdentityTransform -->
   <xsl:template match="/ | @* | node()">
         <xsl:copy>
               <xsl:apply-templates select="@* | node()" />
         </xsl:copy>
   </xsl:template>

   <xsl:template match="config/global/blocks">
       <xsl:copy>
           <xsl:apply-templates select="@* | node()" />

           <xsl:element name="{$rewrite_package}">
               <rewrite>
                   <xsl:element name="{$rewrite_class}"><xsl:value-of select="$class_name" /></xsl:element>
               </rewrite>
           </xsl:element>
       </xsl:copy>
   </xsl:template>

   <!--
   <xsl:template match="config/global[not(blocks)]">
       <xsl:copy>
           <xsl:apply-templates select="@* | node()" />
           <blocks>
               <xsl:element name="{$event_name}">
                   <observers>
                       <xsl:element name="{$observer_name}">
                           <class><xsl:value-of select="$class_name" /></class>
                           <method><xsl:value-of select="$method_name" /></method>
                       </xsl:element>
                   </observers>
               </xsl:element>
           </blocks>
       </xsl:copy>
   </xsl:template>
   -->

</xsl:stylesheet>
