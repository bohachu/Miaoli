package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.net.SharedObject;
	import flash.sensors.Geolocation;
	import flash.events.GeolocationEvent;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import GashaponData;
	
	public class TreasureGameHome extends MovieClip {

		static public const CLICK_PLAY:String = "TreasureGameHome.CLICK_PLAY";
		static public const CLICK_COLLECTION:String = "TreasureGameHome.CLICK_COLLECTION";
		
		private var sharedObject:SharedObject = SharedObject.getLocal("TreasureGame");
		private var eventChannel:EventChannel = null;
		private var gashaponData:GashaponData = GashaponData.getInstance();
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var homeScreen:MovieClip = null;
		
		private var gameIntro:MovieClip = null;
		
		public function TreasureGameHome(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			
			if (Geolocation.isSupported) {
				// 讓使用者在開啟尋寶遊戲首頁便會詢問開啟定位服務
				var _geo:Geolocation = new Geolocation();
				_geo.addEventListener(GeolocationEvent.UPDATE, geoHandler);
			}
		}
		
		private function geoHandler(e:GeolocationEvent) {
			// 讓使用者在開啟尋寶遊戲首頁便會詢問開啟定位服務
			var _geo:Geolocation = e.target as Geolocation;
			_geo.removeEventListener(GeolocationEvent.UPDATE, geoHandler);
			_geo = null;
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
			initHomeScreen();
//			
//			if (!sharedObject.data.hasOwnProperty("hasShowIntro")) showGameIntro();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeGameIntro();
			removeHomeScreen();
			eventChannel = null;
		}
		
		private function changeLayoutForIphone5() {
		}
		
		private function initHomeScreen() {
			homeScreen = (isIphone5Layout) ? new TreasureHomeIphone5() : new TreasureHomeIphone4();
			homeScreen.playGashaponButton.addEventListener(MouseEvent.CLICK, onButtonClick);
			homeScreen.collectionButton.addEventListener(MouseEvent.CLICK, onButtonClick);
			this.addChild(homeScreen);
		}
		
		private function removeHomeScreen() {
			homeScreen.playGashaponButton.removeEventListener(MouseEvent.CLICK, onButtonClick);
			homeScreen.collectionButton.removeEventListener(MouseEvent.CLICK, onButtonClick);
			this.removeChild(homeScreen);
			homeScreen = null;
		}
		
		private function onButtonClick(e:MouseEvent) {
			if (e.target.name == "playGashaponButton") eventChannel.writeEvent(new Event(TreasureGameHome.CLICK_PLAY)); 
			if (e.target.name == "collectionButton")   eventChannel.writeEvent(new Event(TreasureGameHome.CLICK_COLLECTION)); 
		}
		
		private function showGameIntro() {
			sharedObject.data["hasShowIntro"] = true;
			sharedObject.flush();
			
			gameIntro = (isIphone5Layout) ? new GameIntroIphone5() : new GameIntroIphone4();
			gameIntro.addEventListener(MouseEvent.CLICK, removeGameIntro);
			this.addChild(gameIntro);
		}
		
		private function removeGameIntro(e:MouseEvent = null) {
			if (gameIntro) this.removeChild(gameIntro);
			gameIntro = null;
		}
	}
	
}
