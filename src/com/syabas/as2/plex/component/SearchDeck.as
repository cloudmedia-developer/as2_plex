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
* Class Description: The searching deck on the main menu
*
***************************************************/

import com.syabas.as2.plex.component.ComponentUtils;
import com.syabas.as2.plex.component.DeckBase;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;


import mx.utils.Delegate;

class com.syabas.as2.plex.component.SearchDeck extends DeckBase
{
	private static var INDEX_MOVIE:Number = 0;
	private static var INDEX_TV_SHOW:Number = 1;
	private static var INDEX_EPISODE:Number = 2;
	private static var INDEX_ARTIST:Number = 3;
	private static var INDEX_ALBUM:Number = 4;
	private static var INDEX_TRACK:Number = 5;
	private static var INDEX_ACTOR:Number = 6;
	
	private static var TOTAL_ROW:Number = 7;
	
	private var maskMC:MovieClip = null;
	private var loadingMC:MovieClip = null;
	private var errorTF:TextField = null;
	
	private var movieGrid:GridLite = null;
	private var tvShowGrid:GridLite = null;
	private var episodeGrid:GridLite = null;
	private var artistGrid:GridLite = null;
	private var albumGrid:GridLite = null;
	private var trackGrid:GridLite = null;
	private var actorGrid:GridLite = null;
	
	private var titleMarquee:Marquee = null;
	
	private var keyword:String = null;
	private var id:String = null;
	
	private var focusIndex:Number = -1;
	private var oriY:Number = null;
	private var loadedCount:Number = null;
	private var error:Boolean = null;
	private var isAvailable:Boolean = false;
	
	public function destroy():Void
	{
		this.cleanup();
		this.movieGrid.destroy();
		this.tvShowGrid.destroy();
		this.episodeGrid.destroy();
		this.artistGrid.destroy();
		this.albumGrid.destroy();
		this.actorGrid.destroy();
		this.trackGrid.destroy();
		
		delete this.titleMarquee;
		delete this.movieGrid;
		delete this.tvShowGrid;
		delete this.episodeGrid;
		delete this.artistGrid;
		delete this.albumGrid;
		delete this.actorGrid;
		delete this.trackGrid;
		
		delete this.oriY;
		delete this.keyword;
		delete this.id;
		
		this.loadingMC.removeMovieClip();
		delete this.loadingMC;
		this.loadingMC = null;
		
		super.destroy();
	}
	
	public function SearchDeck(mc:MovieClip, maskMC:MovieClip, errorText:TextField)
	{
		super(mc);
		this.oriY = mc._y;
		this.maskMC = maskMC;
		this.errorTF = errorText;
		mc.setMask(maskMC);
		
		this.config = Share.APP_SETTING.mainMenuConfig.searchDeckConfig;
		
		this.movieGrid = this.createGrid(this.deckMC.mc_movieSearch, this.config.movieConfig, this.movieUpdateCB, this.movieClearCB);
		this.tvShowGrid = this.createGrid(this.deckMC.mc_tvShowSearch, this.config.tvShowConfig, this.showUpdateCB, this.showClearCB);
		this.episodeGrid = this.createGrid(this.deckMC.mc_episodeSearch, this.config.episodeConfig, this.episodeUpdateCB, this.episodeClearCB);
		this.artistGrid = this.createGrid(this.deckMC.mc_artistSearch, this.config.artistConfig, this.artistUpdateCB, this.artistClearCB);
		this.albumGrid = this.createGrid(this.deckMC.mc_albumSearch, this.config.albumConfig, this.albumUpdateCB, this.albumClearCB);
		this.trackGrid = this.createGrid(this.deckMC.mc_trackSearch, this.config.trackConfig, this.trackUpdateCB, this.trackClearCB);
		this.actorGrid = this.createGrid(this.deckMC.mc_actorSearch, this.config.actorConfig, this.actorUpdateCB, this.actorClearCB);
		
		
		this.deckMC.mc_movieSearch.txt_group.text = Share.getString("movie");
		this.deckMC.mc_tvShowSearch.txt_group.text = Share.getString("tv_show");
		this.deckMC.mc_episodeSearch.txt_group.text = Share.getString("episode");
		this.deckMC.mc_artistSearch.txt_group.text = Share.getString("artist");
		this.deckMC.mc_albumSearch.txt_group.text = Share.getString("album");
		this.deckMC.mc_trackSearch.txt_group.text = Share.getString("track");
		this.deckMC.mc_actorSearch.txt_group.text = Share.getString("actor");
		
		this.titleMarquee = new Marquee();
	}
	
	/*
	 * Show the deck. To be implemented by sub classes
	 */
	public function showDeck(keyword:String, pointerMC:MovieClip):Void
	{
		/*if (this.isAvailable)
		{
			this.hideDeck();
		}*/
		this.hideDeck();
		this.pointerMC = pointerMC;
		pointerMC._visible = false;
		
		this.keyword = keyword;
		this.startSearch();
	}
	
	/*
	 * Hide the deck. To be implemented by sub classes
	 */
	public function hideDeck():Void
	{
		this.deckMC._visible = false;
		this.errorTF.text = "";
		this.cleanup();
		this.focusIndex = -1;
	}
	
	/*
	 * Enable the deck navigation control. To be implemented by sub classes
	 */
	public function enable():Void
	{
		if (this.focusIndex > -1)
		{
			//this.focusIndex --;
			this.getGridAndParentMC(this.focusIndex).grid.highlight();
		}
		else
		{
			this.overBottomCB();
		}
		
		this.pointerMC._visible = true;
	}
	
	/*
	 * Disable the deck navigation control. To be implemented by sub classes
	 */
	public function disable():Void
	{
		this.titleMarquee.stop();
		
		var obj:Object = this.getGridAndParentMC(this.focusIndex);
		obj.grid.unhighlight();
		
		this.pointerMC._visible = false;
	}
	
	/*
	 * To check whether this deck is available to be focused. To be overwritted by sub classes
	 */
	public function available():Boolean
	{
		//return false;
		return this.isAvailable;
	}
	
	private function startSearch():Void
	{
		this.loadedCount = 0;
		this.error = false;
		this.errorTF.text = "";
		if (this.loadingMC == null)
		{
			this.loadingMC = this.showLoadingMC("mc_loadingSearch", this.maskMC._x + (this.maskMC._width / 2), this.maskMC._y + (this.maskMC._height / 2));
		}
		
		var key1:String = "/search?local=1&query=" + this.keyword;
		var key2:String = "/search?type=10&query=" + this.keyword;
		var key3:String = "/search/actor?query=" + this.keyword;
		
		key1 = Share.getPaginationKey(key1, 0, 80);
		key2 = Share.getPaginationKey(key2, 0, 30);
		key3 = Share.getPaginationKey(key3, 0, 30);
		
		Share.api.load(key1, null, Share.systemGateway, { loadType:"local" }, Delegate.create(this, this.dataLoaded), "search_1");
		Share.api.load(key2, null, Share.systemGateway, { loadType:"track" }, Delegate.create(this, this.dataLoaded), "search_2");
		Share.api.load(key3, null, Share.systemGateway, { loadType:"actor" }, Delegate.create(this, this.dataLoaded), "search_3");
	}
	
	private function dataLoaded(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		this.loadedCount ++;
		if (success)
		{
			//this.isAvailable = true;
			//this.deckMC._visible = true;
			this.id = data.identifier;
			
			var items:Array = data.items;
			var len:Number = items.length;
			var item:MediaModel = null;
			var loadType:String = userparams.loadType;
			
			for (var i:Number = 0; i < len; i ++)
			{
				item = items[i];
				if (item.type == MediaModel.CONTENT_TYPE_MOVIE)
				{
					this.movieGrid.data.push(item);
				}
				else if (item.type == MediaModel.CONTENT_TYPE_SHOW)
				{
					this.tvShowGrid.data.push(item);
				}
				else if (item.type == MediaModel.CONTENT_TYPE_EPISODE)
				{
					this.episodeGrid.data.push(item);
				}
				else if (item.type == MediaModel.CONTENT_TYPE_ARTIST)
				{
					this.artistGrid.data.push(item);
				}
				else if (item.type == MediaModel.CONTENT_TYPE_ALBUM)
				{
					this.albumGrid.data.push(item);
				}
				else if (item.type == MediaModel.CONTENT_TYPE_TRACK)
				{
					this.trackGrid.data.push(item);
				}
				else if (item.type == MediaModel.CONTENT_TYPE_PERSON)
				{
					this.actorGrid.data.push(item);
				}
			}
			
			if (loadType == "local")
			{
				this.movieGrid.createUI();
				this.tvShowGrid.createUI();
				this.episodeGrid.createUI();
				this.albumGrid.createUI();
				this.artistGrid.createUI();
			}
			else if (loadType == "track")
			{
				this.trackGrid.createUI();
			}
			else if (loadType == "actor")
			{
				this.actorGrid.createUI();
			}
		}
		else
		{
			this.error = true;
		}
		
		if (this.loadedCount >= 3)
		{
			this.loadingMC.removeMovieClip(); 
			delete this.loadingMC;
			this.loadingMC = null;
			
			// all item loaded completed
			this.checkDeckAvailability();
		}
	}
	
	//--------------------------------------------------------- Grid ---------------------------------------------
	
	private function createGrid(mc:MovieClip, config:Object, updateCB:Function, clearCB:Function):GridLite
	{
		var grid:GridLite = new GridLite();
		
		grid.xMCArray = UI.attachMovieClip( { parentMC:mc, rSize:1, cSize:config.column } );
		grid.data = [];
		grid.xWrapLine = false;
		grid.xWrap = false;
		grid.xHoriz = true;
		grid.xHLStopTime = 1500;
		grid.hlCB = Delegate.create(this, this.hlCB);
		grid.onHLStopCB = Delegate.create(this, this.hlStopCB);
		grid.unhlCB = Delegate.create(this, this.unhlCB);
		grid.onItemClearCB = Delegate.create(this, clearCB);
		grid.onItemUpdateCB = Delegate.create(this, updateCB);
		grid.onEnterCB = Delegate.create(this, this.enterCB);
		grid.overLeftCB = Delegate.create(this, this.overLeftCB);
		grid.overTopCB = Delegate.create(this, this.overTopCB);
		grid.overBottomCB = Delegate.create(this, this.overBottomCB);
		grid.onKeyDownCB = Delegate.create(this, this.keyDownCB);
		grid.xEnablePageMove = true;
		grid.xScroll = GridLite.SCROLL_PAGE;
		
		grid.createUI();
		return grid;
	}
	
	private function hlCB(o:Object):Void
	{
		o.mc.gotoAndStop("hl");
		
		var obj:Object = this.getGridAndParentMC(this.focusIndex);
		var media:MediaModel = o.data;
		var title:String = null;
		this.titleMarquee.stop();
		
		if (this.focusIndex == INDEX_MOVIE || this.focusIndex == INDEX_TV_SHOW)
		{
			title = "<FONT COLOR='" + this.config.highlightTextColor + "'>" + Share.returnStringForDisplay(media.title) + "</FONT> " + Share.SEPARATOR_CHARACTER + " " + 
					Share.returnStringForDisplay(media.year + "") + " " + Share.SEPARATOR_CHARACTER + " " + Share.convertTime(media.duration);
		}
		else if (this.focusIndex == INDEX_EPISODE)
		{
			title = "<FONT COLOR='" + this.config.highlightTextColor + "'>" + Share.returnStringForDisplay(media.grandParentTitle) + "</FONT> " + 
					Share.SEPARATOR_CHARACTER + " " + Share.returnStringForDisplay(media.originalAirDate) + " " + Share.SEPARATOR_CHARACTER + " " + "<FONT COLOR='" + 
					this.config.highlightTextColor + "'>" + Share.returnStringForDisplay(media.title) + "</FONT> " + Share.SEPARATOR_CHARACTER + " " 
					+ Share.convertTime(media.duration);
		}
		else if (this.focusIndex == INDEX_ARTIST || this.focusIndex == INDEX_ACTOR)
		{
			title = Share.returnStringForDisplay(media.title);
		}
		else if (this.focusIndex == INDEX_ALBUM)
		{
			title = "<FONT COLOR='" + this.config.highlightTextColor + "'>" + Share.returnStringForDisplay(media.parentTitle) + "</FONT> " + Share.SEPARATOR_CHARACTER + " " + 
					Share.returnStringForDisplay(media.title) + " " + Share.SEPARATOR_CHARACTER + " " + Share.returnStringForDisplay(media.year + "");
		}
		else if (this.focusIndex == INDEX_TRACK)
		{
			title = "<FONT COLOR='" + this.config.highlightTextColor + "'>" + Share.returnStringForDisplay(media.parentTitle) + "</FONT> " + Share.SEPARATOR_CHARACTER + " " + 
					Share.returnStringForDisplay(media.title) + " " + Share.SEPARATOR_CHARACTER + " " + Share.convertTime(media.duration);
		}
		
		obj.mc.txt_title.htmlText = title;
		
		//this.pointerMC._y = this.deckMC._y + ( (o.mc._y + o.mc._height) / 2 );
	}
	
	private function hlStopCB(o:Object):Void
	{
		// start marquee
		var obj:Object = this.getGridAndParentMC(this.focusIndex);
		Share.startMarquee(this.titleMarquee, obj.mc.txt_title, obj.config.titleMarqueeConfig);
	}
	
	private function unhlCB(o:Object):Void
	{
		o.mc.gotoAndStop("unhl");
	}
	
	private function movieClearCB(o:Object):Void
	{
		this.clearCB(o, 0);
	}
	
	private function showClearCB(o:Object):Void
	{
		this.clearCB(o, 1);
	}
	
	private function episodeClearCB(o:Object):Void
	{
		this.clearCB(o, 2);
	}
	
	private function artistClearCB(o:Object):Void
	{
		this.clearCB(o, 3);
	}
	
	private function albumClearCB(o:Object):Void
	{
		this.clearCB(o, 4);
	}
	
	private function trackClearCB(o:Object):Void
	{
		this.clearCB(o, 5);
	}
	
	private function actorClearCB(o:Object):Void
	{
		this.clearCB(o, 6);
	}
	
	private function clearCB(o:Object, id:Number):Void
	{
		var thumbnailMC:MovieClip = o.mc.mc_thumbnail.mc_thumb;
		Share.imageLoader.unload(id + "_" + o.mc._name, thumbnailMC);
		
		o.mc.txt_title.text = "";
		o.mc.txt_artist.text = "";
		o.mc.txt_show.text = "";
		o.mc.txt_episode.text = "";
		
		o.mc._visible = false;
	}
	
	private function movieUpdateCB(o:Object):Void
	{
		this.updateCB(o, 0);
	}
	
	private function showUpdateCB(o:Object):Void
	{
		this.updateCB(o, 1);
	}
	
	private function episodeUpdateCB(o:Object):Void
	{
		this.updateCB(o, 2);
	}
	
	private function artistUpdateCB(o:Object):Void
	{
		this.updateCB(o, 3);
	}
	
	private function albumUpdateCB(o:Object):Void
	{
		this.updateCB(o, 4);
	}
	
	private function trackUpdateCB(o:Object):Void
	{
		this.updateCB(o, 5);
	}
	
	private function actorUpdateCB(o:Object):Void
	{
		this.updateCB(o, 6);
	}
	
	private function updateCB(o:Object, id:Number):Void
	{
		o.mc._visible = true;
		
		var obj:Object = this.getGridAndParentMC(id);
		var media:MediaModel = o.data;
		
		if (o.mc["mc_thumbnailMaskFor_" + o.mc.mc_thumbnail._name] == null || o.mc["mc_thumbnailMaskFor_" + o.mc.mc_thumbnail._name] == undefined)
		{
			Share.createMask(o.mc, o.mc.mc_thumbnail, obj.config.itemThumbnailConfig);
		}
			
		Share.loadThumbnail(id + "_" + o.mc._name, o.mc.mc_thumbnail, media.thumbnail, obj.config.itemThumbnailConfig, 1, 2);
		
		o.mc.txt_title.htmlText = Share.returnStringForDisplay(media.title);
		o.mc.txt_artist.htmlText = Share.returnStringForDisplay(id == INDEX_ALBUM ? media.parentTitle : media.grandParentTitle);
		o.mc.txt_show.htmlText = Share.returnStringForDisplay(media.grandParentTitle);
		
		var episodeNumberText:String = Share.getString("search_episode_count_format");
		
		if (media.index != null && media.parentIndex != null)
		{
			episodeNumberText = Util.replaceAll(episodeNumberText, "|EPISODE_NUMBER|", media.index + "");
			episodeNumberText = Util.replaceAll(episodeNumberText, "|SEASON_NUMBER|", media.parentIndex + "");
			
			o.mc.txt_episode.htmlText = Share.returnStringForDisplay(episodeNumberText);
		}
	}
	
	private function enterCB(o:Object):Void
	{
		if (this.focusIndex == INDEX_TRACK)
		{
			//call the parent key to get the list of item to start playback
			var media:MediaModel = o.data;
			Share.api.load(Share.getPaginationKey(media.parentKey, 0, 30), null, Share.systemGateway, { playIndex:media.index, key:media.parentKey }, Delegate.create(this, this.playlistLoaded), null);
		}
		else if (this.onItemSelected(o.data, this.id))
		{
			this.disable();
		}
	}
	
	private function overLeftCB(o:Object):Boolean
	{
		this.titleMarquee.stop();
		this.getGridAndParentMC(this.focusIndex).mc.txt_title.text = "";
		this.pointerMC._visible = false;
		this.overLeft();
		this.disable();
		return false;
	}
	
	private function overTopCB(o:Object):Boolean
	{
		if (this.focusIndex <= 0)
		{
			return true;
		}
		
		var obj:Object = null;
		var obj2:Object = null;
		var mc:MovieClip = null;
		var grid:GridLite = null;
		for (var i:Number = this.focusIndex - 1; i > -1; i --)
		{
			obj = this.getGridAndParentMC(i);
			if (obj.grid.data.length > 0)
			{
				obj2 = this.getGridAndParentMC(this.focusIndex);
				mc = obj2.mc;
				grid = obj2.grid;
				
				var index:Number = grid.getC();
				
				mc.unfocus();
				mc.txt_title.text = "";
				
				this.focusIndex = i;
				grid = obj.grid;
				mc = obj.mc;
				
				// change position and such
				var maskStartPoint:Number = this.maskMC._y;
				var deckStartPoint:Number = mc._y + this.deckMC._y;
				
				var diff:Number = deckStartPoint - maskStartPoint;
				
				if (diff < 0)
				{
					// move down
					this.deckMC._y -= diff;
				}
				
				mc.focus();
				grid.highlight(grid._top + index);
				this.pointerMC._y = this.deckMC._y + mc._y + (mc._height / 2);
				
				return false;
			}
		}
		
		return true;
	}
	
	private function overBottomCB(o:Object):Boolean
	{
		if (this.focusIndex >= TOTAL_ROW - 1)
		{
			return true;
		}
		
		var obj:Object = null;
		var obj2:Object = null;
		var mc:MovieClip = null;
		var grid:GridLite = null;
		for (var i:Number = this.focusIndex + 1; i < TOTAL_ROW; i ++)
		{
			obj = this.getGridAndParentMC(i);
			if (obj.grid.data.length > 0)
			{
				obj2 = this.getGridAndParentMC(this.focusIndex);
				mc = obj2.mc;
				grid = obj2.grid;
				
				var index:Number = grid.getC();
				
				mc.unfocus();
				mc.txt_title.text = "";
				
				this.focusIndex = i;
				grid = obj.grid;
				mc = obj.mc;
				
				// change position and such
				var maskEndPoint:Number = this.maskMC._y + this.maskMC._height;
				var deckEndPoint:Number = mc._y + mc._height + this.deckMC._y;
				
				var diff:Number = maskEndPoint - deckEndPoint;
				if (diff < 0)
				{
					// move up
					this.deckMC._y += diff;
				}
				
				mc.focus();
				grid.highlight(grid._top + index);
				
				this.pointerMC._y = this.deckMC._y + mc._y + (mc._height / 2);
				
				return false;
			}
		}
		
		return true;
	}
	
	private function keyDownCB(o:Object):Void
	{
		var keyCode:Number = o.keyCode;
		
		switch (keyCode)
		{
			case Key.BACK:
				this.overLeftCB();
				break;
		}
	}
	
	//--------------------------------------------- Util Function -----------------------------------------
	
	private function getGridAndParentMC(index:Number):Object
	{
		if (index < 0 || index > TOTAL_ROW - 1)
		{
			return null;
		}
		
		if (index == INDEX_MOVIE)
		{
			return { grid:this.movieGrid, mc:this.deckMC.mc_movieSearch, config:this.config.movieConfig };
		}
		
		if (index == INDEX_TV_SHOW)
		{
			return { grid:this.tvShowGrid, mc:this.deckMC.mc_tvShowSearch, config:this.config.tvShowConfig };
		}
		
		if (index == INDEX_EPISODE)
		{
			return { grid:this.episodeGrid, mc:this.deckMC.mc_episodeSearch, config:this.config.episodeConfig };
		}
		
		if (index == INDEX_ARTIST)
		{
			return { grid:this.artistGrid, mc:this.deckMC.mc_artistSearch, config:this.config.artistConfig };
		}
		
		if (index == INDEX_ALBUM)
		{
			return { grid:this.albumGrid, mc:this.deckMC.mc_albumSearch, config:this.config.albumConfig };
		}
		
		if (index == INDEX_TRACK)
		{
			return { grid:this.trackGrid, mc:this.deckMC.mc_trackSearch, config:this.config.trackConfig };
		}
		
		if (index == INDEX_ACTOR)
		{
			return { grid:this.actorGrid, mc:this.deckMC.mc_actorSearch, config:this.config.actorConfig };
		}
	}
	
	private function cleanup():Void
	{
		this.deckMC._y = this.oriY;
		this.keyword = null;
		this.isAvailable = false;
		this.titleMarquee.stop();
		
		Share.api.disposeRequest("search_1");
		Share.api.disposeRequest("search_2");
		Share.api.disposeRequest("search_3");
		
		var obj:Object = null;
		var grid:GridLite = null;
		var mc:MovieClip = null;
		
		for (var i:Number = 0; i < TOTAL_ROW; i ++)
		{
			obj = this.getGridAndParentMC(i);
			grid = obj.grid;
			grid.clear();
			grid.data = [];
			
			mc = obj.mc;
			
			mc.txt_title.text = "";
			mc.unfocus();
		}
	}
	
	private function checkDeckAvailability():Void
	{
		var grid:GridLite = null;
		var mc:MovieClip = null;
		var o:Object = null;
		var nodata:Boolean = true;
		for (var i:Number = 0; i < TOTAL_ROW; i ++)
		{
			o = this.getGridAndParentMC(i);
			grid = o.grid;
			mc = o.mc;
			
			if (grid.data.length < 1)
			{
				// no data?
				mc._visible = false;
				mc.skip = true;
			}
			else
			{
				mc._visible = true;
				mc.skip = false;
				nodata = false;
			}
		}
		
		this.alignAllDeckMC();
		
		if (nodata)
		{
			// show error message
			this.errorTF.htmlText = Share.getString("no_data");
			this.isAvailable = false;
			this.deckMC._visible = false;
		}
		else
		{
			this.isAvailable = true;
			this.deckMC._visible = true;
		}
		
	}
	
	private function alignAllDeckMC():Void
	{
		var gap:Number = this.config.valignGap;
		var components:Array = new Array();
		for (var i:Number = 0; i < TOTAL_ROW; i ++)
		{
			components.push(this.getGridAndParentMC(i).mc);
		}
		
		ComponentUtils.alignComponents(components, { vgap:gap, hgap:0, alignVertical:true } );
	}
	
	//--------------------------------------------------------------- Playback ------------------------------------------------
	private function playlistLoaded(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		if (success)
		{
			Share.PLAYER.startBatchPlayback(data, userparams.playIndex - 1, false, userparams.key, null);
		}
	}
}