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
* Class Description: Class managing the playback routine
***************************************************/

import com.syabas.as2.plex.api.FileOperation;
import com.syabas.as2.plex.api.ListNetworkContent;
import com.syabas.as2.plex.component.Popup;
import com.syabas.as2.plex.component.PlaybackOptionPopup;
import com.syabas.as2.plex.component.PlaybackResumePopup;
import com.syabas.as2.plex.model.*;
import com.syabas.as2.plex.playback.EpisodePlayback;
import com.syabas.as2.plex.playback.PhotoPlayback;
import com.syabas.as2.plex.playback.PlaybackConfig;
import com.syabas.as2.plex.playback.PlaylistLoadingTask;
import com.syabas.as2.plex.Share;


import com.syabas.as2.common.PlayerMain;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
class com.syabas.as2.plex.manager.PlaybackManager
{
	public static var playbackConfig:PlaybackConfig = null;
	
	private var playerMC:MovieClip = null;
	private var loadingMC:MovieClip = null;
	private var playbackInfoPanelMC:MovieClip = null;
	
	private var player:PlayerMain = null;					// for fullscreen playback (video)
	private var player2:PlayerMain = null;					// for non fullscreen playback (audio)
	private var pod:PhotoPlayback = null;
	private var episodePlayback:EpisodePlayback = null;
	
	private var playbackModel:MediaModel = null;			// current playback model
	private var playbackMedia:MediaElement = null;			// current playback stream
	private var container:ContainerModel = null;
	
	private var fsPlaylistBuilder:PlaylistLoadingTask = null;
	private var subPlaylistBuilder:PlaylistLoadingTask = null;
	private var episodePlaylistBuilder:PlaylistLoadingTask = null;
	
	public var getCurrentPath:Function = null;
	
	private var playbackEnded:Function = null;				// Callback when playback ended. Assign by BrowseManager.as
	private var setUIVisibilityCB:Function = null;			// function call to change the visibility of the UI Layer
	
	private var config:Object = null;
	private var floatWindowConfig:Object = null;
	private var subPlayerKL:Object = null;
	
	private var id:String = null;
	private var playbackArg:Array = null;
	
	private var updateInterval:Number = null;
	private var isError:Boolean = false;
	
	private var pingInterval:Number = null;
	
	public function PlaybackManager(mc:MovieClip, endCB:Function, visibilityCB:Function)
	{
		playerMC = mc;
		
		this.playbackEnded = endCB;
		this.setUIVisibilityCB = visibilityCB;
		
		this.playbackInfoPanelMC = mc.attachMovie("playbackFloatWindowMC", "mc_playbackInfo", 30);
		this.playbackInfoPanelMC._visible = false;
		
		this.subPlayerKL = new Object();
		Key.addListener(this.subPlayerKL);
		
		playbackConfig = new PlaybackConfig();
	}
	
	public function moveInfoPanel(config:Object):Void
	{
		this.playbackInfoPanelMC._x = config.x;
		this.playbackInfoPanelMC._y = config.y;
		this.playbackInfoPanelMC.mc_bg._visible = !(config.hideBG == true);
		
		if (config != Share.APP_SETTING.playbackConfig.playbackFloatWindowConfig)
		{
			this.floatWindowConfig = config;
		}
	}
	
	public function startVideoPlayback(model:MediaModel, id:String):Void
	{
		this.playbackMedia = null;
		
		this.playbackModel = model;
		this.id = id;
		
		if (model.media.length > 1)
		{
			// multiple stream to choose
			Share.POPUP.showPlaybackOptionPopup(model.media, Delegate.create(this, this.onStreamSelected), Delegate.create(this, this.cancelPopup));
		}
		else if (model.media.length == 1)
		{
			// only one stream
			var media:MediaElement = model.media[0];
			this.startMedia(media, model.itemType, null);
		}
		else
		{
			// no stream, probably is the key
			
			var playbackObj:Object = this.getDefaultPlayerObject();
			var obj:Object = this.getMediaPart(model, model.itemType);
			if (obj != null && obj != undefined)
			{
				playbackObj.mediaObj = [obj];
				
				this.startPlayer(playbackObj);
			}
		}
	}
	
	public function startEpisodePlayback(container:ContainerModel, index:Number, key:String, path:String):Void
	{
		this.id = container.identifier;
		var fsPlayback:Boolean = true;
		
		var playbackObject:Object = this.getDefaultPlayerObject();
		var newObj:Object = this.buildMediaObj(container.items, index);
		playbackObject.mediaObj = newObj.mediaObj;
		playbackObject.disableInfoKey = !fsPlayback;
		playbackObject.disableBackKey = !fsPlayback;
		playbackObject.updateInfo = !fsPlayback;
		playbackObject.disableKeyListener = !fsPlayback;
		playbackObject.fsPlayback = fsPlayback;
		playbackObject.startIndex = newObj.newIndex;
		playbackObject.showOtherMediaTitle = !fsPlayback;
		playbackObject.isEpisodePlayback = true;
		
		var media:MediaModel = container.items[index];
		
		if (media.viewOffset > 0)
		{
			// show resume dialog
			Share.POPUP.showPlaybackResumePopup(media.viewOffset, Delegate.create(this, function(resume:Boolean)
			{
				if (resume)
				{
					if (Util.startsWith(playbackObject.mediaObj[playbackObject.startIndex].url, "smb://") || Util.startsWith(playbackObject.mediaObj[playbackObject.startIndex].url, "nfs://"))
					{
						playbackObject.startFrom = media.viewOffset / 1000;
						if (playbackObject.startFrom > 5)
						{
							playbackObject.startFrom -= 5;
						}
					}
					else
					{
						playbackObject.resumeFrom = media.viewOffset / 1000;
						if (playbackObject.resumeFrom > 5)
						{
							playbackObject.resumeFrom -= 5;
						}
					}
				}
				if (Share.useNativePlayer)
				{
					this.removeSubPlayer();
					playbackObject.container = container;
					playbackObject.key = key;
					playbackObject.path = path;
					
					this.episodePlayback.destroy();
					delete this.episodePlayback;
					
					this.episodePlayback = new EpisodePlayback();
					this.episodePlayback.buildMediaObj = Delegate.create(this, this.buildMediaObj);
					this.episodePlayback.getURL = Delegate.create(this, this.getURL);
					this.episodePlayback.startEpisodePlayback(playbackObject, playbackConfig, Delegate.create(this, this.onEpisodePlaybackComplete));
				}
				else
				{
					this.startPlayer(playbackObject, true);
					if (container.size > container.items.length)
					{
						// have to build playlist
						this.episodePlaylistBuilder.destroy();
						delete this.episodePlaylistBuilder;
						
						this.episodePlaylistBuilder = new PlaylistLoadingTask();
						this.episodePlaylistBuilder.buildFullPlaylist(key, path, Delegate.create(this, this.episodeListBuilded), container.offset);
					}
				}
				
			}), Delegate.create(this, this.cancelPopup));
			return;
		}
		else
		{
			if (Share.useNativePlayer)
			{
				this.removeSubPlayer();
				playbackObject.container = container;
				playbackObject.key = key;
				playbackObject.path = path;
				
				this.episodePlayback.destroy();
				delete this.episodePlayback;
				
				this.episodePlayback = new EpisodePlayback();
				this.episodePlayback.buildMediaObj = Delegate.create(this, this.buildMediaObj);
				this.episodePlayback.getURL = Delegate.create(this, this.getURL);
				this.episodePlayback.startEpisodePlayback(playbackObject, playbackConfig, Delegate.create(this, this.onEpisodePlaybackComplete));
			}
			else
			{
				this.startPlayer(playbackObject, true);
				
				if (container.size > container.items.length)
				{
					// have to build playlist
					this.episodePlaylistBuilder.destroy();
					delete this.episodePlaylistBuilder;
					
					this.episodePlaylistBuilder = new PlaylistLoadingTask();
					this.episodePlaylistBuilder.buildFullPlaylist(key, path, Delegate.create(this, this.episodeListBuilded), container.offset);
				}
			}
		}
	}
	
	/*
	 * Start batch (multiple file) playback
	 * 1. container					- The container which contain the files
	 * 2. index						- The starting index to play
	 * 3. fsPlayback				- True if it is POD, false otherwise
	 * 4. key						- To build up the URL for full playlist retrieval
	 * 5. path						- To build up the URL for full playlist retrieval
	 */
	public function startBatchPlayback(container:ContainerModel, index:Number, fsPlayback:Boolean, key:String, path:String):Void
	{
		if (fsPlayback == null || fsPlayback == undefined)
		{
			fsPlayback = true;
		}
		if (fsPlayback == false)
		{
			this.container = container;
		}
		
		this.id = container.identifier;
		
		var playbackObject:Object = this.getDefaultPlayerObject();
		var newObj:Object = this.buildMediaObj(container.items, index);
		playbackObject.mediaObj = newObj.mediaObj;
		playbackObject.disableInfoKey = !fsPlayback;
		playbackObject.disableBackKey = !fsPlayback;
		playbackObject.updateInfo = !fsPlayback;
		playbackObject.disableKeyListener = !fsPlayback;
		playbackObject.startPlayCB = null;
		playbackObject.fsPlayback = fsPlayback;
		
		playbackObject.startIndex = newObj.newIndex;
		playbackObject.showOtherMediaTitle = !fsPlayback;
		
		if (!fsPlayback)
		{
			playbackObject.playbackEventCB = Delegate.create(this, this.playbackEventCB2);
		}
		
		this.startPlayer(playbackObject, fsPlayback);
		
		if (!fsPlayback)
		{
			this.playbackInfoPanelMC._visible = true;
			this.updateSongInfo(container.items[index]);
		}
		
		if (container.size > container.items.length)
		{
			// have to build playlist
			if (fsPlayback)
			{
				this.fsPlaylistBuilder.destroy();
				delete this.fsPlaylistBuilder;
				
				this.fsPlaylistBuilder = new PlaylistLoadingTask();
				this.fsPlaylistBuilder.buildFullPlaylist(key, path, Delegate.create(this, this.playlistBuilded), container.offset);
			}
			else
			{
				this.subPlaylistBuilder.destroy();
				delete this.subPlaylistBuilder;
				
				this.subPlaylistBuilder = new PlaylistLoadingTask();
				this.subPlaylistBuilder.buildFullPlaylist(key, path, Delegate.create(this, this.playlistBuilded2), container.offset);
			}
		}
	}
	
	public function stopAllPlayback():Void
	{
		this.player.stop();
		this.player2.stop();
		this.removeFullscreenPlayer();
		this.removeSubPlayer();
	}
	
	public function setupPlaybackConfig(configXML:XML):Void
	{
		playbackConfig.fromXML(configXML);
		Share.appSO.data.config = playbackConfig.toObject();
		Share.appSO.flush();
	}
	
	public function reuseOldConfig():Void
	{
		if (Share.appSO.data.config != null && Share.appSO.data.config != undefined)
		{
			playbackConfig.fromObject(Share.appSO.data.config);
		}
	}
	
	// Inspect media elements to determine playback
	private function startMedia(media:MediaElement, playbackType:Number, resume:Boolean):Void
	{
		this.playbackMedia = media;
		if (media.indirect)
		{
			// do indirect play link loading
			this.showLoadingMC(true);
			
			var indirectURL:String = media.parts[0].key;
			var postURL:String = media.parts[0].postURL;
			
			if (postURL != null && postURL != undefined)
			{
				indirectURL += "&postURL=" + (escape(media.parts[0].postURL));
				
				if (Util.startsWith(indirectURL, "http://") || Util.startsWith(indirectURL, "https://"))
				{
					var o:Object = { target:"string", indirectURL:indirectURL, playbackType:playbackType };
					Util.loadURL(postURL, Delegate.create(this, postURLOnLoaded), o);
					
					return;
				}
			}
			
			Share.api.load(indirectURL, null, Share.systemGateway, { playbackType:playbackType }, Delegate.create(this, playbackURLOnLoaded));
			
			return;
		}
		
		if (playbackType == MediaModel.TYPE_VIDEO)
		{
			if (this.playbackModel.viewOffset > 0 && (resume == null || resume == undefined))
			{
				// show resume dialog
				Share.POPUP.showPlaybackResumePopup(this.playbackModel.viewOffset, Delegate.create(this, this.onResumeSelected), Delegate.create(this, this.cancelPopup));
				return;
			}
		}
		
		var len:Number = media.parts.length;
		var playbackObj:Object = this.getDefaultPlayerObject();
		playbackObj.mediaObj = [];
		
		var part:MediaPart = null;
		var mObj:Object = null;
		
		for (var i:Number = 0; i < len; i ++)
		{
			part = media.parts[i];
			mObj = this.getMediaPart(part, playbackType);
			
			if (mObj == null || mObj == undefined)
			{
				return;
			}
			
			playbackObj.mediaObj.push(mObj);
		}
		
		if (resume == true)
		{
			playbackObj.resumeFrom = Math.round(this.playbackModel.viewOffset / 1000);
			if (playbackObj.resumeFrom > 5)
			{
				playbackObj.resumeFrom -= 5;
			}
		}
		
		// Check whether is BDMV or DVD
		var url:String = playbackObj.mediaObj[0].url;
		var newURL:String = null;
		if (Util.startsWith(url, "smb://") || Util.startsWith(url, "nfs://"))
		{
			// only affect samba playback
			playbackObj.startFrom = playbackObj.resumeFrom;
			playbackObj.resumeFrom = null;
			
			if (url.indexOf("PRIVATE/AVCHD/") > -1)
			{
				// avchd
				newURL = url.substring(0, url.indexOf("PRIVATE/AVCHD/"));
			}
			else if (url.indexOf("BDMV/STREAM/") > -1)
			{
				// bdmv
				newURL = url.substring(0, url.indexOf("BDMV/STREAM/"));
			}
			else if (url.indexOf("BDAV/STREAM/") > -1)
			{
				//bdav
				newURL = url.substring(0, url.indexOf("BDAV/STREAM/"));
			}
			else if (url.indexOf("VIDEO_TS/"))
			{
				// DVD Folder?
				newURL = url.substring(0, url.indexOf("VIDEO_TS/"));
			}
		}
		
		if (playbackObj.resumeFrom > 0 && playbackObj.mediaObj.length > 1)
		{
			// the resume time and starting index need adjustment 
			var partLen:Number = playbackObj.mediaObj.length;
			var tempPart:MediaPart = null;
			var totalDuration:Number = 0;
			for (var i:Number = 0; i < partLen; i ++)
			{
				tempPart = playbackObj.mediaObj[i].part;
				if (tempPart.duration > 0)
				{
					totalDuration += (tempPart.duration / 1000);
				}
				
				if (totalDuration > playbackObj.resumeFrom)
				{
					// this is the right part
					playbackObj.resumeFrom = Math.round(totalDuration - playbackObj.resumeFrom);
					playbackObj.startIndex = i;
					break;
				}
			}
		}
		
		if (!Util.isBlank(newURL))
		{
			var tempMediaObj:Object = playbackObj.mediaObj[0];
			tempMediaObj.url = newURL;
			playbackObj.mediaObj = [ tempMediaObj ];
			
			playbackObj.startFrom = null;
		}
		
		if (this.player == null)
		{
			this.startPlayer(playbackObj);
		}
	}
	
	private function startPlayer(config:Object, fsPlayback:Boolean):Void
	{
		if (this.config == null || this.config == undefined)
		{
			this.config = Share.APP_SETTING.playbackInfoConfig;
		}
		
		if (fsPlayback == null || fsPlayback == undefined)
		{
			fsPlayback = true;
		}
		
		if (this.id != null)
		{
			config.identifier = this.id;
			this.id = null;
		}
		
		var player:Object = null;
		var _playerMC:MovieClip = null;
		if (fsPlayback)
		{
			this.removeFullscreenPlayer();
			
			if (config.mediaObj[0].playMode == 3 || config.mediaObj[0].playMode == 1)
			{
				// vod, kill all first
				if (this.player2 != null)
				{
					this.player2.stop();
					
					// wait until player2 is killed
					this.playbackArg = arguments;
					return;
				}
				
				if (Share.useNativePlayer == true)
				{
					config.isNativeInfo = true;
					config.disableInfoKey = true;
				}
				
				player = new PlayerMain();
				this.player = PlayerMain(player);
			}
			else
			{
				if (this.player2 != null)
				{
					// AOD is running, disable all keys for AOD
					this.subPlayerKL.onKeyDown = null;
				}
				
				this.moveInfoPanel(Share.APP_SETTING.playbackConfig.playbackFloatWindowConfig);
				
				player = new PhotoPlayback();
				this.pod = PhotoPlayback(player);
			}
			
			_playerMC = this.playerMC.createEmptyMovieClip("mc_player", 10);
		}
		else 
		{
			// aod
			if (this.player2 != null)
			{
				// previous aod is running, kill first
				this.player2.stop();
				this.playbackArg = arguments;
				return;
			}
			
			this.removeSubPlayer();
			
			player = new PlayerMain();
			this.player2 = PlayerMain(player);
			
			_playerMC = this.playerMC.createEmptyMovieClip("mc_player2", 20);
			this.subPlayerKL.onKeyDown = Delegate.create(this, this.onKeyDown);
			
			this.playbackInfoPanelMC._visible = true;
		}
		
		player.startPlayback(_playerMC, config);
		if (fsPlayback)
		{
			this.setUIVisibilityCB(false);
		}
		else
		{
			this.setUIVisibilityCB(true);
			_playerMC._visible = false;
		}
	}
	
	//--------------------------------------------- Util ------------------------------------------
	
	// get the media object for video item with media and part elements
	private function getMediaPart(media:ModelBase, playbackType:Number):Object
	{
		var filepath:String = "";
		var server:String = null;
		
		var playMode:Number = null;
		
		if (playbackType == MediaModel.TYPE_VIDEO)
		{
			playMode = 3;
		}
		else if (playbackType == MediaModel.TYPE_TRACK)
		{
			playMode = 4;
		}
		
		filepath = this.getURL(media, playbackType);
		
		if (filepath == null)
		{
			Share.POPUP.showMessagePopup(Share.getString("error_no_play_link_title"), Share.getString("error_no_play_link"), Delegate.create(this, this.cancelPopup));
			return null;
		}
		
		var indexOfPlaypath:Number = filepath.indexOf(" playpath=");
		
		if (indexOfPlaypath > -1)
		{
			playMode = 1;
			
			var parts:Array = filepath.split(" ");
			var part:String = null;
			var len:Number = parts.length;
			
			for (var i:Number = 0; i < len; i ++)
			{
				part = parts[i];
				if (i == 0)
				{
					server = part;
				}
				else if (Util.startsWith(part, "app="))
				{
					var app:String = part.substring(4);
					server += (Util.endsWith(server, "/") ? "" : "/") + (Util.startsWith(app, "/") ? app.substring(1) : app);
				}
				else if (Util.startsWith(part, "playpath="))
				{
					filepath = part.substring(9);
				}
			}
		}
		
		var mediaObj = { url:filepath, serverUrl:server, title:this.playbackModel.title, model:this.playbackModel, playMode:playMode, part:media };
		
		return mediaObj;
	}
	
	// get the URL for playback
	private function getURL(part:ModelBase, mediaType:Number):String
	{
		var url:String = "";
		var key:String = part.key;
		var file:String = part.file;
		
		var directPlay:Boolean = true;
		var isVideo:Boolean = (mediaType == MediaModel.TYPE_VIDEO);
		var container:String = MediaElement(part).container;
		if (Util.isBlank(container))
		{
			container = this.playbackMedia.container;
		}
		if (Util.isBlank(container))
		{
			directPlay = true;
		}
		else
		{
			/*
			 * TRANSCODER IF:
			 * 1. disable is blank and container not in enable list
			 * 2. container is in disable list
			 * 
			 * Test Case : MP4, MKV, FLV (in both FreeOTT and Popcorn)
			 */
			
			if (Share.PLAYBACK_CONFIG.capability_disabled.indexOf(container.toLowerCase()) > -1)
			{
				// inside disable list
				directPlay = false;
			}
			else if (!Util.isBlank(Share.PLAYBACK_CONFIG.capability_enabled) && !(Share.PLAYBACK_CONFIG.capability_enabled.indexOf(container.toLowerCase()) > -1))
			{
				// not inside enable list
				directPlay = false;
			}
		}
		
		// Do replace policy first
		var temp:String = playbackConfig.replace(file);
		if (!Util.isBlank(temp) && directPlay && Share.useSMB && isVideo)
		{
			url = Util.replaceAll(temp, "\\", "/");
		}
		else if (Util.startsWith(file, "\\\\") && directPlay && Share.useSMB && isVideo)
		{
			// possible samba link
			url = Util.escapeHTML("smb:" + Util.replaceAll(file, "\\", "/"));
		}
		else if (Util.startsWith(file, "smb://") && directPlay && Share.useSMB && isVideo)
		{
			// samba link
			url = file;
			
		}
		else if (Util.startsWith(key, "http://") || Util.startsWith(key, "https://") || Util.startsWith(key, "rtmp://"))
		{
			url = Util.escapeHTML(key);
		}
		else if (Util.startsWith(key, "plex://"))
		{
			var params:Array = key.substring(key.indexOf("?") + 1).split("&");
			var param:String = null;
			var paramsLen:Number = params.length;
			var otherParams:String = "";
			var paramPart:Array = null;
			for (var i:Number = 0; i < paramsLen; i ++)
			{
				param = params[i];
				if (Util.startsWith(param, "url="))
				{
					url = param.substring(4);
					url = unescape(url);
				}
				else
				{
					paramPart = param.split("=");
					paramPart[1] = escape(paramPart[1]);
					otherParams += "&" + paramPart.join("=");
				}
			}
			
			url = Share.getVideoTranscodeURL(this.playbackModel.key, Share.WEBKIT_QUALITY, Share.WEBKIT_BITRATE, Share.WEBKIT_VIDEO_WIDTH, Share.WEBKIT_VIDEO_HEIGHT, true, otherParams);
		}
		else if (!Util.isBlank(key))
		{
			if (key.charAt(0) != "/" || Util.startsWith(key, "http://") || Util.startsWith(key, "https://"))
			{
				var path:String = this.getCurrentPath();
				
				key = path + (Util.endsWith(path, "/") ? "" : "/") + key;
			}
			if (this.id == "com.plexapp.plugins.library" && mediaType == MediaModel.TYPE_VIDEO)
			{
				if (this.playbackMedia != null)
				{
					// Check whether the player is capable of playing the media directly
					if (directPlay)
					{
						url = Share.systemGateway + (Util.endsWith(Share.systemGateway, "/") ? "" : "/") + (key.charAt(0) == "/" ? key.substring(1) : key);
					}
					else
					{
						url = Share.getVideoTranscodeURL(this.playbackModel.key, Share.WEBKIT_QUALITY, Share.WEBKIT_BITRATE, Share.WEBKIT_VIDEO_WIDTH, Share.WEBKIT_VIDEO_HEIGHT, false, null);
						
					}
				}
				else
				{
					// library items not giving media and parts ? try to use key as link
					url = Share.systemGateway + (Util.endsWith(Share.systemGateway, "/") ? "" : "/") + (key.charAt(0) == "/" ? key.substring(1) : key);
				}
			}
			else
			{
				// Non library items, directly use key as link.
				url = Share.systemGateway + (Util.endsWith(Share.systemGateway, "/") ? "" : "/") + (key.charAt(0) == "/" ? key.substring(1) : key);
			}
		}
		else
		{
			url = null;
		}
		
		return url;
	}
	
	// Build the playlist for playback.
	private function buildMediaObj(items:Array, index:Number):Object
	{
		var mediaObj:Array = new Array();
		var itemLen:Number = items.length;
		var item:MediaModel = null;
		var media:MediaElement = null;
		var playMode:Number = null;
		var newIndex:Number = index;
		for (var i:Number = 0; i < itemLen; i ++)
		{
			item = items[i];
			
			if (item.itemType != MediaModel.TYPE_TRACK && item.itemType != MediaModel.TYPE_PHOTO && item.itemType != MediaModel.TYPE_VIDEO)
			{
				if (i < index)
				{
					newIndex --;
				}
				continue;
			}
			
			if (item.itemType == MediaModel.TYPE_TRACK)
			{
				playMode = 4;
			}
			else if (item.itemType == MediaModel.TYPE_PHOTO)
			{
				playMode = 2;
			}
			else if (item.itemType == MediaModel.TYPE_VIDEO)
			{
				playMode = 3;
			}
			
			media = item.media[0];
			if (media == null || media == undefined)
			{
				mediaObj.push( { url:this.getURL(item, item.itemType), title:item.title, model:item, playMode:playMode } );
			}
			else
			{
				mediaObj.push( { url:this.getURL(media.parts[0], item.itemType), title:item.title, model:item, playMode:playMode } );
			}
		}
		
		return { mediaObj:mediaObj, newIndex:newIndex };
	}
	
	// Get the player configuration object
	private function getDefaultPlayerObject():Object
	{
		var playbackObj:Object = new Object();
		
		playbackObj.parentPath = Share.APP_LOCATION_URL;
		playbackObj.completePlaybackCB = Delegate.create(this, this.completePlayback);
		playbackObj.userActionStopPlaybackCB = Delegate.create(this, this.stopPlayback);
		playbackObj.otherMediaCB = Delegate.create(this, this.otherMediaCB);
		playbackObj.playbackEventCB = Delegate.create(this, this.playbackEventCB);
		playbackObj.startPlayCB = Delegate.create(this, this.startPlayCB);
		playbackObj.enableSeek = true;
		playbackObj.startFrom = 0;
		
		return playbackObj;
	}
	
	// kill the full screen player, VOD and POD
	private function removeFullscreenPlayer():Void
	{
		if (this.player != null)
		{
			this.player.destroy();
			delete this.player;
			
			this.playerMC.mc_player.removeMovieClip();
			
			this.fsPlaylistBuilder.destroy();
			delete this.fsPlaylistBuilder;
		}
		
		if (this.pod != null)
		{
			this.pod.destroy();
			delete this.pod;
			
			this.playerMC.mc_player.removeMovieClip();
			
			this.fsPlaylistBuilder.destroy();
			delete this.fsPlaylistBuilder;
			
			this.episodePlaylistBuilder.destroy();
			delete this.episodePlaylistBuilder;
		}
	}
	
	// kill the AOD player
	private function removeSubPlayer():Void
	{
		if (this.player2 != null)
		{
			this.player2.destroy();
			delete this.player2;
			
			this.playerMC.mc_player2.removeMovieClip();
			this.subPlaylistBuilder.destroy();
			delete this.subPlaylistBuilder;
		}
	}
	
	// Clear up playback and key listener.
	private function cleanup(o:Object):Void
	{
		if (o.updateInfo == true)
		{
			clearInterval(this.updateInterval);
			this.updateInterval = null;
		
			this.removeSubPlayer();
			this.playbackInfoPanelMC._visible = false;
			
			delete this.container;
			this.container = null;
			
			this.subPlayerKL.onKeyDown = null;
		}
		else
		{
			this.removeFullscreenPlayer();
		}
	}
	
	private function getActualPlaybackTime(o:Object):Number
	{
		if (o.currentMediaIndex == 0)
		{
			return o.currentMediaTime;
		}
		
		if (o.mediaObj.length > 1)
		{
			// need to add up the time
			var len:Number = o.currentMediaIndex;
			var tempPart:MediaPart = null;
			var time:Number = 0;
			for (var i:Number = 0; i < len; i ++)
			{
				tempPart = o.mediaObj[i].part;
				if (tempPart.duration > 0)
				{
					time += (tempPart.duration / 1000);
				};
			}
			
			return time + o.currentMediaTime;
		}
		
		return 0;
	}
	
	//-------------------------------------------------- Update Floating Window -------------------------------------------------
	
	private function updateSongInfo(media:MediaModel):Void
	{
		var albumTitle:String = null;
		var artistName:String = null;
		var thumbnailURL:String = null;
		
		if (media.parentTitle != null)
		{
			albumTitle = media.parentTitle;
		}
		else
		{
			albumTitle = this.container.parentTitle;
		}
		
		if (media.grandParentTitle != null)
		{
			artistName = media.grandParentTitle;
		}
		else
		{
			artistName = this.container.grandParentTitle;
		}
		
		if (media.thumbnail != null)
		{
			thumbnailURL = media.thumbnail;
		}
		else
		{
			thumbnailURL = this.container.thumbnail;
		}
		
		this.playbackInfoPanelMC.txt_songTitle.htmlText = Share.returnStringForDisplay(media.title);
		this.playbackInfoPanelMC.txt_albumTitle.htmlText = Share.returnStringForDisplay(albumTitle);
		this.playbackInfoPanelMC.txt_artist.htmlText = Share.returnStringForDisplay(artistName);
		
		if (this.playbackInfoPanelMC["mc_thumbnailMaskFor_mc_thumbnail"] == null || this.playbackInfoPanelMC["mc_thumbnailMaskFor_mc_thumbnail"] == undefined)
		{
			Share.createMask(this.playbackInfoPanelMC, this.playbackInfoPanelMC.mc_thumbnail, this.config.thumbnailConfig);
		}
		
		if (!Util.isBlank(thumbnailURL))
		{
			Share.loadThumbnail(this.playbackInfoPanelMC.mc_thumbnail._name, this.playbackInfoPanelMC.mc_thumbnail, Share.getResourceURL(thumbnailURL), this.config.thumbnailConfig);
		}
		else
		{
			Share.imageLoader.unload(this.playbackInfoPanelMC.mc_thumbnail._name, this.playbackInfoPanelMC.mc_thumbnail.mc_thumb, null);
			this.playbackInfoPanelMC.mc_thumbnail.mc_thumb.removeMovieClip();
		}
		
		this.playbackInfoPanelMC.txt_time.text = "-- / --";
	}
	
	private function updatePlaybackTime():Void
	{
		var info:Object = this.player2.getCurrentPlaybackInfo();
		if (info.updateInfo == true)
		{
			this.playbackInfoPanelMC.txt_time.text = Share.convertTime(info.currentMediaTime * 1000) + " / " + Share.convertTime(info.totalMediaTime * 1000);
		}
	}
	
	//------------------------------------------- Player Callback -------------------------------------------------
	
	// Playback completed
	private function completePlayback(o:Object):Void
	{
		var media:MediaModel = o.mediaObj[o.currentMediaIndex].model;
		var trulyComplete:Boolean = (o.totalMediaTime > 0) && (o.currentMediaTime + 5 >= o.totalMediaTime) && (o.currentMediaIndex == (o.mediaObj.length - 1));
		if (media.itemType == MediaModel.TYPE_VIDEO)
		{
			if (!this.isError)
			{
				if (o.identifier.indexOf("myplex") > -1 && trulyComplete)
				{
					Share.api.setWatched(Share.MY_PLEX_BASE_URL + "/pms/", media.ratingKey, o.identifier, Delegate.create(this, function()
					{
						if (o.isEpisodePlayback == true)
						{
							this.playbackEnded(2);
						}
						else
						{
							this.playbackEnded(1);
						}
					}));
				}
				else if (o.identifier.indexOf("plugins.library") > -1 && trulyComplete)
				{
					Share.api.setWatched(Share.systemGateway, media.ratingKey, o.identifier, Delegate.create(this, function()
					{
						if (o.isEpisodePlayback == true)
						{
							this.playbackEnded(2);
						}
						else
						{
							this.playbackEnded(1);
						}
					}));
				}
				else 
				{
					if (o.isEpisodePlayback == true)
					{
						this.playbackEnded(2);
					}
					else
					{
						this.playbackEnded(1);
					}
				}
			}
			else
			{
				this.playbackEnded(((o.identifier.indexOf("plugins.library") > -1) || (o.identifier.indexOf("myplex") > -1)) ? 1 : 0);
			}
		}
		else if (o.fsPlayback == false)
		{
			// is music
			if (this.pod == null || this.pod == undefined)
			{
				this.playbackEnded(0);
			}
		}
		else
		{
			this.playbackEnded(0);
		}
		
		this.isError = false;
		
		this.cleanup(o);
		if (this.playbackArg != null)
		{
			this.startPlayer.apply(this, this.playbackArg);
			this.playbackArg = null;
			
			return;
		}
		
		if (this.player2 != null)
		{
			//this.player2.enableKeyListener();
			this.subPlayerKL.onKeyDown = Delegate.create(this, this.onKeyDown);
		}
		
		if (!(this.pod != null && this.pod != undefined))
		{
			this.setUIVisibilityCB(true);
		}
		
		this.moveInfoPanel(this.floatWindowConfig);
	}
	
	// Playback stopped
	private function stopPlayback(o:Object):Void
	{
		var media:MediaModel = o.mediaObj[o.currentMediaIndex].model;
		
		this.cleanup(o);
		
		if (this.playbackArg != null)
		{
			this.startPlayer.apply(this, this.playbackArg);
			this.playbackArg = null;
			
			return;
		}
		
		if (this.player2 != null)
		{
			this.subPlayerKL.onKeyDown = Delegate.create(this, this.onKeyDown);
		}
		
		this.moveInfoPanel(this.floatWindowConfig);
		if (o.fsPlayback == false)
		{
			if (this.pod == null || this.pod == undefined)
			{
				this.playbackEnded(0);
			}
		}
		else
		{
			if (o.isEpisodePlayback == true)
			{
				this.playbackEnded(2);
			}
			else
			{
				this.playbackEnded(((o.identifier.indexOf("plugins.library") > -1) || (o.identifier.indexOf("myplex") > -1)) ? 1 : 0);
			}
		}
		
		if (!(this.pod != null && this.pod != undefined))
		{
			this.setUIVisibilityCB(true);
		}
	}
	
	// Playback event handling for VOD
	private function playbackEventCB(o:Object):Void
	{
		var event:String = o.event;
		var info:Object = this.player.getCurrentPlaybackInfo();
		
		if (event == "playback start")
		{
			if (info.currentMediaUrl.indexOf("video/:/transcode") > -1)
			{
				//start ping interval
				clearInterval(this.pingInterval);
				this.pingInterval = setInterval(Delegate.create(this, this.pingTranscoder), 10000);
			}
		}
		
		this.handleEvent(event, info);
	}
	
	// Playback event handling for AOD
	private function playbackEventCB2(o:Object):Void
	{
		var event:String = o.event;
		var info:Object = this.player2.getCurrentPlaybackInfo();
		if (event == "playback start" || event == "playback on resume")
		{
			// start interval
			if (info.updateInfo == true)
			{
				clearInterval(this.updateInterval);
				this.updateInterval = setInterval(Delegate.create(this, this.updatePlaybackTime), 1000);
			}
		}
		else
		{
			this.handleEvent(event, info);
		}
	}
	
	// Common playback event handling for VOD and AOD (POD does not have any event)
	private function handleEvent(event:String, info:Object):Void
	{
		var media:MediaModel = info.mediaObj[info.currentMediaIndex].model;
		
		if (event == "playback on timelines update")
		{
			if (info.currentMediaTime % 3 == 0)
			{
				if (info.identifier.indexOf("myplex") > -1)
				{
					Share.api.reportPlaybackProgress(Share.MY_PLEX_BASE_URL + "/pms/", media.ratingKey, info.identifier, this.getActualPlaybackTime(info), "playing");
				}
				else
				{
					Share.api.reportPlaybackProgress(Share.systemGateway, media.ratingKey, info.identifier, this.getActualPlaybackTime(info), "playing");
				}
			}
		}
		else if (event == "playback on pause")
		{
			if (info.updateInfo == true)
			{
				clearInterval(this.updateInterval);
			}
			
			if (info.identifier.indexOf("myplex") > -1)
			{
				Share.api.reportPlaybackProgress(Share.MY_PLEX_BASE_URL + "/pms/", media.ratingKey, info.identifier, this.getActualPlaybackTime(info), "paused");
			}
			else
			{
				Share.api.reportPlaybackProgress(Share.systemGateway, media.ratingKey, info.identifier, this.getActualPlaybackTime(info), "paused");
			}
		}
		else if (event == "playback on stop")
		{
			if (info.identifier.indexOf("myplex") > -1)
			{
				Share.api.reportPlaybackProgress(Share.MY_PLEX_BASE_URL + "/pms/", media.ratingKey, info.identifier, this.getActualPlaybackTime(info), "stopped");
			}
			else
			{
				Share.api.reportPlaybackProgress(Share.systemGateway, media.ratingKey, info.identifier, this.getActualPlaybackTime(info), "stopped");
			}
			
			clearInterval(this.pingInterval);
			Share.api.stopTranscoder();
		}
		else if (event == "playback error")
		{
			this.isError = true;
		}
	}
	
	// Event when AOD chages playback item
	private function otherMediaCB(o:Object):Void
	{
		if (o.updateInfo == true)
		{
			clearInterval(this.updateInterval);
			this.updateInterval = null;
		
			var media:MediaModel = o.mediaObj[o.currentMediaIndex].model;
			this.updateSongInfo(media);
		}
		
		if (o.isEpisodePlayback == true)
		{
			
			var media:MediaModel = o.mediaObj[o.previousMediaIndex].model;
			var trulyComplete:Boolean = ((o.previousTotalMediaTime > 0) && (o.previousMediaTime + 5 >= o.previousTotalMediaTime));
			
			if (media.itemType == MediaModel.TYPE_VIDEO)
			{
				if (!this.isError)
				{
					if (o.identifier.indexOf("myplex") > -1 && trulyComplete)
					{
						Share.api.setWatched(Share.MY_PLEX_BASE_URL + "/pms/", media.ratingKey, o.identifier, null);
					}
					else if (o.identifier.indexOf("plugins.library") > -1 && trulyComplete)
					{
						Share.api.setWatched(Share.systemGateway, media.ratingKey, o.identifier, null);
					}
					else 
					{
						
					}
				}
				else
				{
					
				}
			}
		}
	}
	
	private function startPlayCB(o:Object):Void
	{
		var obj:Object = o.mediaObj[o.currentMediaIndex];
		var url:String = obj.oriURL;
		
		if (Util.isBlank(url))
		{
			url = obj.url;
		}
		
		if (Util.startsWith(url, "smb://") || Util.startsWith(url, "nfs://"))
		{
			// maybe is protected server
			var login:Object = playbackConfig.checkLogin(url);
			
			if (login != null && login != undefined)
			{
				// need to login
				var path:String = login.path;
				var indexOfSlash:Number = path.indexOf("/", 6);
				var serverPath:String = path.substring(0, indexOfSlash);
				var mountPath:String = path.substring(indexOfSlash + 1);
				
				var api:ListNetworkContent = new ListNetworkContent();
				api.getXML(Delegate.create(this, this.onMount), serverPath, mountPath, login.username, login.password, { url:url, index:o.currentMediaIndex, isMounted:true } );
				
				return;
			}
		}
		
		this.onMount(true, "0", { url:url, index:o.currentMediaIndex } );
	}
	
	private function onMount(success:Boolean, returnValue:String, param:Object):Void
	{
		if (Util.startsWith(param.url, "http://") || Util.startsWith(param.url, "https://"))
		{
			// direct play
			this.player.play(param.index);
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
			
			var info:Object = this.player.getCurrentPlaybackInfo();
			var mediaObj:Object = info.mediaObj[param.index];
			mediaObj.oriURL = param.url;
			mediaObj.url = newURL;
			
			this.player.updateMediaObj(param.index, mediaObj);
			this.player.play(param.index);
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
			var info:Object = this.player.getCurrentPlaybackInfo();
			var mediaObj:Object = info.mediaObj[param.index];
			mediaObj.oriURL = param.url;
			mediaObj.url = name;
			
			this.player.updateMediaObj(param.index, mediaObj);
		}
		
		this.player.play(param.index);
	}
	
	private function pingTranscoder():Void
	{
		Share.api.pingTranscoder();
	}
	
	private function onEpisodePlaybackComplete(refershMode:Number):Void
	{
		this.episodePlayback.destroy();
		this.playbackEnded(refershMode);
		this.setUIVisibilityCB(true);
	}
	
	//---------------------------------------------------- Popup Selection Callbacks ----------------------------------------------
	
	private function onStreamSelected(stream:MediaElement):Void
	{
		this.startMedia(stream, this.playbackModel.itemType);
	}
	
	private function onResumeSelected(resume:Boolean):Void
	{
		this.startMedia(this.playbackMedia, this.playbackModel.itemType, resume);
	}
	
	private function cancelPopup():Void
	{
		this.playbackMedia = null;
		this.playbackModel = null;
		this.playbackEnded();
	}
	
	//-------------------------------------------------- Indirect Link Playback Callbacks ----------------------------------------
	
	private function postURLOnLoaded(success:Boolean, data:String, o:Object):Void
	{
		if (success)
		{
			var html:XML = new XML();
			html.toString = Delegate.create(data, function()
			{
				return this.toString();
			});
			
			Share.api.load(o.o.indirectURL, null, Share.systemGateway, { request:html, playbackType:o.o.playbackType }, Delegate.create(this, playbackURLOnLoaded));
		}
		else
		{
			// show error
			this.showLoadingMC(false);
			if (o.httpStatus < 100 || o.httpStatus == null || o.httpStatus == undefined)
			{
				Share.POPUP.showMessagePopup(Share.getString("error_no_connection_title"), Share.getString("error_no_connection"), Delegate.create(this, this.cancelPopup));
			}
			else
			{
				Share.POPUP.showMessagePopup(Share.getString("error_unknown_title"), Share.getString("error_unknown"), Delegate.create(this, this.cancelPopup));
			}
			
		}
	}
	
	private function playbackURLOnLoaded(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		this.showLoadingMC(false);
		if (success)
		{
			this.startMedia(data.items[0].media[0], userparams.playbackType, null);
		}
		else
		{
			// show error
			if (httpStatus < 100 || httpStatus == null || httpStatus == undefined)
			{
				Share.POPUP.showMessagePopup(Share.getString("error_no_connection_title"), Share.getString("error_no_connection"), Delegate.create(this, this.cancelPopup));
			}
			else
			{
				Share.POPUP.showMessagePopup(Share.getString("error_unknown_title"), Share.getString("error_unknown"), Delegate.create(this, this.cancelPopup));
			}
		}
	}
	
	//----------------------------------------------------- Playlist Building Callbacks -----------------------------------------------
	
	// Callback when POD playlist is built
	private function playlistBuilded(playlist:Array, previousOffset:Number):Void
	{
		var info:Object = this.pod.getCurrentPlaybackInfo();
		var newObj:Object = this.buildMediaObj(playlist, previousOffset);
		var newPlaylist:Array = newObj.mediaObj;
		var newIndex:Number = info.currentMediaIndex + newObj.newIndex;
		
		this.pod.updatePlaylist(newPlaylist, newIndex);
	}
	
	// Callback when AOD playlist is built
	private function playlistBuilded2(playlist:Array, previousOffset:Number):Void
	{
		var info:Object = this.player2.getCurrentPlaybackInfo();
		
		var newObj:Object = this.buildMediaObj(playlist, previousOffset);
		var newPlaylist:Array = newObj.mediaObj;
		var newIndex:Number = info.currentMediaIndex + newObj.newIndex;
		
		this.player2.updatePlaylist(newPlaylist, newIndex);
	}
	
	private function episodeListBuilded(playlist:Array, previousOffset:Number):Void
	{
		var info:Object = this.player.getCurrentPlaybackInfo();
		
		var newObj:Object = this.buildMediaObj(playlist, previousOffset);
		var newPlaylist:Array = newObj.mediaObj;
		var newIndex:Number = info.currentMediaIndex + newObj.newIndex;
		
		this.player.updatePlaylist(newPlaylist, newIndex);
	}
	
	//------------------------------------------------- Server Mounting -------------------------------------------------------------
	
	//------------------------------------------ Key Listener ----------------------------------------------
	
	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();
		
		switch (keyCode)
		{
			case Key.NEXT:
				this.player2.next();
				break;
			case Key.PREVIOUS:
				this.player2.previous();
				break;
			case Key.STOP:
				this.player2.stop();
				break;
			case Key.PAUSE:
				this.player2.pause();
				break;
			case Key.PLAY:
				this.player2.resume();
				break;
		}
	}
	
	//------------------------------------------------- UI ---------------------------------------------------------------------
	private function showLoadingMC(show:Boolean):Void
	{
		if (show)
		{
			if (this.loadingMC == null)
			{
				this.loadingMC = this.playerMC.attachMovie("loadingMC", "mc_loading", this.playerMC.getNextHighestDepth(), { _x:640, _y:360 } );
			}
		}
		else
		{
			this.loadingMC.removeMovieClip();
			delete this.loadingMC;
			this.loadingMC = null;
		}
	}
}