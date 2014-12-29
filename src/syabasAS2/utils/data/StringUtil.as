/***************************************************
* Copyright (c) Syabas Technology Sdn. Bhd.
* All Rights Reserved.
*
* The information contained herein is confidential property of Syabas Technology Sdn. Bhd.
* The use of such information is restricted to Syabas Technology Sdn. Bhd. platform and
* devices only.
*
* THIS SOURCE CODE IS PROVIDED ON AN "AS-IS" BASIS WITHOUT WARRANTY OF ANY KIND AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL Syabas Technology Sdn. Bhd. BE LIABLE FOR ANY DIRECT, INDIRECT,
* INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS UPDATE, EVEN IF Syabas Technology Sdn. Bhd.
* HAS BEEN ADVISED BY USER OF THE POSSIBILITY OF SUCH POTENTIAL LOSS OR DAMAGE.
* USER AGREES TO HOLD Syabas Technology Sdn. Bhd. HARMLESS FROM AND AGAINST ANY AND
* ALL CLAIMS, LOSSES, LIABILITIES AND EXPENSES.
*
* Version 1.0.0
*
* Developer: Syabas Technology Sdn. Bhd.
***************************************************/
/**
 * ...
 * @author Darien Toh
 */
class syabasAS2.utils.data.StringUtil
{
	private var _bytesLevel:Array = ["bytes", "Kb", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
	
	public function StringUtil() 
	{
		
	}
	
	/**
	 * having zero in front of each number, eg 01, 02, 029
	 * @param	num
	 * @param	length
	 * @return
	 */
	public function leadingZero(num:Number, length:Number):String
	{
		var numLen:Number = num.toString().length;
		var totalZero:Number = length - numLen;
		var str:String = "";
		if (totalZero > 0) {
			var i:Number = 0;
			while (i < totalZero) 
			{
				str += "0";
				i++;
			}
			str += num.toString();
		} else {
			str = num.toString();
		}
		
		return str;
	}
	
	/**
	 * convert utc formatted date string: Mon Mar 21 03:00:20 2011
	 * @param	dateString
	 * @return
	 */
	public function getDateStringToDate(dateString:String):Date
	{
		var split:Array = dateString.split(" ");
		if (split.length >= 5) {
			//cleanup
			var i:Number = 0;
			while (i < split.length) 
			{
				if (split[i] == "") {
					split.splice(i, 1);
				}
				i++;
			}
		}
		var splitTime:Array = split[3].split(":");
		
		var newDate:Date = new Date();
		newDate.setFullYear(parseInt(split[4]));
		var month:Number = this.getMonthToInt(split[1])
		newDate.setMonth(month);
		newDate.setDate(parseInt(split[2]));
		newDate.setHours(parseInt(splitTime[0]));
		newDate.setMinutes(parseInt(splitTime[1]));
		newDate.setSeconds(parseInt(splitTime[2]));
		
		return newDate;
	}
	
	/**
	 * convert 3 characters month name to intergre. start with 0
	 * @param	month
	 */
	public function getMonthToInt(month:String):Number
	{
		var monthArr:Array = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
		for (var i:Number = 0; i < monthArr.length; i++ ) {
			if (month.toUpperCase() == monthArr[i]) {
				return i;
			}
		}
		return NaN;
		//return new ArrayUtil().find(monthArr, month.toUpperCase())[0];
	}
	
	/**
	 * convert bytes to string like 20MB, 200kB, 1GB
	 * @param	bytes
	 * @return
	 */
	public function bytesToString(bytes:Number):String
	{
		var index:Number = Math.floor(Math.log(bytes)/Math.log(1024));
		return Math.ceil(bytes / Math.pow(1024, index)) + " " + this._bytesLevel[index];
	}
	
	/**
	 * to fix precision decimal point
	 */
	public function toFixed(num:Number, length:Number):String
	{
		var testStr:String = num.toString();
		if (testStr.indexOf(".") != -1) {
			return testStr.substr(0, testStr.indexOf(".") + length + 1);
		}
		return testStr;
	}
	
	public function trimPath(path:String, tf:TextField):String
	{
		var path		:String		= path;
		var pathArr		:Array 		= path.split("/");
		var endString	:String		;
		var fullString	:String		;
		var lastString	:String		= ".../" + pathArr[pathArr.length - 1] + "...";
		var count		:Number		= 1;
		//----------------------------------------------------------------------------------------------------------
		var lastTf		:TextField 	= tf;
			lastTf.htmlText 		= lastString;
		//----------------------------------------------------------------------------------------------------------
		if (lastTf.textWidth > lastTf._width)
		{
			while (lastTf.textWidth > lastTf._width)
			{
				lastString 	= lastString.substring( 0 , lastString.length - 9) + "...";
				lastTf.htmlText = lastString;
			}
			//----------------------------------------------------------------------------------------------------------
			endString = lastString;
		}
		else 
		{
			var fullTf		:TextField 	= tf;
			var total		:Number		= pathArr.length;
				fullTf.htmlText 		= path;
			//----------------------------------------------------------------------------------------------------------
			for (var i:Number = 0;  i < total; i++ )
			{
				if (i == 0 && pathArr.length == 3)
				{
					//trace("FIRST ENTRY");
					pathArr.splice(1, count, "...");
					fullString = pathArr.join("/");
					fullTf.htmlText = fullString;
					//----------------------------------------------------------------------------------------------------------
					if (fullTf.textWidth * 1.05 > fullTf._width)
					{
						count ++
						pathArr.splice(0, count, "...");
						fullString = pathArr.join("/");
						fullTf.htmlText = fullString;
					}
				}
				else
				{
					if (pathArr.length == 3) 
					{
						pathArr.shift();
						fullString = pathArr.join("/");
						fullTf.htmlText = fullString;
					}
					else
					{
						pathArr.splice(1, count, "...");
						count++;
						count = Math.min(count, 2);
						fullString 	= pathArr.join("/");
						fullTf.htmlText = fullString;
					}
				}
				//----------------------------------------------------------------------------------------------------------
				if (fullTf.textWidth * 1.05 < fullTf._width)
				{
					break;
				}
			}
			endString = fullString;
		}
		return endString;
	}
}