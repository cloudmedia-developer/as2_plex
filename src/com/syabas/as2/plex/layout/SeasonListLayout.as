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
* Class Description: Season List
*
***************************************************/
import com.syabas.as2.plex.component.ComponentUtils;
import com.syabas.as2.plex.layout.ListLayout;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.Constants;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
class com.syabas.as2.plex.layout.SeasonListLayout extends ListLayout
{
	private var synopsisMarquee:Marquee = null;
	private var ratingMaskMC:MovieClip = null;
	private var ratingWidth:Number = null;
	
	public function destroy():Void
	{
		this.synopsisMarquee.stop();
		delete this.synopsisMarquee;
		
		delete this.ratingMaskMC;
		delete this.ratingWidth;
		
		super.destroy();
	}
	
	public function SeasonListLayout(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.seasonListConfig;
		this.synopsisMarquee = new Marquee();
	}
	
	/*
	 * Overwrite super class
	 */
	public function renderItems(container:ContainerModel):Void
	{
		this.synopsisMarquee.stop();
		
		super.renderItems(container);
		
		// create mask for the thumbnail
		if (this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == null || this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == undefined)
		{
			Share.createMask(this.listMC, this.listMC.mc_thumbnail, this.config.thumbnailConfig);
		}
		
		ComponentUtils.fitTextInTextField(this.listMC.mc_red.txt, Share.getString("indicator_mark_watched"));
		ComponentUtils.fitTextInTextField(this.listMC.mc_green.txt, Share.getString("indicator_mark_unwatched"));
		
		// apply mask for the rating
		this.ratingMaskMC = this.createRatingMask(this.listMC.mc_ratingStar);
		this.ratingWidth = this.ratingMaskMC._width;
		
		// set the synopsis
		this.listMC.txt_synopsis.htmlText = Share.returnStringForDisplay(container.summary);
		
		Share.startMarquee(synopsisMarquee, this.listMC.txt_synopsis, this.config.synopsisMarqueeConfig);
	}
	
	/*
	 * Overwrite super class
	 */
	private function createList():Void
	{
		this.listMC.removeMovieClip();
		this.listMC = this.parentMC.attachMovie("seasonListMC", "mc_seasonList", this.parentMC.getNextHighestDepth());
		
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
		this.listMC.txt_title.htmlText = Share.returnStringForDisplay(media.title);
		
		Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
		this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
		
		var seasonFormat:String = Share.getString("season_count_format");
		seasonFormat = Util.replaceAll(seasonFormat, "|TOTAL_EPISODE_COUNT|", Share.returnStringForDisplay(media.childCount + ""));
		seasonFormat = Util.replaceAll(seasonFormat, "|UNWATCHED_EPISODE_TITLE|", Share.returnStringForDisplay((media.childCount - media.viewedChildCount) + ""));
		
		this.listMC.txt_episodeNumber.htmlText = Share.returnStringForDisplay(seasonFormat);
		
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
		
		this.listMC.mc_red._visible = false;
		this.listMC.mc_green._visible = false;
		
		if (media.type == MediaModel.CONTENT_TYPE_SEASON)
		{
			var align:Array = [this.listMC.mc_exit, this.listMC.mc_back, this.listMC.mc_blue];
			var watched:Number = media.viewedChildCount;
			var total:Number = media.childCount;
			
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
			
			Share.alignIndicators(align);
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlStopCB(o:Object):Void
	{
		super.hlStopCB(o);
		
		var media:MediaModel = o.data;
		
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
			o.mc.txt_episodeNumber.htmlText = Share.returnStringForDisplay(media.childCount + "");
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function clearCB(o:Object):Void
	{
		super.clearCB(o);
		o.mc.txt_episodeNumber.text = "";
	}
	
	/*
	 * Overwrite super class
	 */
	private function showCB(o:Object):Void
	{
		super.showCB(o);
		if (o.data == null || o.data == undefined)
		{
			o.mc.txt_episodeNumber.text = "";
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
		switch (keyCode)
		{
			case Key.RED:
				// mark as watched
				if (media.type == MediaModel.CONTENT_TYPE_SEASON && media.viewedChildCount != media.childCount && media.childCount > 0)
				{
					this.disable();
					Share.POPUP.showConfirmationPopup(Share.getString("indicator_mark_watched"), Share.getString("message_mark_watched"), Delegate.create(this, function()
					{
						Share.api.setWatched(Share.systemGateway, media.ratingKey, this.container.identifier, Delegate.create(this, this.refreshCurrentItem));
					}), Delegate.create(this, this.enable));
				}
				break;
			case Key.GREEN:
				// mark as unwatched
				if (media.type == MediaModel.CONTENT_TYPE_SEASON && media.viewedChildCount > 0)
				{
					this.disable();
					Share.POPUP.showConfirmationPopup(Share.getString("indicator_mark_unwatched"), Share.getString("message_mark_unwatched"), Delegate.create(this, function()
					{
						Share.api.setUnwatched(Share.systemGateway, media.ratingKey, this.container.identifier, Delegate.create(this, this.refreshCurrentItem));
					}), Delegate.create(this, this.enable));
				}
				break;
			default:
				super.keyDownCB(o);
				break;
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function clearImageLoad():Void
	{
		super.clearImageLoad();
		
		Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
		this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
	}
}
