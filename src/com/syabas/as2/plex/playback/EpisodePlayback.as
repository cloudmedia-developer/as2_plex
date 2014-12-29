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
* Class Description: Class managing the playback routine for episodes
***************************************************/
import com.syabas.as2.plex.api.ListNetworkContent;
import com.syabas.as2.plex.api.FileOperation;
import com.syabas.as2.plex.Share;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.playback.PlaylistLoadingTask;
import com.syabas.as2.plex.playback.PlaybackConfig;

import com.syabas.as2.common.Util;
import mx.utils.Delegate;
import mx.xpath.XPathAPI;
class com.syabas.as2.plex.playback.EpisodePlayback
{
	public var getURL:Function = null;
	public var buildMediaObj:Function = null;
	
	private var episodePlaylistBuilder:PlaylistLoadingTask = null;
	private var callback:Function = null;
	private var playbackObj:Object = null;
	private var playbackConfig:PlaybackConfig = null;
	private var xmlScoket:XMLSocket = null;
	private var indexPathDictionary:Object = null;
	
	private var timeInterval:Number = null;
	private var currentItem:Object = null;
	private var currentTime:Number = null;
	private var currentTotalTime:Number = null;
	
	private var beforePlayback:Boolean = false;
	private var urlIndexMap:Object = null;
	
	public function destroy():Void
	{
		delete this.getURL;
		delete this.buildMediaObj;
		delete this.callback;
		
		delete this.playbackObj;
		delete this.playbackConfig;
		
		this.xmlScoket.close();
		delete this.xmlScoket;
		
		clearInterval(this.timeInterval);
		delete this.timeInterval;
		
		delete this.indexPathDictionary;
		delete this.currentItem;
		delete this.currentTime;
		delete this.currentTotalTime;
		
		delete this.beforePlayback;
		delete this.urlIndexMap;
	}
	
	public function startEpisodePlayback(playbackObj:Object, playbackConfig:PlaybackConfig, callback:Function):Void
	{
		if (playbackObj.startFrom == null || playbackObj.startFrom == undefined)
		{
			playbackObj.startFrom = 0;
		}
		this.playbackObj = playbackObj;
		this.playbackConfig = playbackConfig;
		this.callback = callback;
		this.indexPathDictionary = new Object();
		
		var key:String = playbackObj.key;
		var path:String = playbackObj.path;
		var container:ContainerModel = playbackObj.container;
		
		this.xmlScoket = new XMLSocket();
		this.xmlScoket.onData = Delegate.create(this, this.onXMLData);
		this.xmlScoket.connect("127.0.0.1", 8118);
		
		if (container.size > container.items.length)
		{
			// have to build playlist
			this.episodePlaylistBuilder.destroy();
			delete this.episodePlaylistBuilder;
			
			this.episodePlaylistBuilder = new PlaylistLoadingTask();
			this.episodePlaylistBuilder.buildFullPlaylist(key, path, Delegate.create(this, this.episodeListBuilded), container.offset);
		}
		else
		{
			this.startInsertQueue( { index:playbackObj.startIndex - 1 } );
		}
	}
	
	private function episodeListBuilded(playlist:Array, previousOffset:Number):Void
	{
		var newObj:Object = this.buildMediaObj(playlist, previousOffset);
		var newPlaylist:Array = newObj.mediaObj;
		var newIndex:Number = this.playbackObj.startIndex + newObj.newIndex;
		
		this.playbackObj.mediaObj = newPlaylist;
		this.playbackObj.startIndex = newIndex;
		
		this.startInsertQueue( { index:newIndex - 1 } );
	}
	
	
	//---------------------------------------------------- Insert Queue ------------------------------------------------------
	private function startInsertQueue(params:Object):Void
	{
		if (params.index >= this.playbackObj.mediaObj.length - 1)
		{
			_global["setTimeout"](Delegate.create(this, this.getQueue), 100);
			return;
		}
		params.index ++;
		var obj:Object = this.playbackObj.mediaObj[params.index];
		var url:String = obj.oriURL;
		
		if (Util.isBlank(url))
		{
			url = obj.url;
		}
		
		if (Util.startsWith(url, "http://") || Util.startsWith(url, "https://"))
		{
			this.insertVOD(url, params.index, params);
			
			return;
		}
		else
		{
			// maybe is protected server
			var login:Object = this.playbackConfig.checkLogin(url);
			
			if (login != null && login != undefined)
			{
				// need to login
				var path:String = login.path;
				var indexOfSlash:Number = path.indexOf("/", 6);
				var serverPath:String = path.substring(0, indexOfSlash);
				var mountPath:String = path.substring(indexOfSlash + 1);
				
				var api:ListNetworkContent = new ListNetworkContent();
				api.getXML(Delegate.create(this, this.onMount), serverPath, mountPath, login.username, login.password, { url:url, index:params.index, isMounted:true } );
				
				return;
			}
		}
		
		this.onMount(true, "0", { url:url, index:params.index } );
	}
	
	private function onMount(success:Boolean, returnValue:String, param:Object):Void
	{
		if (Util.startsWith(param.url, "http://") || Util.startsWith(param.url, "https://"))
		{
			// direct play
			this.insertVOD(param.url, param.index, param);
		}
		else
		{
			// get the OPT/ path first
			
			if (Util.startsWith(param.url, "nfs://") && param.isMounted != true)
			{
				// NFS protocol, need to mount first
				var serverSlashIndex:Number = param.url.indexOf("/", 6);
				var lastSlashIndex:Number = param.url.lastIndexOf("/");
				var serverPath:String = param.url.substring(0, serverSlashIndex);
				var mountPath:String = param.url.substring(serverSlashIndex, lastSlashIndex);
				
				var lncapi:ListNetworkContent = new ListNetworkContent();
				lncapi.getXML(Delegate.create(this, this.onNFSMount), serverPath, mountPath, "", "", param);
				
				return;
			}
			
			this.getLocalFilePath(param);
		}
	}
	
	private function onNFSMount(success:Boolean, returnValue:String, param:Object):Void
	{
		this.getLocalFilePath(param);
	}
	
	private function getLocalFilePath(param:Object):Void
	{
		var url:String = param.url;
		var lastSlashIndex:Number = url.lastIndexOf("/");
		var filename:String = url.substring(lastSlashIndex);
		var folderPath:String = url.substring(0, lastSlashIndex);
		
		param.filename = filename;
		
		var api:FileOperation = new FileOperation();
		api.getXML(Delegate.create(this, this.onFileOperation), folderPath, param);
	}
	
	private function onFileOperation(success:Boolean, data:Object, param:Object):Void
	{
		var newURL:String = data.path.toString();
		
		if (!Util.isBlank(newURL))
		{
			if (Util.endsWith(newURL, "/"))
			{
				newURL = newURL.substring(0, newURL.length - 1);
			}
			
			newURL += param.filename;
			
			this.insertVOD("file://" + newURL, param.index, param);
		}
		else
		{
			var api:FileOperation = new FileOperation();
			api.getXML(Delegate.create(this, this.onRetryFileOperation), param.url, param);
		}
	}
	
	private function onRetryFileOperation(success:Boolean, data:Object, param:Object):Void
	{
		var name:String = data.name.toString();
		
		if (!Util.isBlank(name))
		{
			this.insertVOD("file://" + name, param.index, param);
		}
		else
		{
			this.insertVOD("file://" + param.url, param.index, param);
		}
	}
	
	private function insertVOD(url:String, index:Number, params:Object):Void
	{
		this.indexPathDictionary[url] = index;
		var loadURL:String = "http://127.0.0.1:8008/playback?arg0=insert_vod_queue&arg1=title&arg2=" + escape(url) + "&arg3=show&arg4=" + (index == this.playbackObj.startIndex ? this.playbackObj.startFrom : 0);
		Util.loadURL(loadURL, Delegate.create(this, this.onInsertVOD), { index:index, params:params } );
	}
	
	private function onInsertVOD(success:Boolean, data:Object, o:Object):Void
	{
		_global["setTimeout"](Delegate.create(this, function()
		{
			this.startInsertQueue(o.o.params);
		}), 50);
	}
	
	//---------------------------------------------- Player Handling ---------------------------------------
	
	private function onXMLData(data:String):Void
	{
		var tempXML:XML = new XML();
		tempXML = new XML();
		tempXML.ignoreWhite = true;
		tempXML.parseXML(data);
		
		var event:String = XPathAPI.selectSingleNode(tempXML.firstChild, "/theDavidBox/event").firstChild.nodeValue.toString();
		switch (event)
		{
			case "playback start":
				clearInterval(this.timeInterval);
				this.timeInterval = setInterval(Delegate.create(this, this.checkTime), 3000);
				break;
			case "playback end":
				Share.api.reportPlaybackProgress(Share.systemGateway, this.currentItem.model.ratingKey, this.playbackObj.container.identifier, this.currentTime, "stopped");
				if (this.currentTime + 5 > this.currentTotalTime)
				{
					// consider ended
					Share.api.setWatched(Share.systemGateway, this.currentItem.model.ratingKey, this.playbackObj.container.identifier, null);
				}
				clearInterval(this.timeInterval);
				this.timeInterval = null;
				break;
			case "playback terminate":
				if (this.currentTime + 5 > this.currentTotalTime)
				{
					// consider ended
					Share.api.setWatched(Share.systemGateway, this.currentItem.model.ratingKey, this.playbackObj.container.identifier, null);
				}
				this.callback(2);
				break;
		}
		
		delete tempXML.idMap;
		delete tempXML;
	}
	
	private function checkTime():Void
	{
		var url:String = "http://127.0.0.1:8008/playback?arg0=get_current_vod_info";
		Util.loadURL(url, Delegate.create(this, this.onCheckTime), { target:"xml" });
	}
	
	private function onCheckTime(success:Boolean, xml:XML, o:Object):Void
	{
		var currentTime:Number = new Number(XPathAPI.selectSingleNode(xml.firstChild, "theDavidBox/response/currentTime").firstChild.nodeValue.toString());
		var totalTime:Number = new Number(XPathAPI.selectSingleNode(xml.firstChild, "theDavidBox/response/totalTime").firstChild.nodeValue.toString());
		var url:String = XPathAPI.selectSingleNode(xml.firstChild, "theDavidBox/response/fullPath").firstChild.nodeValue.toString();
		
		url = url.substring(0, 8) + Util.replaceAll(url.substring(8), "//", "/");
		if (Util.startsWith(url, "/opt"))
		{
			url = "file://" + url;
		}
		
		if (this.urlIndexMap[this.getURLIndexString(url)] != null && this.urlIndexMap[this.getURLIndexString(url)] != undefined)
		{
			this.currentItem = this.playbackObj.mediaObj[this.playbackObj.startIndex - 1 + this.urlIndexMap[getURLIndexString(url)]];
		}
		
		if (currentTime > 0)
		{
			Share.api.reportPlaybackProgress(Share.systemGateway, currentItem.model.ratingKey, this.playbackObj.container.identifier, currentTime, "playing");
			if (this.playbackObj.resumeFrom != null)
			{
				if (this.playbackObj.startIndex == this.indexPathDictionary[url])
				{
					Util.loadURL("http://127.0.0.1:8008/playback?arg0=set_time_seek_vod&arg1=" + this.getTimeString(this.playbackObj.resumeFrom), null, null);
					this.playbackObj.resumeFrom = null;
				}
			}
		}
		
		if (totalTime > 0)
		{
			this.currentTotalTime = totalTime;
		}
		
		if (currentTime > 5)
		{
			this.currentTime = currentTime;
		}
	}
	
	private function getQueue():Void
	{
		var url:String = "http://127.0.0.1:8008/playback?arg0=list_vod_queue_info";
		Util.loadURL(url, Delegate.create(this, this.onGetQueue), { target:"xml" });
	}
	
	private function onGetQueue(success:Boolean, data:XML, o:Object):Void
	{
		this.urlIndexMap = new Object();
		
		var queueItems:Array = XPathAPI.selectNodeList(data.firstChild, "theDavidBox/response/queue");
		var queueLen:Number = queueItems.length;
		var xmlNode:XMLNode = null;
		var url:String = null;
		var index:Number = null;
		
		for (var i:Number = 0; i < queueLen; i ++)
		{
			xmlNode = queueItems[i];
			url = XPathAPI.selectSingleNode(xmlNode, "queue/fullpath").firstChild.nodeValue.toString();
			index = parseInt(XPathAPI.selectSingleNode(xmlNode, "queue/index").firstChild.nodeValue.toString());
			this.urlIndexMap[getURLIndexString(url)] = index;
		}
	}
	
	private function getTimeString(timeInSecond:Number):String
	{
		timeInSecond = new Number(timeInSecond);
		if (isNaN(timeInSecond))
		{
			return "";
		}
		
		var seconds:Number = timeInSecond;
		var minutes:Number = Math.floor(seconds / 60);
		var hours:Number = Math.floor(minutes / 60);
		
		seconds %= 60;
		minutes %= 60;
		
		var result:String = "";
		if (hours > 9)
		{
			result += hours + ":";
		}
		else
		{
			result += "0" + hours + ":";
		}
		
		if (minutes > 9)
		{
			result += minutes + ":";
		}
		else
		{
			result += "0" + minutes + ":";
		}
		
		if (seconds > 9)
		{
			result += seconds + "";
		}
		else
		{
			result += "0" + seconds;
		}
		
		return result;
	}
	
	private function getURLIndexString(url:String):String
	{
		if (Util.startsWith(url, "file://"))
		{
			return "file://" + Util.replaceAll(url.substring(7), "//", "/");
		}
		
		return url;
	}
}