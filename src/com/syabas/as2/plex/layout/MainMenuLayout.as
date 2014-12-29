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
* Class Description: The main menu
*
***************************************************/

import com.syabas.as2.plex.api.API;
import com.syabas.as2.plex.component.*;
import com.syabas.as2.plex.interfaces.LayoutInterface;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.*;

import mx.utils.Delegate;

class com.syabas.as2.plex.layout.MainMenuLayout implements LayoutInterface
{
	public static var FANART_PER_SECTION:Number = 10;			// The number of fanart to be used from each library section
	
	public var itemSelectedCallback:Function = null;			// Callback when user select an item. Assign by BrowseManager.as
	
	private var parentMC:MovieClip = null;
	private var mainMenuMC:MovieClip = null;
	private var fanartHolderMC:MovieClip = null;
	private var fanart1MC:MovieClip = null;
	private var fanart2MC:MovieClip = null;
	
	private var currentDeck:DeckBase = null;
	
	private var menuList:CenteredList = null;
	private var videoDeck:VideoDeck = null;
	private var musicDeck:MusicDeck = null;
	private var photoDeck:PhotoDeck = null;
	private var pluginDeck:PluginDeck = null;
	private var loginDeck:LoginDeck = null;
	private var preferenceDeck:PreferenceDeck = null;
	private var searchDeck:SearchDeck = null;

	private var fn:Object = null;
	
	private var menuData:Array = null;
	
	private var fanartList:Array = null;
	private var fanartIndex:Number = -1;
	private var fanartTimeout:Number = null;
	private var activeFanartList:Array = null;
	
	private var focusIndex:Number = null;
	private var lastSavedSearchKey:String = null;
	
	public function destroy():Void
	{
		this.videoDeck.destroy();
		this.musicDeck.destroy();
		this.photoDeck.destroy();
		this.pluginDeck.destroy();
		this.loginDeck.destroy();
		this.preferenceDeck.destroy();
		this.searchDeck.destroy();
		
		this.menuList.destroy();
		
		this.fanartHolderMC.removeMovieClip();
		this.mainMenuMC.removeMovieClip();
		
		clearInterval(this.fanartTimeout);
		delete this.fanartTimeout;
		this.fanartTimeout = null;
		
		delete this.fanartHolderMC;
		delete this.fanart1MC;
		delete this.fanart2MC;
		
		delete this.mainMenuMC;
		delete this.videoDeck;
		delete this.musicDeck;
		delete this.photoDeck;
		delete this.pluginDeck;
		delete this.loginDeck;
		delete this.preferenceDeck;
		delete this.searchDeck;
		delete this.fn;
		
		delete this.fanartList;
		delete this.fanartIndex;
		
		delete this.menuData;
		delete this.itemSelectedCallback;
		delete this.activeFanartList;
		delete this.focusIndex;
		delete this.lastSavedSearchKey;
		delete this.currentDeck;
	}
	
	public function MainMenuLayout(mc:MovieClip)
	{
		this.fn = { fanartOnLoad:Delegate.create(this, this.fanartOnLoad),
					switchFanart:Delegate.create(this, this.switchFanart) };
		this.parentMC = mc;
		
		this.fanartHolderMC = mc.createEmptyMovieClip("mc_mainMenuFanartHolder", mc.getNextHighestDepth());
		this.mainMenuMC = mc.attachMovie("mainMenuMC", "mc_mainMenu", mc.getNextHighestDepth());
		
		ComponentUtils.fitTextInTextField(this.mainMenuMC.mc_exit.txt, Share.getString("exit"));
		ComponentUtils.fitTextInTextField(this.mainMenuMC.mc_red.txt, Share.getString("indicator_mark_watched"));
		ComponentUtils.fitTextInTextField(this.mainMenuMC.mc_green.txt, Share.getString("indicator_mark_unwatched"));
		ComponentUtils.fitTextInTextField(this.mainMenuMC.mc_info.txt, Share.getString("showInfo"));
		
		// create all deck classes
		this.videoDeck = new VideoDeck(this.mainMenuMC.mc_videoDeck);
		this.musicDeck = new MusicDeck(this.mainMenuMC.mc_musicDeck);
		this.photoDeck = new PhotoDeck(this.mainMenuMC.mc_photoDeck);
		this.pluginDeck = new PluginDeck(this.mainMenuMC.mc_pluginDeck);
		this.loginDeck = new LoginDeck(this.mainMenuMC.mc_login);
		this.preferenceDeck = new PreferenceDeck(this.mainMenuMC.mc_preference);
		this.searchDeck = new SearchDeck(this.mainMenuMC.mc_search, this.mainMenuMC.mc_searchMask, this.mainMenuMC.txt_error);
		
		var overLeft:Function = Delegate.create(this, this.deckReturnCB);
		var loadFanart:Function = Delegate.create(this, this.loadFanart);
		var showLoadingMC:Function = Delegate.create(this, this.showLoadingMC);
		var clearFanartCB:Function = Delegate.create(this, this.clearFanart);
		
		this.videoDeck.overLeft = overLeft
		this.musicDeck.overLeft = overLeft;
		this.photoDeck.overLeft = overLeft;
		this.pluginDeck.overLeft = overLeft;
		this.loginDeck.overLeft = overLeft;
		this.preferenceDeck.overLeft = overLeft;
		this.searchDeck.overLeft = overLeft;
		
		this.videoDeck.loadFanartCB = loadFanart;
		this.musicDeck.loadFanartCB = loadFanart;
		this.photoDeck.loadFanartCB = loadFanart;
		this.pluginDeck.loadFanartCB = loadFanart;
		this.preferenceDeck.loadFanartCB = loadFanart;
		this.searchDeck.loadFanartCB = loadFanart;
		
		this.videoDeck.showLoadingMC = showLoadingMC;
		this.musicDeck.showLoadingMC = showLoadingMC;
		this.photoDeck.showLoadingMC = showLoadingMC;
		this.pluginDeck.showLoadingMC = showLoadingMC;
		this.preferenceDeck.showLoadingMC = showLoadingMC;
		this.searchDeck.showLoadingMC = showLoadingMC;
		
		this.videoDeck.clearFanartCB = clearFanartCB
		this.musicDeck.clearFanartCB = clearFanartCB;
		this.photoDeck.clearFanartCB = clearFanartCB;
		this.pluginDeck.clearFanartCB = clearFanartCB;
		this.loginDeck.clearFanartCB = clearFanartCB;
		this.preferenceDeck.clearFanartCB = clearFanartCB;
		this.searchDeck.clearFanartCB = clearFanartCB;
		
		this.videoDeck.homeMC = this.mainMenuMC.mc_exit;
		this.videoDeck.redMC = this.mainMenuMC.mc_red;
		this.videoDeck.greenMC = this.mainMenuMC.mc_green;
		this.videoDeck.infoMC = this.mainMenuMC.mc_info;
		
		this.mainMenuMC.mc_topbar.g_topbar._visible = false;
		this.mainMenuMC.mc_searchHint._visible = false;
		this.mainMenuMC.mc_green._visible = false;
		this.mainMenuMC.mc_red._visible = false;
		this.mainMenuMC.mc_info._visible = false;
		
		this.lastSavedSearchKey = "";
		
		// hide all deck
		this.mainMenuMC.mc_rightArrow._visible = false;
		this.showDeck(null);
	}
	
	/*
	 * Overwrite super class
	 */
	public function renderItems(container:ContainerModel):Void
	{
		Share.PLAYER.moveInfoPanel(Share.APP_SETTING.mainMenuConfig.playbackFloatWindowConfig);
		this.focusIndex = 0;
		this.menuData = container.items;
		
		this.loadFanartList();
		
		if (this.menuList == null)
		{
			this.menuList = new CenteredList();
			this.initMainMenuList();
		}
		
		this.menuList.data = this.buildMenu(this.menuData);
		this.menuList.createUI();
		
		if (this.menuList.data.length == 1)
		{
			// only 1 item, direct open panel
			this.menuEnterCB( { data:this.menuList.getData(0) } );
		}
		
		if (!Util.isBlank(Share.systemGateway))
		{
			this.mainMenuMC.mc_topbar.txt_item.text = Share.stripServerAddress(Share.systemGateway);
		}
	}
	
	/*
	 * Overwrite super class
	 */
	public function getClockTextField():TextField
	{
		return this.mainMenuMC.mc_topbar.txt_time;
	}
	
	/*
	 * Overwrite super class
	 */
	public function disable():Void
	{
		this.menuList.disable();
		this.currentDeck.disable();
	}
	
	/*
	 * Overwrite super class
	 */
	public function enable():Void
	{
		if (this.focusIndex == 1)
		{
			// highlight the deck
			
			if (this.currentDeck.available())
			{
				this.currentDeck.enable();
				return;
			}
			
		}
		this.menuList.enable();
		this.setAllNonFocusedItemVisible(true);
	}
	
	/*
	 * Overwrite super class
	 */
	public function setCallback(cbObj:Object):Void
	{
		var cb:Function = cbObj.itemSelectedCallback;
		this.itemSelectedCallback = cb;
		
		this.videoDeck.onItemSelected = cb;
		this.musicDeck.onItemSelected = cb;
		this.photoDeck.onItemSelected = cb;
		this.pluginDeck.onItemSelected = cb;
		this.searchDeck.onItemSelected = cb;
	}
	
	/*
	 * Overwrite super class
	 */
	public function setLoadingParameter(key:String, path:String):Void
	{
		
	}
	
	/*
	 * Overwrite super class
	 */
	public function getHistoryRecordObject():Object
	{
		return { hl:this.menuList.hl };
	}
	
	/*
	 * Overwrite super class
	 */
	public function restoreHistoryState(historyObj:Object):Void
	{
		if (historyObj.hl != null && historyObj.hl != undefined)
		{
			this.menuList.highlight(historyObj.hl);
		}
	}
	
	//---------------------------------------------- Menu Data -----------------------------------------------
	private function reloadMenu():Void
	{
		var index:Number = this.menuList.hl;
		this.menuList.clear();
		this.menuList.data = this.buildMenu(this.menuData);
		this.menuList.createUI(index);
	}
	
	private function buildMenu(libraryMenu:Array):Array
	{
		var extraXMLString:String = "";
		extraXMLString += '<MediaContainer machineIdentifier="">';
		
		if (Util.isBlank(Share.systemGateway) || libraryMenu == null || libraryMenu == undefined)
		{
			// return the preference
			libraryMenu = new Array();
			extraXMLString += '<Directory count="0" key="__setting__" title="' + Share.getString("preference_setting") + '" />';
		}
		else
		{
			extraXMLString += '<Directory count="0" type="plugin" key="/video" title="' + Share.getString("video_channel") + '" art="_embed_videos" />';
			extraXMLString += '<Directory count="0" type="plugin" key="/music" title="' + Share.getString("music_channel") + '" art="_embed_music" />';
			extraXMLString += '<Directory count="0" type="plugin" key="/photos" title="' + Share.getString("photo_channel") + '" art="_embed_photos" />';
			extraXMLString += '<Directory count="0" key="/system/plexonline" title="' + Share.getString("plex_online") + '" />';
			
			if (Share.MY_PLEX_TOKEN != null && Share.MY_PLEX_TOKEN != undefined)
			{
				extraXMLString += '<Directory count="0" key="' + Share.MY_PLEX_BASE_URL + '/pms/playlists/queue" title="' + Share.getString("my_queue") + '" />';
				extraXMLString += '<Directory count="0" key="__logout__" title="' + Share.getString("logout") + '" />';
			}
			else
			{
				extraXMLString += '<Directory count="0" key="__login__" title="' + Share.getString("login") + '" />';
			}
			
			extraXMLString += '<Directory count="0" key="__search__" title="' + Share.getString("search") + '" />';
			extraXMLString += '<Directory count="0" key="__setting__" title="' + Share.getString("preference_setting") + '" />';
		}
		
		extraXMLString += '</MediaContainer>';
		
		var extraXML:XML = new XML(extraXMLString);
		
		var extraData:ContainerModel = new ContainerModel();
		extraData.fromXML(extraXML.firstChild);
		
		libraryMenu = libraryMenu.concat(extraData.items);
		
		delete extraXML.idMap;
		extraXML = null;
		extraData = null;
		
		return libraryMenu;
	}
	
	//--------------------------------------- Main Menu List --------------------------------------
	private function initMainMenuList():Void
	{
		var mcArray:Array = new Array();
		var len:Number = Share.APP_SETTING.mainMenuConfig.mainMenuPreviousItemCount;
		
		for (var i:Number = 0; i < len; i ++)
		{
			mcArray.push(this.mainMenuMC["mc_previousItem" + i]);
		}
		
		this.menuList.mcArrayBefore = mcArray;
		
		mcArray = new Array();
		len = Share.APP_SETTING.mainMenuConfig.mainMenuNextItemCount;
		
		for (var i:Number = 0; i < len; i ++)
		{
			mcArray.push(this.mainMenuMC["mc_nextItem" + i]);
		}
		
		this.menuList.mcArrayAfter = mcArray;
		this.menuList.centerFocusMC = this.mainMenuMC.mc_centeredItem;
		this.menuList.onItemClearCB = Delegate.create(this, menuClearCB);
		this.menuList.onItemUpdateCB = Delegate.create(this, menuUpdateCB);
		this.menuList.onEnterCB = Delegate.create(this, menuEnterCB);
		this.menuList.onKeyDownCB = Delegate.create(this, menuKeyDownCB);
		this.menuList.onOverRightCB = Delegate.create(this, menuOverRigthCB);
		this.menuList.hlCB = Delegate.create(this, this.menuHLCB);
		this.menuList.unhlCB = Delegate.create(this, this.menuUnHLCB);
		this.menuList.hlStopCB = Delegate.create(this, this.menuHLStopCB);
		this.menuList.hlStopTime = 1000;
		this.menuList.wrap = true;
	}
	
	private function menuUpdateCB(o:Object):Void
	{
		o.mc.txt_title.htmlText = Share.returnStringForDisplay(o.data.title);
	}
	
	private function menuClearCB(o:Object):Void
	{
		o.mc.txt_title.text = "";
		o.mc.gotoAndStop("unhl");
	}
	
	private function menuEnterCB(o:Object):Void
	{
		if (o.data.key == "__login__")
		{
			// do login
			this.loginDeck.showDeck();
			this.fanartHolderMC._visible = false;
			this.setAllNonFocusedItemVisible(false);
			this.menuList.disable();
			o.mc.gotoAndStop("selected");
		}
		else if (o.data.key == "__logout__")
		{
			// show logout confirmation
			this.menuList.disable();
			Share.POPUP.showConfirmationPopup(Share.getString("logout_confirmation_title"), Share.getString("logout_confirmation"), Delegate.create(this, this.confirmLogout), Delegate.create(this, this.enable));
		}
		else if (o.data.key == "__setting__")
		{
			this.preferenceDeck.showDeck();
			this.fanartHolderMC._visible = false;
			this.setAllNonFocusedItemVisible(false);
			this.preferenceDeck.enable();
			this.menuList.disable();
			o.mc.gotoAndStop("selected");
		}
		else if (o.data.key == "__search__")
		{
			this.menuList.disable();
			this.setAllNonFocusedItemVisible(false);
			Share.KEYBOARD.startKeyboard(Delegate.create(this, this.searchDoneCB), Delegate.create(this, this.searchCancelCB), Share.getString("search"), this.lastSavedSearchKey, false, false);
		}
		else if (this.itemSelectedCallback(o.data))
		{
			
			this.disable();
		}
	}
	
	private function menuKeyDownCB(o:Object):Void
	{
		
	}
	
	private function menuOverRigthCB(o:Object):Boolean
	{
		if (this.currentDeck != null)
		{
			if (this.currentDeck.available())
			{
				// highlight to the shown deck
				this.focusIndex = 1;
				this.currentDeck.enable();
				this.setAllNonFocusedItemVisible(false);
				this.menuList.centerFocusMC.gotoAndStop("selected");
				return false;
			}
		}
		return true;
	}
	
	private function menuHLCB(o:Object):Void
	{
		o.mc.gotoAndStop("hl");
		if (this.currentDeck != null)
		{
			this.showDeck(null);
		}
		
		this.fanartHolderMC._visible = true;
	}
	
	private function menuUnHLCB(o:Object):Void
	{
		o.mc.gotoAndStop("unhl");
	}
	
	private function menuHLStopCB(o:Object):Void
	{
		var obj:MediaModel = o.data;
		if (obj.type == MediaModel.CONTENT_TYPE_MOVIE)
		{
			this.showDeck(this.videoDeck, obj);
		}
		else if (obj.type == MediaModel.CONTENT_TYPE_ARTIST)
		{
			this.showDeck(this.musicDeck, obj);
		}
		else if (obj.type == MediaModel.CONTENT_TYPE_PHOTO)
		{
			this.showDeck(this.photoDeck, obj);
		}
		else if (obj.type == MediaModel.CONTENT_TYPE_SHOW)
		{
			this.showDeck(this.videoDeck, obj);
		}
		else if (obj.type == MediaModel.CONTENT_TYPE_PLUGIN)
		{
			this.showDeck(this.pluginDeck, obj);
		}
		else if (this.currentDeck != null)
		{
			this.showDeck(null);
		}
		
		var item:Object = this.menuData[o.dataIndex];
		
		if (item.fanartList != null && item.fanartList != undefined && item.fanartList.length > 0)
		{
			// got fanart list, use the section's fanart to do slideshow
			this.activeFanartList = item.fanartList;
			this.fanartIndex = this.fanartIndex % this.activeFanartList.length;
			
			this.switchFanart();
		}
		else if (this.fanartList != null && this.fanartList != undefined && this.fanartList.length > 0)
		{
			// use all fanart to run slideshow
			if (this.fanartList != this.activeFanartList)
			{
				// previously is running slideshow for the same list
				this.activeFanartList = this.fanartList;
				this.fanartIndex = this.fanartIndex % this.activeFanartList.length;
				
				this.switchFanart();
			}
		}
	}
	
	
	//------------------------------------------- Fanart --------------------------------------
	private function loadFanartList():Void
	{
		if (Share.hideBG)
		{
			return;
		}
		
		this.fanartList = new Array();
		var section:MediaModel = null;
		var key:String = null;
		var path:String = "/library/sections";
		
		var len:Number = this.menuData.length;
		
		for (var i:Number = 0; i < len; i ++)
		{
			section = this.menuData[i];
			key = Share.getPaginationKey(section.key + "/arts", 0, FANART_PER_SECTION);
			
			Share.api.load(key, path, Share.systemGateway, { menuIndex:i }, Delegate.create(this, this.fanartListOnLoad), null);
		}
	}
	
	private function fanartListOnLoad(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		if (success)
		{
			var previousLength:Number = this.fanartList.length;
			var array:Array = data.items;
			var len:Number = array.length;
			var num1:Number = null;
			var num2:Number = null;
			var temp:Object = null;
			for (var i:Number = 0; i < len; i ++)
			{
				num1 = Math.floor(Math.random() * len);
				num2 = num1;
				
				while (num1 == num2)
				{
					num2 = Math.round(Math.random() * len);
				}
				
				temp = array[num1];
				array[num1] = array[num2];
				array[num2] = temp;
			}
			
			this.menuData[userparams.menuIndex].fanartList = data.items;
			
			var fanartLen:Number = this.fanartList.length;
			
			for (var i:Number = 0; i < len; i ++)
			{
				num1 = Math.floor(Math.round() * fanartLen);
				this.fanartList.splice(num1, 0, array[i]);
				
				fanartLen ++;
			}
			
			if (this.fanartIndex < 0 || previousLength < 2 || previousLength == null || previousLength == undefined)
			{
				// first time loaded, start the fanart slideshow
				this.fanartIndex = -1;
				this.activeFanartList = this.fanartList;
				this.switchFanart();
			}
		}
	}
	
	private function switchFanart():Void
	{
		if (Share.hideBG)
		{
			return;
		}
		
		clearInterval(this.fanartTimeout);
		this.fanartTimeout = null;
		
		if (this.activeFanartList.length < 1 || this.activeFanartList == null || this.activeFanartList == undefined)
		{
			return;
		}
		
		var nextIndex:Number = this.fanartIndex;
		
		nextIndex = (nextIndex + 1) % this.activeFanartList.length;
		this.fanartIndex = nextIndex;
		
		var fanartItem:MediaModel = this.activeFanartList[this.fanartIndex];
		var url:String = Share.getResourceURL(fanartItem.key);
		
		this.loadFanart(url, true);
	}
	
	private function loadFanart(url:String, isSlideshow:Boolean):Void
	{
		if (Share.hideBG)
		{
			return;
		}
		
		clearInterval(this.fanartTimeout);
		this.fanartTimeout = null;
		
		if (isSlideshow == null || isSlideshow == undefined)
		{
			isSlideshow = false;
		}
		url = Share.getPhotoTranscodeURL(url, 1280, 720);
		
		if (this.fanart2MC != null)
		{
			Share.imageLoader.unload("mainMenuFanart", this.fanart2MC, null);
			this.fanart2MC.removeMovieClip();
			delete this.fanart2MC;
			this.fanart2MC = null;
		}
		
		this.fanart2MC = this.fanartHolderMC.createEmptyMovieClip("mc_fanart_" + this.fanartHolderMC.getNextHighestDepth(), this.fanartHolderMC.getNextHighestDepth());
		Share.imageLoader.load("mainMenuFanart", url, this.fanart2MC, { isSlideshow:isSlideshow, scaleMode:1, scaleProps: { center:true, actualSizeOption:3, width:1280, height:720 }, doneCB:this.fn.fanartOnLoad } );
	}
	
	private function clearFanart():Void
	{
		Share.imageLoader.unload("mainMenuFanart", this.fanart2MC, null);
		this.fanart2MC.removeMovieClip();
		delete this.fanart2MC;
		this.fanart2MC = null;
		
		Share.imageLoader.unload("mainMenuFanart", this.fanart1MC, null);
		this.fanart1MC.removeMovieClip();
		delete this.fanart1MC;
		this.fanart1MC = null;
	}
	
	private function fanartOnLoad(success:Boolean, o:Object):Void
	{
		if (this.activeFanartList.length > 1 && o.o.isSlideshow == true)
		{
			this.fanartTimeout = setInterval(this.fn.switchFanart, Share.FANART_SWITCH_TIME);
		}
		
		if (success)
		{
			Share.imageLoader.unload("mainMenuFanart", this.fanart1MC, null);
			this.fanart1MC.removeMovieClip();
			this.fanart1MC = this.fanart2MC;
			
			this.fanart2MC = null;
		}
	}
	
	//------------------------------------------ UI -------------------------------------------
	private function showLoadingMC(name:String, x:Number, y:Number, width:Number, height:Number):MovieClip
	{
		var mc:MovieClip = this.mainMenuMC.attachMovie("loadingMC", name, this.mainMenuMC.getNextHighestDepth());
		x = new Number(x);
		y = new Number(y);
		width = new Number(width);
		height = new Number(height);
		
		if (!isNaN(x))
		{
			mc._x = x;
		}
		
		if (!isNaN(y))
		{
			mc._y = y;
		}
		
		if (!isNaN(width))
		{
			mc._width = width;
		}
		
		if (!isNaN(height))
		{
			mc._height = height;
		}
		
		return mc;
	}
	
	private function showDeck(deck:DeckBase, data:MediaModel):Void
	{
		this.currentDeck.hideDeck();
		this.currentDeck = deck;
		
		if (this.videoDeck == deck)
		{
			this.videoDeck.showDeck(data, this.mainMenuMC.mc_rightArrow);
		}
		else
		{
			this.videoDeck.hideDeck();
		}
		
		if (this.photoDeck == deck)
		{
			this.photoDeck.showDeck(data, this.mainMenuMC.mc_rightArrow);
		}
		else
		{
			this.photoDeck.hideDeck();
		}
		
		if (this.musicDeck == deck)
		{
			this.musicDeck.showDeck(data, this.mainMenuMC.mc_rightArrow);
		}
		else
		{
			this.musicDeck.hideDeck();
		}
		
		if (this.pluginDeck == deck)
		{
			this.pluginDeck.showDeck(data, this.mainMenuMC.mc_rightArrow);
		}
		else
		{
			this.pluginDeck.hideDeck();
		}
		
		if (this.loginDeck == deck)
		{
			this.loginDeck.showDeck();
		}
		else
		{
			this.loginDeck.hideDeck();
		}
		
		if (this.preferenceDeck == deck)
		{
			this.preferenceDeck.showDeck();
		}
		else
		{
			this.preferenceDeck.hideDeck();
		}
		if (this.searchDeck == deck)
		{
			this.searchDeck.showDeck();
		}
		else
		{
			this.searchDeck.hideDeck();
		}
		
	}
	
	private function setAllNonFocusedItemVisible(visible:Boolean):Void
	{
		var arr:Array = this.menuList.mcArrayBefore;
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i ++)
		{
			arr[i]._visible = visible;
		}
		
		arr = this.menuList.mcArrayAfter;
		len = arr.length;
		
		for (var i:Number = 0; i < len; i ++)
		{
			arr[i]._visible = visible;
		}
	}
	
	
	private function deckReturnCB(reloadMenu:Boolean):Void
	{
		this.focusIndex = 0;
		
		if (reloadMenu == true)
		{
			this.reloadMenu();
		}
		if (this.currentDeck != this.searchDeck)
		{
			this.fanartHolderMC._visible = true;
		}
		this.menuList.centerFocusMC.gotoAndStop("hl");
		this.enable();
		this.switchFanart();
	}
	
	private function confirmLogout():Void
	{
		Share.MY_PLEX_TOKEN = null;
		Share.saveSharedObject();
		
		Share.POPUP.showMessagePopup(Share.getString("logout_done_title"), Share.getString("logout_done"), Delegate.create(this, this.reloadMenu));
	}
	
	private function searchDoneCB(o:Object):Void
	{
		var keyword:String = o.text;
		this.lastSavedSearchKey = keyword;
		this.searchDeck.showDeck(keyword, this.mainMenuMC.mc_rightArrow);
		this.fanartHolderMC._visible = false;
		this.setAllNonFocusedItemVisible(true);
		
		this.menuList.enable();
		this.currentDeck = this.searchDeck;
	}
	
	private function searchCancelCB():Void
	{
		this.deckReturnCB(false);
	}
	
	
	//---------------------------- Refreshing --------------------------------------------
	public function refreshCurrentItem():Void
	{
		if (this.currentDeck == this.videoDeck)
		{
			this.videoDeck.refreshCurrentItem();
		}
		else
		{
			this.enable();
		}
	}
}