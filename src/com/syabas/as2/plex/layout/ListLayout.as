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
* Class Description: Base Class for all kind of List Layout in the app
*
***************************************************/

import com.syabas.as2.plex.component.ComponentUtils;
import com.syabas.as2.plex.interfaces.LayoutInterface;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Grid2;
import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;

class com.syabas.as2.plex.layout.ListLayout implements LayoutInterface
{
	private var parentMC:MovieClip = null;				// The parent movie clip to attach the list
	private var listMC:MovieClip = null;				// The list movie clip
	private var loadingMC:MovieClip = null;				// The loading animation icon movie clip
	
	private var fanartHolderMC:MovieClip = null;		// The holder / parent movie clip to contain all fan art loading
	private var fanart1MC:MovieClip = null;				// The currently loaded fanart movie clip
	private var fanart2MC:MovieClip = null;				// The currently loading fanart movie clip
	private var categoryArt:MovieClip = null;			// The fanart movie clip which contains the parent's fan art
	
	private var grid:Grid2 = null;
	private var titleMarquee:Marquee = null;
	
	private var fn:Object = null;
	private var config:Object = null;					// Configuration object
	private var loads:Object = null;					// To track different data loads (for audio and photo to start playback)
	private var loadSequence:Array = null;
	private var container:ContainerModel = null;		// The container of the list items
	
	private var itemSelectedCallback:Function = null;	// Callback when an item is selected
	private var returnCallback:Function = null;			// Callback when user press "Return" button
	private var homeCallback:Function = null;			// Callback when user press "Blue" button
	private var switchLayoutCallback:Function = null;	// Callback when user switch layout
	
	private var loadingKey:String = null;				// The key to load more data
	private var loadingPath:String = null;				// The path to load more data
	
	private var historyHL:Number = null;
	private var readied:Boolean = false;
	
	public function destroy():Void
	{
		this.clearImageLoad();
		
		this.grid.destroy();
		delete this.grid;
		this.grid = null;
		
		this.fanartHolderMC.removeMovieClip();
		delete this.fanartHolderMC;
		this.fanartHolderMC = null;
		
		delete this.loads;
		delete this.loadSequence;
		
		this.titleMarquee.stop();
		delete this.titleMarquee;
		this.titleMarquee = null;
		
		delete this.fanart1MC;
		delete this.fanart2MC;
		
		delete this.fn;
		delete this.categoryArt;
		delete this.container;
		
		delete this.itemSelectedCallback;
		delete this.returnCallback;
		
		this.parentMC = null;
		
		this.listMC.removeMovieClip();
		delete this.listMC;
		this.listMC = null;
		
		delete this.config;
		this.config = null;
		
		delete this.loadingKey;
		delete this.loadingPath;
	}
	
	public function ListLayout(mc:MovieClip)
	{
		this.parentMC = mc;
		
		this.fanartHolderMC = mc.createEmptyMovieClip("mc_listFanartHolder", mc.getNextHighestDepth());
		this.categoryArt = this.fanartHolderMC.createEmptyMovieClip("mc_categoryArt", this.fanartHolderMC.getNextHighestDepth());
		this.fn = { fanartOnLoad:Delegate.create(this, this.fanartOnLoad) };
		
		this.titleMarquee = new Marquee();
		this.config = Share.APP_SETTING.listConfig;
	}
	
	/*
	 * Overwrite super class
	 */
	public function renderItems(container:ContainerModel):Void
	{
		Share.PLAYER.moveInfoPanel(this.config.playbackFloatWindowConfig);
		
		delete this.loads;
		delete this.loadSequence;
		
		this.loads = new Object();
		this.loadSequence = [];
		
		this.readied = false;
		this.historyHL = null;
		
		this.clearImageLoad();
		this.titleMarquee.stop();
		
		this.container = container;
		
		if (this.listMC == null)
		{
			this.createList();
			this.createGrid();
		}
		
		this.grid.clear();		// clear previous grid data if previous load is from the same layout
		this.grid.createUI();
		
		if (this.container.art != null && this.container.art != undefined && Share.hideBG != true)
		{
			Share.imageLoader.unload("listCategoryFanart", this.categoryArt, null);
			
			var url:String = Share.getResourceURL(this.container.art);
			url = Share.getPhotoTranscodeURL(url, 1280, 720);
			Share.imageLoader.load("listCategoryFanart", url, this.categoryArt, { scaleMode:1, scaleProps: { center:true, actualSizeOption:3, width:1280, height:720 } } );
		}
		
		ComponentUtils.fitTextInTextField(this.listMC.mc_exit.txt, Share.getString("exit"), false);
		ComponentUtils.fitTextInTextField(this.listMC.mc_back.txt, Share.getString("back"), false);
		ComponentUtils.fitTextInTextField(this.listMC.mc_blue.txt, Share.getString("backToHome"), false);
		
		this.showTitle(container);
		this.showItemCount(container);
		Share.alignIndicators([this.listMC.mc_exit, this.listMC.mc_back, this.listMC.mc_blue]);
	}
	
	/*
	 * Overwrite super class
	 */
	public function setLoadingParameter(key:String, path:String):Void
	{
		this.loadingKey = key;
		this.loadingPath = path;
	}
	
	/*
	 * Overwrite super class
	 */
	public function disable():Void
	{
		this.grid.unhighlight();
	}
	
	/*
	 * Overwrite super class
	 */
	public function enable():Void
	{
		this.grid.highlight();
	}
	
	/*
	 * Overwrite super class
	 */
	public function setCallback(cbObj:Object):Void
	{
		this.homeCallback = cbObj.homeCallback;
		this.returnCallback = cbObj.returnCallback;
		this.itemSelectedCallback = cbObj.itemSelectedCallback;
		this.switchLayoutCallback = cbObj.switchLayoutCallback;
	}
	
	/*
	 * Overwrite super class
	 */
	public function getClockTextField():TextField
	{
		return this.listMC.mc_topbar.txt_time;
	}
	
	/*
	 * Overwrite super class
	 */
	public function getHistoryRecordObject():Object
	{
		return { hl:this.grid._hl };
	}
	
	/*
	 * Overwrite super class
	 */
	public function restoreHistoryState(historyObj:Object):Void
	{
		if (historyObj.hl != null && historyObj.hl != undefined)
		{
			if (this.readied != true)
			{
				this.historyHL = historyObj.hl;
			}
			else
			{
				this.grid.highlight(historyObj.hl);
			}
		}
	}
	
	/*
	 * Clear all request to load images
	 */
	private function clearImageLoad():Void
	{
		Share.imageLoader.unload("listFanart", this.fanart1MC, null);
		Share.imageLoader.unload("listFanart", this.fanart2MC, null);
		Share.imageLoader.unload("listFanart", this.categoryArt, null);
	}
	
	/*
	 * Attach the list movie clip
	 */
	private function createList():Void
	{
		this.listMC.removeMovieClip();
		this.listMC = this.parentMC.attachMovie("listMC", "mc_list", this.parentMC.getNextHighestDepth());
	}
	
	private function createGrid():Void
	{
		var row:Number = this.config.row;
		var column:Number = this.config.column;
		
		if (isNaN(new Number(row)))
		{
			row = 1;
		}
		if (isNaN(new Number(column)))
		{
			column = 1;
		}
		
		this.grid = new Grid2();
		this.grid.xMCArray = UI.attachMovieClip( { parentMC:this.listMC, rSize:row, cSize:column } );
		this.grid.hlCB = Delegate.create(this, this.hlCB);
		this.grid.unhlCB = Delegate.create(this, this.unhlCB);
		this.grid.onHLStopCB = Delegate.create(this, this.hlStopCB);
		this.grid.onItemUpdateCB = Delegate.create(this, this.updateCB);
		this.grid.onItemClearCB = Delegate.create(this, this.clearCB);
		this.grid.onItemShowCB = Delegate.create(this, this.showCB);
		this.grid.onEnterCB = Delegate.create(this, this.enterCB);
		this.grid.onKeyDownCB = Delegate.create(this, this.keyDownCB);
		this.grid.loadDataCB = Delegate.create(this, this.loadDataCB);
		this.grid.xHLStopTime = 500;
		this.grid.xLoadSize = 50;
		this.grid.xMaxLoad = 10;
		this.grid.xHoriz = (this.config.horizontal == true);
		this.grid.xWrap = true;
		this.grid.xWrapLine = ((!this.grid.xHoriz && column > 1) || (this.grid.xHoriz && row > 1));
		this.grid.xEnablePageMove = true;
		this.grid.xScroll = Grid2.SCROLL_PAGE;
		this.grid.totalRecord = this.container.size;// row * column;
	}
	
	//------------------------- Grid Callback --------------------------------
	private function loadDataCB(startIndex:Number, loadSize:Number):Void
	{
		if (startIndex < this.container.items.length)
		{
			// Data already exists
			this.readied = true;
			var newArray:Array = this.container.items.slice(startIndex, startIndex + loadSize);
			
			this.listMC.mc_scrollbar.calculateBarHeight(this.container.size, this.grid._size);
			
			this.grid.onLoadDataCB(newArray, this.container.size);
			
			if (this.historyHL != null)
			{
				this.grid.highlight(this.historyHL);
				this.historyHL = null;
			}
			else
			{
				this.grid.highlight();
			}
		}
		else
		{
			// load next
			var key:String = Share.getPaginationKey(this.loadingKey, startIndex, loadSize);
			
			Share.api.load(key, this.loadingPath, Share.systemGateway, { start:startIndex }, Delegate.create(this, this.onDataLoaded), "listLoading");
		}
	}
	
	private function onDataLoaded(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		if (success)
		{
			this.readied = true;
			this.grid.onLoadDataCB(data.items, data.size);
			this.grid.highlight();
			this.listMC.mc_scrollbar.calculateBarHeight(data.size, this.grid._size);
			
			var startIndex = userparams.start;
			this.loads[startIndex + ""] = data;
			
			this.loadSequence.push(startIndex);
			
			while (this.loadSequence.length > this.grid.xMaxLoad)
			{
				// kick off 1
				var index = this.loadSequence.shift();
				delete this.loads[index + ""];
				this.loads[index + ""] = null;
			}
			
			if (this.historyHL != null)
			{
				this.grid.highlight(this.historyHL);
				this.historyHL = null;
			}
			else
			{
				this.grid.highlight();
			}
		}
		else
		{
			this.grid.skipLoadData();
		}
	}
	
	private function hlCB(o:Object):Void
	{
		o.mc.gotoAndStop("hl");
		this.listMC.mc_scrollbar.moveBarTo(this.grid._top, this.grid.totalRecord, this.grid._size);
		
		this.clearLoadedFanart();
	}
	
	private function hlStopCB(o:Object):Void
	{
		// start loading the fan art
		var url:String = o.data.art;
		this.loadFanart(url);
		
		this.startTitleMarquee(o.mc.txt_title);
	}
	
	private function showCB(o:Object):Void
	{
		o.data.mcName = null;
		if (o.data == null || o.data == undefined)
		{
			o.mc.gotoAndStop("unhl");
			o.mc.txt_title.text = Share.getString("loading");
		}
		else
		{
			this.updateCB(o);
			
			o.data.mcName = o.mc._name;
		}
	}
	
	private function unhlCB(o:Object):Void
	{
		o.mc.gotoAndStop("unhl");
		this.titleMarquee.stop();
	}
	
	private function updateCB(o:Object):Void
	{
		if (o.data.mcName == o.mc._name)
		{
			return;
		}
		
		o.mc.gotoAndStop("hl");
		o.mc.gotoAndStop("unhl");
		
		if (o.data != null && o.data != undefined)
		{
			o.mc.txt_title.htmlText = Share.returnStringForDisplay(o.data.title);
			if (Util.isBlank(o.data.title))
			{
				o.mc.txt_title.text = "-";
			}
		}
		else
		{
			o.mc.txt_title.htmlText = Share.getString("no_data");
		}
		
		if (o.dataIndex == this.grid._hl)
		{
			o.mc.gotoAndStop("unhl");
			o.mc.gotoAndStop("hl");
		}
	}
	
	private function clearCB(o:Object):Void
	{
		o.mc.txt_title.text = "";
	}
	
	private function enterCB(o:Object):Void
	{
		if (this.itemSelectedCallback(o.data, this.container.identifier))
		{			
			this.disable();
		}
	}
	
	private function keyDownCB(o:Object):Void
	{
		var keyCode:Number = o.keyCode;
		
		switch(keyCode)
		{
			case Key.BACK:
				this.grid.unhighlight();
				this.returnCallback();
				break;
			case Key.BLUE:
				this.grid.unhighlight();
				this.homeCallback();
				break;
		}
	}
	
	
	//------------------------------------------------- Fanart -----------------------------------------------------
	private function loadFanart(url:String):Void
	{
		if (Share.hideBG)
		{
			return;
		}
		if (this.fanart2MC != null)
		{
			Share.imageLoader.unload("listFanart", this.fanart2MC, null);
			this.fanart2MC.removeMovieClip();
			delete this.fanart2MC;
		}
		
		if (url != null && url != undefined)
		{
			url = Share.getResourceURL(url);
			url = Share.getPhotoTranscodeURL(url, 1280, 720);
			
			Share.imageLoader.unload("listFanart", this.fanart1MC, null);
			this.fanart1MC.removeMovieClip();
			
			this.fanart2MC = this.fanartHolderMC.createEmptyMovieClip("mc_listFanart_" + this.fanartHolderMC.getNextHighestDepth(), this.fanartHolderMC.getNextHighestDepth());
			Share.imageLoader.load("listFanart", url, this.fanart2MC, { scaleMode:1, scaleProps: { center:true, actualSizeOption:3, width:1280, height:720 }, doneCB:this.fn.fanartOnLoad } );
		}
		else if (this.fanart1MC != null)
		{
			Share.imageLoader.unload("listFanart", this.fanart1MC, null);
			this.fanart1MC.removeMovieClip();
			
			this.fanart1MC = null;
		}
	}
	
	private function fanartOnLoad(success:Boolean, o:Object):Void
	{
		if (success)
		{
			this.fanart1MC = this.fanart2MC;
			
			this.fanart2MC = null;
		}
	}
	
	
	//------------------------------------------------- UI ----------------------------------------------------
	private function createRatingMask(ratingStarMC:MovieClip):MovieClip
	{
		var ratingMaskMC = ratingStarMC.mc_mask;
		
		ratingStarMC.mc_star.setMask(ratingMaskMC);
		
		return ratingMaskMC;
	}
	
	private function showTitle(container:ContainerModel):Void
	{
		var title:String = "<FONT COLOR='" + Share.APP_SETTING.highlightTextColor + "'>" + Share.SEPARATOR_CHARACTER + "</FONT> ";
		var hasTitle:Boolean = false;
		if (!Util.isBlank(container.title1))
		{
			title += container.title1;
			hasTitle = true;
		}
		if (!Util.isBlank(container.title2))
		{
			title += (Util.isBlank(container.title1) ? "" : " : ") + container.title2;
			hasTitle = true;
		}
		
		if (!hasTitle)
		{
			if (!Util.isBlank(container.externalTitle))
			{
				title += container.externalTitle;
			}
		}
		
		this.listMC.mc_topbar.txt_title.htmlText = title;
	}
	
	private function showItemCount(container:ContainerModel):Void
	{
		var sizeStr:String = null;
		
		switch(container.viewGroup)
		{
			case ContainerModel.VIEW_GROUP_ALBUM:
				sizeStr = Share.getString("item_count_album");
				break;
			case ContainerModel.VIEW_GROUP_ARTIST:
				sizeStr = Share.getString("item_count_artist");
				break;
			case ContainerModel.VIEW_GROUP_MOVIE:
				sizeStr = Share.getString("item_count_movie");
				break;
			case ContainerModel.VIEW_GROUP_PHOTO:
				sizeStr = Share.getString("item_count_photo");
				break;
			case ContainerModel.VIEW_GROUP_TRACK:
				sizeStr = Share.getString("item_count_track");
				break;
			case ContainerModel.VIEW_GROUP_TV_EPISODE:
				sizeStr = Share.getString("item_count_episode");
				break;
			case ContainerModel.VIEW_GROUP_TV_SEASON:
				sizeStr = Share.getString("item_count_season");
				break;
			case ContainerModel.VIEW_GROUP_TV_SHOW:
				sizeStr = Share.getString("item_count_show");
				break;
			default:
				sizeStr = Share.getString("item_count_object");
				break;
		}
		
		sizeStr = "<FONT COLOR='" + Share.APP_SETTING.highlightTextColor + "'>" + Share.SEPARATOR_CHARACTER + "</FONT> " + sizeStr + " : <FONT COLOR='" + Share.APP_SETTING.highlightTextColor + "'>" + 
					container.size + "</FONT>";
		
		this.listMC.mc_topbar.txt_item.htmlText = sizeStr;
	}
	
	private function startTitleMarquee(tf:TextField):Void
	{
		this.titleMarquee.stop();
		Share.startMarquee(this.titleMarquee, tf, this.config.titleMarqueeConfig);
	}
	
	public function refreshCurrentItem():Void
	{
		this.disable();
		
		var data:MediaModel = MediaModel(this.grid.getData());
		var key:String = data.key;
		if (data.itemType == MediaModel.TYPE_DIRECTORY)
		{
			key = key.substring(0, key.lastIndexOf("/"));
		}
		
		Share.api.load(key, this.loadingPath, Share.systemGateway, { index:this.grid._hl }, Delegate.create(this, this.onRefresh), "refresh");
	}
	
	private function onRefresh(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		this.loadingMC.removeMovieClip();
		this.loadingMC = null;
		if (success)
		{
			if (data.items.length > 0)
			{
				var index:Number = userparams.index;
				
				if (index < this.container.items.length)
				{
					// update in container
					this.container.items[index] = data.items[0];
				}
				else
				{
					// update in loads
					var loadID:Number = Math.floor(index / this.grid.xLoadSize) * this.grid.xLoadSize;
					this.loads[loadID + ""].items[index - loadID] = data.items[0];
				}
				this.grid.setData(data.items[0]);
				this.updateCB( { mc:this.grid.getMC(), data:data.items[0], dataIndex:index } );
			}
		}
		else
		{
			
		}
		
		this.enable();
	}
	
	private function clearLoadedFanart():Void
	{
		Share.imageLoader.unload("listFanart", this.fanart1MC, null);
		Share.imageLoader.unload("listFanart", this.fanart2MC, null);
		
		this.fanart1MC.removeMovieClip();
		this.fanart2MC.removeMovieClip();
	}
	
	private function showLayoutChangePopup(array:Array, currentType:Number, callback:Function):Void
	{
		var newArr:Array = [];
		
		var len:Number = array.length;
		var obj:Object = null;
		
		for (var i:Number = 0; i < len; i ++)
		{
			obj = array[i];
			
			if (obj.type == currentType)
			{
				continue;
			}
			
			newArr.push( { title:Share.getString(obj.key), displayType:obj.type } );
		}
		
		var container:ContainerModel = new ContainerModel();
		container.items = newArr;
		
		Share.POPUP.showSelectionPopup(container, callback, Delegate.create(this, this.enable));
	}
}