package  {
	
	import tw.cameo.data.WordPressParser;
	import tw.cameo.net.FileCache;
	
	public class ContentAndQuizParser extends WordPressParser
	{
		public var funcConverter : Function = null;
		public function ContentAndQuizParser(strPathFile : String = null) 
		{
			super(strPathFile);
		}

		public function parseContent(dicData : Object) : *
		{
			var strContent : String = dicData.content;
			var intContentIndexStart:int = strContent.indexOf("[有獎問答]：");
			var intContentIndexEnd:int;
			if( intContentIndexStart != -1){
				var intContentIndexLinkStart:int = strContent.indexOf("<a href=\"", intContentIndexStart) + 9;
				intContentIndexEnd = strContent.indexOf("\">", intContentIndexLinkStart);

				dicData["quiz"] = strContent.substring(intContentIndexLinkStart, intContentIndexEnd);
			}

			var xmlContent : XML;
			if( intContentIndexStart != -1){
				//把內容中 "[有獎問答]" 的資料過濾掉:
				intContentIndexEnd = strContent.indexOf("</a>", intContentIndexStart) + 4;
				var strPattern = strContent.substring(intContentIndexStart, intContentIndexEnd);
  	        	xmlContent = new XML("<content>" + strContent.replace(strPattern, "") + "</content>");
			}
			else{
            	xmlContent = new XML("<content>" + dicData.content + "</content>");
			}
			
            var intCount : Number = xmlContent.p.length();
            var lstDicImage : Array = new Array();
            var strContentText : String = "";
			// 欄位相關變數
			var isFieldStarted : Boolean = false;
			var lstStrFieldToStrValue : Array = [];
			var intMaxField : Number = 0;
			var strField = null;
			var strValue = null;
			
            for (var i : Number = 0; i < intCount; i++)
            {
                    var paragraph : XML = xmlContent.p[i];
                    var lstImg : XMLList = paragraph..img;
                    if (lstImg.length() > 0)
                    {
                        for (var j : Number = 0; j <lstImg.length(); j++)
                        {
                            var strImgSrc : String = lstImg[j].@src;
							var fileCache : FileCache = new FileCache(strImgSrc);
							if (fileCache.isCached == false) fileCache.download();

                            lstDicImage.push({ title: lstImg[j].@alt, image: fileCache.toString() });
                        }
                    }
                    else
                    {
                try
                {
                        var strText : String = paragraph.toString();
                        if (strText)
                        {
							var lstStr : Array = strText.split("\n");
							for (var k in lstStr)
							{
								var str : String = lstStr[k];
								trace("ContentAndQuizParser: Raw Line = " + str);
								if (/^(.*?)(\[.+?\]：)(.*?)$/.test(str))
								{
									if (isFieldStarted)
									{
										// 2014-05-08 Noin: 把前一個欄位存起來
										lstStrFieldToStrValue.push({ "field": strField, "value": strValue });
										trace("ContentAndQuizParser: value = " + strValue);
									}
									// 2014-05-08 Noin: 找到欄位
									isFieldStarted = true;
									var result = /(.*?)(\[.+?\]：)(.*?)$/.exec(str);
									strField = result[2];
									strValue = result[3];
									trace("ContentAndQuizParser: field = " + strField);
									
									// 2014-05-08 Noin: 取得欄位名稱最大長度
									intMaxField = Math.max(intMaxField, strField.length);
								}
								else
								{
									if (isFieldStarted)
									{
										// 2014-05-08 Noin: 欄位已經開始就附加到欄位值
										strValue += str + "\n";
									}
									else
									{
										// 2014-05-08 Noin: 不屬於欄位則直接附在內容文字
										strContentText += str + "\n";
									}
								}
							}
                        }

                }
                catch (error : Error)
                {
                    trace(error.getStackTrace());
                }
                    }
            }
			if (isFieldStarted)
			{
				// 2014-05-16 Noin: 把最後的欄位存起來
				lstStrFieldToStrValue.push({ "field": strField, "value": strValue });
			}

			var strFields : String = "";
			if (lstStrFieldToStrValue.length > 0)
			{
				strFields += "<table cellpadding=\"0\" cellspacing=\"0\">";
				for (var m in lstStrFieldToStrValue)
				{
					var dic = lstStrFieldToStrValue[m];
					var intFieldWidth : Number = funcConverter((intMaxField - 1) * 36);
					var intValueWidth : Number = funcConverter(564) - intFieldWidth;
					strFields += "<tr><td style=\"vertical-align: top; width: " + intFieldWidth + "px\">" + dic.field + "</td><td style=\"width: " + intValueWidth + "px\">" + dic.value + "</td></tr>";
				}
				strFields += "</table>\n";
			}
			strContentText = strFields + strContentText;
						
			dicData.lstStrFieldToStrValue = lstStrFieldToStrValue;
			dicData.lstDicImage = ((lstDicImage.length == 0) ? (null) : (lstDicImage));
			dicData.content = strContentText;

			return dicData;
		}

		public override function parse() : *
		{
			super.parse();
			if (data.length == 0) return data;
			
			//Roy: 問卷要特別處理
			var strContent:String = data[0].content;
			var intContentIndexStart:int = strContent.indexOf("[有獎問答]：");
			var intContentIndexEnd:int;
			if( intContentIndexStart != -1){
				var intContentIndexLinkStart:int = strContent.indexOf("<a href=\"", intContentIndexStart) + 9;
				intContentIndexEnd = strContent.indexOf("\">", intContentIndexLinkStart);
				
				data[0]["quiz"] = strContent.substring(intContentIndexLinkStart, intContentIndexEnd);
			}

			var xmlContent : XML;
			if( intContentIndexStart != -1){
				//把內容中 "[有獎問答]" 的資料過濾掉:
				intContentIndexEnd = strContent.indexOf("</a>", intContentIndexStart) + 4;
				var strPattern = strContent.substring(intContentIndexStart, intContentIndexEnd);
  	        	xmlContent = new XML("<content>" + strContent.replace(strPattern, "") + "</content>");
			}
			else{
            	xmlContent = new XML("<content>" + data[0].content + "</content>");
			}
			
            var intCount : Number = xmlContent.p.length();
            var lstDicImage : Array = new Array();
            var strContentText : String = "";
			// 欄位相關變數
			var isFieldStarted : Boolean = false;
			var lstStrFieldToStrValue : Array = [];
			var intMaxField : Number = 0;
			var strField = null;
			var strValue = null;
			
            for (var i : Number = 0; i < intCount; i++)
            {
                try
                {
                    var paragraph : XML = xmlContent.p[i];
                    var lstImg : XMLList = paragraph..img;
                    if (lstImg.length() > 0)
                    {
                        for (var j : Number = 0; j <lstImg.length(); j++)
                        {
                            var strImgSrc : String = lstImg[j].@src;
							var fileCache : FileCache = new FileCache(strImgSrc);
							if (fileCache.isCached == false) fileCache.download();

                            lstDicImage.push({ title: lstImg[j].@alt, image: fileCache.toString() });
                        }
                    }
                    else
                    {
                        var strText : String = paragraph.toString();
                        if (strText)
                        {
							var lstStr : Array = strText.split("\n");
							for (var k in lstStr)
							{
								var str : String = lstStr[k];
								trace("ContentAndQuizParser: Raw Line = " + str);
								if (/^(.*?)(\[.+?\]：)(.*?)$/.test(str))
								{
									if (isFieldStarted)
									{
										// 2014-05-08 Noin: 把前一個欄位存起來
										lstStrFieldToStrValue.push({ "field": strField, "value": strValue });
										trace("ContentAndQuizParser: value = " + strValue);
									}
									// 2014-05-08 Noin: 找到欄位
									isFieldStarted = true;
									var result = /(.*?)(\[.+?\]：)(.*?)$/.exec(str);
									strField = result[2];
									strValue = result[3];
									trace("ContentAndQuizParser: field = " + strField);
									
									// 2014-05-08 Noin: 取得欄位名稱最大長度
									intMaxField = Math.max(intMaxField, strField.length);
								}
								else
								{
									if (isFieldStarted)
									{
										// 2014-05-08 Noin: 欄位已經開始就附加到欄位值
										strValue += str + "\n";
									}
									else
									{
										// 2014-05-08 Noin: 不屬於欄位則直接附在內容文字
										strContentText += str + "\n";
									}
								}
							}
                        }
                    }
                }
                catch (error : Error)
                {
                    trace(error.getStackTrace());
                }
            }
			if (isFieldStarted)
			{
				// 2014-05-16 Noin: 把最後的欄位存起來
				lstStrFieldToStrValue.push({ "field": strField, "value": strValue });
			}

			var strFields : String = "";
			if (lstStrFieldToStrValue.length > 0)
			{
				strFields += "<table cellpadding=\"0\" cellspacing=\"0\">";
				for (var m in lstStrFieldToStrValue)
				{
					var dic = lstStrFieldToStrValue[m];
					var intFieldWidth : Number = funcConverter((intMaxField - 1) * 36);
					var intValueWidth : Number = funcConverter(564) - intFieldWidth;
					strFields += "<tr><td style=\"vertical-align: top; width: " + intFieldWidth + "px\">" + dic.field + "</td><td style=\"width: " + intValueWidth + "px\">" + dic.value + "</td></tr>";
				}
				strFields += "</table>\n";
			}
			strContentText = strFields + strContentText;
						
			data[0]["lstStrFieldToStrValue"] = lstStrFieldToStrValue;
			data[0]["lstDicImage"] = ((lstDicImage.length == 0) ? (null) : (lstDicImage));
			data[0]["content"] = strContentText;

			trace("ContentAndQuizParser: Content -> ", strContentText);

			return data[0];
		}
	}	
}
