<?xml version="1.0" encoding="utf-8"?>

<!-- by @ruvebal-->

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:atom="http://www.w3.org/2005/Atom"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:func="http://exslt.org/functions"
  xmlns:str="http://exslt.org/strings"
  xmlns:my="tag:plasmasturm.org,2004:EXSLT-Functions" exclude-result-prefixes="atom date func str my" extension-element-prefixes="date func str my" version="1.1">


  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" doctype-public="-//W3C//DTD XHTML 1.1//EN" doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" encoding="utf-8" />

  <!-- Includes and Imports-->
  <xsl:include href="blog.menu.xsl"/>
  <!--
  <xsl:import href="../functions/functions.xsl" />
  -->

  <!-- Parameters -->
  <xsl:param name="admin" />
  <xsl:param name="langCurr" />
  <xsl:param name="scriptCurr" />
  <xsl:param name="glossReadEntries" />
  <xsl:param name="glossWriteEntry" />
  <xsl:param name="glossSubscribe" />
  <xsl:param name="titlePage" />

  <!--Variables -->

  <!-- define a few utility templates first of all -->

  <xsl:template match="node()" mode="copy-checking-escaping">
    <xsl:value-of select="normalize-space(.)" />
  </xsl:template>

  <xsl:template match="node()[@mode='xml']" mode="copy-checking-escaping">
    <xsl:copy-of select="*" />
  </xsl:template>

  <xsl:template match="node()[@mode='escaped']" mode="copy-checking-escaping">
    <xsl:value-of select="normalize-space(.)" disable-output-escaping="yes" />
  </xsl:template>

  <xsl:template match="node()" mode="make-link">
    <xsl:variable name="href" select="../atom:link[@rel='alternate' and @type='text/html']/@href" />
    <xsl:choose>
      <xsl:when test="$href">
        <a href="{$href}">
          <xsl:apply-templates select="." mode="copy-checking-escaping" />
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="copy-checking-escaping" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- now we put the style in “stylesheet” -->

  <!-- discard by default: -->
  <xsl:template match="node()|@*" mode="atom-feed" />

  <xsl:template match="atom:entry/atom:issued|atom:entry/atom:modified" mode="atom-feed">
    <div class="{ local-name( . ) }">
      <xsl:text>(</xsl:text>
      <span class="date">
        <xsl:value-of select="my:format-date( . )" />
      </span>
      <xsl:text> @ </xsl:text>
      <span class="time">
        <xsl:value-of select="my:format-time( . )" />
      </span>
      <xsl:text>)</xsl:text>
    </div>
  </xsl:template>

  <xsl:template match="atom:tagline|atom:entry/atom:summary|atom:entry/atom:content" mode="atom-feed">
    <div class="{ local-name( . ) }">
      <xsl:apply-templates select="." mode="copy-checking-escaping" />
    </div>
  </xsl:template>



  <xsl:template match="atom:feed/atom:entry" mode="atom-feed">
    <div class="entry">
      <h2>
        <xsl:apply-templates select="atom:title" mode="make-link" />
      </h2>
      <xsl:apply-templates select="atom:issued" mode="atom-feed" />
      <xsl:if test="date:seconds( date:difference( atom:issued, atom:modified ) ) != 0">
        <xsl:apply-templates select="atom:modified" mode="atom-feed" />
      </xsl:if>
      <xsl:apply-templates select="atom:summary" mode="atom-feed" />
      <xsl:apply-templates select="atom:content" mode="atom-feed" />
    </div>
  </xsl:template>


  <!-- Allready Working -->

  <xsl:template name="entries">

    <div id="BLG" class="teidiv1">
      <ul>
        <xsl:for-each select="/atom:feed/atom:entry">
          <li>
            <span class="titlem">
              <xsl:value-of select="./atom:title"/>
            </span>. 
            <span class="authorm">
              <xsl:value-of select="./atom:author/atom:name"/>
            </span>, 
            <span class="datem">
              <!--
	      <xsl:value-of select="my:format-date(./atom:published)"/>
	      -->
              <xsl:value-of select="atom:published"/>
            </span>. 
            <div class="citquote">
              <xsl:value-of select="./atom:content/node()"/>
            </div>
          </li>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>


  <xsl:template match="atom:feed" mode="atom-feed">

    <xsl:call-template name="blogMenu"/>
    <xsl:call-template name="entries">
      <!--
      <xsl:sort select="date:seconds( atom:updated )" data-type="number" order="descending" />
      -->
    </xsl:call-template>

  </xsl:template>


  <xsl:template match="/">
    <html>
      <head>
        <title>
          <xsl:value-of select="normalize-space(atom:feed/atom:title[@xml:lang=$langCurr
	  or @xml:lang=''][1])" />
        </title>
      </head>
      <body>

        <xsl:apply-templates select="atom:feed" mode="atom-feed" />

      </body>
    </html>
  </xsl:template>


</xsl:transform>