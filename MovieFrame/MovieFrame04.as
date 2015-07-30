package MovieFrame {
	
	import flash.events.Event;
	import flash.display.Bitmap;
	import tw.cameo.MovieChangePhotoAndObjectPropertyModify;
	
	public class MovieFrame04 extends MovieChangePhotoAndObjectPropertyModify {
		
		private var intPhotoWidth:int = 640;
		private var intPhotoHeight:int = 960;
		private var intPhotoWidthIphone5:int = 640;
		private var intPhotoHeightIphone5:int = 1136;
		private var isUseIphone5Layout:Boolean = false;
		
		public function MovieFrame04(photoBitmapIn:Bitmap = null, isSoundEnableIn:Boolean = true, isPlayOnAddedIn:Boolean = true, isUseIphone5LayoutIn:Boolean = false) {
			// constructor code
			
			super(photoBitmapIn, isSoundEnableIn, isPlayOnAddedIn);
			isUseIphone5Layout = isUseIphone5LayoutIn;
			
			if (isUseIphone5Layout) {
				changeLayoutForIphone5();
			}
			
//			if (photoBitmap == null) {
//				photoBitmap = new Bitmap(new TestBitmapData());
//			}
//			if (photoBitmap) {
//				setBitmap();
//			}

			stageMovie = new MovieFrame04MovieClip();
			strPhotoContainerName = "PhotoContainer";
			initMovie();
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function changeLayoutForIphone5() {
			intPhotoWidth = intPhotoWidthIphone5;
			intPhotoHeight = intPhotoHeightIphone5;
		}
		
		override public function setBitmap():void {
			if (photoBitmap.width/photoBitmap.height > intPhotoWidth/intPhotoHeight) {
				photoBitmap.width *= intPhotoHeight/photoBitmap.height;
				photoBitmap.height = intPhotoHeight;
			} else {
				photoBitmap.height *= intPhotoWidth/photoBitmap.width;
				photoBitmap.width = intPhotoWidth;
			}
			photoBitmap.x = (intPhotoWidth - photoBitmap.width) / 2;
			photoBitmap.y = (intPhotoHeight - photoBitmap.height) / 2;
		}
	}
	
}
