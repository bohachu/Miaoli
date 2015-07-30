package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import tw.cameo.LayoutManager;
	import tw.cameo.LayoutSettings;
	import tw.cameo.GetVersionNumber;
	
	public class Help extends MovieClip {
		
		private var intDefaultWidth:Number = LayoutSettings.intDefaultWidth;
		private var intDefaultHeight:Number = LayoutSettings.intDefaultHeight;
		private const intDefaultHeightForIphone5:Number = LayoutSettings.intDefaultHeightForIphone5;
		private var isIphone5Layout:Boolean = false;
		private var bg:Sprite = null;
		
		private var commentButton:SimpleButton = null;
		private const intCommentButtonX:int = 39;
		private var intCommentButtonY:int = 45;
		private const intCommentButtonYIphone5:int = 125;
		private const strCommentUrl:String = "http://www3.cyhg.gov.tw/sp.asp?xdURL=bossmail/prosecuteMail.asp&pbid=165&mp=2&ctNode=31162";
		
		private var postButton:SimpleButton = null;
		private const intPostButtonX:int = 39;
		private var intPostButtonY:int = 390;
		private const intPostButtonYIphone5:int = 530;
		private const strPostUrl:String = "mailto:service@cameo.tw?subject=嘉義田園APP回饋";
		
		public function Help(... args) {
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
			intCommentButtonY = intCommentButtonYIphone5;
			intPostButtonY = intPostButtonYIphone5;
		}
		
		private function createBackground() {
			bg = (isIphone5Layout) ? new HelpBackgroundIphone5() : new HelpBackgroundIphone4();
			var versionTextField:TextField = bg.getChildByName("VersionTextField") as TextField;
			versionTextField.text = GetVersionNumber.getAppVersion();
			this.addChild(bg);
		}
		
		private function removeBackground() {
			this.removeChild(bg);
			bg = null;
		}
		
		private function createButton() {
			commentButton = new CommentButton();
			commentButton.x = intCommentButtonX;
			commentButton.y = intCommentButtonY;
			this.addChild(commentButton);
			
			postButton = new PostButton();
			postButton.x = intPostButtonX;
			postButton.y = intPostButtonY;
			this.addChild(postButton);
			
			addButtonEventListener();
		}
		
		private function addButtonEventListener() {
			commentButton.addEventListener(MouseEvent.CLICK, onButtonClick);
			postButton.addEventListener(MouseEvent.CLICK, onButtonClick);
		}
		
		private function removeButton() {
			removeButtonEventListener();
			this.addChild(commentButton);
			this.addChild(postButton);
			commentButton = null;
			postButton = null;
		}
		
		private function removeButtonEventListener() {
			commentButton.removeEventListener(MouseEvent.CLICK, onButtonClick);
			postButton.removeEventListener(MouseEvent.CLICK, onButtonClick);
		}
		
		private function onButtonClick(e:MouseEvent) {
			if (e.target is CommentButton) openUrl(strCommentUrl);
			if (e.target is PostButton)    openUrl(strPostUrl);
		}
		
		private function openUrl(strUrl:String):void {
			var url:URLRequest = new URLRequest(strUrl);
			navigateToURL(url);
		}
	}
	
}
