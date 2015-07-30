copy /Y C:\github\ChiaYi\Main.swf
call "C:\Program Files (x86)\Adobe\Adobe Flash CS6\AIR3.7\bin\adt" -package -target apk-captive-runtime -storetype pkcs12 -keystore androidFlash.p12 -storepass 123456 ChiaYi-v2.11.8.apk Main-app-android.xml -extdir "C:\github\flashcommon\ane\Android" Main.swf icons Resource cache

pause
