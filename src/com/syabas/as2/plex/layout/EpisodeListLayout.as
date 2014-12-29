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
* Class Description: Episode List
*
***************************************************/
import com.syabas.as2.plex.component.ComponentUtils;
import com.syabas.as2.plex.layout.VideoListLayout;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.Constants;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
class com.syabas.as2.plex.layout.EpisodeListLayout extends VideoListLayout
{
	public function EpisodeListLayout(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.episodeListConfig;
	}
	
	/*
	 * Overwrite super class
	 */
	public function renderItems(container:ContainerModel):Void
	{
		super.renderItems(container);
		
		ComponentUtils.fitTextInTextField(this.listMC.mc_red.txt, Share.getString("indicator_mark_watched"));
		ComponentUtils.fitTextInTextField(this.listMC.mc_green.txt, Share.getString("indicator_mark_unwatched"));
	}
	
	/*
	 * Overwrite super class
	 */
	private function createList():Void
	{
		this.listMC.removeMovieClip();
		this.listMC = this.parentMC.attachMovie("episodeListMC", "mc_episodeList", this.parentMC.getNextHighestDepth());
		
		this.listMC.mc_red._visible = false;
		this.listMC.mc_green._visible = false;
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
			var showTitle:String = this.container.grandParentTitle;
			if (Util.isBlank(showTitle))
			{
				showTitle = this.container.parentTitle;
				if (Util.isBlank(showTitle))
				{
					showTitle = media.grandParentTitle;
					if (Util.isBlank(showTitle))
					{
						showTitle = media.index + "";
					}
				}
			}
			
			o.mc.txt_title.htmlText = Share.returnStringForDisplay(showTitle) + " : " + Share.returnStringForDisplay(media.title);
			if (media.viewCount > 0)
			{
				// already watched before
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
	private function hlCB(o:Object):Void
	{
		super.hlCB(o);
		
		var media:MediaModel = o.data;
		var episodeNumberText:String = Share.getString("episode_count_format");
		var showTitle:String = this.container.grandParentTitle;
		this.clearEpisodeImage();
		
		if (Util.isBlank(showTitle))
		{
			showTitle = this.container.parentTitle;
			if (Util.isBlank(showTitle))
			{
				showTitle = media.grandParentTitle;
				if (Util.isBlank(showTitle))
				{
					showTitle = media.title;
				}
			}
		}
		
		this.listMC.txt_seasonTitle.htmlText = Share.returnStringForDisplay(showTitle);
		if (media.index != null && this.container.parentIndex != null)
		{
			var episodeIndex:Number = media.index;
			var seasonIndex:Number = this.container.parentIndex;
			
			if (this.container.mixedParents)
			{
				// invalid ?
				seasonIndex = media.parentIndex;
				
			}
			if (seasonIndex < 1 || seasonIndex == null)
			{
				episodeNumberText = "";
			}
			else
			{
				episodeNumberText = Util.replaceAll(episodeNumberText, "|EPISODE_NUMBER|", episodeIndex + "");
				episodeNumberText = Util.replaceAll(episodeNumberText, "|SEASON_NUMBER|", seasonIndex + "");
				episodeNumberText = Util.replaceAll(episodeNumberText, "|EPISODE_TITLE|", Share.returnStringForDisplay(media.title));
			}
		}
		else
		{
			episodeNumberText = Share.returnStringForDisplay(media.title);
		}
		
		this.listMC.txt_episodeNumber.htmlText = episodeNumberText;
		
		var align:Array = [this.listMC.mc_exit, this.listMC.mc_back, this.listMC.mc_blue];
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
		
		Share.alignIndicators(align);
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlStopCB(o:Object):Void
	{
		super.hlStopCB(o);
		var media:MediaModel = o.data;
		
		// looad the studio logo
		if (media.studio != null)
		{
			Share.loadMediaTag(this.listMC.mc_studio, this.listMC.mc_studio, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_STUDIO, media.studio), this.config.studioSizeConfig);
		}
		else
		{
			Share.imageLoader.unload(this.listMC.mc_studio._name, this.listMC.mc_studio.mc_tag, null);
			this.listMC.mc_studio.mc_tag.removeMovieClip();
		}
		
		// load the content rating logo
		if (media.contentRating != null)
		{
			Share.loadMediaTag(this.listMC.mc_contentRating, this.listMC.mc_contentRating, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_CONTENT_RATING, media.contentRating), this.config.contentRatingSizeConfig);
		}
		else
		{
			Share.imageLoader.unload(this.listMC.mc_contentRating._name, this.listMC.mc_contentRating.mc_tag, null);
			this.listMC.mc_contentRating.mc_tag.removeMovieClip();
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
				if (media.viewCount < 1)
				{
					this.disable();
					Share.api.setWatched(Share.systemGateway, media.ratingKey, this.container.identifier, Delegate.create(this, this.refreshCurrentItem));
				}
				break;
			case Key.GREEN:
				// mark as unwatched
				if ((media.viewCount > 0) || (media.viewCount < 1 && media.viewOffset > 0))
				{
					this.disable();
					Share.api.setUnwatched(Share.systemGateway, media.ratingKey, this.container.identifier, Delegate.create(this, this.refreshCurrentItem));
				}
				break;
			case Key.PLAY:
				var index:Number = this.grid._hl;
				var loadID:Number = Math.floor(index / this.grid.xLoadSize) * this.grid.xLoadSize;
				var container:ContainerModel = null;
				
				if (loadID == 0)
				{
					container = this.container;
				}
				else
				{
					container = this.loads[loadID + ""];
				}
				
				index = index - loadID;
				
				Share.PLAYER.startEpisodePlayback(container, index, this.loadingKey, this.loadingPath);
				
				this.disable();
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
		this.clearEpisodeImage();
	}
	
	private function clearEpisodeImage():Void
	{
		Share.imageLoader.unload(this.listMC.mc_studio._name, this.listMC.mc_studio.mc_tag, null);
		Share.imageLoader.unload(this.listMC.mc_contentRating._name, this.listMC.mc_contentRating.mc_tag, null);
		
		this.listMC.mc_contentRating.mc_tag.removeMovieClip();
		this.listMC.mc_studio.mc_tag.removeMovieClip();
	}
	
}