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
* Class Description: Photo List
*
***************************************************/
import com.syabas.as2.plex.layout.ListLayout;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaElement;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.MediaPart;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Util;
class com.syabas.as2.plex.layout.PhotoListLayout extends ListLayout
{
	public function PhotoListLayout(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.photoListConfig;
	}
	
	/*
	 * Overwrite super class
	 */
	public function renderItems(container:ContainerModel):Void
	{
		super.renderItems(container);
		
		// create mask for preview
		if (this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == null || this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == undefined)
		{
			Share.createMask(this.listMC, this.listMC.mc_thumbnail, this.config.thumbnailConfig);
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function createList():Void
	{
		this.listMC.removeMovieClip();
		this.listMC = this.parentMC.attachMovie("photoListMC", "mc_photoList", this.parentMC.getNextHighestDepth());
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
			var url:String = o.data.thumbnail;
			
			// create mask for the thumbnail
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
				var thumbnailMC:MovieClip = o.mc.mc_thumbnail.mc_thumb;
				Share.imageLoader.unload(o.mc._name, thumbnailMC);
				
				thumbnailMC.removeMovieClip();
			}
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function clearCB(o:Object):Void
	{
		super.clearCB(o);
		var thumbnailMC:MovieClip = o.mc.mc_thumbnail.mc_thumb;
		Share.imageLoader.unload(o.mc._name, thumbnailMC);
		
		thumbnailMC.removeMovieClip();
		
		o.mc._visible = false;
	}
	
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
		
		Share.PLAYER.startBatchPlayback(container, index, true, this.loadingKey, this.loadingPath);
		this.disable();
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
	
	/*
	 * Overwrite super class
	 */
	private function hlCB(o:Object):Void
	{
		super.hlCB(o);
		
		Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
		this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
		
		this.titleMarquee.stop();
		this.listMC.txt_title.htmlText = Share.returnStringForDisplay(o.data.title);
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlStopCB(o:Object):Void
	{
		super.hlStopCB(o);
		var media:MediaModel = o.data;
		var mediaStream:MediaElement = media.media[0];
		var mediaPart:MediaPart = mediaStream.parts[0];
		
		// load the preview
		if (!Util.isBlank(mediaPart.key))
		{
			Share.loadThumbnail(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail, Share.getResourceURL(mediaPart.key), this.config.thumbnailConfig, 2, 2);
		}
		else if (!Util.isBlank(media.key))
		{
			Share.loadThumbnail(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail, Share.getResourceURL(media.key), this.config.thumbnailConfig, 2, 2);
		}
		else
		{
			Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
			this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
		}
		
		Share.startMarquee(this.titleMarquee, this.listMC.txt_title, this.config.titleMarqueeConfig);
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