package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.SimpleButton;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	import flash.net.URLVariables;
	
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.LocationManager;
	import tw.cameo.events.MovieEvents;
	import tw.cameo.ToastMessage;
	import tw.cameo.net.HttpRequest;
	import tw.cameo.events.HttpRequestEvent;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import GashaponData;
	import TreasureGameLocationData;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class Gashapon extends MovieClip {
		
		private const strPostUrl:String = CONFIG::WEB_SERVER_URL + CONFIG::WEB_PATH_PREFIX + "eventUserData.php";

		private var intResetTotalRemainingSecond:int = 10; // 測試每 10 秒玩一次

		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var gashaponData:GashaponData = GashaponData.getInstance();
		private var sharedObject:SharedObject = SharedObject.getLocal("TreasureGame");
		private var lstUngetGashapon:Array = null;
		private var lstGotGashapon:Array = null;
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var machineLayer:Sprite = null;
		private var countDownTimerLayer:Sprite = null;
		
		private var machine:MovieClip = null;
		private const intMachineX:int = 324;
		private var intMachineY:int = 455;
		private const intMachineYIphone5:int = 539;
		private var machinePlayTimer:Timer = null;
		private var isComplete:Boolean = false;
		
		private var bgSound:Sound = null;
		private var shakeSound:Sound = null;
		private var taDaSound:Sound = null;
		private var bgSoundChannel:SoundChannel = null;
		private var fxSoundChannel:SoundChannel = null;
		
		private var intTotalRemaingingSecond:Number = 0;
		private var intLeaveTime:Number = 0;
		private var countDownTimer:Timer = null;
		private var countDOwnTimerPannel:MovieClip = null;
		private const intTimerPannelX:int = 320;
		private var intTimerPannelY:int = 480;
		private const intTimerPannelYIphone5:int = 568;
		
		private var locationManager:LocationManager = null;
		private var isNear:Boolean = false;
		private var intNearLocationIndex:int = -1;
		
		private var isLastSticker:Boolean = false;
		private var isNewSticker:Boolean = false;
		private var intStickerIndex:int = 0;
		private var isShowBonusDraw:Boolean = false;

		private var strStickerName:String = "1";
		private var stickerInfoDialog:MovieClip = null;
		
		private var informationPannel:MovieClip = null;
		private var finalStickerDialog:MovieClip = null;
		private var uploadingInfo:MovieClip = null;
		
		public function Gashapon(... args) {
			// constructor code
		
			CAMEO::ANE {
				intResetTotalRemainingSecond = 600; // 正式版本 10 分鐘玩一次
			}
			
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			lstUngetGashapon = gashaponData.getLstUngetGashapon();
			lstGotGashapon = gashaponData.getLstGotGashapon();
			adjustTotalRemainingSecond();
		}
		
		private function adjustTotalRemainingSecond() {
			if (!sharedObject.data.hasOwnProperty("intTotalRemainingSecond")) {
				intTotalRemaingingSecond = 0;
			}
			
			if (sharedObject.data.hasOwnProperty("intTotalRemainingSecond")) {
				intTotalRemaingingSecond = sharedObject.data["intTotalRemainingSecond"];
				var currentDate:Date = new Date();
				
				if (!sharedObject.data.hasOwnProperty("leaveTime")) intLeaveTime = currentDate.time;
				if (sharedObject.data.hasOwnProperty("leaveTime")) intLeaveTime = sharedObject.data["leaveTime"];
				
				var intTimeDiff:int = int((currentDate.time - intLeaveTime) / 1000); // 取秒數
				if (intTimeDiff < 0) intTimeDiff = 0;
				
				if ((intTotalRemaingingSecond - intTimeDiff) > 0) intTotalRemaingingSecond = intTotalRemaingingSecond - intTimeDiff;
				if ((intTotalRemaingingSecond - intTimeDiff) <= 0) intTotalRemaingingSecond = 0;
			}
			
//			intTotalRemaingingSecond = 300;
			if (intTotalRemaingingSecond > intResetTotalRemainingSecond) intTotalRemaingingSecond = intResetTotalRemainingSecond;
		}
		
		private function saveLeaveDateTime() {
			var currentDate:Date = new Date();
			sharedObject.data["leaveTime"] = currentDate.time;
			sharedObject.data["intTotalRemainingSecond"] = intTotalRemaingingSecond;
			sharedObject.flush();
		}
		
		private function init(e:Event) {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, destructor);
			
			LayoutManager.setLayout(this);
			isIphone5Layout = LayoutManager.useIphone5Layout();
			
			if (isIphone5Layout) {
				changeLayoutForIphone5();
			}
			createBg();
			initLayer();
			initSound();
			initCountDownTimer();
			initStopMachine();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeFinalStickerDialog();
			removeUploadingInfo();
			removeInformationPannel();
			removeStickerInfoDialog();
			removeLocationManager();
			removeMachinePlayTimer();
			removeMachine();
			removeCountDownTimer();
			removeSound();
			removeLayer();
			removeBg();
			saveLeaveDateTime();
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onMessageClose);
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
			intMachineY = intMachineYIphone5;
			intTimerPannelY = intTimerPannelYIphone5;
		}
		
		private function createBg() {
			bg = new Sprite();
			bg.graphics.beginFill(0xFFCC00);
			bg.graphics.drawRect(0, 0, 640, 1136);
			bg.graphics.endFill();
			this.addChild(bg);
		}
		
		private function removeBg() {
			this.removeChild(bg);
			bg = null;
		}
		
		private function initLayer() {
			machineLayer = new Sprite();
			this.addChild(machineLayer);
			countDownTimerLayer = new Sprite();
			this.addChild(countDownTimerLayer);
		}
		
		private function removeLayer() {
			this.removeChild(machineLayer);
			this.removeChild(countDownTimerLayer);
			machineLayer = null;
			countDownTimerLayer = null;
		}
		
		private function initSound() {
			bgSound = new BgSound();
			shakeSound = new ShakeSound();
			taDaSound = new TaDaSound();
			bgSoundChannel = new SoundChannel();
			fxSoundChannel = new SoundChannel();
		}
		
		private function removeSound() {
			if (bgSoundChannel) bgSoundChannel.stop();
			if (fxSoundChannel) fxSoundChannel.stop();
			bgSound = null;
			shakeSound = null;
			taDaSound = null;
			bgSoundChannel = null;
			fxSoundChannel = null;
		}
		
		private function initCountDownTimer() {
			if (intTotalRemaingingSecond > 0) {
				countDownTimer = new Timer(1000);
				countDownTimer.addEventListener(TimerEvent.TIMER, onTimer);
				countDownTimer.start();
				createCountDownTimerPannel();
			}
		}
		
		private function createCountDownTimerPannel() {
			countDOwnTimerPannel = new CountTimerPannel();
			countDOwnTimerPannel.x = intTimerPannelX;
			countDOwnTimerPannel.y = intTimerPannelY;
			countDownTimerLayer.addChild(countDOwnTimerPannel);
		}
		
		private function removeCountDownTimer() {
			if (countDownTimer) {
				countDownTimer.removeEventListener(TimerEvent.TIMER, onTimer);
				countDownTimer.stop();
			}
			countDownTimer = null;
			removeCountDownTimerPannel();
		}

		private function removeCountDownTimerPannel() {
			if (countDOwnTimerPannel) {
				countDownTimerLayer.removeChild(countDOwnTimerPannel);
				countDOwnTimerPannel = null;
			}
		}
		
		private function onTimer(e:TimerEvent) {
			intTotalRemaingingSecond--;
			setTimerText();
			
			if (intTotalRemaingingSecond == 0) {
				removeCountDownTimer();
			}
		}

		private function setTimerText() {
			var intRemainSecond:int = 0;
			
			var intRemainHour:int = Math.floor(intTotalRemaingingSecond/3600);
			intRemainSecond = Math.floor(intTotalRemaingingSecond%3600);
			
			var intRemainMinute:int = Math.floor(intRemainSecond/60);
			intRemainSecond = Math.floor(intRemainSecond%60);
			
			countDOwnTimerPannel.hourText.text = (intRemainHour > 9) ? String(intRemainHour) : "0" + String(intRemainHour);
			countDOwnTimerPannel.minuteText.text = (intRemainMinute > 9) ? String(intRemainMinute) : "0" + String(intRemainMinute);
			countDOwnTimerPannel.secondText.text = (intRemainSecond > 9) ? String(intRemainSecond) : "0" + String(intRemainSecond);
		}
		
		private function initStopMachine() {
			machine = new MachineStop();
			machine.x = intMachineX;
			machine.y = intMachineY;
			
			machine.startButton.addEventListener(MouseEvent.CLICK, playGashapon);
			
			machineLayer.addChild(machine);
		}
		
		private function removeMachine() {
			if (machine) {
				if (machine is MachineStop) machine.startButton.removeEventListener(MouseEvent.CLICK, playGashapon);
				machine.removeEventListener(MovieEvents.MOVIE_PLAY_END, onMachineEndingPlayEnd);
				machineLayer.removeChild(machine);
			}
			machine = null;
		}
		
		private function playGashapon(e:MouseEvent) {
			removeMachine();
			initPlayMachine();
			initMachinePlayTimer();
			setWinSticker();
		}
		
		private function initPlayMachine() {
			isComplete = false;
			machine = new MachinePlay();
			machine.x = intMachineX;
			machine.y = intMachineY;
			machineLayer.addChild(machine);
			bgSoundChannel = bgSound.play(0, int.MAX_VALUE);
			fxSoundChannel = shakeSound.play(0, int.MAX_VALUE);
		}
		
		private function initMachinePlayTimer() {
			machinePlayTimer = new Timer(3000);
			machinePlayTimer.addEventListener(TimerEvent.TIMER, onMachinePlayTimer);
			machinePlayTimer.start();
		}
		
		private function removeMachinePlayTimer() {
			if (machinePlayTimer) {
				machinePlayTimer.stop();
				machinePlayTimer.removeEventListener(TimerEvent.TIMER, onMachinePlayTimer);
			}
			machinePlayTimer = null;
		}
		
		private function setWinSticker() {
			isNear = false;
			locationManager = new LocationManager();
			locationManager.addEventListener(LocationManager.EventNearFound, nearFoundHandler);
			locationManager.addEventListener(LocationManager.EventFailIntent, eventFail);
			locationManager.addEventListener(LocationManager.EventNearNoFound, nearNoFoundHandler);
			
			CAMEO::ANE {
				locationManager.isNearRange(TreasureGameLocationData.lstLocation, 15.0); // 3km
			}
			
			CAMEO::NO_ANE{
				nearFoundHandler();
			}
		}
		
		private function removeLocationManager() {
			if (locationManager) {
				locationManager.addEventListener(LocationManager.EventNearFound, nearFoundHandler);
				locationManager.addEventListener(LocationManager.EventFailIntent, eventFail);
				locationManager.addEventListener(LocationManager.EventNearNoFound, nearNoFoundHandler);
			}
			locationManager = null;
		}
		
		private function nearFoundHandler(e:Event = null) {
			isNear = true;
			CAMEO::ANE {
				intNearLocationIndex = locationManager.getIndexNear();
			}
			
			CAMEO::NO_ANE {
				intNearLocationIndex = 4;
			}
			removeLocationManager();
			getSticker();
		}
		
		private function eventFail(e:Event = null) {
			removeLocationManager();
			getSticker();
		}
		
		private function nearNoFoundHandler(e:Event = null) {
			removeLocationManager();
			getSticker();
		}
		
		private function getSticker() {
//			trace("Gashapon.as / getSticker: isNear", isNear);
			isNewSticker = (Math.round(Math.random()) == 1) ? true : false;
			
			if (lstGotGashapon.length == 0) isNewSticker = true; // 還沒抽過任何扭蛋，就一定會抽到新的扭蛋
			if (lstUngetGashapon.length == 0) isNewSticker = false; // 如果已經沒有任何新扭蛋，就一定會抽到舊的扭蛋
			
			if (isNear) {
				strStickerName = String(intNearLocationIndex + 1);
				if (lstGotGashapon.indexOf(strStickerName) >= 0) {
					if (isNewSticker) getNewSticker();
					if (!isNewSticker) getOldSticker();
				} else {
					isNewSticker = true;
					intStickerIndex = lstUngetGashapon.indexOf(strStickerName);
				}
			}
			
			if (!isNear) {
				if (isNewSticker) getNewSticker();
				if (!isNewSticker) getOldSticker();
			}
			
			if (isNewSticker) {
				lstGotGashapon.push(lstUngetGashapon[intStickerIndex]);
				lstUngetGashapon.splice(intStickerIndex, 1);
				gashaponData.saveData(lstUngetGashapon, lstGotGashapon);
				if (lstUngetGashapon.length == 0) isLastSticker = true;
			}
			
//			CAMEO::NO_ANE {
//				isLastSticker = true;
//			}
			
			intTotalRemaingingSecond = intResetTotalRemainingSecond;
			isComplete = true;
			
//			trace("Gashapon.as / getSticker: isNewSticker, intStickerIndex:", isNewSticker, intStickerIndex);
//			trace("Gashapon.as / getSticker:", lstUngetGashapon, lstGotGashapon);
		}
		
		private function getNewSticker() {
			if (lstUngetGashapon.length == 1) {
				intStickerIndex = 0;
			} else {
				intStickerIndex = Math.floor(Math.random()*(lstUngetGashapon.length));
			}
			strStickerName = lstUngetGashapon[intStickerIndex];
		}
		
		private function getOldSticker() {
			if (lstGotGashapon.length == 1) {
				intStickerIndex = 0;
			} else {
				intStickerIndex = Math.floor(Math.random()*(lstGotGashapon.length));
			}
			strStickerName = lstGotGashapon[intStickerIndex];
		}
		
		private function onMachinePlayTimer(e:TimerEvent) {
			if (isComplete) {
				removeMachinePlayTimer();
				removeMachine();
				initEndingMachine();
			}
		}
		
		private function initEndingMachine() {
			fxSoundChannel.stop();
			machine = new MachineEnding();
			machine.x = intMachineX;
			machine.y = intMachineY;
			machine.addEventListener(MovieEvents.MOVIE_PLAY_END, onMachineEndingPlayEnd);
			machineLayer.addChild(machine);
		}
		
		private function onMachineEndingPlayEnd(e:Event) {
			if (machine) {
				machine.removeEventListener(MovieEvents.MOVIE_PLAY_END, onMachineEndingPlayEnd);
			}
			showStickerInfoDialog();
			fxSoundChannel = taDaSound.play(0);
		}
		
		private function showStickerInfoDialog() {
			stickerInfoDialog = new StickerInfoDialog();
			stickerInfoDialog.x = 320;
			stickerInfoDialog.y = intDefaultHeight/2-35;
			
			if (isNewSticker) {
				stickerInfoDialog.againButton.visible = false;
				stickerInfoDialog.goButton.addEventListener(MouseEvent.CLICK, goNextStep);
			} else {
				stickerInfoDialog.goButton.visible = false;
				stickerInfoDialog.againButton.addEventListener(MouseEvent.CLICK, onAgainButtonClick);
			}
			
			var iconClass:Class = getDefinitionByName("Icon" + strStickerName) as Class;
			var infoClass:Class = getDefinitionByName("Info" + strStickerName) as Class;
			
			stickerInfoDialog.iconArea.removeChildren();
			stickerInfoDialog.infoArea.removeChildren();
			
			stickerInfoDialog.iconArea.addChild(new iconClass());
			stickerInfoDialog.infoArea.addChild(new infoClass());
			
			stickerInfoDialog.scaleX = stickerInfoDialog.scaleY = 0.4;
			stickerInfoDialog.alpha = 0;
			stickerInfoDialog.rotation = -90;
			this.addChild(stickerInfoDialog);
			TweenLite.to(stickerInfoDialog, 1, {scaleX:1, scaleY:1, alpha:1, rotation:0, ease:Bounce.easeOut});
		}
		
		private function removeStickerInfoDialog() {
			if (stickerInfoDialog) {
				this.removeChild(stickerInfoDialog);
				stickerInfoDialog.goButton.removeEventListener(MouseEvent.CLICK, goNextStep);
				stickerInfoDialog.againButton.removeEventListener(MouseEvent.CLICK, onAgainButtonClick);
			}
			stickerInfoDialog = null;
		}
		
		private function dummyFuncForDynamicCreate() {
			var icon1:Icon1 = null;
			var icon2:Icon2 = null;
			var icon3:Icon3 = null;
			var icon4:Icon4 = null;
			var icon5:Icon5 = null;
			var icon6:Icon6 = null;
			var icon7:Icon7 = null;
			var icon8:Icon8 = null;
			var icon9:Icon9 = null;
			var icon10:Icon10 = null;
			var icon11:Icon11 = null;
			var icon12:Icon12 = null;
			var icon13:Icon13 = null;
			
			var info1:Info1 = null;
			var info2:Info2 = null;
			var info3:Info3 = null;
			var info4:Info4 = null;
			var info5:Info5 = null;
			var info6:Info6 = null;
			var info7:Info7 = null;
			var info8:Info8 = null;
			var info9:Info9 = null;
			var info10:Info11 = null;
			var info11:Info12 = null;
			var info12:Info13 = null;
			var info13:Info13 = null;
		}
		
		private function onAgainButtonClick(e:MouseEvent) {
			bgSoundChannel.stop();
			removeStickerInfoDialog();
			removeMachine();
			initStopMachine();
			initCountDownTimer();
		}
		
		private function goNextStep(e:MouseEvent) {
			bgSoundChannel.stop();
			removeStickerInfoDialog();
			removeMachine();
			initStopMachine();
			initCountDownTimer();
			
			if (isLastSticker) {
				showAllStickerGetDialog();
//			} else {
//				showInformationPannel();
			}
		}
		
		private function showInformationPannel() {
			informationPannel = new InformationPannel();
			informationPannel.y = (isIphone5Layout) ? 0 : -123;
			informationPannel.doneButton.addEventListener(MouseEvent.CLICK, onDoneClick);
			informationPannel.cancelButton.addEventListener(MouseEvent.CLICK, onCancelClick);
			
			if (sharedObject.data.hasOwnProperty("strEmail")) {
				informationPannel.emailText.text = sharedObject.data["strEmail"];
			}
			if (sharedObject.data.hasOwnProperty("strAddress")) {
				informationPannel.addressText.text = sharedObject.data["strAddress"];
			}
			if (isShowBonusDraw) {
				informationPannel.titleText.text = "集滿加碼再抽一次！";
			}
			
			if (isLastSticker) {
				if (isShowBonusDraw) {
					isLastSticker = false;
					isShowBonusDraw = false;
				} else {
					isShowBonusDraw = true;
				}
			}
			
			this.addChild(informationPannel);
		}
		
		private function onDoneClick(e:MouseEvent) {
			if (informationPannel.emailText.text == "" || informationPannel.addressText.text == "") {
				ToastMessage.showToastMessage(this, "填妥資料即可參加抽獎！");
			} else {
				sharedObject.data["strEmail"] = informationPannel.emailText.text;
				sharedObject.data["strAddress"] = informationPannel.addressText.text;
				sharedObject.flush();
				
				var variables:URLVariables = new URLVariables();
				variables.email = informationPannel.emailText.text;
				variables.address = informationPannel.addressText.text;
				
				eventChannel.addEventListener(HttpRequestEvent.SEND_SUCCESS, sendInformationSuccess);
				eventChannel.addEventListener(HttpRequestEvent.UNKNOW_ERROR, handleUnknowError);
				eventChannel.addEventListener(HttpRequestEvent.SEND_FAIL, sendInformationFail);
				
//				trace(strPostUrl);
				HttpRequest.postUrl(strPostUrl, variables);
				uploadingInfo = new UploadingInfo();
				this.addChild(uploadingInfo);
			}
		}
		
		private function onCancelClick(e:MouseEvent) {
			removeInformationPannel();
			if (isShowBonusDraw) showInformationPannel();
		}
		
		private function removeUploadingInfo() {
			if (uploadingInfo) this.removeChild(uploadingInfo);
			uploadingInfo = null;
		}
		
		private function removeInformationPannel() {
			removeHttpListener();
			if (informationPannel) {
				informationPannel.cancelButton.removeEventListener(MouseEvent.CLICK, onCancelClick);
				informationPannel.doneButton.removeEventListener(MouseEvent.CLICK, onDoneClick);
				this.removeChild(informationPannel);
			}
			informationPannel = null;
		}
		
		private function removeHttpListener() {
			eventChannel.removeEventListener(HttpRequestEvent.SEND_SUCCESS, sendInformationSuccess);
			eventChannel.removeEventListener(HttpRequestEvent.UNKNOW_ERROR, handleUnknowError);
			eventChannel.removeEventListener(HttpRequestEvent.SEND_FAIL, sendInformationFail);
		}
		
		private function sendInformationSuccess(e:HttpRequestEvent) {
			removeHttpListener();
			removeUploadingInfo();
			eventChannel.addEventListener(ToastMessage.CLOSE_MESSAGE, onMessageClose);
			ToastMessage.showToastMessage(this, "已成功參加抽獎！");
		}
		
		private function onMessageClose(e:Event) {
			eventChannel.removeEventListener(ToastMessage.CLOSE_MESSAGE, onMessageClose);
			removeInformationPannel();
			
			if (isShowBonusDraw) showInformationPannel();
		}
		
		private function handleUnknowError(e:HttpRequestEvent = null) {
			removeHttpListener();
			removeUploadingInfo();
			ToastMessage.showToastMessage(this, "無法傳送資料，請檢查網路是否開啟");
		}
		
		private function sendInformationFail(e:HttpRequestEvent = null) {
			removeHttpListener();
			removeUploadingInfo();
			ToastMessage.showToastMessage(this, "資料傳送失敗，請再重試一次");
		}
		
		private function showAllStickerGetDialog() {
			fxSoundChannel = taDaSound.play(0);
//			isLastSticker = false;
			finalStickerDialog = new FinalStickerDialog();
			finalStickerDialog.y = (isIphone5Layout) ? 0 : -88;
			finalStickerDialog.addEventListener(MouseEvent.CLICK, onFinalStickerDialogClick);
			this.addChild(finalStickerDialog);
		}
		
		private function removeFinalStickerDialog() {
			if (finalStickerDialog) {
				finalStickerDialog.removeEventListener(MouseEvent.CLICK, onFinalStickerDialogClick);
				this.removeChild(finalStickerDialog);
			}
			finalStickerDialog = null;
		}
		
		private function onFinalStickerDialogClick(e:MouseEvent) {
			removeFinalStickerDialog();
//			showInformationPannel();
		}
		
	}
	
}
