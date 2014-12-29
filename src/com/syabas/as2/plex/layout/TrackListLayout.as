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
* Class Description: Music Track List
*
***************************************************/
import com.syabas.as2.plex.layout.ListLayout;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.Constants;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.MediaElement;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;

class com.syabas.as2.plex.layout.TrackListLayout extends ListLayout
{
	public function TrackListLayout(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.trackListConfig;
	}
	
	/*
	 * Overwrite super class
	 */
	public function renderItems(container:ContainerModel):Void
	{
		super.renderItems(container);
		
		// create mask for album thumbnail
		if (this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == null || this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == undefined)
		{
			Share.createMask(this.listMC, this.listMC.mc_thumbnail, this.config.artistThumbnailConfig);
		}
		
		// create mask for artist fanart
		if (this.listMC["mc_thumbnailMaskFor_mc_thumbnail2"] == null || this.listMC["mc_thumbnailMaskFor_mc_thumbnail2"] == undefined)
		{
			Share.createMask(this.listMC, this.listMC.mc_thumbnail2, this.config.artistArtConfig);
		}
		
		// load album thumbnail
		if (!Util.isBlank(container.thumbnail))
		{
			Share.loadThumbnail(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail, Share.getResourceURL(container.thumbnail), this.config.artistThumbnailConfig);
		}
		else
		{
			Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
			this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
		}
		
		// load artist fanart
		if (!Util.isBlank(container.art))
		{
			Share.loadThumbnail(this.listMC.mc_thumbnail2._name, this.listMC.mc_thumbnail2, Share.getResourceURL(container.art), this.config.artistArtConfig);
		}
		else
		{
			Share.imageLoader.unload(this.listMC.mc_thumbnail2._name, this.listMC.mc_thumbnail2.mc_thumb, null);
			this.listMC.mc_thumbnail2.mc_thumb.removeMovieClip();
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function createList():Void
	{
		this.listMC.removeMovieClip();
		this.listMC = this.parentMC.attachMovie("trackListMC", "mc_trackList", this.parentMC.getNextHighestDepth());
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlCB(o:Object):Void
	{
		super.hlCB(o);
		
		var media:MediaModel = o.data;
		this.listMC.txt_title.htmlText = Share.returnStringForDisplay(media.title);
		
		this.clearTrackImage();
		
		if (!Util.isBlank(this.container.parentTitle) && !this.container.mixedParents)
		{
			this.listMC.txt_albumTitle.htmlText = Share.returnStringForDisplay(this.container.parentTitle);
		}
		else
		{
			this.listMC.txt_albumTitle.htmlText = Share.returnStringForDisplay(media.parentTitle);
		}
		
		this.listMC.txt_duration.htmlText = Share.returnStringForDisplay(Share.convertTime(media.duration));		
		
		
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlStopCB(o:Object):Void
	{
		super.hlStopCB(o);
		var media:MediaModel = o.data;
		var mediaStream:MediaElement = media.media[0];
		
		if (mediaStream.audioChannel != null)
		{
			Share.loadMediaTag(this.listMC.mc_audioChannel, this.listMC.mc_audioChannel, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_AUDIO_CHANNELS, mediaStream.audioChannel), this.config.audioChannelSizeConfig, 1, 1);
		}
		else
		{
			Share.imageLoader.unload(this.listMC.mc_audioChannel._name, this.listMC.mc_audioChannel.mc_tag, null);
			this.listMC.mc_audioChannel.mc_tag.removeMovieClip();
		}
		
		if (this.container.mixedParents || Util.isBlank(container.thumbnail))
		{
			// not track in an album
			Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
			this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
			
			Share.imageLoader.unload(this.listMC.mc_thumbnail2._name, this.listMC.mc_thumbnail2.mc_thumb, null);
			this.listMC.mc_thumbnail2.mc_thumb.removeMovieClip();
			
			// load album thumbnail
			if (!Util.isBlank(media.thumbnail))
			{
				Share.loadThumbnail(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail, Share.getResourceURL(media.thumbnail), this.config.artistThumbnailConfig);
			}
			
			// load artist art
			if (!Util.isBlank(media.art))
			{
				Share.loadThumbnail(this.listMC.mc_thumbnail2._name, this.listMC.mc_thumbnail2, Share.getResourceURL(media.art), this.config.artistArtConfig);
			}
			else if (!Util.isBlank(this.container.art))
			{
				Share.loadThumbnail(this.listMC.mc_thumbnail2._name, this.listMC.mc_thumbnail2, Share.getResourceURL(this.container.art), this.config.artistArtConfig);
			}
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
			o.mc.txt_duration.htmlText = Share.returnStringForDisplay(Share.convertTime(o.data.duration));
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function enterCB(o:Object):Void
	{
		var media:MediaModel = o.data;
		if (media.itemType == MediaModel.TYPE_DIRECTORY)
		{
			if (this.itemSelectedCallback(media, this.container.identifier))
			{
				this.disable();
			}
			
			return;
		}
		var index:Number = o.dataIndex;
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
		
		Share.PLAYER.startBatchPlayback(container, index, false, this.loadingKey, this.loadingPath);
	}
	
	/*
	 * Overwrite super class
	 */
	private function clearCB(o:Object):Void
	{
		super.clearCB(o);
		o.mc.txt_duration.text = "";
	}
	
	/*
	 * Overwrite super class
	 */
	private function showCB(o:Object):Void
	{
		super.showCB(o);
		if (o.data == null || o.data == undefined)
		{
			o.mc.txt_duration.text = "";
		}
		else
		{
			this.updateCB(o);
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function clearImageLoad():Void
	{
		super.clearImageLoad();
		this.clearTrackImage();
	}
	
	
	private function clearTrackImage():Void
	{
		Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail, null);
		Share.imageLoader.unload(this.listMC.mc_thumbnail2._name, this.listMC.mc_thumbnail2, null);
		
		this.listMC.mc_thumbnail.removeMovieClip();
		this.listMC.mc_thumbnail2.removeMovieClip();
	}
}