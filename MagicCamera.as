package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Point;
	
	import com.greensock.BlitMask;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.events.MovieEvents;
	import tw.cameo.game.ChosePicturePannelWithCameraRollAS3AndCameraUI;
	import tw.cameo.ObjectControler;
	import tw.cameo.MovieChangePhotoAndObjectPropertyModify;
	import MovieFrame.MovieFrame01;
	import MovieFrame.MovieFrame02;
	import MovieFrame.MovieFrame03;
	import MovieFrame.MovieFrame04;
	import tw.cameo.game.MakeGameMovie;
	import tw.cameo.events.GameMakerEvent;
	
	public class MagicCamera extends MovieClip {
		
		private var eventChannel:EventChannel = EventChannel.getInstance();
		private const lstStrMovieSoundName:Array = new Array("MovieFrame01Sound.mp3", "MovieFrame02Sound.mp3", "MovieFrame03Sound.mp3", "MovieFrame04Sound.mp3");
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var pictureBitmap:Bitmap = null;
		private var pictureSprite:Sprite = null;
		private var intPictureScale:Number = 1;
		
		private var chosePicturePannel:ChosePicturePannelWithCameraRollAS3AndCameraUI = null;
		private var pictureControler:ObjectControler = null;
		private var lstObjectControler:Array = null;
		
		private var intAddedOnMovieClip:int = 0;
		private var intFrameId:int = 1;
		private const intTotalFrameNumber:int = 4;
		private var frame1:MovieFrame01 = null;
		private var frame2:MovieFrame02 = null;
		private var frame3:MovieFrame03 = null;
		private var frame4:MovieFrame04 = null;
		private var frameContainer:Sprite = new Sprite();
		private var frameContainer1:Sprite = new Sprite();
		private var frameContainer2:Sprite = new Sprite();
		private var frameContainer3:Sprite = new Sprite();
		private var frameContainer4:Sprite = new Sprite();
		private var frame1Mask:BlitMask = null;
		private var frame2Mask:BlitMask = null;
		private var frame3Mask:BlitMask = null;
		private var frame4Mask:BlitMask = null;
		
		private var prevButton:SimpleButton = null;
		private var nextButton:SimpleButton = null;
		private var prevButtonPoint:Point = new Point(25, 410);
		private var nextButtonPoint:Point = new Point(580, 410);
		private const intButtonYForIphone5:int = 470;
		
		private var movieControlPannel:MovieClip = null;
		private var intMovieControlPannelY:int = 812;
		private const intMovieControlPannelYIphone5:int = 960;
		private var previewButton:SimpleButton = null;
		private var shareButton:SimpleButton = null;
		private var saveButton:SimpleButton = null;
		
		private var makeGameMovie:MakeGameMovie = null;
		private var endingMovie:MovieClip = null;

		public function MagicCamera(... args) {
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
			
			CAMEO::ANE {
				initChosePicturePannel();
			}
			
			CAMEO::NO_ANE {
				choseMovieFrame();
			}
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeMakeGameMovie();
			removeMovieControlPannel();
			
			for (var i=1; i<5; i++) {
				removeMaskFromFrameContainer(i);
			}
			
			removeControlFromMovieFrame();
			removeMovieFrame();
			removePicture();
			removeChosePicturePannel();
			removeBackground();
			eventChannel = null;
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
			prevButtonPoint.y = nextButtonPoint.y = intButtonYForIphone5;
			intMovieControlPannelY = intMovieControlPannelYIphone5;
		}
		
		private function createBackground() {
			bg = new Sprite();
			bg.graphics.beginFill(0xf7ce42);
			bg.graphics.drawRect(0, 0, 640, 1136);
			bg.graphics.endFill();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			if (bg) this.removeChild(bg);
			bg = null;
		}
		
		private function initChosePicturePannel() {
			chosePicturePannel = new ChosePicturePannelWithCameraRollAS3AndCameraUI("請挑選或拍攝任何人物的照片");
			chosePicturePannel.addEventListener(ChosePicturePannelWithCameraRollAS3AndCameraUI.PICTURE_LOADED, onPictureLoaded);
			this.addChild(chosePicturePannel);
		}
		
		private function removeChosePicturePannel() {
			if (chosePicturePannel) {
				chosePicturePannel.removeEventListener(ChosePicturePannelWithCameraRollAS3AndCameraUI.PICTURE_LOADED, onPictureLoaded);
				this.removeChild(chosePicturePannel);
			}
			chosePicturePannel = null;
		}
		
		private function onPictureLoaded(e:Event) {
			pictureBitmap = chosePicturePannel.getBitmap();
			removeChosePicturePannel();
			
			choseMovieFrame();
		}
		
		private function choseMovieFrame() {
			if (pictureBitmap == null) pictureBitmap = new Bitmap(new TestPhoto());
			
			pictureSprite = new Sprite();
			pictureSprite.addChild(pictureBitmap);
			
			setPictureSizeAndPosition();
			this.addChild(pictureSprite);
			pictureControler = new ObjectControler([pictureSprite], null);
			
			initMagicFrame();
			setButton();
			initMovieControlPannel();
		}
		
		private function removePicture() {
			if (pictureControler) pictureControler.dispose();
			if (pictureSprite) this.removeChild(pictureSprite);
			if (pictureBitmap) pictureSprite.removeChild(pictureBitmap);
			
			pictureControler = null;
			pictureBitmap = null;
			pictureSprite = null;
		}
		
		private function setPictureSizeAndPosition():void {
			if (pictureSprite.width/pictureSprite.height > intDefaultWidth/(intDefaultHeight)) {
				intPictureScale = (intDefaultHeight)/pictureSprite.height;
			} else {
				intPictureScale = intDefaultWidth/pictureSprite.width;
			}
			pictureSprite.scaleX = pictureSprite.scaleY = intPictureScale;
			pictureSprite.x = (intDefaultWidth - pictureSprite.width) / 2;
			pictureSprite.y = ((intDefaultHeight) - pictureSprite.height) / 2;
		}
		
		private function initMagicFrame() {
			this.addChild(frameContainer);
			
			frame1 = new MovieFrame01(null, true, false);
			frame1.clearObjectProperty();
			frame2 = new MovieFrame02(null, true, false);
			frame2.clearObjectProperty();
			frame3 = new MovieFrame03(null, true, false);
			frame3.clearObjectProperty();
			frame4 = new MovieFrame04(null, true, false);
			
			for (var i=1; i<5; i++) {
				var strFrameContainerName:String = "frameContainer" + String(i);
				var strFrameName:String = "frame" + String(i);
				this[strFrameName].addEventListener(MovieEvents.MOVIE_READY, onMovieReady);
				this[strFrameContainerName].x = 640 * (i-1);
				this[strFrameContainerName].addChild(this[strFrameName]);
				frameContainer.addChild(this[strFrameContainerName]);
				if (i > 1) addMaskToFrameContainer(i);
			}
		}
		
		private function removeMovieFrame() {
			if (frameContainer) this.removeChild(frameContainer);
			for (var i=1; i<5; i++) {
				var strFrameContainerName:String = "frameContainer" + String(i);
				var strFrameName:String = "frame" + String(i);
				if (this[strFrameContainerName]) {
					frameContainer.removeChild(this[strFrameContainerName]);
					if (this[strFrameName]) {
						this[strFrameName].removeEventListener(MovieEvents.MOVIE_READY, onMovieReady);
						this[strFrameContainerName].removeChild(this[strFrameName]);
					}
				}
				this[strFrameName] = null;
				this[strFrameContainerName] = null;
			}
			frameContainer = null;
		}
		
		private function onMovieReady(e:MovieEvents) {
			var movieFrame:MovieChangePhotoAndObjectPropertyModify = e.target as MovieChangePhotoAndObjectPropertyModify;
			movieFrame.gotoAndStopAtEnd();
			
			intAddedOnMovieClip++;
			if (intAddedOnMovieClip == 4) addControlToMovieFrame();
		}
		
		private function addControlToMovieFrame() {
			lstObjectControler = new Array();
			lstObjectControler.push(new ObjectControler(frame1.getControlObjectList(), null, frame1.getOutLineObjectList()));
			lstObjectControler.push(new ObjectControler(frame2.getControlObjectList(), null, frame2.getOutLineObjectList()));
			lstObjectControler.push(new ObjectControler(frame3.getControlObjectList(), null, frame3.getOutLineObjectList()));
		}
		
		private function removeControlFromMovieFrame() {
			if (lstObjectControler) {
				for (var i=0; i<3; i++) {
					if (lstObjectControler[i]) (lstObjectControler[i] as ObjectControler).dispose();
					lstObjectControler[i] = null;
				}
				lstObjectControler.length = 0;
			}
			lstObjectControler = null;
		}
		
		private function addMaskToFrameContainer(intId:int) {
			var frameContainerName:String = "frameContainer" + String(intId);
			var frameMaskName:String = "frame" + String(intId) + "Mask";
			if (this[frameMaskName] == null) {
				this[frameMaskName] = new BlitMask(this[frameContainerName], (640*intId - 640*intFrameId - frameContainer.x), 0, 640, 1136, false, true);
				this[frameMaskName].disableBitmapMode();
			}
		}
		
		private function removeMaskFromFrameContainer(intId:int) {
			var frameMaskName:String = "frame" + String(intId) + "Mask";
			if (this[frameMaskName]) {
				(this[frameMaskName] as BlitMask).dispose();
			}
			this[frameMaskName] = null;
		}
		
		private function setButton() {
			if (intFrameId == 1) {
				if (prevButton) {
					this.removeChild(prevButton);
					prevButton.removeEventListener(MouseEvent.CLICK, changeFrameId);
					prevButton = null;
				}
			}
			if (intFrameId > 1) {
				if (prevButton == null) {
					prevButton = new PrevButton();
					prevButton.x = prevButtonPoint.x;
					prevButton.y = prevButtonPoint.y;
					prevButton.addEventListener(MouseEvent.CLICK, changeFrameId);
					this.addChild(prevButton);
				}
			}
			if (intFrameId < intTotalFrameNumber) {
				if (nextButton == null) {
					nextButton = new NextButton();
					nextButton.x = nextButtonPoint.x;
					nextButton.y = nextButtonPoint.y;
					nextButton.addEventListener(MouseEvent.CLICK, changeFrameId);
					this.addChild(nextButton);
				}
			}
			if (intFrameId == intTotalFrameNumber) {
				if (nextButton) {
					nextButton.removeEventListener(MouseEvent.CLICK, changeFrameId);
					this.removeChild(nextButton);
					nextButton = null;
				}
			}
		}
		
		private function changeFrameId(e:MouseEvent) {
			addMaskToFrameContainer(intFrameId);
			if (e.target is PrevButton) intFrameId--;
			if (e.target is NextButton) intFrameId++;
			setButton();
			changeFrame();
		}
		
		private function changeFrame() {
			TweenLite.killTweensOf(frameContainer);
			TweenLite.to(frameContainer, 1, {x:640-intFrameId*640, ease:Strong.easeOut, onComplete:removeNowFrameContainerMask});
		}
		
		private function removeNowFrameContainerMask() {
			removeMaskFromFrameContainer(intFrameId);
		}
		
		private function initMovieControlPannel() {
			movieControlPannel = (isIphone5Layout) ? new MovieControlPannelIphone5() : new MovieControlPannelIphone4();
			movieControlPannel.y = intMovieControlPannelY;
			
			previewButton = movieControlPannel.getChildByName("PlayButton") as SimpleButton;
			previewButton.addEventListener(MouseEvent.CLICK, onPreviewClick);
			shareButton = movieControlPannel.getChildByName("ShareButton") as SimpleButton;
			shareButton.addEventListener(MouseEvent.CLICK, onShareClick);
			
			this.addChild(movieControlPannel);
		}
		
		private function removeMovieControlPannel() {
			if (previewButton) previewButton.removeEventListener(MouseEvent.CLICK, onPreviewClick);
			if (shareButton) shareButton.removeEventListener(MouseEvent.CLICK, onShareClick);
			if (movieControlPannel) this.removeChild(movieControlPannel);
			previewButton = null;
			shareButton = null;
			movieControlPannel = null;
		}
		
		private function onPreviewClick(e:MouseEvent) {
			var strFrameName:String = "frame" + String(intFrameId);
			(this[strFrameName] as MovieChangePhotoAndObjectPropertyModify).playMovie();
			(this[strFrameName] as MovieChangePhotoAndObjectPropertyModify).addEventListener(MovieEvents.MOVIE_PLAY_END, onMoviePlayEnd);
			removeControlFromMovieFrame();
			hideChangeButtonAndControlPannel();
		}
		
		private function hideChangeButtonAndControlPannel() {
			if (!isIphone5Layout) TweenLite.to(movieControlPannel, 1, {y:intDefaultHeight, ease:Strong.easeOut});
			if (prevButton) TweenLite.to(prevButton, 1, {alpha:0});
			if (nextButton) TweenLite.to(nextButton, 1, {alpha:0});
		}
		
		private function showChangeButtonAndControlPannel() {
			if (!isIphone5Layout) TweenLite.to(movieControlPannel, 1, {y:intMovieControlPannelY, ease:Strong.easeOut});
			if (prevButton) TweenLite.to(prevButton, 1, {alpha:1});
			if (nextButton) TweenLite.to(nextButton, 1, {alpha:1});
		}
		
		private function onMoviePlayEnd(e:Event) {
			addControlToMovieFrame();
			showChangeButtonAndControlPannel();
		}
		
		private function onShareClick(e:MouseEvent) {
			goMakeMovie(false);
		}
		
		private function goMakeMovie(isShareClick:Boolean = false) {
			var bitmapToRecord:Bitmap = new Bitmap(pictureBitmap.bitmapData);
			var gameMovieToRecord;
			bitmapToRecord.transform.matrix = pictureSprite.transform.matrix;
			
//			var testSprite:Sprite = new Sprite();
//			testSprite.addChild(bitmapToRecord);
//			this.addChild(testSprite);
//			testSprite.addEventListener(MouseEvent.MOUSE_DOWN, function onMouseDownTest(e:MouseEvent) {
//										testSprite.startDrag();
//										});
			
			var strSelectFrameMovieName:String = "frame" + String(intFrameId);
			(this[strSelectFrameMovieName] as MovieChangePhotoAndObjectPropertyModify).saveObjectProperty();
			
			if (intFrameId == 1) gameMovieToRecord = new MovieFrame01(bitmapToRecord, false);
			if (intFrameId == 2) gameMovieToRecord = new MovieFrame02(bitmapToRecord, false);
			if (intFrameId == 3) gameMovieToRecord = new MovieFrame03(bitmapToRecord, false);
			if (intFrameId == 4) gameMovieToRecord = new MovieFrame04(bitmapToRecord, false);
			makeGameMovie = new MakeGameMovie(gameMovieToRecord, lstStrMovieSoundName[intFrameId-1], null, "", "ChiaYi", "MovieUrl", isShareClick);
			makeGameMovie.addEventListener(GameMakerEvent.EXPORT_MOVIE_FINISH, onExportMovieFinish);
			makeGameMovie.setEndingMovie(new EndingMovie());
			makeGameMovie.y = -70;
			this.addChild(makeGameMovie);
			removeMovieControlPannel();
			
			for (var i=1; i<5; i++) {
				removeMaskFromFrameContainer(i);
			}
			
			removeControlFromMovieFrame();
			removeMovieFrame();
		}
		
		private function removeMakeGameMovie() {
			if (makeGameMovie) {
				makeGameMovie.removeEventListener(GameMakerEvent.EXPORT_MOVIE_FINISH, onExportMovieFinish);
				this.removeChild(makeGameMovie);
			}
			makeGameMovie = null;
		}
		
		private function onExportMovieFinish(e:Event) {
			makeGameMovie.removeEventListener(GameMakerEvent.EXPORT_MOVIE_FINISH, onExportMovieFinish);
			eventChannel.writeEvent(new Event(GameMakerEvent.EXPORT_MOVIE_FINISH));
		}
		
		private function dummyFuntionForReference() {
			var makeGameMovieBackground:MakeGameMovieBackground = null;
		}
	}
	
}
