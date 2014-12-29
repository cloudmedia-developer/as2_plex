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
* Class Description: Class managing layouts displaying and browse history
*
***************************************************/

import com.syabas.as2.plex.component.SelectionPopup;
import com.syabas.as2.plex.component.SettingPopup;
import com.syabas.as2.plex.component.Popup;
import com.syabas.as2.plex.interfaces.ClockUpdateInterface;
import com.syabas.as2.plex.interfaces.LayoutInterface;
import com.syabas.as2.plex.layout.*;
import com.syabas.as2.plex.manager.ConfigLoaderManager;
import com.syabas.as2.plex.manager.KeyboardManager;
import com.syabas.as2.plex.manager.PlaybackManager;
import com.syabas.as2.plex.manager.PopupManager;
import com.syabas.as2.plex.model.*;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Util;

import mx.utils.Delegate;
class com.syabas.as2.plex.manager.BrowseManager
{
	public static var RELAUNCH:Function = null;					// Callback for other component to relaunch the app (without going back to PlexMain.as again)
	private var mainMC:MovieClip = null;						// The library.swf
	private var UIMainMC:MovieClip = null;						// The main layer to render UI
	private var loadingMC:MovieClip = null;						// The loading animation icon
	
	private var layout:LayoutInterface = null;					// Current displaying layout
	private var clockInterface:ClockUpdateInterface = null;		// Current clock update layout
	
	private var mainMenu:ContainerModel = null;					// The list of library sections of current Media Server
	private var history:Array = null;							// The history stack
	private var currentPath:String = null;						// Current path for data loading
	private var currentSelectedItem:MediaModel = null;			// Last selected item
	
	private var fn:Object = null;
	
	private var timeUpdateInterval:Number = null;
	
	public function BrowseManager(mc:MovieClip)
	{
		this.mainMC = mc;
		
		this.UIMainMC = mc.createEmptyMovieClip("mc_uiMain", mc.getNextHighestDepth());
		this.UIMainMC.attachMovie("mainBackgroundMC", "mc_mainBackground", this.UIMainMC.getNextHighestDepth());
		
		var playerMainMC:MovieClip = mc.createEmptyMovieClip("mc_playerMain", mc.getNextHighestDepth());
		var popupMC:MovieClip = mc.createEmptyMovieClip("mc_popupHolder", mc.getNextHighestDepth());
		var keyboardMC:MovieClip = mc.createEmptyMovieClip("mc_keyboard", mc.getNextHighestDepth());
		var configLoadMC:MovieClip = mc.createEmptyMovieClip("mc_configLoaderBase", mc.getNextHighestDepth());
		
		// init the managers
		Share.PLAYER = new PlaybackManager(playerMainMC, Delegate.create(this, this.donePlayback), Delegate.create(this, this.setUIVisibility));
		Share.KEYBOARD = new KeyboardManager(keyboardMC);
		Share.POPUP = new PopupManager(popupMC);
		Share.CONFIG_LOADER = new ConfigLoaderManager(configLoadMC);
		
		this.fn = { updateTime:Delegate.create(this, this.updateTime),
					itemSelectedCB:Delegate.create(this, this.itemSelected),
					returnCB:Delegate.create(this, this.historyBack),
					homeCB:Delegate.create(this, this.backToMenu),
					switchLayoutCB:Delegate.create(this, this.switchLayout) };
					
		init();
		RELAUNCH = Delegate.create(this, this.reinit);
		
		Share.PLAYER.getCurrentPath = Delegate.create(this, this.getCurrentPath);
	}
	
	private function init():Void
	{
		this.history = new Array();
		Share.APP_SETTING = mainMC.config;
		this.currentPath = "/library/sections/";
		
		if (!Util.isBlank(Share.systemGateway))
		{
			// got system gateway, load menu
			this.showLoadingMC(true);
			Share.api.load("sections", "/library", Share.systemGateway, null, Delegate.create(this, onMenuLoaded));
		}
		else
		{
			// show only setting
			this.mainMenu = null;
			this.showMenu();
		}
		
	}
	
	private function reinit():Void
	{
		this.clearLayout();
		
		delete this.mainMenu;
		this.mainMenu = null;
		
		delete this.history;
		this.history = null;
		
		delete this.currentPath;
		this.currentPath = null;
		
		delete this.currentSelectedItem;
		this.currentSelectedItem = null;
		
		
		Share.saveSharedObject();
		this.init();
	}
	
	private function setUIVisibility(visible:Boolean):Void
	{
		this.UIMainMC._visible = visible;
	}
	
	private function onMenuLoaded(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		this.showLoadingMC(false);
		if (success)
		{
			this.mainMenu = data;
			this.showMenu();
		}
		else
		{
			this.mainMenu = null;
			Share.POPUP.showMessagePopup(Share.getString("error_cannot_connect_media_server_title"), Share.getString("error_cannot_connect_media_server"), Delegate.create(this, this.showMenu));
		}
	}
	
	private function showMenu():Void
	{
		this.clearLayout();
		
		this.history = [ { id:"MENU" } ];
		var menuLayout:MainMenuLayout =  new MainMenuLayout(this.UIMainMC);
		menuLayout.setCallback( { itemSelectedCallback:this.fn.itemSelectedCB } );
		menuLayout.renderItems(this.mainMenu);
		
		this.clockInterface = menuLayout;
		this.layout = menuLayout;
		
		this.updateTime();
	}
	
	private function clearLayout():Void
	{
		if (this.layout != null)
		{
			this.layout.destroy();
			delete this.layout;
			this.layout = null;
		}
		if (this.clockInterface != null)
		{
			delete this.clockInterface;
			this.clockInterface = null;
		}
	}
	
	
	//---------------------------------------- Callback ------------------------------------------------
	private function historyBack():Void
	{
		this.currentSelectedItem = null;
		var currentItem:Object = this.history.pop();
		if (this.history.length > 1)
		{
			var historyItem:Object = this.history.pop();
			this.currentPath = historyItem.path;
			this.currentSelectedItem = historyItem.selectedItem;
			
			this.loadData(historyItem.model, null, historyItem, currentItem);
		}
		else
		{
			var historyItem:Object = this.history.pop();
			this.currentPath = "/library/sections/";
			this.showMenu();
			this.layout.restoreHistoryState(historyItem.historyRecord);
		}
	}
	
	private function backToMenu():Void
	{
		this.history.splice(2, this.history.length - 1);
		this.historyBack();
	}
	
	private function switchLayout():Void
	{
		Share.saveSharedObject();
		this.history[this.history.length - 1].historyRecord = this.layout.getHistoryRecordObject();
		
		var duplicate:Object = new Object();
		var original:Object = this.history[this.history.length - 1];
		
		for (var i:String in original)
		{
			duplicate[i] = original[i];
		}
		
		duplicate.historyRecord = { };
		
		for (var i:String in original.historyRecord)
		{
			duplicate.historyRecord[i] = original.historyRecord[i];
		}
		
		duplicate.isSwitchLayout = true;
		
		this.history.push(duplicate);
		
		this.historyBack();
	}
	
	private function itemSelected(item:Object, identifier:String):Boolean			// return true if the action is consumed
	{
		if (item instanceof MediaModel)
		{
			var mediaModel:MediaModel = MediaModel(item);
			this.currentSelectedItem = mediaModel;
			
			if (mediaModel.key == "none")
			{
				// no need to do anything
				return false;
			}
			
			if (mediaModel.itemType == MediaModel.TYPE_DIRECTORY)
			{
				if (mediaModel.isSearch)
				{
					// flag is true to search
					this.startSearch(mediaModel);
				}
				else
				{
					// load data else 
					this.loadData(mediaModel);
				}
				
				return true;
			}
			else if (mediaModel.itemType == MediaModel.TYPE_VIDEO)
			{
				// video item, start playback
				Share.PLAYER.startVideoPlayback(mediaModel, identifier);
				return true;
			}
			else if (mediaModel.itemType == MediaModel.TYPE_TRACK)
			{
				// track (audio) item, start playback
				// This clause if for exception case, AOD will be directed to another function
				
			}
			else if (mediaModel.itemType == MediaModel.TYPE_PHOTO)
			{
				// do nothing,
				// same exception case, POD will be directed to another function
			}
		}
		
		return false;
	}
	
	private function onLoad(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		this.showLoadingMC(false);
		
		if (success)
		{
			if (data.items.length == 0 || data.items == null)
			{
				if (!Util.isBlank(data.header) || !Util.isBlank(data.message))
				{
					// show message popup
					Share.POPUP.showMessagePopup(data.header, data.message, Delegate.create(this, this.closePopup));
				}
				else
				{
					// no data
					Share.POPUP.showMessagePopup(Share.getString("error_no_data_title"), Share.getString("error_no_data"), Delegate.create(this, this.closePopup));
					if (userparams.history != null && userparams.history != undefined && userparams.currentItem != null && userparams.currentItem != undefined)
					{
						if (userparams.currentItem.isSwitchLayout != true)
						{
							this.history.push(userparams.currentItem);
						}
					}
				}
				
				return;
			}
			
			if (this.currentSelectedItem.isPopup == true)
			{
				// The item previously selected has popup flag
				Share.POPUP.showSelectionPopup(data, Delegate.create(this, this.selectionSelected), Delegate.create(this, this.closePopup));
				
				return;
			}
			
			if (this.currentSelectedItem.isSetting == true)
			{
				// The item previously selected has setting flag
				Share.POPUP.showSettingPopup(data, Delegate.create(this, this.settingCompleted), Delegate.create(this, this.closePopup));
				
				return;
			}
			
			if (userparams.history == null || userparams.history == undefined)
			{
				// loaded successful, save previous item history record
				this.history[this.history.length - 1].historyRecord = this.layout.getHistoryRecordObject();
			}
			
			this.history.push( { path:userparams.path, model:userparams.model, selectedItem:this.currentSelectedItem } );
			
			if (userparams.newPath != null)
			{
				this.currentPath = userparams.newPath;
			}
			
			
			this.clearLayout();
			
			// Create Layout depending on the type of returned data
			data.externalTitle = userparams.model.title;
			
			var viewGroup:String = data.viewGroup;
			var contentType:String = data.contentType;
			var content:String = data.content;
			
			var useNormalList:Boolean = false;
			
			if (viewGroup == ContainerModel.VIEW_GROUP_ALBUM)
			{
				if (this.layout.__proto__ != AlbumListLayout.prototype)
				{
					this.clearLayout();
					this.layout = new AlbumListLayout(this.UIMainMC);
				}
			}
			else if (viewGroup == ContainerModel.VIEW_GROUP_ARTIST)
			{
				if (this.layout.__proto__ != ArtistListLayout.prototype)
				{
					this.clearLayout();
					this.layout = new ArtistListLayout(this.UIMainMC);
				}
			}
			else if (viewGroup == ContainerModel.VIEW_GROUP_MOVIE)
			{
				if (this.checkItems(data, MediaModel.TYPE_VIDEO, MediaModel.CONTENT_TYPE_MOVIE))
				{
					var movieDisplayType = Share.movieDisplayToChange;
				
					if (movieDisplayType == null)
					{
						movieDisplayType = Share.movieDisplayType;
					}
					
					Share.movieDisplayType = movieDisplayType;
					Share.movieDisplayToChange = null;
					
					Share.saveSharedObject();
					
					if ((movieDisplayType == Share.MOVIE_DISPLAY_TYPE_WALL || movieDisplayType == Share.MOVIE_DISPLAY_TYPE_WALL_WITH_TITLE) && this.layout.__proto__ != MovieWallLayout.prototype)
					{
						this.clearLayout();
						this.layout = new MovieWallLayout(this.UIMainMC);
					}
					else if (movieDisplayType == Share.MOVIE_DISPLAY_TYPE_INFO && this.layout.__proto__ != MovieInfoLayout.prototype)
					{
						this.clearLayout();
						this.layout = new MovieInfoLayout(this.UIMainMC);
					}
					else if (movieDisplayType == Share.MOVIE_DISPLAY_TYPE_LIST && this.layout.__proto__ != MovieListLayout.prototype)
					{
						this.clearLayout();
						this.layout = new MovieListLayout(this.UIMainMC);
					}
				}
				else
				{
					// use back normal list
					useNormalList = true;
				}
			}
			else if (viewGroup == ContainerModel.VIEW_GROUP_PHOTO)
			{
				if (this.checkItems(data, MediaModel.TYPE_PHOTO, MediaModel.CONTENT_TYPE_PHOTO))
				{
					// create photo
					if (this.layout.__proto__ != PhotoListLayout.prototype)
					{
						this.clearLayout();
						this.layout = new PhotoListLayout(this.UIMainMC);
					}
				}
				else
				{
					// use back normal list
					useNormalList = true;
				}
			}
			else if (viewGroup == ContainerModel.VIEW_GROUP_TRACK)
			{
				if (this.checkItems(data, MediaModel.TYPE_TRACK, MediaModel.CONTENT_TYPE_TRACK))
				{
					// create track
					if (this.layout.__proto__ != TrackListLayout.prototype)
					{
						this.clearLayout();
						this.layout = new TrackListLayout(this.UIMainMC);
					}
				}
				else
				{
					// use back normal list
					useNormalList = true;
				}
			}
			else if (viewGroup == ContainerModel.VIEW_GROUP_TV_EPISODE)
			{
				if (this.checkItems(data, MediaModel.TYPE_VIDEO, MediaModel.CONTENT_TYPE_EPISODE))
				{
					// create episode
					if (this.layout.__proto__ != EpisodeListLayout.prototype)
					{
						this.clearLayout();
						this.layout = new EpisodeListLayout(this.UIMainMC);
					}
				}
				else
				{
					// use back normal list
					useNormalList = true;
				}
			}
			else if (viewGroup == ContainerModel.VIEW_GROUP_TV_SEASON)
			{
				if (this.layout.__proto__ != SeasonListLayout.prototype)
				{
					this.clearLayout();
					this.layout = new SeasonListLayout(this.UIMainMC);
				}
			}
			else if (viewGroup == ContainerModel.VIEW_GROUP_TV_SHOW)
			{
				var tvShowDisplayType = Share.tvShowDisplayToChange;
				
				if (tvShowDisplayType == null)
				{
					tvShowDisplayType = Share.tvShowDisplayType;
				}
				
				Share.tvShowDisplayType = tvShowDisplayType;
				Share.tvShowDisplayToChange = null;
				
				Share.saveSharedObject();
				
				if (tvShowDisplayType == Share.TV_SHOW_DISPLAY_TYPE_INFO && this.layout.__proto__ != ShowInfoLayout.prototype)
				{
					this.clearLayout();
					this.layout = new ShowInfoLayout(this.UIMainMC);
				}
				else if (tvShowDisplayType == Share.TV_SHOW_DISPLAY_TYPE_LIST && this.layout.__proto__ != ShowListLayout.prototype)
				{
					this.clearLayout();
					this.layout = new ShowListLayout(this.UIMainMC);
				}
				else if ((tvShowDisplayType == Share.TV_SHOW_DISPLAY_TYPE_WALL || tvShowDisplayType == Share.TV_SHOW_DISPLAY_TYPE_WALL_WITH_TITLE) && this.layout.__proto__ != ShowWallLayout.prototype)
				{
					this.clearLayout();
					this.layout = new ShowWallLayout(this.UIMainMC);
				}
				else if (tvShowDisplayType == Share.TV_SHOW_DISPLAY_TYPE_BANNER && this.layout.__proto__ != ShowBannerLayout.prototype)
				{
					this.clearLayout();
					this.layout = new ShowBannerLayout(this.UIMainMC);
				}
			}
			else if (content == ContainerModel.CONTENT_PLUGIN)
			{
				if (this.layout.__proto__ != PluginListLayout.prototype)
				{
					this.clearLayout();
					this.layout = new PluginListLayout(this.UIMainMC);
					var mediaType:Number = 0;
					var key:String = userparams.model.key.substring(1);
					if (key == "video")
					{
						mediaType = 0;
					}
					else if (key == "music")
					{
						mediaType = 1;
					}
					else if (key == "photo")
					{
						mediaType = 2;
					}
					
					PluginListLayout(this.layout).setMediaType(mediaType);
				}
			}
			else
			{
				var nodeType:Number = this.getContainerItemType(data);
				if (nodeType == MediaModel.TYPE_VIDEO)
				{
					// use video list
					if (this.layout.__proto__ != VideoListLayout.prototype)
					{
						this.clearLayout();
						this.layout = new VideoListLayout(this.UIMainMC);
					}
				}
				else if (nodeType == MediaModel.TYPE_TRACK)
				{
					// use track
					if (this.layout.__proto__ != TrackListLayout.prototype)
					{
						this.clearLayout();
						this.layout = new TrackListLayout(this.UIMainMC);
					}
				}
				else if (nodeType == MediaModel.TYPE_PHOTO)
				{
					if (this.layout.__proto__ != PhotoListLayout.prototype)
					{
						this.clearLayout();
						this.layout = new PhotoListLayout(this.UIMainMC);
					}
				}
				else
				{
					useNormalList = true;
				}
			}
			
			if (useNormalList == true)
			{
				if (this.layout.__proto__ != ItemListLayout.prototype)
				{
					this.clearLayout();
					this.layout = new ItemListLayout(this.UIMainMC);
				}
			}
			
			// clear all image request from previous layout
			Share.imageLoader.clear();
			
			this.layout.setCallback(
			{
				homeCallback:this.fn.homeCB,
				returnCallback:this.fn.returnCB,
				itemSelectedCallback:this.fn.itemSelectedCB,
				switchLayoutCallback:this.fn.switchLayoutCB
			});
			this.layout.setLoadingParameter(userparams.model.key, userparams.loadingPath);
			this.layout.renderItems(data);
			
			if (userparams.history != null && userparams.history != undefined)
			{
				this.layout.restoreHistoryState(userparams.history.historyRecord);
			}
			
			this.clockInterface = this.layout;
			this.updateTime();
		}
		else
		{
			if (userparams.history != null && userparams.history != undefined && userparams.currentItem != null && userparams.currentItem != undefined)
			{
				this.history.push(userparams.history);
				
				if (userparams.currentItem.isSwitchLayout != true)
				{
					this.history.push(userparams.currentItem);
				}
			}
			if (httpStatus < 100 || httpStatus == null || httpStatus == undefined)
			{
				// no connection
				Share.POPUP.showMessagePopup(Share.getString("error_no_connection_title"), Share.getString("error_no_connection"), Delegate.create(this, this.closePopup));
			}
			else if (httpStatus == 404)
			{
				Share.POPUP.showMessagePopup(Share.getString("error_no_data_title"), Share.getString("error_no_data"), Delegate.create(this, this.closePopup));
			}
			else 
			{
				Share.POPUP.showMessagePopup(Share.getString("error_unknown_title"), Share.getString("error_unknown"), Delegate.create(this, this.closePopup));
			}
		}
	}
	
	private function selectionSelected(media:MediaModel):Void
	{
		this.itemSelected(media);
	}
	
	private function settingCompleted(container:ContainerModel):Void
	{
		var key:String = this.currentSelectedItem.key;
		if (!Util.endsWith(key, "/"))
		{
			key += "/";
		}
		key += "set?";
		
		var len:Number = container.items.length;
		var setting:SettingModel = null;
		
		for (var i:Number = 0; i < len; i ++)
		{
			setting = container.items[i];
			key += setting.id + "=" + setting.value;
			if (i < len - 1)
			{
				key += "&";
			}
		}
		
		var path = (Util.startsWith(key, "/") ? null : this.currentPath);
		Share.api.load(key, path, Share.systemGateway, { }, null, null);
		
		this.closePopup();
	}
	
	private function onLoginCompleted():Void
	{
		this.layout.enable();
	}
	
	/*
	 * Function : callback when the playback is completed
	 * 1.	refresh:Number 				- A Number to tell whether to refresh the data. 0 : No refresh, 1 : Refresh single (current selected) item, 2 : Refresh the whole list.
	 */
	private function donePlayback(refresh:Number):Void
	{
		refresh = new Number(refresh);
		
		if (isNaN(refresh))
		{
			refresh = 0;
		}
		
		if (refresh == 1)
		{
			this.layout.refreshCurrentItem();
		}
		else if (refresh == 2)
		{
			this.history[this.history.length - 1].historyRecord = this.layout.getHistoryRecordObject();
			this.history.push( {  } );
			
			this.historyBack();
		}
		else if (!Share.POPUP.isShowingPopup() && this.loadingMC == null)
		{
			this.layout.enable();
		}
		
	}
	
	private function closePopup():Void
	{
		this.layout.enable();
	}
	
	//------------------------------------------------ Search -----------------------------------------------------------
	private function startSearch(model:MediaModel):Void
	{
		Share.KEYBOARD.startKeyboard(Delegate.create(this, this.searchQueryReceived), Delegate.create(this, this.cancelSearch), model.prompt, "", false, false);
	}
	
	private function cancelSearch():Void
	{
		this.layout.enable();
	}
	
	private function searchQueryReceived(o:Object):Void
	{
		var query:String = o.text;
		if (!Util.isBlank(query))
		{
			// start search
			this.loadData(this.currentSelectedItem, query);
		}
		else
		{
			this.cancelSearch();
		}
	}
	
	//---------------------------------------------- UI ------------------------------------------------------
	private function showLoadingMC(show:Boolean):Void
	{
		if (show)
		{
			if (this.loadingMC == null)
			{
				this.loadingMC = this.UIMainMC.attachMovie("loadingMC", "mc_loading", this.UIMainMC.getNextHighestDepth(), { _x:640, _y:360 } );
			}
		}
		else
		{
			this.loadingMC.removeMovieClip();
			delete this.loadingMC;
			this.loadingMC = null;
		}
	}
	
	private function updateTime():Void
	{
		clearInterval(this.timeUpdateInterval);
		this.timeUpdateInterval = null;
		
		var date:Date = new Date();
		var hour:Number = date.getHours();
		var min:Number = date.getMinutes();
		
		var indicator:String = "AM";
		
		if (hour > 11)
		{
			indicator = "PM";
			if (hour != 12)
			{
				hour -= 12;
			}
		}
		
		var dateStr:String = "<FONT COLOR='" + Share.APP_SETTING.highlightTextColor + "'>" + Share.SEPARATOR_CHARACTER + "</FONT> " + hour + " : " + (min > 9 ? min : "0" + min) + " " + indicator;
		
		this.clockInterface.getClockTextField().htmlText = dateStr;
		
		var timeForNextUpdate:Number = (60 - date.getSeconds()) * 995;
		
		this.timeUpdateInterval = setInterval(this.fn.updateTime, timeForNextUpdate);
	}
	
	//--------------------------------------------------- Util -------------------------------------------------------
	
	/*
	 * Load the data. Query is passed in for searching
	 */
	private function loadData(model:ModelBase, query:String, history:Object, currentItem:Object):Void
	{
		this.showLoadingMC(true);
		
		var key:String = model.key;
		var path:String = this.currentPath;
		var newPath:String = null;
		
		if (!Util.isBlank(query))
		{
			model._query = query;
		}
		
		if (!Util.isBlank(model._query))
		{
			if (key.indexOf("?") > 0)
			{
				key += "&";
			}
			else
			{
				key += "?";
			}
			
			key += "query=" + model._query;
			//model.key = key;
		}
		
		if (key.charAt(0) == "/" || Util.startsWith(key, "http://") || Util.startsWith(key, "https://"))
		{
			path = null;
			newPath = key;
		}
		else
		{
			newPath = path + (Util.endsWith(path, "/") ? "" : "/") + key;
		}
		
		key = Share.getPaginationKey(key, 0, Share.LAYOUT_DATA_PRELOAD_SIZE);
		
		Share.api.load(key, path, Share.systemGateway, { newPath:newPath, model:model, path:this.currentPath, loadingPath:path, history:history, currentItem:currentItem }, Delegate.create(this, onLoad));
	}
	
	/*
	 * Check whether the list contains any of the node type specified
	 */
	private function checkItems(container:ContainerModel, nodeType:Number, contentType:String):Boolean
	{
		var itemLen:Number = container.items.length;
		var mediaItem:MediaModel = null;
		for (var i:Number = 0; i < itemLen; i ++)
		{
			mediaItem = container.items[i];
			if (nodeType >= 0)
			{
				if (mediaItem.itemType == nodeType)
				{
					return true;
				}
			}
			else if (Util.isBlank(contentType))
			{
				if (mediaItem.type == contentType)
				{
					return true;
				}
			}
		}
		return false;
	}
	
	/*
	 * Get which type of item contain in the list
	 */
	private function getContainerItemType(container:ContainerModel):Number
	{
		var nodeType:Number = MediaModel.TYPE_DIRECTORY;
		
		var items:Array = container.items;
		var len:Number = items.length;
		var media:MediaModel = null;
		
		for (var i:Number = 0; i < len; i ++)
		{
			media = items[i];
			if (media.itemType == MediaModel.TYPE_TRACK || media.itemType == MediaModel.TYPE_VIDEO || media.itemType == MediaModel.TYPE_PHOTO)
			{
				return media.itemType;
			}
		}
		
		return nodeType;
	}
	
	private function getCurrentPath():String
	{
		return this.currentPath;
	}
}