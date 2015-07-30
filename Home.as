package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.RandomRotateObjectModify;
	import com.adobe.protocols.dict.Database;
	import tw.cameo.net.HttpLink;
	
	public class Home extends MovieClip {

		static public const CLICK_ABOUT:String = "Home.CLICK_ABOUT";
		static public const CLICK_ACTIVITY:String = "Home.CLICK_ACTIVITY";
		static public const CLICK_NEWS:String = "Home.CLICK_NEWS";
		static public const CLICK_CALENDAR:String = "Home.CLICK_CALENDAR";
		static public const CLICK_VIDEO:String = "Home.CLICK_VIDEO";
		static public const CLICK_TRAFFIC:String = "Home.CLICK_TRAFFIC";
		static public const CLICK_GAME:String = "Home.CLICK_GAME";
		static public const CLICK_TRESURE_GAME:String = "Home.CLICK_TRESURE_GAME";
		
		private var eventChannel:EventChannel = null;
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		private var logo:Sprite = null;
		
		private var date:Date = new Date();
		private var gameLimitDate:Date = new Date(2014, 9, 1, 23, 59, 59);
		
		private var aboutButton:SimpleButton = null;
		private const intAboutButtonX:int = 565;
		private const intAboutButtonY:int = 10;
		
		private var activityButton:SimpleButton = null;
		private const intActivityButtonX:int = 100;
		private var intActivityButtonY:int = 313;
		private const intActivityButtonYIphone5:int = 387;
		
		private var newsButton:SimpleButton = null;
		private const intNewsButtonX:int = 365;
		private var intNewsButtonY:int = 318;
		private const intNewsButtonYIphone5:int = 387;
		
		private var calendarButton:SimpleButton = null;
		private const intCalendarButtonX:int = 105;
		private var intCalendarButtonY:int = 548;
		private const intCalendarButtonYIphone5:int = 658;
		
		private var videoButton:SimpleButton = null;
		private const intMovieButtonX:int = 387;
		private var intMovieButtonY:int = 531;
		private const intMovieButtonYIphone5:int = 640;
		
		private var trafficButton:SimpleButton = null;
		private const intTrafficButtonX:int = 108;
		private var intTrafficButtonY:int = 736;
		private const intTrafficButtonYIphone5:int = 899;
		
		private var gameButton:SimpleButton = null;
		private const intGameButtonX:int = 370;
		private var intGameButtonY:int = 743;
		private const intGameButtonYIphone5:int = 908;
		
		private var treasureGameButton:SimpleButton = null;
		private const intTreasureGameButtonX:int = 0;
		private var intTreasureGameButtonY:int = 111;
		private const intTreasureGameButtonYIphone5:int = 163;
		private var treasureGameMessage:Sprite = null;
		private var randomRotate:RandomRotateObjectModify = null;
		
		public function Home() {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			eventChannel = EventChannel.getInstance();
			
			LayoutManager.setLayout(this);
			isIphone5Layout = LayoutManager.useIphone5Layout();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBackground();
			createButton();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeTreasureGameMessage();
			removeButton();
			removeBackground();
			date = null;
			eventChannel = null;
		}
		
		private function changeLayoutForIphone5() {
			intActivityButtonY = intActivityButtonYIphone5;
			intNewsButtonY = intNewsButtonYIphone5;
			intCalendarButtonY = intCalendarButtonYIphone5;
			intMovieButtonY = intMovieButtonYIphone5;
			intTrafficButtonY = intTrafficButtonYIphone5;
			intGameButtonY = intGameButtonYIphone5;
		}
		
		private function createBackground() {
			var intNowHour:int = date.hours;
			
			if (intNowHour >= 7 && intNowHour < 12) {
				bg = (isIphone5Layout) ? new BackgroundMorningIphone5() : new BackgroundMorningIphone4();
			}
			if (intNowHour >= 12 && intNowHour < 19) {
				bg = (isIphone5Layout) ? new BackgroundAfternoonIphone5() : new BackgroundAfternoonIphone4();
			}
			if (intNowHour >= 19 || intNowHour < 7) {
				bg = (isIphone5Layout) ? new BackgroundNightIphone5() : new BackgroundNightIphone4();
			}
			
			this.addChild(bg);
			
			logo = new Logo();
			logo.x = 1.5;
			logo.y = 7;
			this.addChild(logo);
		}
		
		private function removeBackground() {
			this.removeChild(bg);
			bg = null;
			this.removeChild(logo);
			logo = null;
		}
		
		private function createButton() {
			aboutButton = new HomeButton_About();
			aboutButton.x = intAboutButtonX;
			aboutButton.y = intAboutButtonY;
			this.addChild(aboutButton);
			
			activityButton = new HomeButton_Activity();
			activityButton.x = intActivityButtonX;
			activityButton.y = intActivityButtonY;
			this.addChild(activityButton);
			
			newsButton = new HomeButton_News();
			newsButton.x = intNewsButtonX;
			newsButton.y = intNewsButtonY;
			this.addChild(newsButton);
			
			calendarButton = new HomeButton_Calendar();
			calendarButton.x = intCalendarButtonX;
			calendarButton.y = intCalendarButtonY;
			this.addChild(calendarButton);
			
			videoButton = new HomeButton_Video();
			videoButton.x = intMovieButtonX;
			videoButton.y = intMovieButtonY;
			this.addChild(videoButton);
			
			trafficButton = new HomeButton_Traffic();
			trafficButton.x = intTrafficButtonX;
			trafficButton.y = intTrafficButtonY;
			this.addChild(trafficButton);
			
			gameButton = new HomeButton_Game();
			gameButton.x = intGameButtonX;
			gameButton.y = intGameButtonY;
			this.addChild(gameButton);
			
			treasureGameButton = new TreasureGameButton();
			treasureGameButton.x = intTreasureGameButtonX;
			treasureGameButton.y = intTreasureGameButtonY;
			this.addChild(treasureGameButton);
			randomRotate = new RandomRotateObjectModify(treasureGameButton);
//			if (date <= gameLimitDate) {
//			}
			
			addButtonEventListener();
		}
		
		private function addButtonEventListener() {
			aboutButton.addEventListener(MouseEvent.CLICK, onHomeButtonClick);
			activityButton.addEventListener(MouseEvent.CLICK, onHomeButtonClick);
			newsButton.addEventListener(MouseEvent.CLICK, onHomeButtonClick);
			calendarButton.addEventListener(MouseEvent.CLICK, onHomeButtonClick);
			videoButton.addEventListener(MouseEvent.CLICK, onHomeButtonClick);
			trafficButton.addEventListener(MouseEvent.CLICK, onHomeButtonClick);
			gameButton.addEventListener(MouseEvent.CLICK, onHomeButtonClick);
			
			treasureGameButton.addEventListener(MouseEvent.CLICK, openUrl);
		}
		
		private function removeButtonEventListener() {
			aboutButton.removeEventListener(MouseEvent.CLICK, onHomeButtonClick);
			activityButton.removeEventListener(MouseEvent.CLICK, onHomeButtonClick);
			newsButton.removeEventListener(MouseEvent.CLICK, onHomeButtonClick);
			calendarButton.removeEventListener(MouseEvent.CLICK, onHomeButtonClick);
			videoButton.removeEventListener(MouseEvent.CLICK, onHomeButtonClick);
			trafficButton.removeEventListener(MouseEvent.CLICK, onHomeButtonClick);
			gameButton.removeEventListener(MouseEvent.CLICK, onHomeButtonClick);
			
			treasureGameButton.removeEventListener(MouseEvent.CLICK, openUrl);
		}
		
		private function removeButton() {
			removeButtonEventListener();
			this.removeChild(aboutButton);
			this.removeChild(activityButton);
			this.removeChild(newsButton);
			this.removeChild(calendarButton);
			this.removeChild(videoButton);
			this.removeChild(trafficButton);
			this.removeChild(gameButton);
			
			if (treasureGameButton) {
				randomRotate.dispose();
				randomRotate = null;
				this.removeChild(treasureGameButton);
			}
			
			aboutButton = null;
			activityButton = null;
			newsButton = null;
			calendarButton = null;
			videoButton = null;
			trafficButton = null;
			gameButton = null;
			treasureGameButton = null;
		}
		
		private function onHomeButtonClick(e:MouseEvent) {
			if (e.target is HomeButton_About)    eventChannel.writeEvent(new Event(Home.CLICK_ABOUT)); 
			if (e.target is HomeButton_Activity) eventChannel.writeEvent(new Event(Home.CLICK_ACTIVITY)); 
			if (e.target is HomeButton_News)     eventChannel.writeEvent(new Event(Home.CLICK_NEWS)); 
			if (e.target is HomeButton_Calendar) eventChannel.writeEvent(new Event(Home.CLICK_CALENDAR)); 
			if (e.target is HomeButton_Video)    eventChannel.writeEvent(new Event(Home.CLICK_VIDEO)); 
			if (e.target is HomeButton_Traffic)  eventChannel.writeEvent(new Event(Home.CLICK_TRAFFIC)); 
			if (e.target is HomeButton_Game)     eventChannel.writeEvent(new Event(Home.CLICK_GAME)); 
//			if (e.target is TreasureGameButton)  eventChannel.writeEvent(new Event(Home.CLICK_TRESURE_GAME)); 
		}
		
		private function openUrl(e:MouseEvent) {
			HttpLink.openUrl("http://235tbocc.info/");
		}
		
		private function showTreasureGameMessage(e:MouseEvent) {
			treasureGameMessage = new TreasureGameMessage();
			if (!isIphone5Layout) {
				treasureGameMessage.y = -70;
			}
			treasureGameMessage.addEventListener(MouseEvent.CLICK, goToTreasureGame);
			this.addChild(treasureGameMessage);
		}
		
		private function goToTreasureGame(e:MouseEvent = null) {
			removeTreasureGameMessage();
//			eventChannel.writeEvent(new Event(Home.CLICK_TRESURE_GAME));
		}
		
		private function removeTreasureGameMessage(e:MouseEvent = null) {
			if (treasureGameMessage) {
				treasureGameMessage.removeEventListener(MouseEvent.CLICK, removeTreasureGameMessage);
				this.removeChild(treasureGameMessage);
			}
			treasureGameMessage = null;
		}
	}
	
}
