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
* Class Description: TV Show banner List
*
***************************************************/
import com.syabas.as2.plex.component.ComponentUtils;
import com.syabas.as2.plex.layout.ListLayout;
import com.syabas.as2.plex.manager.AlphabertSwitchingManager;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.MediaElement;
import com.syabas.as2.plex.model.Constants;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
class com.syabas.as2.plex.layout.ShowBannerLayout extends ListLayout
{
	private var alphaSwitching:AlphabertSwitchingManager = null;
	private var isShowTitle:Boolean = false;
	
	private var restoreTitleTO:Number = null;
	
	public function destroy():Void
	{
		_global["clearTimeout"](this.restoreTitleTO);
		delete this.restoreTitleTO;
		
		this.alphaSwitching.destroy();
		delete this.alphaSwitching;
		
		this.isShowTitle = null;
		super.destroy();
	}
	
	public function ShowBannerLayout(mc:MovieClip, enableTitle:Boolean)
	{
		super(mc);
		this.config = Share.APP_SETTING.tvShowBannerConfig;
	}
	
	/*
	 * Overwrite super class
	 */
	public function renderItems(container:ContainerModel):Void
	{
		super.renderItems(container);
		this.isShowTitle = false;
		this.showHideTitle(this.isShowTitle);
		
		if (Util.startsWith(this.loadingKey, "all"))
		{
			this.alphaSwitching = new AlphabertSwitchingManager();
			this.alphaSwitching.init(this.loadingKey, this.loadingPath);
		}
		
		ComponentUtils.fitTextInTextField(this.listMC.mc_red.txt, Share.getString("indicator_mark_watched"));
		ComponentUtils.fitTextInTextField(this.listMC.mc_green.txt, Share.getString("indicator_mark_unwatched"));
		ComponentUtils.fitTextInTextField(this.listMC.mc_yellow.txt, Share.getString("indicator_switch_layout"));
		ComponentUtils.fitTextInTextField(this.listMC.mc_info.txt, Share.getString("showInfo"));
		
		
		Share.alignIndicators([this.listMC.mc_exit, this.listMC.mc_back, this.listMC.mc_info, this.listMC.mc_blue, this.listMC.mc_yellow]);
	}
	
	/*
	 * Overwrite super class
	 */
	private function createList():Void
	{
		this.listMC.removeMovieClip();
		this.listMC = this.parentMC.attachMovie("tvShowBannerMC", "mc_tvShowBanner", this.parentMC.getNextHighestDepth());
		
		this.listMC.mc_red._visible = false;
		this.listMC.mc_green._visible = false;
		
	}
	
	private function restoreTopTitle():Void
	{
		_global["clearTimeout"](this.restoreTitleTO);
		delete this.restoreTitleTO;
		
		this.showTitle(this.container);
		this.listMC.mc_topbar.txt_title.htmlText += " : " + Share.returnStringForDisplay(this.grid.getData().title);
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlStopCB(o:Object):Void
	{
		super.hlStopCB(o);
		
		var media:MediaModel = o.data;
		
		if (media == null || media == undefined)
		{
			return;
		}
		
		// change the info
		_global["clearTimeout"](this.restoreTitleTO);
		delete this.restoreTitleTO;
		
		this.restoreTitleTO = _global["setTimeout"](Delegate.create(this, this.restoreTopTitle), 3000);
	}
	
	private function hlCB(o:Object)
	{
		super.hlCB(o);
		
		var media:MediaModel = o.data;
		
		_global["clearTimeout"](this.restoreTitleTO);
		delete this.restoreTitleTO;
		
		this.listMC.mc_topbar.txt_title.htmlText = Share.returnStringForDisplay(media.title);
		
		var align:Array = [this.listMC.mc_exit, this.listMC.mc_back, this.listMC.mc_info, this.listMC.mc_blue, this.listMC.mc_yellow];
		if (media.type == MediaModel.CONTENT_TYPE_MOVIE)
		{
			
		}
		else
		{
			var watched:Number = media.viewedChildCount;
			var total:Number = media.childCount;
			
			this.listMC.mc_red._visible = false;
			this.listMC.mc_green._visible = false;
			
			if (watched > 0)
			{
				// watched some ?
				if (watched != total)
				{
					// not totally watched, add mark as watched
					align.push(this.listMC.mc_red);
					this.listMC.mc_red._visible = true;
				}
				
				// add mark as unwatched
				align.push(this.listMC.mc_green);
				this.listMC.mc_green._visible = true;
			}
			else
			{
				// totally not watched before
				align.push(this.listMC.mc_red);
				this.listMC.mc_red._visible = true;
			}
		}
		
		Share.alignIndicators(align);
	}
	
	/*
	 * Overwrite super class
	 */
	private function updateCB(o:Object):Void
	{
		if (o.data.mcName == o.mc._name)
		{
			return;
		}
		
		o.mc.txt_title = o.mc.mc_title.txt_title;
		super.updateCB(o);
		if (o.data != null && o.data != undefined)
		{
			var media:MediaModel = o.data;
			var url:String = media.banner;
			
			// create a mask for the thumbnail
			if (o.mc["mc_thumbnailMaskFor_" + o.mc.mc_thumbnail._name] == null || o.mc["mc_thumbnailMaskFor_" + o.mc.mc_thumbnail._name] == undefined)
			{
				Share.createMask(o.mc, o.mc.mc_thumbnail, this.config.itemThumbnailConfig);
			}
			
			// load thumbnail
			if (!Util.isBlank(url))
			{
				Share.loadThumbnail(o.mc._name, o.mc.mc_thumbnail, Share.getResourceURL(url), this.config.itemThumbnailConfig);
			}
			else
			{
				Share.imageLoader.unload(o.mc._name, o.mc.mc_thumbnail.mc_thumb, null);
				o.mc.mc_thumbnail.mc_thumb.removeMovieClip();
			}
			
			o.mc.mc_title.txt_title.htmlText = media.title;
			
			if (media.type == MediaModel.CONTENT_TYPE_MOVIE)
			{
				// change the watched icon
				if (media.viewCount > 0)
				{
					o.mc.mc_watchedIcon._visible = false;
				}
				else
				{
					if (media.viewOffset > 0)
					{
						// watched halfway
						o.mc.mc_watchedIcon._visible = true;
						o.mc.mc_watchedIcon.gotoAndStop("half");
					}
					else
					{
						// not watched before
						o.mc.mc_watchedIcon._visible = true;
						o.mc.mc_watchedIcon.gotoAndStop("full");
					}
				}
			}
			else
			{
				o.mc.mc_watchedIcon._visible = false;
			}
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function clearCB(o:Object):Void
	{
		super.clearCB(o);
		var thumbnailMC:MovieClip = o.mc.mc_thumbnail.mc_thumb
		Share.imageLoader.unload(o.mc._name, thumbnailMC);
		
		thumbnailMC.removeMovieClip();
		
		o.mc._visible = false;
	}
	
	/*
	 * Overwrite super class
	 */
	private function showCB(o:Object):Void
	{
		super.showCB(o);
		o.mc._visible = true;
		
		if (o.data == null || o.data == undefined)
		{
			var thumbnailMC:MovieClip = o.mc.mc_thumbnail.mc_thumb
			Share.imageLoader.unload(o.mc._name, thumbnailMC);
			
			thumbnailMC.removeMovieClip();
		}
		else
		{
			this.updateCB(o);
		}
	}
	
	private function keyDownCB(o:Object):Void
	{
		var keyCode:Number = o.keyCode;
		var media:MediaModel = MediaModel(this.grid.getData());
		var mc:MovieClip = this.grid.getMC();
		
		var asciiCode:Number = o.asciiCode;
		if (asciiCode > 47 && asciiCode < 58)
		{
			var index:Number = this.alphaSwitching.tap(asciiCode);
			
			if (index > -1)
			{
				// got index
				this.grid.unhighlight();
				this.grid.highlight(index);
				return;
			}
		}
		
		switch (keyCode)
		{
			case Key.RED:
				// mark as watched
				if (media.viewedChildCount != media.childCount && media.childCount > 0)
				{
					this.disable();
					Share.POPUP.showConfirmationPopup(Share.getString("indicator_mark_watched"), Share.getString("message_mark_watched"), Delegate.create(this, function()
					{
						var thumbConfig:Object = this.config.itemThumbnailConfig;
						var size:Number = Math.min(thumbConfig.width, thumbConfig.height) / 2;
						var mc:MovieClip = this.grid.getMC();
						
						this.loadingMC.removeMovieClip();
						this.loadingMC = mc.attachMovie("loadingMC", "mc_loading", mc.getNextHighestDepth(), { _x:mc.mc_thumbnail._x + (thumbConfig.width / 2), _y:mc.mc_thumbnail._y + (thumbConfig.height / 2), _width:size, _height:size } );
						
						Share.api.setWatched(Share.systemGateway, media.ratingKey, this.container.identifier, Delegate.create(this, this.refreshCurrentItem));
					}), Delegate.create(this, this.enable));
				}
				break;
			case Key.GREEN:
				// mark as unwatched
				if (media.viewedChildCount > 0)
				{
					this.disable();
					Share.POPUP.showConfirmationPopup(Share.getString("indicator_mark_unwatched"), Share.getString("message_mark_unwatched"), Delegate.create(this, function()
					{
						var thumbConfig:Object = this.config.itemThumbnailConfig;
						var size:Number = Math.min(thumbConfig.width, thumbConfig.height) / 2;
						var mc:MovieClip = this.grid.getMC();
						
						this.loadingMC.removeMovieClip();
						this.loadingMC = mc.attachMovie("loadingMC", "mc_loading", mc.getNextHighestDepth(), { _x:mc.mc_thumbnail._x + (thumbConfig.width / 2), _y:mc.mc_thumbnail._y + (thumbConfig.height / 2), _width:size, _height:size } );
						
						Share.api.setUnwatched(Share.systemGateway, media.ratingKey, this.container.identifier, Delegate.create(this, this.refreshCurrentItem));
					}), Delegate.create(this, this.enable));
				}
				break;
			case Key.YELLOW:
				// switch to list
				if (media != null && media != undefined)
				{
					this.disable();
					this.showLayoutChangePopup(Share.TV_DISPLAY_ARRAY, Share.tvShowDisplayType, Delegate.create(this, this.changeLayout));
				}
				break;
			case Key.INFO:
				this.disable();
				Share.POPUP.showShowInfoPopup(media, this.container, Delegate.create(this, this.enable));
				break;
			default:
				super.keyDownCB(o);
				break;
		}
	}
	
	private function changeLayout(data:Object):Void
	{
		var displayType:Number = data.displayType;
		Share.tvShowDisplayToChange = displayType;
		this.switchLayoutCallback();
	}
	
	/*
	 * Overwrite super class
	 */
	private function clearImageLoad():Void
	{
		super.clearImageLoad();
	}
	
	private function showHideTitle(show:Boolean):Void
	{
		var len1:Number = this.grid.xMCArray.length;
		var len2:Number = 0;
		for (var i:Number = 0; i < len1; i ++)
		{
			len2 = this.grid.xMCArray[i].length;
			for (var j = 0; j < len2; j ++)
			{
				this.grid.xMCArray[i][j].mc_title._visible = show;
			}
		}
		
		this.isShowTitle = show;
	}
}