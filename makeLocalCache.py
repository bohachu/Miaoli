#!/usr/bin/python

from urllib2 import urlopen, quote
from md5 import md5
import libxml2
import os.path
from datetime import datetime

STR_WEB_SERVER = "http://chiayi.tapmovie.com"
STR_PATH_PREFIX = "/chiayiapp/"

def getImgSrc(node):
    for property in node.properties:
        if (property.name == 'src'):
            return property.content

def getMd5(str):
    return md5(str).hexdigest()
    
def getStrFromURL(strURL):
    downloadToFile(strURL)
    return urlopen(strURL).read()

def getAllImageInDoc(doc):
    context = doc.xpathNewContext()
    context.xpathRegisterNs("content", "http://purl.org/rss/1.0/modules/content/")
    for item in context.xpathEval("//item/content:encoded"):
        docItem = libxml2.parseDoc("<!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd' ><item>" + item.getContent() + "</item>")
        for img in docItem.xpathEval("//img"):
            strSrc = getImgSrc(img)
            intIndex = strSrc.rindex(".")
            strSrc = strSrc[0:intIndex] + "-150x150" + strSrc[intIndex:]
            downloadToFile(strSrc)

def getLinkIndoc(doc):
    lstStrLink = []
    for link in doc.xpathEval("//item/link"):
        strLink = link.getContent() + "feed/?withoutcomments=1"
        print(unicode(strLink, 'utf-8', 'ignore'))
        lstStrLink.append(strLink)
    return lstStrLink

def downloadToFile(strURL):
    strPath = "cache/" + getMd5(strURL)
    if (os.path.exists(strPath)): 
        return
    print strURL + "-> " + strPath

    f = open(strPath, "wb")
    f.write(urlopen(strURL).read())
    f.close()

if __name__ == '__main__':
    dt = datetime(1970, 1, 1)
    intDate = (datetime.now() - dt).total_seconds()
    
    file = open(r"cache\info.txt", "w")
    file.write("%s" % intDate)
    file.close()
    
    exit;

    lstStrURL = [
        STR_WEB_SERVER + STR_PATH_PREFIX + "cat/%E5%A5%BD%E5%BA%B7%E5%A0%B1%E4%BD%A0%E7%9F%A5/feed/",
        STR_WEB_SERVER + STR_PATH_PREFIX + "cat/%E6%96%B0%E8%81%9E%E7%9C%8B%E6%9D%BF/feed/",
        STR_WEB_SERVER + STR_PATH_PREFIX + "cat/%E6%B4%BB%E5%8B%95%E7%9C%8B%E6%9D%BF/feed/",
        STR_WEB_SERVER + STR_PATH_PREFIX + "cat/%E5%BD%B1%E9%9F%B3%E5%85%A7%E5%AE%B9/feed/",
    ];
    
    lstStrURLSub = [
        
    ];
    for strURL in lstStrURL:
        doc = libxml2.parseDoc(getStrFromURL(strURL))
        getAllImageInDoc(doc)
        
        lstStrURLSub.extend(getLinkIndoc(doc))
        
        dicStrTitleToIntCount = {}
        for nodeTitle in doc.xpathEval("//item/title"):
            strTitle = nodeTitle.getContent();#.split('-')[1]
            dicStrTitleToIntCount.setdefault(strTitle, 0)
            dicStrTitleToIntCount[strTitle] += 1;

        for strTitle in dicStrTitleToIntCount:
            if (dicStrTitleToIntCount[strTitle] == 1):
                continue
            strURLList = strURL.replace("/feed/", "+" + quote(strTitle) + "/feed/")
            downloadToFile(strURLList)
            docList = libxml2.parseDoc(getStrFromURL(strURLList))
            lstStrURLSub.extend(getLinkIndoc(docList))

    for strURL in lstStrURLSub:
        doc = libxml2.parseDoc(getStrFromURL(strURL))
        getAllImageInDoc(doc)

    downloadToFile(STR_WEB_SERVER + STR_PATH_PREFIX + "js/jquery.min.js");
    downloadToFile(STR_WEB_SERVER + STR_PATH_PREFIX + "js/swipe.js");
    downloadToFile(STR_WEB_SERVER + STR_PATH_PREFIX + "images/background_item_article_list.png");
    downloadToFile(STR_WEB_SERVER + STR_PATH_PREFIX + "images/background_item_subject_view.png");
    downloadToFile(STR_WEB_SERVER + STR_PATH_PREFIX + "images/background_page.png");
    downloadToFile(STR_WEB_SERVER + STR_PATH_PREFIX + "images/background_page_subject_view.png");
    downloadToFile(STR_WEB_SERVER + STR_PATH_PREFIX + "images/fb.png");
    downloadToFile(STR_WEB_SERVER + STR_PATH_PREFIX + "images/next.png");
    downloadToFile(STR_WEB_SERVER + STR_PATH_PREFIX + "images/prev.png");
    downloadToFile(STR_WEB_SERVER + STR_PATH_PREFIX + "images/image_default_article_list.png");
    downloadToFile(STR_WEB_SERVER + STR_PATH_PREFIX + "images/Questions.png");