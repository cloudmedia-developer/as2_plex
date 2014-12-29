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
* Class Description: The video deck to be shown on main menu
*
***************************************************/
import com.syabas.as2.plex.api.API;
import com.syabas.as2.plex.component.DeckBase;
import com.syabas.as2.plex.model.*;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Grid2;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
class com.syabas.as2.plex.component.VideoDeck extends DeckBase
{
	private var grid1:Grid2 = null;
	private var grid2:Grid2 = null;
	
	private var loadPath:String = null;			// The path to load the data
	private var loadKey:String = null;			// The key to load the data
	
	private var focusIndex:Number = -1;
	private var id:String = null;
	
	private var identifier:String = null;
	
	private var isGrid1Loaded:Boolean = false;
	private var isGrid2Loaded:Boolean = false;
	
	private var container:ContainerModel = null;
	
	public function destroy():Void
	{
		delete this.loadKey;
		delete this.loadPath;
		
		this.grid1.clear();
		this.grid1.destroy();
		delete this.grid1;
		
		this.grid2.clear();
		this.grid2.destroy();
		delete this.grid2;
		
		delete this.focusIndex;
		delete this.identifier;
		
		delete this.container;
		
		super.destroy();
	}
	
	public function VideoDeck(mc:MovieClip)
	{
		super(mc);
		this.deckMC.txt_group1.htmlText = Share.getString("on_deck");
		this.deckMC.txt_group2.htmlText = Share.getString("recently_added");
		
		this.config = Share.APP_SETTING.mainMenuConfig.videoDeckConfig;
		
		this.createGrid();
	}
	
	/*
	 * Overwrite super class
	 */
	public function available():Boolean
	{
		return this.deckMC._visible;
	}
	
	/*
	 * Overwrite super class
	 */
	public function showDeck(item:MediaModel, pointerMC:MovieClip):Void
	{
		this.isShown = true;
		this.isGrid1Loaded = false;
		this.isGrid2Loaded = false;
		
		this.pointerMC = pointerMC;
		pointerMC._visible = false;
		
		this.loadPath = "/library/sections/";
		this.loadKey = item.key;
		
		this.grid1.clear();
		this.grid1.totalRecord = 100;
		this.grid1.createUI();
		
		this.grid2.clear();
		this.grid2.totalRecord = 100;
		this.grid2.createUI();
	}
	
	/*
	 * Overwrite super class
	 */
	public function hideDeck():Void
	{
		this.focusIndex = -1;
		this.isShown = false;
		this.deckMC._visible = false;
		this.grid1.clear();
		this.grid2.clear();
	}
	
	/*
	 * Overwrite super class
	 */
	public function enable():Void
	{
		if (this.focusIndex == -1)
		{
			//this.focusIndex = 0;
			if (this.isGrid1Loaded == true && this.grid1.hasData())
			{
				this.focusIndex = 0;
			}
			else if (this.isGrid2Loaded == true && this.grid2.hasData())
			{
				this.focusIndex = 1;
			}
		}
		if (this.focusIndex == 0)
		{
			this.grid1.highlight();
		}
		else if (this.focusIndex == 1)
		{
			this.grid2.highlight();
		}
		
		this.pointerMC._visible = (this.focusIndex > -1);
	}
	
	/*
	 * Overwrite super class
	 */
	public function disable():Void
	{
		this.grid1.unhighlight();
		this.grid2.unhighlight();
		
		this.pointerMC._visible = false;
		this.titleMarquee.stop();
		this.deckMC.txt_title.text = "";
		
		this.redMC._visible = false;
		this.greenMC._visible = false;
		this.infoMC._visible = false;
	}
	
	//---------------------------------------- Grid ----------------------------------------
	private function createGrid():Void
	{
		var row:Number = 2;
		var column:Number = this.config.itemColumn;
		var mcArrayAll:Array = UI.attachMovieClip( { parentMC:this.deckMC, rSize:row, cSize:column } );
		
		this.grid1 = new Grid2();
		
		this.grid1.xMCArray = [mcArrayAll[0]];
		this.grid1.hlCB = Delegate.create(this, this.cellHLCB);
		this.grid1.unhlCB = Delegate.create(this, this.cellUnHLCB);
		this.grid1.onHLStopCB = Delegate.create(this, this.cellHLStopCB);
		this.grid1.onItemUpdateCB = Delegate.create(this, this.cellUpdateCB);
		this.grid1.onItemClearCB = Delegate.create(this, this.cellClearCB);
		this.grid1.onEnterCB = Delegate.create(this, this.cellOnEnterCB);
		this.grid1.overLeftCB = Delegate.create(this, this.overLeftCB);
		this.grid1.loadDataCB = Delegate.create(this, this.deckLoadDataCB);
		this.grid1.overBottomCB = Delegate.create(this, this.overBottomCB);
		this.grid1.onItemShowCB = Delegate.create(this, this.cellOnShowCB);
		this.grid1.onKeyDownCB = Delegate.create(this, this.keyDownCB);
		
		this.grid1.totalRecord = 100;
		this.grid1.xMaxLoad = 3;
		this.grid1.xLoadSize = 30;
		this.grid1.xWrap = false;
		this.grid1.xWrapLine = false;
		this.grid1.xHoriz = true;
		this.grid1.xHLStopTime = 1000;
		this.grid1.xEnablePageMove = true;
		this.grid1.xScroll = Grid2.SCROLL_PAGE;
		
		this.grid2 = new Grid2();
		
		this.grid2.xMCArray = [mcArrayAll[1]];
		this.grid2.hlCB = Delegate.create(this, this.cellHLCB);
		this.grid2.unhlCB = Delegate.create(this, this.cellUnHLCB);
		this.grid2.onHLStopCB = Delegate.create(this, this.cellHLStopCB);
		this.grid2.onItemUpdateCB = Delegate.create(this, this.cellUpdateCB2);
		this.grid2.onItemClearCB = Delegate.create(this, this.cellClearCB);
		this.grid2.onEnterCB = Delegate.create(this, this.cellOnEnterCB);
		this.grid2.overLeftCB = Delegate.create(this, this.overLeftCB);
		this.grid2.loadDataCB = Delegate.create(this, this.recentLoadDataCB);
		this.grid2.overTopCB = Delegate.create(this, this.overTopCB);
		this.grid2.onItemShowCB = Delegate.create(this, this.cellOnShowCB2);
		this.grid2.onKeyDownCB = Delegate.create(this, this.keyDownCB);
		
		this.grid2.totalRecord = 100;
		this.grid2.xMaxLoad = 3;
		this.grid2.xLoadSize = 30;
		this.grid2.xWrap = false;
		this.grid2.xWrapLine = false;
		this.grid2.xHoriz = true;
		this.grid2.xHLStopTime = 1000;
		this.grid2.xEnablePageMove = true;
		this.grid2.xScroll = Grid2.SCROLL_PAGE;
		
		this.grid1.clear();
		this.grid2.clear();
	}
	
	private function deckLoadDataCB(startIndex:Number, loadSize:Number):Void
	{
		var key:String = this.loadKey + (Util.endsWith(this.loadKey, "/") ? "onDeck" : "/onDeck");
		key = Share.getPaginationKey(key, startIndex, loadSize);
		
		Share.api.load(key, this.loadPath, Share.systemGateway, { loadTarget:"deck", key:this.loadKey }, Delegate.create(this, this.dataOnLoaded), "deck");
	}
	
	private function recentLoadDataCB(startIndex:Number, loadSize:Number):Void
	{
		var key:String = this.loadKey + (Util.endsWith(this.loadKey, "/") ? "recentlyAdded" : "/recentlyAdded");
		key = Share.getPaginationKey(key, startIndex, loadSize);
		
		Share.api.load(key, this.loadPath, Share.systemGateway, { loadTarget:"recent", key:this.loadKey }, Delegate.create(this, this.dataOnLoaded), "recent");
	}
	
	private function dataOnLoaded(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		if (this.isShown != true)
		{
			return;
		}
		
		if (userparams.key != this.loadKey)
		{
			return;
		}
		
		this.identifier = data.identifier;
		this.container = data;
		
		var target:String = userparams.loadTarget;
		
		if (this.isGrid1Loaded == false && target == "deck")
		{
			this.isGrid1Loaded = true;
		}
		
		if (this.isGrid2Loaded == false && target == "recent")
		{
			this.isGrid2Loaded = true;
		}
		
		if (success)
		{
			this.id = data.identifier;
			if (data.items.length > 0)
			{
				this.deckMC._visible = true;
			}
			
			if (target == "deck")
			{
				this.grid1.onLoadDataCB(data.items, data.size);
			}
			else
			{
				this.grid2.onLoadDataCB(data.items, data.size);
			}
			
		}
		else
		{
			if (target == "deck")
			{
				this.grid1.skipLoadData();
			}
			else
			{
				this.grid2.skipLoadData();
			}
		}
		
		if (target == "deck")
		{
			if (this.focusIndex == 0)
			{
				if (!this.grid1.hasData())
				{
					// no item to highlight, back to menu
					this.overLeftCB( { } );
				}
			}
			else
			{
				this.grid1.unhighlight();
			}
		}
		else
		{
			if (this.focusIndex == 1)
			{
				if (!this.grid2.hasData())
				{
					// no item to highlight, back to menu
					this.overLeftCB( { } );
				}
			}
			else
			{
				this.grid2.unhighlight();
			}
		}
	}
	
	private function cellUpdateCB(o:Object):Void
	{
		if (o.data.mcName == o.mc._name)
		{
			return;
		}
		
		this.updateCell(o);
		if (o.dataIndex == this.grid1._hl)
		{
			o.mc.gotoAndStop("unhl");
			o.mc.gotoAndStop("hl");
		}
	}
	
	private function cellUpdateCB2(o:Object):Void
	{
		if (o.data.mcName == o.mc._name)
		{
			return;
		}
		
		this.updateCell(o);
		if (o.dataIndex == this.grid2._hl)
		{
			o.mc.gotoAndStop("unhl");
			o.mc.gotoAndStop("hl");
		}
	}
	
	private function updateCell(o:Object):Void
	{
		if (o.data != null && o.data != undefined)
		{
			var thumbURL:String = o.data.thumbnail;
			if (o.data.type == MediaModel.CONTENT_TYPE_EPISODE)
			{
				o.mc.txt_title.htmlText = "S " + o.data.parentIndex + " " + Share.SEPARATOR_CHARACTER + " E " + o.data.index;
				o.mc.mc_titleBar._visible = true;
				
				if (o.data.grandParentThumbnail != null)
				{
					thumbURL = o.data.grandParentThumbnail;
				}
				else if (o.data.parentThumbnail != null)
				{
					thumbURL = o.data.parentThumbnail;
				}
			}
			else
			{
				o.mc.txt_title.text = "";
				o.mc.mc_titleBar._visible = false;
			}
			
			thumbURL = Share.getResourceURL(thumbURL);
			
			// Create a mask for thumbnail
			if (o.mc["mc_thumbnailMaskFor_" + o.mc.mc_thumbnail._name] == null || o.mc["mc_thumbnailMaskFor_" + o.mc.mc_thumbnail._name] == undefined)
			{
				Share.createMask(o.mc, o.mc.mc_thumbnail, this.config.itemThumbnailConfig);
			}
			
			Share.loadThumbnail(o.mc._name, o.mc.mc_thumbnail, thumbURL, this.config.itemThumbnailConfig);
			
			o.mc._visible = true;
			
			// Change the watched icon
			if (o.data.viewCount > 0)
			{
				o.mc.mc_watchedIcon._visible = false;
			}
			else if (o.data.viewOffset > 0)
			{
				o.mc.mc_watchedIcon._visible = true;
				o.mc.mc_watchedIcon.gotoAndStop("half");
			}
			else
			{
				o.mc.mc_watchedIcon._visible = true;
				o.mc.mc_watchedIcon.gotoAndStop("full");
			}
		}
	}
	
	private function cellClearCB(o:Object):Void
	{
		var thumbnailMC:MovieClip = o.mc.mc_thumbnail.mc_thumb;
		Share.imageLoader.unload(o.mc._name, thumbnailMC);
		
		o.mc.txt_title.text = "";
		o.mc._visible = false;
		o.mc.mc_watchedIcon._visible = false;
	}
	
	private function cellHLCB(o:Object):Void
	{
		if (this.titleMarquee.isRunning())
		{
			this.titleMarquee.stop();
		}
		
		o.mc.gotoAndStop("hl");
		this.pointerMC._y = this.config.pointerYValue[this.focusIndex];
		this.clearFanartCB();
		
		if (o.data != null && o.data != undefined)
		{
			if (o.data.type == MediaModel.CONTENT_TYPE_EPISODE)
			{
				this.deckMC.txt_title.htmlText = "<FONT COLOR='" + Share.APP_SETTING.mainMenuConfig.highlightTextColor + "'>" + Share.returnStringForDisplay(o.data.grandParentTitle) + "</FONT> " + 
													Share.SEPARATOR_CHARACTER + " " + Share.returnStringForDisplay(o.data.originalAirDate) + " " + Share.SEPARATOR_CHARACTER + " " + "<FONT COLOR='" + 
													Share.APP_SETTING.mainMenuConfig.highlightTextColor + "'>" + Share.returnStringForDisplay(o.data.title) + "</FONT> " + Share.SEPARATOR_CHARACTER + " " 
													+ Share.convertTime(o.data.duration);
			}
			else
			{
				this.deckMC.txt_title.htmlText = "<FONT COLOR='" + Share.APP_SETTING.mainMenuConfig.highlightTextColor + "'>" + Share.returnStringForDisplay(o.data.title) + "</FONT> " + 
													Share.SEPARATOR_CHARACTER + " " + Share.returnStringForDisplay(o.data.year) + " " + Share.SEPARATOR_CHARACTER + " " + Share.convertTime(o.data.duration);
			}
			
			//Share.startMarquee(this.titleMarquee, this.deckMC.txt_title, this.config.titleMarqueeConfig);
			var media:MediaModel = o.data;
			var fanartURL:String = o.data.art;
			
			if (fanartURL != null && fanartURL != undefined)
			{
				fanartURL = Share.getResourceURL(fanartURL);
				this.loadFanartCB(fanartURL);
			}
			
			var align:Array = [this.homeMC, this.infoMC];
			this.infoMC._visible = true;
			
			if (media.viewCount > 0)
			{
				//watched
				align.push(this.greenMC);
				
				this.redMC._visible = false;
				this.greenMC._visible = true;
			}
			else
			{
				if (media.viewOffset > 0)
				{
					// watched halfway
					align.push(this.greenMC);
					align.push(this.redMC);
					
					this.redMC._visible = true;
					this.greenMC._visible = true;
				}
				else
				{
					// not watched before
					align.push(this.redMC);
					
					this.redMC._visible = true;
					this.greenMC._visible = false;
				}
			}
			
			Share.alignIndicators(align);
		}
	}
	
	private function cellHLStopCB(o:Object):Void
	{
		Share.startMarquee(this.titleMarquee, this.deckMC.txt_title, this.config.titleMarqueeConfig);
	}
	
	private function cellUnHLCB(o:Object):Void
	{
		o.mc.gotoAndStop("unhl");
	}
	
	private function cellOnShowCB(o:Object):Void
	{
		o.data.mcName = null;
		var thumbnailMC:MovieClip = o.mc.mc_thumbnail.mc_thumb;
		Share.imageLoader.unload(o.mc._name, thumbnailMC);
		
		thumbnailMC.removeMovieClip();
		
		if (o.data == undefined || o.data == null)
		{
			o.mc.txt_title.text = "";
			o.mc.mc_watchedIcon._visible = false;
		}
		else
		{
			this.cellUpdateCB(o);
			o.data.mcName = o.mc._name;
		}
	}
	
	private function cellOnShowCB2(o:Object):Void
	{
		o.data.mcName = null;
		var thumbnailMC:MovieClip = o.mc.mc_thumbnail.mc_thumb;
		Share.imageLoader.unload(o.mc._name, thumbnailMC);
		
		thumbnailMC.removeMovieClip();
		
		if (o.data == undefined || o.data == null)
		{
			o.mc.txt_title.text = "";
			o.mc.mc_watchedIcon._visible = false;
		}
		else
		{
			this.cellUpdateCB2(o);
			o.data.mcName = o.mc._name;
		}
	}
	
	private function cellOnEnterCB(o:Object):Void
	{
		if (this.onItemSelected(o.data, this.id))
		{
			this.disable();
		}
	}
	
	private function overLeftCB(o:Object):Void
	{
		this.overLeft();
		this.disable();
	}
	
	private function overTopCB(o:Object):Boolean
	{
		if ((!this.grid1.hasData() && this.isGrid1Loaded == true) || this.isGrid1Loaded == false)
		{
			// nothing to highlight at top
			return true;
		}
		this.focusIndex = 0;
		var hl:Number = this.grid1._top + this.grid2.getC(this.grid2._hl);
		this.grid1.highlight(hl);
		return false;
	}
	
	private function overBottomCB(o:Object):Boolean
	{
		if ((!this.grid2.hasData() && this.isGrid2Loaded == true) || this.isGrid2Loaded == false)
		{
			// nothing to highlight at bottom
			return true;
		}
		
		this.focusIndex = 1;
		var hl:Number = this.grid2._top + this.grid1.getC(this.grid1._hl);
		this.grid2.highlight(hl);
		return false;
	}
	
	private function keyDownCB(o:Object):Void
	{
		var keyCode:Number = o.keyCode;
		
		var mc:MovieClip = o.mc;
		var media:MediaModel = o.data;
		
		switch (keyCode)
		{
			case Key.BACK:
				this.overLeftCB();
				break;
			case Key.RED:
				// mark as watched
				if (media.viewCount < 1)
				{
					this.disable();
					Share.api.setWatched(Share.systemGateway, media.ratingKey, this.identifier, Delegate.create(this, this.refreshCurrentItem));
					
					var thumbConfig:Object = this.config.itemThumbnailConfig;
					var size:Number = Math.min(thumbConfig.width, thumbConfig.height) / 2;
					
					this.loadingMC.removeMovieClip();
					this.loadingMC = mc.attachMovie("loadingMC", "mc_loading", mc.getNextHighestDepth(), { _x:mc.mc_thumbnail._x + (thumbConfig.width / 2), _y:mc.mc_thumbnail._y + (thumbConfig.height / 2), _width:size, _height:size } );
				}
				break;
			case Key.GREEN:
				// mark as unwatched
				if ((media.viewCount > 0) || (media.viewCount < 1 && media.viewOffset > 0))
				{
					this.disable();
					Share.api.setUnwatched(Share.systemGateway, media.ratingKey, this.identifier, Delegate.create(this, this.refreshCurrentItem));
					
					var thumbConfig:Object = this.config.itemThumbnailConfig;
					var size:Number = Math.min(thumbConfig.width, thumbConfig.height) / 2;
					
					this.loadingMC.removeMovieClip();
					this.loadingMC = mc.attachMovie("loadingMC", "mc_loading", mc.getNextHighestDepth(), { _x:mc.mc_thumbnail._x + (thumbConfig.width / 2), _y:mc.mc_thumbnail._y + (thumbConfig.height / 2), _width:size, _height:size } );
				}
				break;
			case Key.INFO:
				if (media.type == MediaModel.CONTENT_TYPE_MOVIE)
				{
					// show movie info
					this.disable();
					Share.POPUP.showMovieInfoPopup(media, this.container, Delegate.create(this, this.enable));
				}
				else
				{
					// show episode info
					this.disable();
					Share.POPUP.showEpisodeInfoPopup(media, this.container, Delegate.create(this, this.enable));
				}
				break;
		}
	}
	
	
	public function refreshCurrentItem():Void
	{
		/*var grid:Grid2 = (this.focusIndex == 0 ? this.grid1 : this.grid2);
		this.disable();
		var data:MediaModel = MediaModel(grid.getData());
		var key:String = data.key;
		if (data.itemType == MediaModel.TYPE_DIRECTORY)
		{
			key = key.substring(0, key.lastIndexOf("/"));
		}
		
		Share.api.load(key, this.loadPath, Share.systemGateway, { index:grid._hl, grid:grid }, Delegate.create(this, this.onRefresh), "refresh");*/
		this.loadingMC.removeMovieClip();
		delete this.loadingMC;
		this.loadingMC = null;
		
		this.disable();
		
		var grid:Grid2 = (this.focusIndex == 0 ? this.grid1 : this.grid2);
		var grid_unhl:Grid2 = (this.focusIndex == 0 ? this.grid2 : this.grid1);
		var hl1:Number = this.grid1._hl;
		var hl2:Number = this.grid2._hl;
		
		this.grid1.clear();
		this.grid2.clear();
		this.grid1.createUI(hl1);
		this.grid2.createUI(hl2);
		
		grid.highlight();
		grid_unhl.unhighlight();
	}
	
	/*private function onRefresh(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		if (success)
		{
			if (data.items.length > 0)
			{
				var index:Number = userparams.index;
				var grid:Grid2 = userparams.grid;
				
				grid.setData(data.items[0]);
				this.cellUpdateCB( { mc:grid.getMC(), data:data.items[0], dataIndex:index } );
			}
		}
		else
		{
			
		}
		
		this.enable();
	}*/
}