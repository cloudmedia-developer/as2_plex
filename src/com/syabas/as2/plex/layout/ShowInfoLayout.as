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
* Class Description: TV Show information List
*
***************************************************/
import com.syabas.as2.plex.component.ComponentUtils;
import com.syabas.as2.plex.layout.MovieInfoLayout;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.Constants;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;

class com.syabas.as2.plex.layout.ShowInfoLayout extends MovieInfoLayout
{
	public function ShowInfoLayout(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.tvShowInfoConfig;
	}
	
	/*
	 * Overwrite super class
	 */
	public function renderItems(container:ContainerModel):Void
	{
		super.renderItems(container);
	}
	
	/*
	 * Overwrite super class
	 */
	private function createList():Void
	{
		this.listMC.removeMovieClip();
		this.listMC = this.parentMC.attachMovie("tvShowInfoMC", "mc_tvShowInfo", this.parentMC.getNextHighestDepth());
		
		this.listMC.mc_red._visible = false;
		this.listMC.mc_green._visible = false;
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
		this.listMC.txt_group.htmlText = Share.returnStringForDisplay(media.year + "") + " " + Share.SEPARATOR_CHARACTER + " " + Share.returnStringForDisplay(media.genre[0]);
		this.listMC.txt_aired.htmlText = "<FONT COLOR='" + this.config.labelColor + "'>" + Share.getString("show_label_air_date") + " : </FONT>" + Share.returnStringForDisplay(media.originalAirDate);
		this.listMC.txt_genre.htmlText = "<FONT COLOR='" + this.config.labelColor + "'>" + Share.getString("show_label_genre") + " : </FONT>" + Share.returnStringForDisplay(media.genre[0]);
		this.listMC.txt_duration.htmlText = "<FONT COLOR='" + this.config.labelColor + "'>" + Share.getString("show_label_duration") + " : </FONT>" + Share.returnStringForDisplay(Share.convertTime(media.duration));
		this.listMC.txt_episode.htmlText = "<FONT COLOR='" + this.config.labelColor + "'>" + Share.getString("show_label_episode") + " : </FONT>" + Share.returnStringForDisplay(media.childCount + "");
		this.listMC.txt_watched.htmlText = "<FONT COLOR='" + this.config.labelColor + "'>" + Share.getString("show_label_watched") + " : </FONT>" + Share.returnStringForDisplay(media.viewedChildCount + "");
		this.listMC.txt_unwatched.htmlText = "<FONT COLOR='" + this.config.labelColor + "'>" + Share.getString("show_label_unwatched") + " : </FONT>" + Share.returnStringForDisplay((media.childCount - media.viewedChildCount) + "");
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
				// switch to wall
				if (media != null && media != undefined)
				{
					this.disable();
					this.showLayoutChangePopup(Share.TV_DISPLAY_ARRAY, Share.tvShowDisplayType, Delegate.create(this, this.changeLayout));
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
		Share.tvShowDisplayToChange = displayType;
		this.switchLayoutCallback();
	}
}