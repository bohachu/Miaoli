package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IEventDispatcher;
	import flash.filesystem.*;
	import flash.net.SharedObject;
	import flash.media.SoundMixer;
	import flash.system.System;
	import tw.cameo.TitleBarAndSideMenu;
	import tw.cameo.EventChannel;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.events.TitleBarEvent;
	import tw.cameo.WebViewLog;
	import flash.text.*; 
	
	// Cache
	import tw.cameo.net.FileCache;
	import tw.cameo.net.FileCacheManager;
	import tw.cameo.net.BackgroundURLLoader;
	import tw.cameo.data.WordPressParser;
	
	// for Android Splash Screen
	import flash.system.Capabilities;
	import tw.cameo.SplashScreenForAndroid;
	
	// content
	import tw.cameo.UI.PageMapOneView;
	import tw.cameo.UI.PageMapRoute;
	import tw.cameo.UI.PageArticleList;
	import tw.cameo.UI.PagePhotoWithTitleAndTextAndQuiz;
	import tw.cameo.UI.PageSubjectView;
	import tw.cameo.UI.PageCalendar;
	import tw.cameo.UI.LoadingIndicator;
	import tw.cameo.InternetStatus;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import ContentAndQuizParser;
	
	CAMEO::ANE {
	import tw.cameo.lib.WebViewNativeExtension;
	import tw.cameo.lib.WebViewNativeExtensionEvent;
	}
	
	// BACK KEY
	import flash.desktop.NativeApplication;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;

	// Push Notification	
	import flash.notifications.NotificationStyle; 
    import flash.notifications.RemoteNotifier; 
    import flash.notifications.RemoteNotifierSubscribeOptions; 
    import flash.events.RemoteNotificationEvent; 
    import flash.events.StatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	CAMEO::Android {
		import tw.cameo.pushnotification.PushNotification;
	}
	
	public class Main extends MovieClip {
		
		static public const FEED_URL_INFO:String = "cat/%E5%A5%BD%E5%BA%B7%E5%A0%B1%E4%BD%A0%E7%9F%A5/feed/";
		static public const FEED_URL_NEWS:String = "cat/%E6%96%B0%E8%81%9E%E7%9C%8B%E6%9D%BF/feed/";
		static public const FEED_URL_ACT:String = "cat/%E6%B4%BB%E5%8B%95%E7%9C%8B%E6%9D%BF/feed/";
		static public const FEED_URL_VIDEO:String = "cat/%E5%BD%B1%E9%9F%B3%E5%85%A7%E5%AE%B9/feed/";
		
		static public const CACHE_INFO:String = "INFO";
		static public const CACHE_NEWS:String = "NEWS";
		static public const CACHE_ACT:String = "ACT";
		static public const CACHE_VIDEO:String = "VIDEO";
		
		private var sharedObject:SharedObject = null;;
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var splashScreenForAndroid:SplashScreenForAndroid = null;
		private var navigator:TitleBarAndSideMenu = null;
		private var internetStatus : InternetStatus = null;

		// Push Notification
		private var remoteNotifierSubscribeOptions : RemoteNotifierSubscribeOptions = new RemoteNotifierSubscribeOptions(); 
        private var remoteNotifier : RemoteNotifier = new RemoteNotifier(); 
		
		// 20140507 roy: Show unread article number 
		private var isShowUpdateIcon:Boolean = false;
		private var isShowUpdateIconNews:Boolean = false;
		private var isShowUpdateIconAct:Boolean = false;
		private var isShowUpdateIconVideo:Boolean = false;
		private var isShowUpdateIconOthers:Boolean = false;
		private var movieclipNewInfo = new MovieclipNewInfo();
		private var movieclipNewInfoNews = new MovieclipNewInfo();
		private var movieclipNewInfoAct = new MovieclipNewInfo();
		private var movieclipNewInfoVideo = new MovieclipNewInfo();
		private var movieclipNewInfoBG = new MovieclipNewInfoBG();
		private var labelNum:TextField = new TextField();
		private var newFormat2:TextFormat = new TextFormat();
		
		private var _isChecking : Boolean = false;
		private var _backgroundLoader : BackgroundURLLoader = null;
		private var _isCheckingNews : Boolean = false;
		private var _isCheckingAct : Boolean = false;
		
		public function Main() {
			// constructor code
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			this.stage.addEventListener(Event.DEACTIVATE, deactivateHandler);
		}
		
		private function init (e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			// for Dynamic Create  roy
			var titleBarIconHome     : TitleBarIcon_Home = null;
			var titleBarIconBack     : TitleBarIcon_Back = null;
			var titleBarIconSideMenu : TitleBarIcon_SideMenu = null;
			var titleBarIconLocate   : TitleBarIcon_Locate = null;
			var titleBarIconListView   : TitleBarIcon_ListView = null;  //20140405 add by roy
			var titleBarIconCalendarView   : TitleBarIcon_CalendarView = null;  //20140405 add by roy
			CAMEO::ANE {
			var pageArticleList      	  		 : PageArticleList = null;
			var pageSubjectView           		 : PageSubjectView = null;
			var pagePhotoWithTitleAndTextAndQuiz : PagePhotoWithTitleAndTextAndQuiz = null;
			var pageCalendar              		 : PageCalendar = null;
			}

			// add by mark
			CAMEO::Android {
				var pushNotification : PushNotification = new PushNotification();
				pushNotification.registerDevice("120057183953", CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX);
			}

			// add by mark
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownEevnt);
			// end by mark
			
			this.internetStatus = InternetStatus.getInstance();
			//Roy 20140321: 第一次與每次切開APP時檢查網路並跳出訊息
			this.addEventListener(Event.ACTIVATE, activateSceneHandler, false, 100, false);
			
			eventChannelAddEventListener();
			
			if (Capabilities.os.indexOf("iPhone") == -1) {
				splashScreenForAndroid = new SplashScreenForAndroid();
				this.stage.addChild(splashScreenForAndroid);
				splashScreenForAndroid.addEventListener(SplashScreenForAndroid.OnSplashScreenTimer, onSplashScreenTimer);
			} else {
				// 2014-02-11 bigcookie: 加入這行讓 app 背景執行，以免 iOS 跳出後被重開
				NativeApplication.nativeApplication.executeInBackground = true;
				createHome();
				
				//Roy 20140321: 第一次與每次切開APP時檢查網路並跳出訊息
				checkInternetStatus();
				//Roy 20140410: 第一次與每次切開APP時檢查好康報你知是否有新資料
				checkIsUpdated();
			
				var lstStrNotificationStyles : Vector.<String> = new Vector.<String>();
					lstStrNotificationStyles.push(NotificationStyle.ALERT, NotificationStyle.BADGE, NotificationStyle.SOUND);
				this.remoteNotifierSubscribeOptions.notificationStyles= lstStrNotificationStyles; 
				this.remoteNotifier.addEventListener(RemoteNotificationEvent.TOKEN, remoteNotifierOnToken); 
				this.remoteNotifier.addEventListener(RemoteNotificationEvent.NOTIFICATION, remoteNotifierOnNotification); 
				this.remoteNotifier.addEventListener(StatusEvent.STATUS, remoteNotifierOnStatus); 
				this.remoteNotifier.subscribe(this.remoteNotifierSubscribeOptions);
			}
			
			_backgroundLoader = new BackgroundURLLoader();
			_backgroundLoader.strURLUpdateCheck = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "isUpdated.php";
			
			_backgroundLoader.enqueue(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_INFO);
			_backgroundLoader.enqueue(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_NEWS);
			_backgroundLoader.enqueue(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_ACT);
			_backgroundLoader.enqueue(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_VIDEO);
			
			_backgroundLoader.start();
			
			var file : File = File.applicationDirectory.resolvePath("cache/info.txt");
			trace(file.nativePath);
			var fileStream : FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				
			var strTimestamp : String = fileStream.readUTFBytes(fileStream.bytesAvailable);
				fileStream.close();
			trace(strTimestamp);
		}
		
		function activateSceneHandler(e:Event)
		{		
			//回復畫面時會檢查網路並跳出訊息
			checkInternetStatus();
			//Roy 20140410: 第一次與每次切開APP時檢查好康報你知是否有新資料
			_isChecking = false;
			checkIsUpdated();
			checkIsUnreadArticle(); //20140601 roy added
			
			
//			//20140905 added by roy
//			checkIsUpdated_news();
			//20140905 added by roy
			checkIsUpdated_activity();
			//Roy 20140516: 每次切開APP時檢查是否有新資料
			
			if (_backgroundLoader) return;
			/*
			if (_backgroundLoader)
			{
				_backgroundLoader.stop();
				_backgroundLoader = null;
			}
			*/
			_backgroundLoader = new BackgroundURLLoader();
			_backgroundLoader.strURLUpdateCheck = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "isUpdated.php";
			_backgroundLoader.enqueue(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_NEWS);
			_backgroundLoader.enqueue(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_ACT);
			_backgroundLoader.enqueue(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_VIDEO);
			_backgroundLoader.start();
		}
		
		private function eventChannelAddEventListener() {
//			eventChannel.addEventListener(Home.CLICK_ABOUT, onHomeAboutClick);
//			eventChannel.addEventListener(Home.CLICK_TRAFFIC, onHomeTrafficClick);
//			eventChannel.addEventListener(Home.CLICK_GAME, onHomeGameClick);
//			eventChannel.addEventListener(GameMakerEvent.EXPORT_MOVIE_FINISH, onExportMovieFinish);
//			eventChannel.addEventListener(Home.CLICK_ACTIVITY, onHomeActivityClick);
//			eventChannel.addEventListener(Home.CLICK_NEWS, onHomeNewsClick);
//			eventChannel.addEventListener(Home.CLICK_VIDEO, onHomeVideoClick);
//			eventChannel.addEventListener(Home.CLICK_CALENDAR, onHomeCalendarClick);//Roy added
//			eventChannel.addEventListener(Home.CLICK_TRESURE_GAME, onTreasureGameClick);
//			eventChannel.addEventListener(TreasureGameHome.CLICK_PLAY, onTreasurePlayClick);
//			eventChannel.addEventListener(TreasureGameHome.CLICK_COLLECTION, onTreasureCollectionClick);
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			eventChannelRemoveEventListener();
			eventChannel = null;
			removeSplashScreen();
		}
		
		private function eventChannelRemoveEventListener() {
//			eventChannel.removeEventListener(Home.CLICK_ABOUT, onHomeAboutClick);
//			eventChannel.removeEventListener(Home.CLICK_TRAFFIC, onHomeTrafficClick);
//			eventChannel.removeEventListener(Home.CLICK_GAME, onHomeGameClick);
//			eventChannel.removeEventListener(GameMakerEvent.EXPORT_MOVIE_FINISH, onExportMovieFinish);
//			eventChannel.removeEventListener(Home.CLICK_ACTIVITY, onHomeActivityClick);
//			eventChannel.removeEventListener(Home.CLICK_NEWS, onHomeNewsClick);
//			eventChannel.removeEventListener(Home.CLICK_VIDEO, onHomeVideoClick);
//			eventChannel.removeEventListener(Home.CLICK_CALENDAR, onHomeCalendarClick);//Roy added
//			eventChannel.removeEventListener(Home.CLICK_TRESURE_GAME, onTreasureGameClick);
//			eventChannel.removeEventListener(TreasureGameHome.CLICK_PLAY, onTreasurePlayClick);
//			eventChannel.removeEventListener(TreasureGameHome.CLICK_COLLECTION, onTreasureCollectionClick);
		}
		
		private function onSplashScreenTimer(e:Event) {
			createHome();
			removeSplashScreen();
			//Roy 20140321: 第一次與每次切開APP時檢查網路並跳出訊息
			checkInternetStatus();
			//Roy 20140410: 第一次與每次切開APP時檢查好康報你知是否有新資料
			checkIsUpdated();
			
			checkIsUnreadArticle(); //20140601 roy added
		}
		
		private function removeSplashScreen() {
			if (splashScreenForAndroid) {
				this.stage.removeChild(splashScreenForAndroid);
			}
			splashScreenForAndroid = null;
		}
		
		private function createHome() {
			onHomeActivityClick();
			System.gc();
		}
		
		private function checkIsUpdated() {
//			addHomeNewInfoIconNumber();//20140505 Roy updated
			
			if (_isChecking) return; 
			_isChecking = true;
			
			var strURLFeed : String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_INFO;
            var fileCacheFeed : FileCache = new FileCache(strURLFeed, true);
			
			trace("getDateArticleFirst: ", getDateArticleFirst(fileCacheFeed));
			
                fileCacheFeed.addEventListener(FileCache.CHECK_IS_UPDATED_DONE, function(event : Event) : void
				{
					event.target.removeEventListener(event.type, arguments.callee);
					var fileCache : FileCache = FileCache(event.target);
					// 若是存在更新版本, 則進行下載, 否則使用 cache
            		if (fileCache.isUpdated)
					{
						//addHomeNewInfoIcon(); //20140505 Roy added  //20140407 roy update: 現在不顯示 N 改顯示數字
						fileCache.addEventListener(FileCache.DOWNLOAD_DONE, fileCacheOnDownloadDone);
						fileCache.addEventListener(FileCache.DOWNLOAD_FAIL, fileCacheOnDownloadFail);
						//20140422 Roy: 有新資料時在這裡就直接下載
						fileCache.download();
					}
				});
				fileCacheFeed.addEventListener(FileCache.DOWNLOAD_FAIL, function(event : Event) : void
				{
						_isChecking = false;
				});
                fileCacheFeed.checkIsUpdated();
		}
		
		//20140905 added by roy
		private function checkIsUpdated_news() {
			if (_isCheckingNews) return; 
			_isCheckingNews = true;
			
			var strURLFeed : String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_NEWS;
            var fileCacheFeed : FileCache = new FileCache(strURLFeed, true);
			
			trace("getDateArticleFirst: ", getDateArticleFirst(fileCacheFeed));
			
                fileCacheFeed.addEventListener(FileCache.CHECK_IS_UPDATED_DONE, function(event : Event) : void
				{
					event.target.removeEventListener(event.type, arguments.callee);
					var fileCache : FileCache = FileCache(event.target);
					// 若是存在更新版本, 則進行下載, 否則使用 cache
            		if (fileCache.isUpdated)
					{
						fileCache.addEventListener(FileCache.DOWNLOAD_DONE, fileCacheOnDownloadDone);
						fileCache.addEventListener(FileCache.DOWNLOAD_FAIL, fileCacheOnDownloadFail);
						fileCache.download();
						_isCheckingNews = false;
					}
				});
				fileCacheFeed.addEventListener(FileCache.DOWNLOAD_FAIL, function(event : Event) : void
				{
						_isCheckingNews = false;
				});
                fileCacheFeed.checkIsUpdated();
				
		}		
		
		//20140905 added by roy
		private function checkIsUpdated_activity() {
			if (_isCheckingAct) return; 
			_isCheckingAct = true;
			
			var strURLFeed : String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_ACT;
            var fileCacheFeed : FileCache = new FileCache(strURLFeed, true);
			
			trace("getDateArticleFirst: ", getDateArticleFirst(fileCacheFeed));
			
                fileCacheFeed.addEventListener(FileCache.CHECK_IS_UPDATED_DONE, function(event : Event) : void
				{
					event.target.removeEventListener(event.type, arguments.callee);
					var fileCache : FileCache = FileCache(event.target);
					// 若是存在更新版本, 則進行下載, 否則使用 cache
            		if (fileCache.isUpdated)
					{
						fileCache.addEventListener(FileCache.DOWNLOAD_DONE, fileCacheOnDownloadDone);
						fileCache.addEventListener(FileCache.DOWNLOAD_FAIL, fileCacheOnDownloadFail);
						fileCache.download();
						_isCheckingAct = false;
					}
				});
				fileCacheFeed.addEventListener(FileCache.DOWNLOAD_FAIL, function(event : Event) : void
				{
						_isCheckingAct = false;
				});
                fileCacheFeed.checkIsUpdated();
				
		}				
		
		private function checkIsUnreadArticle() {
				checkUnreadArticle(CACHE_NEWS); 
				checkUnreadArticle(CACHE_ACT); 
				checkUnreadArticle(CACHE_VIDEO); 
		}
		
		private function fileCacheOnDownloadDone(event : Event) : void
		{
			event.target.removeEventListener(FileCache.DOWNLOAD_DONE, fileCacheOnDownloadDone);
			event.target.removeEventListener(FileCache.DOWNLOAD_FAIL, fileCacheOnDownloadFail);
			
			isShowUpdateIcon = true;
			_isChecking = false;
			
//			addHomeNewInfoIconNumber();//20140505 Roy updated
		}
		
		private function fileCacheOnDownloadFail(event : Event) : void
		{
			event.target.removeEventListener(FileCache.DOWNLOAD_DONE, fileCacheOnDownloadDone);
			event.target.removeEventListener(FileCache.DOWNLOAD_FAIL, fileCacheOnDownloadFail);

			_isChecking = false;
			
//			addHomeNewInfoIconNumber();//20140505 Roy updated
		}
		

		//20140516 add by roy
		private function checkUnreadArticle(strIconNameIn:String) {
			//20140531 Roy: 這一段仍有 Bug 會造成文章類別錯亂			
//			if(!isHasUnreadArticle(strIconNameIn)){
//				//removeHomeNewInfoIconOthers(strIconNameIn);
//				return;
//			}
			
			//addHomeNewInfoIcon(strIconNameIn);
			if(strIconNameIn==CACHE_NEWS) isShowUpdateIconNews = true;
			if(strIconNameIn==CACHE_ACT) isShowUpdateIconAct = true;
			if(strIconNameIn==CACHE_VIDEO) isShowUpdateIconVideo = true;
		}
		
//		//20140516 add by roy
//		private function isHasUnreadArticle(strIconNameIn:String):Boolean {
//			if(sharedObject==null) sharedObject = SharedObject.getLocal("ChiayiReadLog");
//			
//			if (!sharedObject.data.hasOwnProperty(strIconNameIn)){
//				return true;
//			}
//			
//			var dateLastRead : String = sharedObject.data[strIconNameIn];
//			var strURLFeedCache : String = "";
//			var fileCacheFeedCheck : FileCache = null;
//			if(strIconNameIn == CACHE_NEWS){
//				strURLFeedCache = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_NEWS;
//			}
//			if(strIconNameIn == CACHE_ACT){
//				strURLFeedCache = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_ACT;
//			}
//			if(strIconNameIn == CACHE_VIDEO){
//				strURLFeedCache = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_VIDEO
//			}
//			
//			if(strURLFeedCache=="") return false;
//            fileCacheFeedCheck = new FileCache(strURLFeedCache, true);
//			
//			//trace("getDateArticleFirst check: ", getDateArticleFirst(fileCacheFeed));
//			
//			if(getDateArticleFirst(fileCacheFeedCheck).toString() != dateLastRead) return true;
//			
//			fileCacheFeedCheck = null;
//			return false;
//		}
		
		//20140516 add by roy
		private function saveLastArticleDate(strIconNameIn:String) {
			if(sharedObject==null) sharedObject = SharedObject.getLocal("ChiayiReadLog");
			
			var strURLFeedCache : String = "";
			var fileCacheFeedCheck : FileCache = null;
			if(strIconNameIn == CACHE_NEWS){
				strURLFeedCache = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_NEWS;
			}
			if(strIconNameIn == CACHE_ACT){
				strURLFeedCache = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_ACT;
			}
			if(strIconNameIn == CACHE_VIDEO){
				strURLFeedCache = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_VIDEO
			}
			
			if(strURLFeedCache==""){
				trace("saveLastArticleDate empty strURLFeedCache");	
				return;
			}
            fileCacheFeedCheck = new FileCache(strURLFeedCache, true);
			sharedObject.data[strIconNameIn] = getDateArticleFirst(fileCacheFeedCheck).toString();
			sharedObject.flush();
			
			
			if(strIconNameIn==CACHE_NEWS) isShowUpdateIconNews = false;
			if(strIconNameIn==CACHE_ACT) isShowUpdateIconAct = false;
			if(strIconNameIn==CACHE_VIDEO) isShowUpdateIconVideo = false;
			
			//trace("getDateArticleFirst save: ", getDateArticleFirst(fileCacheFeed));
		}
		
		private function onHomeActivityClick(event : Event = null) : void
		{
			var strURLFeed : String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_INFO;
			var dicContentParameter = createDicContentParameterForPageArticleList("喲！苗栗", strURLFeed);
			
			setupNavigator(dicContentParameter);
		}
		
		private function setupNavigator(dicContentParameter:Object):void {
			if (navigator == null) {
				navigator = new TitleBarAndSideMenu(dicContentParameter);
				this.stage.addChild(navigator);
			} else {
				navigator.pushContent(dicContentParameter);
			}
		}
		
		private function titleButtonHomeHandler():void {
			this.stage.removeChild(navigator);
			navigator = null;
			createHome();
			
			//20140601 Roy added : 每次回到 home 頁面時確認是否有新文章
			checkIsUpdated();
		}
		
		private function titleButtonBackHandler() : void
		{
			navigator.popContent();
		}
		
		private function deactivateHandler(e:Event) {
			if (_backgroundLoader)
			{
				_backgroundLoader.stop();
				_backgroundLoader = null;
			}
			SoundMixer.stopAll();
		}

		//Roy added: 20140124
		// 2014-06-23 Noin: 參數 strURLFeed 改名為 strData, 因為它可以是 json 也可以是 url
		private function createPagePhotoWithTitleAndTextAndQuiz(strTitle : String, strData : String, strAddress : String = null) : void
		{
			CAMEO::ANE {
			var dicContentParameter = {
				className: "tw.cameo.UI.PagePhotoWithTitleAndTextAndQuiz",
				data: strData,
				title: strTitle,
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick: titleButtonBackHandler,
				rightButton: ((strAddress != null) ? (TitleBarAndSideMenu.TITLE_BUTTON_TYPE_LOCATE) : (TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE)),
				rightButtonOnMouseClick: ((strAddress != null) ? (function() : void { getPageMapOneView(strTitle, strAddress); }) : (null)),
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: function(content : MovieClip) : void
				{
					// Show Loading Indicator
					var loadingIndicator : LoadingIndicator = null;
						loadingIndicator = new LoadingIndicator(0x333333);
						loadingIndicator.x = stage.fullScreenWidth / 4;
						loadingIndicator.y = navigator.getTitleBarHeight() / 2;
						loadingIndicator.scaleX = LayoutManager.intScaleX;
						loadingIndicator.scaleY = LayoutManager.intScaleY;
					this.stage.addChild(loadingIndicator);
					var pagePhotoWithTitleAndTextAndQuiz : PagePhotoWithTitleAndTextAndQuiz = content as PagePhotoWithTitleAndTextAndQuiz;
					var webView : WebViewNativeExtension = pagePhotoWithTitleAndTextAndQuiz.webView;
try
{
					pagePhotoWithTitleAndTextAndQuiz.webView.addEventListener("WebViewStatusEvent.FINISH_LOAD", function(event : WebViewNativeExtensionEvent)
					{
						// Hide Loading Indicator
						loadingIndicator.stopAnim();
						this.stage.removeChild(loadingIndicator);
					});
					pagePhotoWithTitleAndTextAndQuiz.webView.addEventListener("WebViewStatusEvent.ERROR", function(event : WebViewNativeExtensionEvent)
					{
						loadingIndicator.stopAnim();
						this.stage.removeChild(loadingIndicator);
					});
					
					//20140508 Roy: Android 為了影片要特別處理
					CAMEO::Android {
						pagePhotoWithTitleAndTextAndQuiz.webView.addEventListener("WebViewStatusEvent.LOCATION_CHANGED", function(event : WebViewNativeExtensionEvent)
						{
								var strPrefixYoutube1 : String = "http://www.youtube.com/";
								var strPrefixYoutube2 : String = "http://youtu.be/";
								var strPrefixYoutube3 : String = "https://www.youtube.com/";
								var strPrefixGoogleForm : String = "https://docs.google.com/";
								//var strPrefix : String = "http://tapmovie.com/blank.html?id=";  //代表本機儲存的網頁暫存檔
								var strLocationNewBrowser : String = event.strURL;
								if ((strLocationNewBrowser.substring(0, strPrefixYoutube1.length) == strPrefixYoutube1)
									 || (strLocationNewBrowser.substring(0, strPrefixYoutube2.length) == strPrefixYoutube2)
									 || (strLocationNewBrowser.substring(0, strPrefixYoutube3.length) == strPrefixYoutube3)
									 || (strLocationNewBrowser.substring(0, strPrefixGoogleForm.length) == strPrefixGoogleForm))
								{
									var request : URLRequest = new URLRequest(strLocationNewBrowser);
									navigateToURL(request, "_blank");
									
									//產生一頁再回上一頁
									createPagePhotoWithTitleAndTextAndQuiz(strTitle, strData, strAddress);
									titleButtonBackHandler();
								}
						});
						
					}


					var intWebViewY : int = navigator.getTitleBarHeight();
					var intWebViewWidth : int = LayoutManager.intScreenWidth;
					var intWebViewHeight : int = LayoutManager.intScreenHeight - intWebViewY;

					pagePhotoWithTitleAndTextAndQuiz.webView.setWebViewFrame(0, intWebViewY, intWebViewWidth, intWebViewHeight);
					pagePhotoWithTitleAndTextAndQuiz.strHTMLStyleSheet = getStrStyleSheetForPagePhotoWithTitleAndText();
					pagePhotoWithTitleAndTextAndQuiz.strCSSHeightPhoto = convertToScaledLength(480).toString();
					pagePhotoWithTitleAndTextAndQuiz.strHTMLViewPortWidth = (LayoutManager.intScreenWidth).toString();

					pagePhotoWithTitleAndTextAndQuiz.funcOnDataLoaded = function(dicData : *)
					{
						// 2014-01-30 Noin: 加上 FB 按鈕, Roy: 加上 Quiz 按鈕
						var fileCache : FileCache = new FileCache(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "images/fb.png");
						var fileCacheQuiz : FileCache = new FileCache(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "images/Questions.png");
						var strURLShare = "https://www.facebook.com/sharer/sharer.php?u=" + dicData["share"]; //20150626 roy todo: dicData["share"] 在新聞與活動頁是空的 undefined
						var strJavaScript : String = "";
						
						if (dicData["quiz"] != null && dicData["quiz"] != "")
						{
							strJavaScript += "\t\t\tvar fb = $('<div style=\"float: right; margin: " + convertToScaledLength(-30) + " " + convertToScaledLength(36) + " 0 0;\"><a href=\"" + dicData["quiz"] + "\"><img style=\"width: " + convertToScaledLength(80) + "px; height: " + convertToScaledLength(80) + "px;\" src=\"" + fileCacheQuiz.toString() + "\" alt=\"\" /></a> &nbsp;&nbsp; <a href=\"" + strURLShare + "\"><img style=\" width: " + convertToScaledLength(80) + "px; height: " + convertToScaledLength(80) + "px; \" src=\"" + fileCache.toString() + "\" alt=\"\" /></a></div>');\n";
						}
						else
						{
							strJavaScript += "\t\t\tvar fb = $('<div style=\"float: right; margin: " + convertToScaledLength(-30) + " " + convertToScaledLength(36) + " 0 0;\"><a href=\"" + strURLShare + "\"><img  style=\"width: " + convertToScaledLength(80) + "px; height: " + convertToScaledLength(80) + "px;\" src=\"" + fileCache.toString() + "\" alt=\"\" /></a></div>');\n";
						}
												
				        strJavaScript += "\t\t\tfb.insertAfter($('div.content'));\n";
						
						strJavaScript += "\t\t\tvar title = $('div.title');\n";
            			strJavaScript += "\t\t\tif (title.text().length < 15)\n";
            			strJavaScript += "\t\t\t{\n";
						strJavaScript += "\t\t\t\tvar strHeight = '" + convertToScaledLength(96) + "px';\n";
                		strJavaScript += "\t\t\t\ttitle.css('height', strHeight).css('line-height', strHeight).css('vertical-align', 'middle');\n";
            			strJavaScript += "\t\t\t}\n";
						
						// 2014-02-12 Noin: 加上按鈕後才調整文件高度
						strJavaScript += getStrScriptForPagePhotoWithTitleAndText();
						
						pagePhotoWithTitleAndTextAndQuiz.strScriptContentLoaded = strJavaScript;
					};
					
					// 2014-06-20 Noin: 若 data 是 json string 則使用 loadWithDicData()
					// 2014-11-20 Noin: 都已經改成 json string
					var str : String = pagePhotoWithTitleAndTextAndQuiz.data;
					if (str.substr(0, 1) == "{" && str.substr(str.length - 1) == "}")
					{
						var dicData : Object = JSON.parse(str);
						pagePhotoWithTitleAndTextAndQuiz.loadWithDicData(dicData);
					}
					else
					{
						// 2014-06-20 Noin: 以下部分是做 RSS 更新檢查, 有更新或沒有Cache會進行下載, 否則只用 fileCache
						var funcFileCacheCheckIsUpdatedHandler : Function = function(event : Event) {
							event.target.removeEventListener(FileCache.CHECK_IS_UPDATED_DONE, arguments.callee);
							event.target.removeEventListener(FileCache.CHECK_IS_UPDATED_FAIL, arguments.callee);

							if (fileCache.isUpdated || fileCache.isCached == false)
							{
								fileCache.addEventListener(FileCache.DOWNLOAD_DONE, function(event : Event) {
									var eventDispatcher:IEventDispatcher = IEventDispatcher(event.target);
	    	        					eventDispatcher.removeEventListener(event.type, arguments.callee);   
									var parser : ContentAndQuizParser = new ContentAndQuizParser(fileCache.toString());
										parser.funcConverter = convertToScaledLength;
										parser.isThumbnailAvailable = true;
									pagePhotoWithTitleAndTextAndQuiz.loadWithDicData(parser.parse());
								});
								fileCache.download();
							}
							else
							{
								var parser : ContentAndQuizParser = new ContentAndQuizParser(fileCache.toString());
									parser.funcConverter = convertToScaledLength;
									parser.isThumbnailAvailable = true;
									pagePhotoWithTitleAndTextAndQuiz.loadWithDicData(parser.parse());
							}
						};
						var fileCache : FileCache = new FileCache(strData, true);
							fileCache.addEventListener(FileCache.CHECK_IS_UPDATED_DONE, funcFileCacheCheckIsUpdatedHandler);
							fileCache.addEventListener(FileCache.CHECK_IS_UPDATED_FAIL, funcFileCacheCheckIsUpdatedHandler);
							fileCache.checkIsUpdated();
					}

}
catch (error : Error)
{
	webView.webViewLoadString(error.message + "<br />" + error.getStackTrace().replace("\n", "<br />"), "file:///");
}
				}
			};
			
			navigator.pushContent(dicContentParameter);
			} // End of CAMEO::ANE
		}				
		
		private function getStrStyleSheetForPagePhotoWithTitleAndText() : String
		{
			var fileCache1 : FileCache = new FileCache(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "images/background_page.png");

			var intWidthHTML : int = (LayoutManager.intScreenWidth - convertToScaledLength(0));
			var strStyleSheet : String = "";
				strStyleSheet += " body { margin: 0px }";
				strStyleSheet += " div.container { width: " + (intWidthHTML).toString() + "px; height: 100%; background-image: url('" + fileCache1.toString() + "'); background-repeat: repeat-y; background-position: center; background-size: contain; }";
				//20150625 roy updated	//strStyleSheet += " div.title { font: bold " + convertToScaledLength(38) + "px \"Microsoft JhengHei\"; width: " + (intWidthHTML - convertToScaledLength(76)).toString() + "px; height: " + convertToScaledLength(80) + "px; text-align: left; vertical-align: middle; margin: auto " + convertToScaledLength(38) + " auto " + convertToScaledLength(38) + "; color: cc0000; }";
				strStyleSheet += " div.title { font: bold " + convertToScaledLength(38) + "px \"微軟正黑體\"; width: " + (intWidthHTML - convertToScaledLength(76)).toString() + "px; height: " + convertToScaledLength(80) + "px; text-align: left; vertical-align: middle; margin: auto " + convertToScaledLength(38) + " auto " + convertToScaledLength(38) + "; color: cc0000; }";
				//20150625 roy updated	//strStyleSheet += " div.content { width: " + (intWidthHTML - convertToScaledLength(76)).toString() + "px; margin: " + convertToScaledLength(38) + " " + convertToScaledLength(38) + " " + convertToScaledLength(38) + " " + convertToScaledLength(38) + "; padding-bottom: " + convertToScaledLength(38) + "px; text-align: left; color: black; font: " + convertToScaledLength(38) + "px \"Microsoft JhengHei\"; }";
				strStyleSheet += " div.content { width: " + (intWidthHTML - convertToScaledLength(76)).toString() + "px; margin: " + convertToScaledLength(38) + " " + convertToScaledLength(38) + " " + convertToScaledLength(38) + " " + convertToScaledLength(38) + "; padding-bottom: " + convertToScaledLength(38) + "px; text-align: left; color: black; font: " + convertToScaledLength(38) + "px \"微軟正黑體\"; }";
				//20150625 roy updated	//strStyleSheet += " td { font: " + convertToScaledLength(38) + "px \"Microsoft JhengHei\"; }";
				strStyleSheet += " td { font: " + convertToScaledLength(38) + "px \"微軟正黑體\"; }";
				strStyleSheet += " * { margin:0; padding:0; }";
			return strStyleSheet;
		}
		
		private function getStrScriptForPagePhotoWithTitleAndText_orig() : String //原來的版本，某些Android 會跑版
		{
			var strScript : String = "";
				strScript += "\t\t\tvar h = $(document).height() + " + convertToScaledLength(40) + ";\n";
				strScript += "\t\t\t$('div.container').css('height', h.toString());\n";
			return strScript;
		}
		
		private function getStrScriptForPagePhotoWithTitleAndText() : String 
		{
			var strScript : String = "";
				strScript += "\t\t\tvar h = $(document).height() + " + convertToScaledLength(40) + ";\n";
				strScript += "\t\t\t$('div.container').css('height', h.toString());\n";
				strScript += "\t\t\t$('*').css('border', 'solid 1px transparent');\n";
				strScript += "\t\t\tsetTimeout(function() { \n";
				strScript += "\t\t\t\t$('*').css('border', 'solid 0px transparent');\n";
				strScript += "\t\t\t\tvar intHeightByFB = fb.position().top + 100;\n";
				strScript += "\t\t\t\tvar intHeightScreen = " + LayoutManager.intScreenHeight + ";\n";
				strScript += "\t\t\t\tvar intHeight = (intHeightByFB > intHeightScreen) ? (intHeightByFB) : (intHeightScreen);\n";
				strScript += "\t\t\t\t$('div.container').css('height', intHeight);\n";
				strScript += "\t\t\t}, 333);\n";

			return strScript;
		}
		
		private function createDicContentParameterForPageArticleList(strTitle : String, strURLFeed : String) : *
		{
			// 2014-06-20 Noin: 以下是沒有 ANE 的時候, 顯示除錯訊息使用, 正式版不會執行
			CAMEO::NO_ANE {
				var fileCache : FileCache = new FileCache(strURLFeed, true);
				var parser : WordPressParser = new WordPressParser(fileCache.toString());
				var lstDicData : Array = parser.parse();
				for (var i in lstDicData)
				{
					var dicData = lstDicData[i];
					var fileCacheContent : FileCache = new FileCache(dicData["link"], true);
					if (fileCacheContent.isCached)
					{
					var contentParser : ContentAndQuizParser = new ContentAndQuizParser(fileCacheContent.toString());
						contentParser.funcConverter = convertToScaledLength;
						contentParser.isThumbnailAvailable = true;
					trace("[" + i + "]: " + dicData.title + "   " + dicData["link"] + " cached");
					trace(JSON.stringify(contentParser.parse()));
					}
					else
					{
						fileCacheContent.addEventListener(FileCache.DOWNLOAD_DONE, function(e : Event) {
							e.target.removeEventListener(e.type, arguments.callee);
							var fileCacheDownloaded : FileCache = e.target as FileCache;
							var contentParser : ContentAndQuizParser = new ContentAndQuizParser(fileCacheDownloaded.toString());
								contentParser.funcConverter = convertToScaledLength;
								contentParser.isThumbnailAvailable = true;
							trace("[" + i + "]: " + dicData.title + "   " + dicData["link"] + " downloaded");
							trace(JSON.stringify(contentParser.parse()));
							
						})
						fileCacheContent.download();
					}
				}
			}
			
			// 2014-06-20 Noin: 以下是正式版
			CAMEO::ANE {
			var dicContentParameter = {
				className: "tw.cameo.UI.PageArticleList",
				data: strURLFeed,
				title: strTitle,
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
				leftButtonOnMouseClick: null,
				rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
				rightButtonOnMouseClick: null,
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: function(content : MovieClip) : void
				{
					// Show Loading Indicator
					var loadingIndicator : LoadingIndicator = null;
						loadingIndicator = new LoadingIndicator(0xffffff);
						loadingIndicator.x = stage.fullScreenWidth / 5;
						loadingIndicator.y = navigator.getTitleBarHeight() / 2;
						loadingIndicator.scaleX = LayoutManager.intScaleX;
						loadingIndicator.scaleY = LayoutManager.intScaleY;
					this.stage.addChild(loadingIndicator);

					var pageArticleList : PageArticleList = content as PageArticleList;
					pageArticleList.webView.addEventListener("WebViewStatusEvent.START_LOAD", function(event : WebViewNativeExtensionEvent)
					{
						
					});
					pageArticleList.webView.addEventListener("WebViewStatusEvent.FINISH_LOAD", function(event : WebViewNativeExtensionEvent)
					{
						// Hide Loading Indicator
						loadingIndicator.stopAnim();
						this.stage.removeChild(loadingIndicator);
					});
					pageArticleList.webView.addEventListener("WebViewStatusEvent.ERROR", function(event : WebViewNativeExtensionEvent)
					{
						loadingIndicator.stopAnim();
						this.stage.removeChild(loadingIndicator);
					});
					pageArticleList.webView.addEventListener("WebViewStatusEvent.LOCATION_CHANGED", function(event : WebViewNativeExtensionEvent)
					{
						var webView : WebViewNativeExtension = event.target as WebViewNativeExtension;
						try
						{
							var strPrefix : String = "http://tapmovie.com/blank.html?id=";  //代表本機儲存的網頁暫存檔
							var strLocation : String = event.strURL;
							if (strLocation.substring(0, strPrefix.length) == strPrefix) 
							{
								var intIndex : int = parseInt(strLocation.substring(strPrefix.length));
								var dicData : Object = pageArticleList.getDicData(intIndex);
								var strTitle = dicData.title;
								var strURLFeed : String = dicData.link;
								
								var strAddress : String = null;
								var strContent : String = dicData.content;
								// 20140110 bigcookie: 上稿文章是用 "[地址]：" 為開頭搜尋活動地址會找不到
								//var strSearch : String = "[活動地址]：";
								var strSearch : String = "[地址]：";
								var intStart : Number = strContent.indexOf(strSearch);
								if (intStart != -1)
								{
									intStart += strSearch.length;
									var intEnd : Number = strContent.indexOf("<", intStart);
									strAddress = strContent.substr(intStart, intEnd - intStart).replace("\n", "");
								}
							
								//Roy added: 因為有問卷鏈結要特別處理，連結到遠端網頁
								// 2014-06-20 Noin: 改傳 json string 不再使用 feed url
								// 2014-06-24 Noin: dicData 是使用 wordpress parser 產生
								//                  現在要再用 content and quiz parser 再處理一次
								var contentAndQuizParser : ContentAndQuizParser = new ContentAndQuizParser();
								contentAndQuizParser.funcConverter = convertToScaledLength; // 必要
								dicData = contentAndQuizParser.parseContent(dicData);
								createPagePhotoWithTitleAndTextAndQuiz(strTitle, JSON.stringify(dicData), strAddress);
								
								//20140505 Roy added: 記錄看過的文章 URL
								var arrayNewInfo:Array = sharedObject.data["ARRAY_NEW_INFO"];
								if(arrayNewInfo.indexOf(strURLFeed) == -1){
									arrayNewInfo.push(strURLFeed);
									sharedObject.data["ARRAY_NEW_INFO"] = arrayNewInfo;
									sharedObject.flush();
								}
								//20140505 Roy added: 記錄看過的文章 URL End								
							}
						}
						catch (error : Error)
						{
							webView.webViewLoadString(error.message + "<br />" + error.getStackTrace().replace("\n", "<br />"), "file:///");
						}
					});
					
					var intWidthHTML : int = (LayoutManager.intScreenWidth - convertToScaledLength(4));
					var intWebViewY : int = navigator.getTitleBarHeight();
					var intWebViewWidth : int = LayoutManager.intScreenWidth;
					var intWebViewHeight : int = LayoutManager.intScreenHeight - intWebViewY;

					pageArticleList.webView.setWebViewFrame(0, intWebViewY, intWebViewWidth, intWebViewHeight);
					pageArticleList.strHTMLStyleSheet = getStrStyleSheetForPageArticleList(intWidthHTML);
					pageArticleList.strHTMLViewPortWidth = (LayoutManager.intScreenWidth).toString();
					if (Capabilities.os.indexOf("iPhone") != -1) 
					{
						pageArticleList.strHTMLViewPortInitialScale = ((pageArticleList.webView.isRetinaDisplay()) ? ("0.5") : ("1.0"));
						pageArticleList.strHTMLViewPortMaximumScale = ((pageArticleList.webView.isRetinaDisplay()) ? ("0.5") : ("1.0"));
					}
					pageArticleList.strURLImageDefault = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "images/image_default_article_list.png";
					// 2014-02-18 Noin: 設定使用 150x150 縮圖
					pageArticleList.isThumbnailAvailable = true;

					var parser : WordPressParser = new WordPressParser();
					pageArticleList.parser = parser;
					pageArticleList.loadWithParser(false);
				}
			};
			
			//checkIsUpdated(); //20140508 add by roy 
			
			return dicContentParameter;
			} // End of CAMEO::ANE
		}
		
		private function getStrStyleSheetForPageArticleList(intWidthHTML : Number) : String
		{
			var fileCache : FileCache = new FileCache(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "images/background_item_article_list.png");
			
			var strStyleSheet : String = "\t<style type='text/css'>\n";
				strStyleSheet += "\t\tbody { margin: 0px; background-color: eccd50; }\n";
				strStyleSheet += "\t\ttable { width: " + (intWidthHTML).toString() + "px; border-spacing: 10px; }\n";
				strStyleSheet += "\t\ttr {  }\n";
				strStyleSheet += "\t\ttd { width: " + convertToScaledLength(629) + "px; height: " + convertToScaledLength(200) + "px; background-image: url('" + fileCache.toString() + "'); background-repeat: no-repeat; background-position: center; background-size: cover; }\n";
				strStyleSheet += "\t\tdiv.imageOuter { float: left; width: " + convertToScaledLength(200) + "px; height: " + convertToScaledLength(200) + "px; }\n";
				strStyleSheet += "\t\tdiv.imageInner { width: " + convertToScaledLength(178) + "px; height: " + convertToScaledLength(178) + "px; margin: " + convertToScaledLength(10) + " auto " + convertToScaledLength(10) + " auto; overflow: hidden; background-repeat: no-repeat; background-position: center; background-size: cover; }\n";
				strStyleSheet += "\t\tdiv.title { float: left; font: bold " + convertToScaledLength(36) + "px \"微軟正黑體\"; width: " + convertToScaledLength(400) + "px; height: " + convertToScaledLength(60) + "px; line-height: " + convertToScaledLength(60) + "px; text-align: left; vertical-align: middle; color: black; overflow: hidden; }\n";
				strStyleSheet += "\t\tdiv.summary { float: left;  font: " + convertToScaledLength(32) + "px \"微軟正黑體\"; width: " + convertToScaledLength(400) + "px; height: " + convertToScaledLength(32*1.2*3) + "px; line-height: " + convertToScaledLength(32*1.2) + "px; text-align: left; vertical-align: middle; color: black; overflow: hidden; }\n";
				strStyleSheet += "\t\ta { text-decoration: none; color: black; }\n";
				strStyleSheet += "\t</style>\n";
			return strStyleSheet;
		}

		private function convertToScaledLength(intLength : Number) : Number
		{
			return (LayoutManager.intScreenWidth * intLength / 640);
		}
		
//		private function onHomeVideoClick(event : Event) : void
//		{
//			
//			//20140516 add by roy
//			saveLastArticleDate(CACHE_VIDEO);
//			
//			removeHome();
//
//			var fileCache1 : FileCache = 
//				new FileCache(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "images/background_page_subject_view.png");
//			var fileCache2 : FileCache = 
//				new FileCache(CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "images/background_item_subject_view.png");
//			
//			var strURLFeed : String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + FEED_URL_VIDEO;
//			var strTitle : String = "影音內容";
//			CAMEO::ANE {
//				var dicContentParameter = {
//					className: "tw.cameo.UI.PageSubjectView",
//					data: strURLFeed,
//					title: strTitle,
//					leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
//					leftButtonOnMouseClick: titleButtonHomeHandler,
//					rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
//					rightButtonOnMouseClick: null,
//					lstStrSideMenuItem: null,
//					intIndexDefaultSideMenuItem: -1,
//					sideMenuOnClose: null,
//					contentOnLoaded: function(content : MovieClip) : void
//					{
//						// Show Loading Indicator
//						var loadingIndicator : LoadingIndicator = null;
//							loadingIndicator = new LoadingIndicator(0xffffff);
//							loadingIndicator.x = stage.fullScreenWidth / 5;
//							loadingIndicator.y = navigator.getTitleBarHeight() / 2;
//							loadingIndicator.scaleX = LayoutManager.intScaleX;
//							loadingIndicator.scaleY = LayoutManager.intScaleY;
//						this.stage.addChild(loadingIndicator);
//	
//						var pageSubjectView : PageSubjectView = content as PageSubjectView;
//						pageSubjectView.webView.addEventListener("WebViewStatusEvent.START_LOAD", function(event : WebViewNativeExtensionEvent)
//						{
//							
//						});
//						pageSubjectView.webView.addEventListener("WebViewStatusEvent.FINISH_LOAD", function(event : WebViewNativeExtensionEvent)
//						{
//							// Hide Loading Indicator
//							loadingIndicator.stopAnim();
//							this.stage.removeChild(loadingIndicator);
//						});
//						pageSubjectView.webView.addEventListener("WebViewStatusEvent.ERROR", function(event : WebViewNativeExtensionEvent)
//						{
//							loadingIndicator.stopAnim();
//							this.stage.removeChild(loadingIndicator);
//						});
//						pageSubjectView.webView.addEventListener("WebViewStatusEvent.LOCATION_CHANGED", function(event : WebViewNativeExtensionEvent)
//						{
//							var strLocation : String = event.strURL;
//							var intLength : int = pageSubjectView.strIdentifierLink.length;
//							if (strLocation.substring(0, intLength) == pageSubjectView.strIdentifierLink)
//							{
//								try
//								{
//									var intIndex : int = parseInt(strLocation.substring(intLength));
//									var dicData : Object = pageSubjectView.getDicData(intIndex);
//									var request : URLRequest = new URLRequest(dicData.video);
//									navigateToURL(request, "_blank");
//									pageSubjectView.loadData();
//								}
//								catch (error : Error)
//								{
//									pageSubjectView.webView.webViewLoadString(error.message + "<br />" + error.getStackTrace().replace("\n", "<br />"), "file:///");
//								}
//							}
//						});
//						
//						var intWidthHTML : int = (LayoutManager.intScreenWidth - convertToScaledLength(4));
//						var strStyleSheet : String = "\t<style type='text/css'>\n";
//							strStyleSheet += "\t\ta { text-decoration: none; color: black; }\n";
//							strStyleSheet += "\t\tbody { margin: 0px; background-image: url('" + fileCache1.toString() + "'); background-repeat: repeat-y; background-size: contain; width: " + (intWidthHTML).toString() + "px; }\n";
//							strStyleSheet += "\t\ttable { width: " + (intWidthHTML).toString() + "px; border-spacing: " + convertToScaledLength(27) + "px; }\n";
//							strStyleSheet += "\t\ttr { height: " + convertToScaledLength(223) + "px; }\n";
//							strStyleSheet += "\t\ttd { width: " + convertToScaledLength(249) + "px; height: " + convertToScaledLength(223) + "px; }\n";
//							strStyleSheet += "\t\tdiv.title { background-color: black; opacity: 0.66; font: " + convertToScaledLength(24) + "px \"微軟正黑體\"; text-align: center; width: " + convertToScaledLength(219) + "px; height: " + convertToScaledLength(52) + "px; line-height: " + convertToScaledLength(52) + "px; vertical-align: middle; margin: " + convertToScaledLength(114) + " 0 " + convertToScaledLength(-114) + " 0; color: white; overflow: hidden; }\n";
//							strStyleSheet += "\t\tdiv.imageOuter { width: " + convertToScaledLength(249) + "px; height: " + convertToScaledLength(223) + "px; border: solid 1px transparent; background-image: url('" + fileCache2.toString() + "'); background-repeat: no-repeat; background-position: center center;  background-size: cover; }";
//							strStyleSheet += "\t\tdiv.left { margin: auto 0 auto 22; }\n";
//							strStyleSheet += "\t\tdiv.right { margin: auto 22 auto 0; }\n";
//							strStyleSheet += "\t\tdiv.imageInner { width: " + convertToScaledLength(219) + "px; height: " + convertToScaledLength(165) + "px; margin: " + convertToScaledLength(29) + " " + convertToScaledLength(15) + " " + convertToScaledLength(-19) + " " + convertToScaledLength(15) + "; overflow: hidden; background-repeat: no-repeat; background-position: center; background-size: cover; }";
//							strStyleSheet += "\t</style>\n";
//							
//						var intWebViewY : int = navigator.getTitleBarHeight();
//						var intWebViewWidth : int = LayoutManager.intScreenWidth;
//						var intWebViewHeight : int = LayoutManager.intScreenHeight - intWebViewY;
//	
//						pageSubjectView.webView.setWebViewFrame(0, intWebViewY, intWebViewWidth, intWebViewHeight);
//						pageSubjectView.strHTMLStyleSheet = strStyleSheet;
//						pageSubjectView.strHTMLViewPortWidth = (LayoutManager.intScreenWidth).toString();
//						if (Capabilities.os.indexOf("iPhone") != -1) 
//						{
//							pageSubjectView.strHTMLViewPortInitialScale = ((pageSubjectView.webView.isRetinaDisplay()) ? ("0.5") : ("1.0"));
//							pageSubjectView.strHTMLViewPortMaximumScale = ((pageSubjectView.webView.isRetinaDisplay()) ? ("0.5") : ("1.0"));
//						}
//						// 2014-02-18 Noin: 設定使用 150x150 縮圖
//						pageSubjectView.isThumbnailAvailable = true;
//						pageSubjectView.funcOnItemBinding = pageSubjectViewOnItemBinding;
//	
//						pageSubjectView.loadData();
//					}
//				};
//				setupNavigator(dicContentParameter);
//			} // END of CAMEO::ANE
//		}
		
		CAMEO::ANE {
			private function pageSubjectViewOnItemBinding(pageSubjectView : PageSubjectView, dicData : Object, i : int) : String
			{
				var strPosition : String = ((i % 2 == 0) ? ("left") : ("right"));
				var strCell : String = "";
					strCell += "\t\t\t<td>\n";
					strCell += "\t\t\t\t<a href='" + pageSubjectView.strIdentifierLink + i.toString() + "'>\n";
					strCell += "\t\t\t\t\t<div class='imageOuter " + strPosition + "'>\n";
					strCell += "\t\t\t\t\t\t<div class='imageInner' style='background-image: url(" + dicData.image + ")'>\n";
					strCell += "\t\t\t\t\t\t\t<div class='title'>" + dicData.title + "</div>\n";
					strCell += "\t\t\t\t\t\t</div></div>\n";
					strCell += "\t\t\t\t</a>\n";
					strCell += "\t\t\t</td>\n";
				return strCell;
			}
		}
		
		private function getPageMapOneView(strView : String, strAddress : String) 
		{
			CAMEO::ANE {
			var dicContentParameter = {
				className: "tw.cameo.UI.PageMapOneView",
				data: null,
				title: strView,
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick: titleButtonBackHandler,
				rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
				rightButtonOnMouseClick: null,
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: function(content : MovieClip) : void
				{
					var pageMapOneView : PageMapOneView = content as PageMapOneView;
					pageMapOneView.webView.setWebViewFrame(0, navigator.getTitleBarHeight(), LayoutManager.intScreenWidth, LayoutManager.intScreenHeight - navigator.getTitleBarHeight());
					pageMapOneView.setLoadingHeight(navigator.getTitleBarHeight());
					pageMapOneView.setLocation(strView);
					pageMapOneView.setAddress(strAddress);
					pageMapOneView.setFuncOnLocationChanged(createPageMapRoute);
					pageMapOneView.setFuncView(titleButtonBackHandler);
					pageMapOneView.loadData();
				}
			};
			setupNavigator(dicContentParameter);
			} // End of CAMEO::ANE
		}
		
		private function createPageMapRoute(strStore : String, strAddress : String) : void
		{
			CAMEO::ANE {
			var dicContentParameter = {
				className: "tw.cameo.UI.PageMapRoute",
				data: strAddress,
				title: strStore,
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick: titleButtonBackHandler,
				rightButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_NONE,
				rightButtonOnMouseClick: null,
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: function(content : MovieClip) : void
				{
					var pageMapRoute : PageMapRoute = content as PageMapRoute;
					
					pageMapRoute.webView.setWebViewFrame(0, navigator.getTitleBarHeight(), LayoutManager.intScreenWidth, LayoutManager.intScreenHeight - navigator.getTitleBarHeight());
					pageMapRoute.setLoadingHeight(navigator.getTitleBarHeight());
					pageMapRoute.loadData();
				}
			}
			
			setupNavigator(dicContentParameter);
			} // End of CAMEO::ANE
		}
		
		//Roy added: calender
		private var intArrayIndexSelected:Array = new Array();
		private function createDicContentParameterForPageCalendar(strTitle : String, strURLFeed : String, strDateModeIn : String = "", strViewModeIn : String = "LIST_VIEW") : *
		{
			CAMEO::ANE {
			var dicContentParameter = {
				className: "tw.cameo.UI.PageCalendar",
				data: strURLFeed,
				title: strTitle,
				leftButton: TitleBarAndSideMenu.TITLE_BUTTON_TYPE_BACK,
				leftButtonOnMouseClick:function() : void
				{
					intArrayIndexSelected.length = 0; //Clear Array
					if(strViewModeIn == "LIST_VIEW" || strViewModeIn == "CALENDAR_VIEW") titleButtonHomeHandler();  //201400422 roy
					else titleButtonBackHandler();
					//((strViewModeIn == "LIST_VIEW") ? (titleButtonHomeHandler()) : (titleButtonBackHandler()));  //201400422 roy
				},
				rightButton: ((strViewModeIn == "LIST_VIEW") ? (TitleBarAndSideMenu.TITLE_BUTTON_CALENDARVIEW) : (((strViewModeIn == "CALENDAR_VIEW") ? (TitleBarAndSideMenu.TITLE_BUTTON_LISTVIEW) : (null)) )) ,			
				rightButtonOnMouseClick: function() : void
				{
					intArrayIndexSelected.length = 0; //Clear Array
					if(strViewModeIn == "LIST_VIEW") eventChannel.writeEvent(new Event(PageCalendar.CLICK_CALENDARVIEW));
					if(strViewModeIn == "CALENDAR_VIEW") titleButtonBackHandler();
				},
				lstStrSideMenuItem: null,
				intIndexDefaultSideMenuItem: -1,
				sideMenuOnClose: null,
				contentOnLoaded: function(content : MovieClip) : void
				{
					// Show Loading Indicator
					var loadingIndicator : LoadingIndicator = null;
						loadingIndicator = new LoadingIndicator(0xffffff);
						loadingIndicator.x = stage.fullScreenWidth / 5;
						loadingIndicator.y = navigator.getTitleBarHeight() / 2;
						loadingIndicator.scaleX = LayoutManager.intScaleX;
						loadingIndicator.scaleY = LayoutManager.intScaleY;
					this.stage.addChild(loadingIndicator);

					var pageCalendar : PageCalendar = content as PageCalendar;
					if(strDateModeIn == "WORDPRESS_DATE") pageCalendar.setUsingDate(true);  //使用文章上搞時間標示月曆。""預設空字串則使用標籤"[時間]:"去標示月曆。"ARTICLE_LIST": 顯示
					pageCalendar.setArrayIndexSelected(intArrayIndexSelected);
					pageCalendar.webView.addEventListener("WebViewStatusEvent.START_LOAD", function(event : WebViewNativeExtensionEvent)
					{
						pageCalendar.resetData();
					});
					pageCalendar.webView.addEventListener("WebViewStatusEvent.FINISH_LOAD", function(event : WebViewNativeExtensionEvent)
					{
						// Hide Loading Indicator
						loadingIndicator.stopAnim();
						this.stage.removeChild(loadingIndicator);
						
						//Roy: reset the calendar activities after data loaded
						pageCalendar.resetData();
					});
					pageCalendar.webView.addEventListener("WebViewStatusEvent.ERROR", function(event : WebViewNativeExtensionEvent)
					{
						loadingIndicator.stopAnim();
						this.stage.removeChild(loadingIndicator);
					});
					pageCalendar.webView.addEventListener("WebViewStatusEvent.LOCATION_CHANGED", function(event : WebViewNativeExtensionEvent)
					{
						var webView : WebViewNativeExtension = event.target as WebViewNativeExtension;
						try
						{
							var strPrefix : String = "http://tapmovie.com/blank.html?id=";  //代表本機儲存的網頁暫存檔
							var strLocation : String = event.strURL;
							if (strLocation.substring(0, strPrefix.length) == strPrefix)
							{
								var intIndex : int = parseInt(strLocation.substring(strPrefix.length));
								var dicData : Object = pageCalendar.getDicData(intIndex);
								var strTitle = dicData.title;
								var strURLFeed : String = dicData.link;
			
								//Roy: 加入判斷地址
								var strAddress : String = null;
								var strContent : String = dicData.content;
								var strSearch : String = "[地址]：";
								var intStart : Number = strContent.indexOf(strSearch);
								if (intStart != -1)
								{
									intStart += strSearch.length;
									var intEnd : Number = strContent.indexOf("<", intStart);
									strAddress = strContent.substr(intStart, intEnd - intStart).replace("\n", "");
								}
								
								//Roy:有獎問答
								// 2014-06-20 Noin: 改傳 json string 不再使用 feed url
								// 2014-11-20 Noin: 直接傳 parsed data json string
								var contentAndQuizParser : ContentAndQuizParser = new ContentAndQuizParser();
								contentAndQuizParser.funcConverter = convertToScaledLength; // 必要
								dicData = contentAndQuizParser.parseContent(dicData);
								createPagePhotoWithTitleAndTextAndQuiz(strTitle, JSON.stringify(dicData), strAddress);
							}
						}
						catch (error : Error)
						{
							webView.webViewLoadString(error.message + "<br />" + error.getStackTrace().replace("\n", "<br />"), "file:///");
						}
					});
					
					//Roy added: Click calendar and Open the activity list webpage
					pageCalendar.addEventListener(PageCalendar.OPEN_ACTIVITY_PAGE, function(event : Event)
					{
						//pageCalendar.createStrHTMLWithDataCalendar();
						intArrayIndexSelected = pageCalendar.getArrayIndexSelected();
						
						if(intArrayIndexSelected.length > 1) {
							//Roy : 兩篇文章以上就顯示清單
							var dicContentParameterArticleList = createDicContentParameterForPageCalendar(strTitle, strURLFeed, "", "ARTICLE_LIST");
							navigator.pushContent(dicContentParameterArticleList);
						}
						
						if(intArrayIndexSelected.length==1) {
								var dicData : Object = pageCalendar.getDicData(intArrayIndexSelected[0]);
								var strTitleSelected = dicData.title;
								var strURLFeedSelected : String = dicData.link;
			
								//Roy: 加入判斷地址
								var strAddress : String = null;
								var strContent : String = dicData.content;
								var strSearch : String = "[地址]：";
								var intStart : Number = strContent.indexOf(strSearch);
								if (intStart != -1)
								{
									intStart += strSearch.length;
									var intEnd : Number = strContent.indexOf("<", intStart);
									strAddress = strContent.substr(intStart, intEnd - intStart).replace("\n", "");
								}
								
								//Roy:一篇文章就直接顯示內容 
								// 2014-11-20 Noin: 直接傳 parsed data json string
								var contentAndQuizParser : ContentAndQuizParser = new ContentAndQuizParser();
								contentAndQuizParser.funcConverter = convertToScaledLength; // 必要
								dicData = contentAndQuizParser.parseContent(dicData);
								createPagePhotoWithTitleAndTextAndQuiz(strTitleSelected, JSON.stringify(dicData), strAddress);
						}
					});
					
					//20140422 Roy added: Click calendar view
					pageCalendar.addEventListener(PageCalendar.CLICK_CALENDARVIEW, function(event : Event)
					{
						intArrayIndexSelected.length = 0; //Clear Array
						//20140422 Roy : 顯示行事曆
						var dicContentParameterArticleList = createDicContentParameterForPageCalendar(strTitle, strURLFeed, strDateModeIn, "CALENDAR_VIEW");
						navigator.pushContent(dicContentParameterArticleList);
					});
					
					var intWidthHTML : int = (LayoutManager.intScreenWidth - convertToScaledLength(4));
					var intWebViewY : int = navigator.getTitleBarHeight();
					var intWebViewWidth : int = LayoutManager.intScreenWidth;
					var intWebViewHeight : int = LayoutManager.intScreenHeight - intWebViewY;
					
					pageCalendar.setScreenResolution(intWebViewY, intWebViewWidth, intWebViewHeight);
					
					if(strViewModeIn == "ARTICLE_LIST" || strViewModeIn == "LIST_VIEW" )  pageCalendar.showActivityWebView(); //顯示清單
					else pageCalendar.hideActivityWebView(); //顯示月曆
					
					pageCalendar.strHTMLStyleSheet = getStrStyleSheetForPageArticleList(intWidthHTML);
					pageCalendar.strHTMLViewPortWidth = (LayoutManager.intScreenWidth).toString();
					
					CAMEO::IOS {					
						if (Capabilities.os.indexOf("iPhone") != -1) 
						{
							pageCalendar.strHTMLViewPortInitialScale = ((pageCalendar.webView.isRetinaDisplay()) ? ("0.5") : ("1.0"));
							pageCalendar.strHTMLViewPortMaximumScale = ((pageCalendar.webView.isRetinaDisplay()) ? ("0.5") : ("1.0"));
						}
					}
					pageCalendar.strURLImageDefault = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "images/image_default_article_list.png";

					pageCalendar.loadData();
				}
			};
			return dicContentParameter;
			} // End of CAMEO::ANE
		}
		
		private function keyDownEevnt(ev:KeyboardEvent):void {
			if (ev.keyCode == Keyboard.BACK) {
				if (navigator.numOfContent > 1) {
					ev.preventDefault();
        			ev.stopImmediatePropagation();
					titleButtonBackHandler();
				}
			}
		}
		// iOS push notification event handlers
		private function remoteNotifierOnToken(event : RemoteNotificationEvent) : void
        {
			// 將 device token 註冊到 server
			var strDeviceToken : String = event.tokenId.toString();
			var strURL : String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "registerAPN.php?strDeviceToken=" + strDeviceToken;
			var urlRequest : URLRequest = new URLRequest(strURL);
			var urlLoader : URLLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.addEventListener(Event.COMPLETE, function(e : Event)
				{
					// 若收不到推播可以把以下註解拿掉, 看伺服器的回傳是什麼?
					//ToastMessage.showToastMessage(stage, String(e.target.data));
				});
				urlLoader.load(urlRequest);
        } 
		
		private function remoteNotifierOnNotification(event : RemoteNotificationEvent) : void
		{ 
			// 這邊是接收到 push notification
			var strMessage : String = "";
			for (var str:String in event.data) 
			{ 
				if (strMessage.length != 0) strMessage += "\n";
                strMessage += event.data[str];
            }
			//ToastMessage.showToastMessage(this.stage, strMessage);
		} 
		
		private function remoteNotifierOnStatus(e:StatusEvent) : void
		{ 
			// 若是失敗會到這邊
        } 
		
		//Roy 20140219 : Check Internet Status
		private var movieclipNoInternetMessage:MovieClip = new ToastMessageUI();
		private function checkInternetStatus()
		{
			this.internetStatus.addEventListener(InternetStatus.INTERNET_OK, onInternetOK);
			this.internetStatus.addEventListener(InternetStatus.INTERNET_FAIL, onInternetFail);
			this.internetStatus.checkInternetStatus();
		}
		private function removeInternetMonitorEvents()
		{
			if(internetStatus){
				this.internetStatus.removeEventListener(InternetStatus.INTERNET_OK, onInternetOK);
				this.internetStatus.removeEventListener(InternetStatus.INTERNET_FAIL, onInternetFail);
			}
		}		
		private function onInternetOK(e:Event)
		{
			removeInternetMonitorEvents();
		}
		private function onInternetFail(e:Event)
		{
			removeInternetMonitorEvents();
			//showInternetError Message
				movieclipNoInternetMessage.MessageTextField.text = "請開啟網路才可下載新資料";
				this.stage.addChild(movieclipNoInternetMessage);
				LayoutManager.setLayout(movieclipNoInternetMessage);
				movieclipNoInternetMessage.addEventListener(MouseEvent.MOUSE_DOWN, onHideInternetFailMessage);
		}		
		private function onHideInternetFailMessage(e:MouseEvent){
			this.stage.removeChild(movieclipNoInternetMessage);
		}
		
		private function getDateArticleFirst(fileCache : FileCache) : Date
		{
			var date : Date = new Date(0);
			if (fileCache.isCached == false) return date;

			var fileStream : FileStream = new FileStream();
                fileStream.open(fileCache.file, FileMode.READ);
            var strFeed : String = fileStream.readUTFBytes(fileStream.bytesAvailable);
                fileStream.close();
				fileStream = null;

            namespace content = "http://purl.org/rss/1.0/modules/content/";
            use namespace content;
            var rss : XML = new XML(strFeed);
			if (rss.channel.length() == 0 || rss.channel.item.length() == 0)
			{
				return date;
			}
			date.setTime(Date.parse(rss.channel.item[0].pubDate.toString()));
			trace(date);

			return date;
		}
	}

}