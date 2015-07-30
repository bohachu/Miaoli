package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.EventChannel;
	import tw.cameo.events.TitleBarEvent;
	
	import GashaponData;
	import Collection1;
	import Collection2;
	import Collection3;
	import Collection4;
	import Collection5;
	import Collection6;
	import Collection7;
	import Collection8;
	import Collection9;
	import Collection10;
	import Collection11;
	import Collection12;
	import Collection13;
	
	import tw.cameo.DragAndSlide;
	
	public class Collection extends MovieClip {

		private var eventChannel:EventChannel = EventChannel.getInstance();
		private var gashaponData:GashaponData = GashaponData.getInstance();
		private var lstUngetGashapon:Array = null;
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var collectionContainer:Sprite = null;
		private var dragAndSlide:DragAndSlide = null;
		
		public function Collection(... args) {
			// constructor code
			this.addEventListener(Event.ADDED_TO_STAGE, init);
			lstUngetGashapon = gashaponData.getLstUngetGashapon();
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
			initCollectionList();
		}
		
		private function destructor(e:Event) {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, destructor);
			removeBg();
		}
		
		private function changeLayoutForIphone5() {
			intDefaultHeight = intDefaultHeightForIphone5;
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
		
		private function initCollectionList() {
			collectionContainer = new Sprite();
			this.addChild(collectionContainer);
			collectionContainer.graphics.beginFill(0, 0);
			collectionContainer.graphics.drawRect(0, 0, 640, 30);
			
			for (var i:int=1; i<14; i++) {
				var strCollectionClassName:String = "Collection" + String(i);
				var collectionIconClass:Class = getDefinitionByName(strCollectionClassName) as Class;
				var collectionIcon:Sprite = new collectionIconClass();
				
				if (lstUngetGashapon.indexOf(String(i)) >= 0) {
					collectionIcon.alpha = 0.3;
				}
				
				collectionIcon.x = 33;
				if (i == 1) {
					collectionIcon.y = collectionContainer.height;
				} else {
					collectionIcon.y = collectionContainer.height + 30;
				}
				collectionContainer.addChild(collectionIcon);
				
				if (i != 13) {
					var seperatorLine:Sprite = new SeperatorLine();
					seperatorLine.x = 22;
					seperatorLine.y = collectionContainer.height + 30;
					collectionContainer.addChild(seperatorLine);
				}
				
				if (i == 13) {
					collectionContainer.graphics.drawRect(0, collectionContainer.height, 640, 30);
				}
			}
			collectionContainer.graphics.endFill();
			dragAndSlide = new DragAndSlide(collectionContainer, intDefaultHeight-70, "Vertical", true);
		}
		
		private function dummyFuncForDynamicCreate() {
			var collection1:Collection1 = null;
			var collection2:Collection2 = null;
			var collection3:Collection3 = null;
			var collection4:Collection4 = null;
			var collection5:Collection5 = null;
			var collection6:Collection6 = null;
			var collection7:Collection7 = null;
			var collection8:Collection8 = null;
			var collection9:Collection9 = null;
			var collection10:Collection10 = null;
			var collection11:Collection11 = null;
			var collection12:Collection12 = null;
			var collection13:Collection13 = null;
		}

	}
	
}
