package  {
	
	import flash.net.SharedObject;
	
	public class GashaponData {
		
		private static var _instance:GashaponData = null;
		
		private var sharedObject:SharedObject = SharedObject.getLocal("TreasureGame");
		
		private var lstUngetGashapon:Array = null;
		private var lstGotGashpon:Array = null;

		public static function getInstance():GashaponData {
			if (_instance == null) _instance = new GashaponData();
			
			return _instance;
		}
		
		public function GashaponData() {
			// constructor code
			CAMEO::NO_ANE {
				sharedObject.clear();
				sharedObject.flush();
			}
			
			if (lstUngetGashapon == null) {
				if (sharedObject.data.hasOwnProperty("lstUngetGashapon")) {
					lstUngetGashapon = sharedObject.data["lstUngetGashapon"];
					lstGotGashpon = sharedObject.data["lstGotGashpon"];
				} else {
					sharedObject.data["lstUngetGashapon"] = lstUngetGashapon = [
						"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"
					];
					sharedObject.data["lstGotGashpon"] = lstGotGashpon = [];
					sharedObject.flush();
				}
			}
		}
		
		public function getLstUngetGashapon():Array {
			return lstUngetGashapon;
		}
		
		public function getLstGotGashapon():Array {
			return lstGotGashpon;
		}
		
		public function saveData(lstUngetGashaponIn:Array, lstGotGashponIn:Array) {
			sharedObject.data["lstUngetGashapon"] = lstUngetGashapon = lstUngetGashaponIn;
			sharedObject.data["lstGotGashpon"] = lstGotGashpon = lstGotGashponIn;
			sharedObject.flush();
		}

	}
	
}
