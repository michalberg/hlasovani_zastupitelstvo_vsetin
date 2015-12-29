<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output
    method="html" indent="yes"
    doctype-system="http://www.w3.org/TR/REC-html40/loose.dtd"
    doctype-public="-//W3C//DTD HTML 4.0 Transitional//EN"/>

  
  <xsl:param name="htmlFilesIndexed" select="'no'" />

  <xsl:param name="ltxPageTitle" select="'Výsledek hlasování'" />
  <xsl:param name="ltxSpace" select="' '" />

  <xsl:param name="ltxFullComment" select="'Poznámka: '" />
  <!--
  <xsl:param name="ltxComment" select="'Pozn: '" />

  <xsl:param name="ltxTitle" select="'Výsledky hlasování na zasedání č. '" />

  <xsl:param name="ltxChairman" select="'Předsedající: '" />
  <xsl:param name="ltxDate" select="'Konaného dne  '" />
  <xsl:param name="ltxDateFrom" select="'Konaného od '" />
  <xsl:param name="ltxDateTo" select="' do '" />

  <xsl:param name="ltxVoting" select="'Hlasování'" />
  <xsl:param name="ltxTopic" select="'Bod jednání'" />
  <xsl:param name="ltxPresent" select="'Přítomných'" />
  <xsl:param name="ltxAye" select="'Pro'" />
-->

  <xsl:template match="/">
	  <html>
		  <head>
			  <title>
          <xsl:value-of select="$ltxPageTitle"/>
        </title>
        <!--
			  <meta http-equiv="Content-Type" content="text/html" charset="UTF-8"/>
        -->
			  <STYLE type="text/css">
				  .licensee { font: italic bold 11pt  Arial, sans-serif;	text-align: left; }
				  .title { font: 13pt Arial, sans-serif;	text-align: center; }
				  .big_c { font: 16pt Arial, sans-serif;	text-align: center; }
				  .subtitle { font: 10pt Arial, sans-serif; text-align: center; }
				  .label_l { font: bold 9pt Arial, sans-serif; vertical-align: bottom; text-align: left; }
				  .label_r { font: bold 9pt Arial, sans-serif; vertical-align: bottom; text-align: right; }
				  .value { font: 9pt  Arial, sans-serif; text-align: left; line-height: 9pt; }
				  .totals { font: 10pt  Arial, sans-serif; text-align: right; line-height: 14pt; }
				  .footer { font: bold 7pt  Arial, sans-serif; vertical-align: super; text-align: left; }
		    </STYLE>
		  </head>
    
			<body>
				<table border="0" width="100%">
					<tr>
						<td class="licensee">
							<xsl:value-of select="/VotingResult/Copyright/@licensee"/>
						</td>
					</tr>
					<tr>
						<td height="14"/>
					</tr>
					<tr>
						<td class="title">Výsledek hlasování č.
						  <b>
								<xsl:value-of select="/VotingResult/@number"/>
							</b> - bod č. <b>
								<xsl:value-of select="/VotingResult/Topic/@number"/>
							</b> - <xsl:if test="/VotingResult/Topic/@file[.!='']">tisk č. <b>
									<xsl:value-of select="/VotingResult/Topic/@file"/>
								</b> - </xsl:if>
							<b>
								<xsl:value-of select="/VotingResult/Topic"/>
							</b>
						</td>
					</tr>
					<tr>
						<td height="6"/>
					</tr>
					<tr>
						<td class="subtitle">( Poznámka: <b>
								<xsl:choose>
									<xsl:when test="/VotingResult/@category[.=0]">
										Procedurální: Schválení pořadu jednání
									</xsl:when>
									<xsl:when test="/VotingResult/@category[.=1]">
										Procedurální: Volba návrhové komise
									</xsl:when>
									<xsl:when test="/VotingResult/@category[.=2]">
										Procedurální: Volba ověřovatelů zápisu
									</xsl:when>
									<xsl:when test="/VotingResult/@category[.=3]">
										Procedurální: Udělení slova
									</xsl:when>
									<xsl:when test="/VotingResult/@category[.=4]">
										Procedurální: Ukončení diskuse
									</xsl:when>
									<xsl:when test="/VotingResult/@category[.=5]">
										Procedurální: Třetí a další příspěvek zastupitele
									</xsl:when>
									<xsl:when test="/VotingResult/@category[.=6]">
										Procedurální: Jiné
									</xsl:when>
									<xsl:when test="/VotingResult/@category[.=7]">
										Protinávrh
									</xsl:when>
									<xsl:when test="/VotingResult/@category[.=8]">
										Usnesení
									</xsl:when>
								</xsl:choose>
								<xsl:if test="/VotingResult/Comment[.!='']">
									- <xsl:value-of select="/VotingResult/Comment"/>
								</xsl:if>
							</b> )
						</td>
					</tr>
					<tr>
						<th height="14"/>
					</tr>
				</table>
				<table border="0" width="100%">
					<tr>
						<td colspan="6">
							<table border="0" width="100%">
								<tr>
									<td colspan="5" class="label_l">Zasedání č. <xsl:value-of select="/VotingResult/Session/@number"/> - <xsl:value-of select="/VotingResult/Session"/>
									</td>
									<td class="label_r">Dne <xsl:value-of select="/VotingResult/@time"/>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td height="2" align="left" colspan="6" bgcolor="black"/>
					</tr>

					<xsl:choose>
					<xsl:when test="/VotingResult/@is_secret[.='Yes']">
						<tr>
							<td height="100" class="big_c" colspan="6" >Tajné hlasování
							</td>
						</tr>
					</xsl:when>
					<xsl:otherwise>
            <tr>
              <th height="14" width="8%"/>
              <td height="14" width="8%"/>
              <td height="14" width="4%"/>
              <td height="14" width="50"/>
              <td height="14" width="15%"/>
              <td height="14" width="15%"/>
						</tr>
						<tr>
							<td class="label_r">Řádek</td>
							<td class="label_r">Karta</td>
							<td class="label_r"/>
							<td class="label_l">Titul Jméno Příjmení</td>
							<td class="label_l">Strana</td>
							<td class="label_l">Hlasoval(a)</td>
						</tr>
						<tr>
							<td height="1" align="left" colspan="6" bgcolor="black"/>
						</tr>
						<xsl:for-each select="VotingResult/Deputy">
							<tr class="value">
								<td align="right">
									<xsl:value-of select="@order_a"/>
								</td>
								<td align="right">
									<xsl:value-of select="@card"/>
								</td>
								<td align="right"/>
								<td>
                  <xsl:value-of select="@title"/>
                  <xsl:value-of select="$ltxSpace"/>
                  <xsl:value-of select="@first_name"/>
                  <xsl:value-of select="$ltxSpace"/>
                  <xsl:value-of select="$ltxSpace"/>
                  <xsl:value-of select="$ltxSpace"/>
                  <b>
										<xsl:value-of select="@name"/>
									</b>
								</td>
								<td>
									<xsl:value-of select="@party"/>
								</td>
								<td>
									<xsl:choose>
										<xsl:when test="@vote[.='AYE']">PRO</xsl:when>
										<xsl:when test="@vote[.='NO']">PROTI</xsl:when>
										<xsl:when test="@vote[.='ABSTAINED']">ZDRŽEL SE</xsl:when>
										<xsl:when test="@vote[.='NOT_VOTING']">NEHLASOVAL</xsl:when>
										<xsl:when test="@vote[.='MISSING']">NEPŘÍTOMEN</xsl:when>
									</xsl:choose>
								</td>
							</tr>
						</xsl:for-each>
					</xsl:otherwise>
					</xsl:choose>
					<tr>
						<td height="2" colspan="6" bgcolor="black"/>
					</tr>
					<tr>
						<td colspan="6">
							<table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                  <td height="1" width="30%"></td>
                  <td height="1" width="3%"></td>
                  <td height="1" width="30%"></td>
                  <td height="1" width="3%"></td>
                  <td height="1" width="30%"></td>
                  <td height="1" width="3%"></td>
								</tr>
								<tr class="totals">
									<td>PŘÍTOMNÝCH:</td>
									<td>
										<xsl:value-of select="/VotingResult/@present"/>
									</td>
									<td>
										<b>PRO:</b>
									</td>
									<td>
										<b>
											<xsl:value-of select="/VotingResult/@aye"/>
										</b>
									</td>
									<td>ZDRŽELO SE:</td>
									<td>
										<xsl:value-of select="/VotingResult/@abstained"/>
									</td>
								</tr>
								<tr class="totals">
									<td>NEPŘÍTOMNÝCH:</td>
									<td>
										<xsl:value-of select="/VotingResult/@missing"/>
									</td>
									<td>PROTI:</td>
									<td>
										<xsl:value-of select="/VotingResult/@no"/>
									</td>
										<xsl:choose>
											<xsl:when test="/VotingResult/@is_secret[.='Yes']">
												<td>NEPLATNÉ HLASY:</td>
											</xsl:when>
											<xsl:otherwise>
												<td>NEHLASOVALO:</td>
											</xsl:otherwise>
										</xsl:choose>
									<td>
										<xsl:value-of select="/VotingResult/@not_voting"/>
									</td>
								</tr>
								<tr class="totals">
									<td>ČLENŮ ZASTUPITELSTVA:</td>
									<td>
										<xsl:value-of select="/VotingResult/@deputies"/>
									</td>
									<td/>
									<td/>
									<td/>
									<td/>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td colspan="6">
							<table border="0" cellpadding="0" cellspacing="0" width="100%">
								<tr>
									<td height="1" colspan="2" bgcolor="black"/>
								</tr>
								<tr class="footer">
									<td>
										<xsl:value-of select="/VotingResult/Copyright/@representative"/>
									</td>
									<td align="right">
										<xsl:value-of select="/VotingResult/Copyright/@author"/>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
