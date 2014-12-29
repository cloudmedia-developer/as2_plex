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
* Version 1.0.9
*
* Developer: Syabas Technology Sdn. Bhd.
*
* Class Description: Season List
*
***************************************************/
import com.syabas.as2.plex.api.API;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.Share;


import mx.utils.Delegate;

class com.syabas.as2.plex.manager.AlphabertSwitchingManager
{
	private static var TIMEOUT_DURATION:Number = 1500;		// the timeout duration for key tapping
	private static var KEYS:Array = 
	[
		[""],
		["#"],
		["a", "b", "c"],
		["d", "e", "f"],
		["g", "h", "i"],
		["j", "k", "l"],
		["m", "n", "o"],
		["p", "q", "r", "s"],
		["t", "u", "v"],
		["w", "x", "y", "z"]
	];
	
	private var indices:Object = null;
	private var currentTapIndex:Number = null;
	private var currentKeyIndex:Number = null;
	
	public function destroy():Void
	{
		delete this.indices;
		delete this.currentKeyIndex;
		delete this.currentTapIndex;
	}
	
	public function AlphabertSwitchingManager()
	{
		
	}
	
	public function tap(ascii:Number):Number
	{
		var key:Number = parseInt(String.fromCharCode(ascii));
		
		if (this.currentKeyIndex == key)
		{
			// previously tapped a key and not yet time out
			this.currentTapIndex = ( this.currentTapIndex + 1 ) % KEYS[key].length;
		}
		else
		{
			// previous tap had timed out, or it is a new key tapped
			this.currentTapIndex = 0;
		}
		
		this.currentKeyIndex = key;
		
		var char:String = KEYS[key][this.currentTapIndex];
		
		var result:Number = new Number(this.indices[char]);
		if (isNaN(result))
		{
			return -1;
		}
		return result;
	}
	
	public function init(key:String, path:String):Void
	{
		var newKey:String = "firstCharacter";
		var api:API = new API();
		api.load(newKey, path, Share.systemGateway, { }, Delegate.create(this, this.onAPI), null);
	}
	
	private function onAPI(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		if (success)
		{
			this.indices = new Object();
			var len:Number = data.items.length;
			var accumulateIndex:Number = 0;
			for (var i:Number = 0; i < len; i ++)
			{
				var media:MediaModel = data.items[i];
				this.indices[media.title.toLowerCase()] = accumulateIndex;
				accumulateIndex += media.size;
			}
		}
	}
}