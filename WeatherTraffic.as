package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	
	public class WeatherTraffic extends MovieClip {

		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var buttonWeather:SimpleButton = null;
		private const intButtonWeatherX:int = 96;
		private var intButtonWeatherY:int = 22;
		private const intButtonWeatherYIphone5:int = 46;
		private const strWeahterUrl:String = "http://www.cwb.gov.tw/pda/forecast/index.htm";
		
		private var buttonGo:SimpleButton = null;
		private const intButtonGoX:int = 411
		private var intButtonGoY:int = 19;
		private const intButtonGoYIphone5:int = 43;
		private const strGoUrl:String = "http://www.taiwantrip.com.tw/MobileWeb/Index/";
		
		private var buttonHighSpeedRail:SimpleButton = null;
		private const intButtonHighSpeedRailX:int = 101;
		private var intButtonHighSpeedRailY:int = 240;
		private const intButtonHighSpeedRailYIphone5:int = 304;
		private const strHighSpeedRailUrl:String = "http://www.thsrc.com.tw/tw/TimeTable/SearchResult";
		
		private var buttonRailRoad:SimpleButton = null;
		private const intButtonRailRoadX:int = 390;
		private var intButtonRailRoadY:int = 241;
		private const intButtonRailRoadYIphone5:int = 305;
		private const strRailRoadUrl:String = "http://twtraffic.tra.gov.tw/twrail/mobile/home.aspx";
		
		private var buttonBus:SimpleButton = null;
		private const intButtonBusX:int = 94;
		private var intButtonBusY:int = 455;
		private const intButtonBusYIphone5:int = 559;
		private const strBusUrl:String = "http://www.cybus.gov.tw/index.jsp?req=http://61.60.42.190/CYbus/Schedule/OnStopScheduleForPeople.aspx";
		
		private var buttonFreeWayBus:SimpleButton = null;
		private const intButtonFreeWayBusX:int = 389;
		private var intButtonFreeWayBusY:int = 454;
		private const intButtonFreeWayBusYIphone5:int = 558;
		private const strFreeWayBusUrl:String = "http://wwm.cibus.com.tw/modules/tinyd1/index.php?id=4#place";
		
		private var buttonTaxi:SimpleButton = null;
		private const intButtonTaxiX:int = 87;
		private var intButtonTaxiY:int = 643;
		private const intButtonTaxiYIphone5:int = 787;
		///private const strTaxiUrl:String = "http://www.iyp.com.tw/search.php?=&k=%E8%A8%88%E7%A8%8B%E8%BB%8A%E8%A1%8C&a_id=14";
		private const strTaxiUrl:String = "http://chiayiapp.cyhg.gov.tw/chiayiapp/taxi/";
		
		private var buttonRentCar:SimpleButton = null;
		private const intButtonRentCarX:int = 389;
		private var intButtonRentCarY:int = 647;
		private const intButtonRentCarYIphone5:int = 791;
		///private const strRentCarUrl:String = "http://www.iyp.com.tw/showroom.php?cate_name_eng_lv1=transportation&cate_name_eng_lv3=motorcycle-rentals&a_id=14";
		private const strRentCarUrl:String = "http://chiayiapp.cyhg.gov.tw/chiayiapp/rental/";
		
		public function WeatherTraffic(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
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
			removeButton();
			removeBackground();
		}
		
		private function changeLayoutForIphone5() {
			intButtonWeatherY = intButtonWeatherYIphone5;
			intButtonGoY = intButtonGoYIphone5;
			intButtonHighSpeedRailY = intButtonHighSpeedRailYIphone5;
			intButtonRailRoadY = intButtonRailRoadYIphone5;
			intButtonBusY = intButtonBusYIphone5;
			intButtonFreeWayBusY = intButtonFreeWayBusYIphone5;
			intButtonTaxiY = intButtonTaxiYIphone5;
			intButtonRentCarY = intButtonRentCarYIphone5;
		}
		
		private function createBackground() {
			bg = (isIphone5Layout) ? new WeatherTrafficBakcgroundIphone5() : new WeatherTrafficBakcgroundIphone4();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			this.removeChild(bg);
			bg = null;
		}
		
		private function createButton() {
			buttonWeather = new ButtonWeather();
			buttonWeather.x = intButtonWeatherX;
			buttonWeather.y = intButtonWeatherY;
			this.addChild(buttonWeather);
			
			buttonGo = new ButtonGo();
			buttonGo.x = intButtonGoX;
			buttonGo.y = intButtonGoY;
			this.addChild(buttonGo);
			
			buttonHighSpeedRail = new ButtonHighSpeedRail();
			buttonHighSpeedRail.x = intButtonHighSpeedRailX;
			buttonHighSpeedRail.y = intButtonHighSpeedRailY;
			this.addChild(buttonHighSpeedRail);
			
			buttonRailRoad = new ButtonRailRoad();
			buttonRailRoad.x = intButtonRailRoadX;
			buttonRailRoad.y = intButtonRailRoadY;
			this.addChild(buttonRailRoad);
			
			buttonBus = new ButtonBus();
			buttonBus.x = intButtonBusX;
			buttonBus.y = intButtonBusY;
			this.addChild(buttonBus);
			
			buttonFreeWayBus = new ButtonFreeWayBus();
			buttonFreeWayBus.x = intButtonFreeWayBusX;
			buttonFreeWayBus.y = intButtonFreeWayBusY;
			this.addChild(buttonFreeWayBus);
			
			buttonTaxi = new ButtonTaxi();
			buttonTaxi.x = intButtonTaxiX;
			buttonTaxi.y = intButtonTaxiY;
			this.addChild(buttonTaxi);
			
			buttonRentCar = new ButtonRentCar();
			buttonRentCar.x = intButtonRentCarX;
			buttonRentCar.y = intButtonRentCarY;
			this.addChild(buttonRentCar);
			
			addButtonEventListener();
		}
		
		private function addButtonEventListener() {
			buttonWeather.addEventListener(MouseEvent.CLICK, onButtonClick);
			buttonGo.addEventListener(MouseEvent.CLICK, onButtonClick);
			buttonHighSpeedRail.addEventListener(MouseEvent.CLICK, onButtonClick);
			buttonRailRoad.addEventListener(MouseEvent.CLICK, onButtonClick);
			buttonBus.addEventListener(MouseEvent.CLICK, onButtonClick);
			buttonFreeWayBus.addEventListener(MouseEvent.CLICK, onButtonClick);
			buttonTaxi.addEventListener(MouseEvent.CLICK, onButtonClick);
			buttonRentCar.addEventListener(MouseEvent.CLICK, onButtonClick);
		}
		
		private function removeButton() {
			removeButtonEventListener();
			
			this.removeChild(buttonWeather);
			this.removeChild(buttonGo);
			this.removeChild(buttonHighSpeedRail);
			this.removeChild(buttonRailRoad);
			this.removeChild(buttonBus);
			this.removeChild(buttonFreeWayBus);
			this.removeChild(buttonTaxi);
			this.removeChild(buttonRentCar);
			buttonWeather = null;
			buttonGo = null;
			buttonHighSpeedRail = null;
			buttonRailRoad = null;
			buttonBus = null;
			buttonFreeWayBus = null;
			buttonTaxi = null;
			buttonRentCar = null;
		}
		
		private function removeButtonEventListener() {
			buttonWeather.removeEventListener(MouseEvent.CLICK, onButtonClick);
			buttonGo.removeEventListener(MouseEvent.CLICK, onButtonClick);
			buttonHighSpeedRail.removeEventListener(MouseEvent.CLICK, onButtonClick);
			buttonRailRoad.removeEventListener(MouseEvent.CLICK, onButtonClick);
			buttonBus.removeEventListener(MouseEvent.CLICK, onButtonClick);
			buttonFreeWayBus.removeEventListener(MouseEvent.CLICK, onButtonClick);
			buttonTaxi.removeEventListener(MouseEvent.CLICK, onButtonClick);
			buttonRentCar.removeEventListener(MouseEvent.CLICK, onButtonClick);
		}
		
		private function onButtonClick(e:MouseEvent) {
			if (e.target is ButtonWeather)       openUrl(strWeahterUrl);
			if (e.target is ButtonGo)            openUrl(strGoUrl);
			if (e.target is ButtonHighSpeedRail) openUrl(strHighSpeedRailUrl);
			if (e.target is ButtonRailRoad)      openUrl(strRailRoadUrl);
			if (e.target is ButtonBus)           openUrl(strBusUrl);
			if (e.target is ButtonFreeWayBus)    openUrl(strFreeWayBusUrl);
			if (e.target is ButtonTaxi)          openUrl(strTaxiUrl);
			if (e.target is ButtonRentCar)       openUrl(strRentCarUrl);
		}
		
		private function openUrl(strUrl:String):void {
			var url:URLRequest = new URLRequest(strUrl);
			navigateToURL(url);
		}
	}
	
}
