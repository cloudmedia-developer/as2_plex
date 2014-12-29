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
* Class Description: Task to load and build up the whole playlist
*
***************************************************/
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.Share;

import mx.utils.Delegate;
class com.syabas.as2.plex.playback.PlaylistLoadingTask
{
	private static var ITEM_PER_LOAD:Number = 50;
	private var fullPlaylist:Array = null;
	private var completionCB:Function = null;
	private var key:String = null;
	private var path:String = null;
	
	private var interval:Number = null;
	private var nextLoad:Number = null;
	private var previousOffset:Number = null;
	
	public function destroy():Void
	{
		Share.api.disposeRequest("playlist_for_key_" + this.key);
		
		clearInterval(this.interval);
		this.interval = null;
		
		delete this.fullPlaylist;
		delete this.completionCB;
		delete this.key;
		delete this.path;
		delete this.previousOffset;
	}
	
	public function PlaylistLoadingTask()
	{
		
	}
	
	public function buildFullPlaylist(key:String, path:String, cb:Function, offset:Number):Void
	{
		this.key = key;
		this.path = path;
		this.completionCB = cb;
		this.nextLoad = 0;
		this.previousOffset = offset;
		
		this.fullPlaylist = new Array();
		
		this.loadItems();
	}
	
	private function loadItems():Void
	{
		clearInterval(this.interval);
		this.interval = null;
		
		var key:String = Share.getPaginationKey(this.key, this.nextLoad, ITEM_PER_LOAD);
		
		Share.api.load(key, this.path, Share.systemGateway, { }, Delegate.create(this, this.itemLoaded), "playlist_for_key_" + this.key);
	}
	
	private function itemLoaded(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		if (this.completionCB == null || this.completionCB == undefined)
		{
			//this object have been removed
			return;
		}
		if (success)
		{
			this.fullPlaylist = this.fullPlaylist.concat(data.items);
			
			if (this.nextLoad + ITEM_PER_LOAD < data.size)
			{
				// have next load
				this.nextLoad += ITEM_PER_LOAD;
				this.interval = setInterval(Delegate.create(this, this.loadItems), 5000);
			}
			else
			{
				// no more load
				this.completionCB(this.fullPlaylist, this.previousOffset);
				this.destroy();
			}
		}
		else
		{
			this.interval = setInterval(Delegate.create(this, this.loadItems), 5000);
		}
	}
	
	
}