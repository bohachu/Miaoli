copy /Y C:\github\Miaoli\Main.swf
call "C:\Program Files (x86)\Adobe\Adobe Flash CS6\AIR15\bin\adt" -package -target ipa-test -provisioning-profile ChiaYiAppProfile_AppStore.mobileprovision -storetype pkcs12 -keystore Miaoli_AppStore.p12 -storepass cameo Miaoli-v0.1.1-appStore.ipa Main-app-ios-appstore.xml -extdir "C:\github\flashcommon\ane\iOS" Main.swf Default.png Default@2x.png Default-568h@2x.png icons Resource cache

pause