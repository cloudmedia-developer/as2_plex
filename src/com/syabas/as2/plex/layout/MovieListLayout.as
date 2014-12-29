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
* Class Description: Movie List
*
***************************************************/
import com.syabas.as2.plex.component.ComponentUtils;
import com.syabas.as2.plex.layout.ListLayout;
import com.syabas.as2.plex.manager.AlphabertSwitchingManager;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.Constants;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
class com.syabas.as2.plex.layout.MovieListLayout extends ListLayout
{
	private var alphaSwitching:AlphabertSwitchingManager = null;
	private var synopsisMarquee:Marquee = null;
	private var ratingMaskMC:MovieClip = null;
	private var ratingWidth:Number = null;
	
	public function destroy():Void
	{
		this.alphaSwitching.destroy();
		delete this.alphaSwitching;
		
		this.synopsisMarquee.stop();
		delete this.synopsisMarquee;
		
		delete this.ratingMaskMC;
		delete this.ratingWidth;
		
		super.destroy();
	}
	
	public function MovieListLayout(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.movieListConfig;
		this.synopsisMarquee = new Marquee();
	}
	
	/*
	 * Overwrite super class
	 */
	public function renderItems(container:ContainerModel):Void
	{
		this.synopsisMarquee.stop();
		
		super.renderItems(container);
		
		if (Util.startsWith(this.loadingKey, "all"))
		{
			this.alphaSwitching = new AlphabertSwitchingManager();
			this.alphaSwitching.init(this.loadingKey, this.loadingPath);
		}
		
		// create mask for the thumbnail
		if (this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == null || this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == undefined)
		{
			Share.createMask(this.listMC, this.listMC.mc_thumbnail, this.config.thumbnailConfig);
		}
		
		// apply mask for the rating
		this.ratingMaskMC = this.createRatingMask(this.listMC.mc_ratingStar);
		this.ratingWidth = this.ratingMaskMC._width;
		
		
		ComponentUtils.fitTextInTextField(this.listMC.mc_red.txt, Share.getString("indicator_mark_watched"));
		ComponentUtils.fitTextInTextField(this.listMC.mc_green.txt, Share.getString("indicator_mark_unwatched"));
		ComponentUtils.fitTextInTextField(this.listMC.mc_yellow.txt, Share.getString("indicator_switch_layout"));
		
		Share.alignIndicators([this.listMC.mc_exit, this.listMC.mc_back, this.listMC.mc_blue, this.listMC.mc_yellow]);
	}
	
	/*
	 * Overwrite super class
	 */
	private function createList():Void
	{
		this.listMC.removeMovieClip();
		this.listMC = this.parentMC.attachMovie("movieListMC", "mc_movieList", this.parentMC.getNextHighestDepth());
		
		this.listMC.mc_red._visible = false;
		this.listMC.mc_green._visible = false;
		
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlCB(o:Object):Void
	{
		super.hlCB(o);
		
		if (o.data == null || o.data == undefined)
		{
			return;
		}
		
		var media:MediaModel = o.data;
		
		Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
		this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
		
		this.listMC.txt_title.htmlText = Share.returnStringForDisplay(media.title);
		
		this.listMC.txt_group.htmlText = "";
		this.ratingMaskMC._width = 0;
		
		this.listMC.txt_synopsis.htmlText = "";
		
		this.listMC.mc_red._visible = false;
		this.listMC.mc_green._visible = false;
		var align:Array = [this.listMC.mc_exit, this.listMC.mc_back, this.listMC.mc_blue, this.listMC.mc_yellow];
		
		if (media.type == MediaModel.CONTENT_TYPE_MOVIE)
		{
			if (media.viewCount > 0)
			{
				//watched
				align.push(this.listMC.mc_green);
				
				this.listMC.mc_red._visible = false;
				this.listMC.mc_green._visible = true;
			}
			else
			{
				if (media.viewOffset > 0)
				{
					// watched halfway
					align.push(this.listMC.mc_green);
					align.push(this.listMC.mc_red);
					
					this.listMC.mc_red._visible = true;
					this.listMC.mc_green._visible = true;
				}
				else
				{
					// not watched before
					align.push(this.listMC.mc_red);
					
					this.listMC.mc_red._visible = true;
					this.listMC.mc_green._visible = false;
				}
			}
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
	private function hlStopCB(o:Object):Void
	{
		super.hlStopCB(o);
		this.synopsisMarquee.stop();
		var media:MediaModel = o.data;
		if (media != null && media != undefined)
		{
			// load thumbnail
			if (!Util.isBlank(media.thumbnail))
			{
				Share.loadThumbnail(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail, Share.getResourceURL(media.thumbnail), this.config.thumbnailConfig);
			}
			else
			{
				Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
				this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
			}
			
			this.listMC.txt_title.htmlText = Share.returnStringForDisplay(media.title);
			
			this.listMC.txt_group.htmlText = Share.returnStringForDisplay(media.year + "") + " " + Share.SEPARATOR_CHARACTER + " " + Share.returnStringForDisplay(Share.convertTime(media.duration));
			
			// change the rating
			var rating:Number = media.rating / 10;
			if (!isNaN(rating))
			{
				this.ratingMaskMC._width = rating * this.ratingWidth;
			}
			else
			{
				this.ratingMaskMC._width = 0;
			}
			
			// set the synopsis
			this.listMC.txt_synopsis.htmlText = Share.returnStringForDisplay(media.summary);
			
			Share.startMarquee(synopsisMarquee, this.listMC.txt_synopsis, this.config.synopsisMarqueeConfig);
		}
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
		
		super.updateCB(o);
		if (o.data != null && o.data != undefined)
		{
			var media:MediaModel = o.data;
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
		o.mc.mc_watchedIcon._visible = false;
	}
	
	/*
	 * Overwrite super class
	 */
	private function showCB(o:Object):Void
	{
		super.showCB(o);
		if (o.data == null || o.data == undefined)
		{
			o.mc.mc_watchedIcon._visible = false;
		}
		else
		{
			this.updateCB(o);
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function keyDownCB(o:Object):Void
	{
		var keyCode:Number = o.keyCode;
		var media:MediaModel = MediaModel(this.grid.getData());
		var mc:MovieClip = this.listMC;
		
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
				if (media.viewCount < 1)
				{
					this.disable();
					Share.api.setWatched(Share.systemGateway, media.ratingKey, this.container.identifier, Delegate.create(this, this.refreshCurrentItem));
					
					var thumbConfig:Object = this.config.thumbnailConfig;
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
					Share.api.setUnwatched(Share.systemGateway, media.ratingKey, this.container.identifier, Delegate.create(this, this.refreshCurrentItem));
					
					var thumbConfig:Object = this.config.thumbnailConfig;
					var size:Number = Math.min(thumbConfig.width, thumbConfig.height) / 2;
					
					this.loadingMC.removeMovieClip();
					this.loadingMC = mc.attachMovie("loadingMC", "mc_loading", mc.getNextHighestDepth(), { _x:mc.mc_thumbnail._x + (thumbConfig.width / 2), _y:mc.mc_thumbnail._y + (thumbConfig.height / 2), _width:size, _height:size } );
				}
				break;
			case Key.YELLOW:
				// switch layout
				if (media != null && media != undefined)
				{
					this.disable();
					this.showLayoutChangePopup(Share.MOVIE_DISPLAY_ARRAY, Share.movieDisplayType, Delegate.create(this, this.changeLayout));
				}
				break;
			default:
				super.keyDownCB(o);
				break;
		}
	}
	
	private function changeLayout(data:Object):Void
	{
		var displayType:Number = data.displayType;
		Share.movieDisplayToChange = displayType;
		this.switchLayoutCallback();
	}
	
	/*
	 * Overwrite super class
	 */
	private function clearImageLoad():Void
	{
		super.clearImageLoad();
		Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
	}
}
