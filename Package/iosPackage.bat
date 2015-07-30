copy /Y C:\github\ChiaYi\Main.swf
call "C:\Program Files (x86)\Adobe\Adobe Flash CS6\AIR15\bin\adt" -package -target ipa-test -provisioning-profile cameo_enterprise.mobileprovision -storetype pkcs12 -keystore cameo_enterprise.p12 -storepass cameo ChiaYi-v2.10.1210.ipa Main-app-ios.xml -extdir "C:\github\flashcommon\ane\iOS" Main.swf Default.png Default@2x.png Default-568h@2x.png icons Resource cache

pause