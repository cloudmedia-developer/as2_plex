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
* Class Description: Artist List
*
***************************************************/
import com.syabas.as2.plex.layout.ListLayout;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;

class com.syabas.as2.plex.layout.ArtistListLayout extends ListLayout
{
	private var descriptionMarquee:Marquee = null;
	
	public function destroy():Void
	{
		this.clearImageLoad();
		super.destroy();
		
		this.descriptionMarquee.stop();
		delete this.descriptionMarquee;
		this.descriptionMarquee = null;
	}
	
	public function ArtistListLayout(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.artistListConfig;
		this.descriptionMarquee = new Marquee();
	}
	
	/*
	 * Overwrite super class
	 */
	public function renderItems(container:ContainerModel):Void
	{
		this.descriptionMarquee.stop();
		
		super.renderItems(container);
		
		if (this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == null || this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == undefined)
		{
			Share.createMask(this.listMC, this.listMC.mc_thumbnail, this.config.artistThumbnailConfig);
		}
		
		if (this.listMC["mc_thumbnailMaskFor_mc_thumbnail2"] == null || this.listMC["mc_thumbnailMaskFor_mc_thumbnail2"] == undefined)
		{
			Share.createMask(this.listMC, this.listMC.mc_thumbnail2, this.config.artistArtConfig);
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function createList():Void
	{
		this.listMC.removeMovieClip();
		this.listMC = this.parentMC.attachMovie("artistListMC", "mc_artistList", this.parentMC.getNextHighestDepth());
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlCB(o:Object):Void
	{
		super.hlCB(o);
		this.descriptionMarquee.stop();
		
		var media:MediaModel = o.data;
		this.listMC.txt_title.text = Share.returnStringForDisplay(media.title);
		this.listMC.txt_description.text = "";
		
		this.clearArtistImage();
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlStopCB(o:Object):Void
	{
		super.hlStopCB(o);
		
		var media:MediaModel = o.data;
		
		this.listMC.txt_description.text = Share.returnStringForDisplay(media.summary);
		Share.startMarquee(this.descriptionMarquee, this.listMC.txt_description, this.config.descriptionMarqueeConfig);
		
		// load the thumbnail
		if (!Util.isBlank(media.thumbnail))
		{
			Share.loadThumbnail(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail, Share.getResourceURL(media.thumbnail), this.config.artistThumbnailConfig);
		}
		else
		{
			Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
			this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
		}
		
		// load the fanart
		if (!Util.isBlank(media.art))
		{
			Share.loadThumbnail(this.listMC.mc_thumbnail2._name, this.listMC.mc_thumbnail2, Share.getResourceURL(media.art), this.config.artistArtConfig);
		}
		else if (!Util.isBlank(this.container.art))
		{
			Share.loadThumbnail(this.listMC.mc_thumbnail2._name, this.listMC.mc_thumbnail2, Share.getResourceURL(this.container.art), this.config.artistArtConfig);
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
	private function clearImageLoad():Void
	{
		super.clearImageLoad();
		this.clearArtistImage();
		
	}
	
	private function clearArtistImage():Void
	{
		Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
		Share.imageLoader.unload(this.listMC.mc_thumbnail2._name, this.listMC.mc_thumbnail2.mc_thumb, null);
		
		this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
		this.listMC.mc_thumbnail2.mc_thumb.removeMovieClip();
	}
}