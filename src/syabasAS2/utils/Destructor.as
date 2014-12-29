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
class syabasAS2.utils.Destructor {
	
	public static function kill(object, needToTrace:Boolean) {
		if (needToTrace == true) trace("-----------------------------------------------------------------------------------------------------");
		for (var i in object) {
			if (object[i] instanceof MovieClip) {
				Destructor.cleanMC(object[i], false);
			}
			else if (object[i] instanceof Array) {
				var length:Number = object[i].length;
				for (var j:Number = 0; j < length; j++ ) {
					object[i].pop();
				}
			}
			else if (object[i] instanceof TextField) {
				object[i].removeTextField();
			}
			else if (i == "firstChild") {
				var length:Number = object[i].childNodes.length;
				for (var j:Number = 0; j < length; j++) 
				{
					object[i].childNodes.pop();
				}
				object[i].removeNode();
			}
			else if (i == "lastChild") {
				var length:Number = object[i].childNodes.length;
				for (var j:Number = 0; j < length; j++) 
				{
					object[i].childNodes.pop();
				}
				object[i].removeNode();
			}
			delete object[i];
			object[i] = null;
			if (needToTrace == true)	trace("[NTS-DEBUG][Destructor.as | kill():void]: " + i + " | " + object[i]);
		}
		delete object;
		object = null;
	}
	
	public static function cleanMC(target:MovieClip, keepMainMC:Boolean):Void {
		for(var i in target){
			for(var j in target[i]){
				for(var k in target[i][j]){
					target[i][j][k].removeMovieClip();
				}
				target[i][j].removeMovieClip()
			}
			target[i].removeMovieClip();
		}
		if(!keepMainMC){
			target.removeMovieClip();
		}
	}
	
	public static function popArray(object:Array):Void {
		var length:Number = object.length;
		for (var j:Number = 0; j < length; j++ ) {
			object.pop();
		}
		delete object;
		object = null;
	}
}