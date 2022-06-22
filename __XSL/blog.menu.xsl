<?xml version="1.0" encoding="utf-8"?>

<!-- by @ruvebal-->

  <xsl:transform
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:atom="http://www.w3.org/2005/Atom"
    
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:func="http://exslt.org/functions"
    xmlns:str="http://exslt.org/strings"
    xmlns:my="tag:plasmasturm.org,2004:EXSLT-Functions"

    exclude-result-prefixes="atom date func str my"
    extension-element-prefixes="date func str my" 
    version="1.1">

  <!-- Parameters are setted in the calling-from template -->

  <xsl:param name="admin" />  
  <xsl:param name="langCurr" />
  <xsl:param name="scriptCurr" />
  <xsl:param name="glossReadEntries" />
  <xsl:param name="glossWriteEntry" />
  <xsl:param name="glossSubscribe" />
  <xsl:param name="titlePage" />


  <!-- Includes -->
  
  <xsl:include href="../common/titlepage.xsl"/>
  

  <!-- Template -->
  
  <xsl:template name="blogMenu" match="/">
    
    <div class="contentHeader">

    <!-- Variables -->
    
    <xsl:variable name="id" select="/atom:feed/atom:id"/>
    
    <xsl:call-template name="titlePage"/>
      <div class="basicTab">
	<ul>
	  <li>
	    <a>
	      <xsl:attribute name="href">./index.php</xsl:attribute>
	      <xsl:if test="contains($scriptCurr, 'index.php') = true()">
		<xsl:attribute name="class">selected</xsl:attribute>
	      </xsl:if>
	      <xsl:value-of select="$glossReadEntries"/>
	    </a>
	  </li>
	  <li>
	    <a>
	      <xsl:attribute name="href">./post.php</xsl:attribute>
	      <xsl:if test="contains($scriptCurr, 'post.php') = true()">
		<xsl:attribute name="class">selected</xsl:attribute>
	      </xsl:if>	   
	      <xsl:value-of select="$glossWriteEntry"/>
	    </a>
	  </li>
	  <li>
	    <a>
	      <xsl:attribute name="href">/rss/index.php?id=<xsl:value-of
		  select="substring-after($id, '/')"/></xsl:attribute>
	      <xsl:value-of select="$glossSubscribe"/>
	    </a>
	  </li>  
	</ul>
      </div>
    </div>
  </xsl:template>
</xsl:transform>