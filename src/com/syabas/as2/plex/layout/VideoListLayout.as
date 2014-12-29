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
* Class Description: Common Video List
*
***************************************************/

import com.syabas.as2.plex.layout.ListLayout;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.MediaElement;
import com.syabas.as2.plex.model.Constants;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
class com.syabas.as2.plex.layout.VideoListLayout extends ListLayout
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
	
	public function VideoListLayout(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.videoListConfig;
		this.synopsisMarquee = new Marquee();
	}
	
	/*
	 * Overwrite super class
	 */
	public function renderItems(container:ContainerModel):Void
	{
		this.synopsisMarquee.stop();
		
		super.renderItems(container);
		
		// create mask for thumbnail
		if (this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == null || this.listMC["mc_thumbnailMaskFor_mc_thumbnail"] == undefined)
		{
			Share.createMask(this.listMC, this.listMC.mc_thumbnail, this.config.thumbnailConfig);
		}
		
		// apply the mask for rating
		this.ratingMaskMC = this.createRatingMask(this.listMC.mc_ratingStar);
		this.ratingWidth = this.ratingMaskMC._width;
	}
	
	/*
	 * Overwrite super class
	 */
	private function createList():Void
	{
		this.listMC.removeMovieClip();
		this.listMC = this.parentMC.attachMovie("videoListMC", "mc_videoList", this.parentMC.getNextHighestDepth());
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlCB(o:Object):Void
	{
		super.hlCB(o);
		
		if (this.synopsisMarquee.isRunning())
		{
			this.synopsisMarquee.stop();
		}
		
		var media:MediaModel = o.data;
		this.clearVideoImage();
		// update info
		this.listMC.txt_title.htmlText = Share.returnStringForDisplay(media.title);
		this.listMC.txt_synopsis.text = "";
		this.listMC.txt_date.htmlText = Share.returnStringForDisplay(media.originalAirDate);
		
		// change rating
		var rating:Number = media.rating / 10;
		if (!isNaN(rating))
		{
			this.ratingMaskMC._width = rating * this.ratingWidth;
		}
		else
		{
			this.ratingMaskMC._width = 0;
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlStopCB(o:Object):Void
	{
		super.hlStopCB(o);
		var media:MediaModel = o.data;
		
		this.listMC.txt_synopsis.text = Share.returnStringForDisplay(media.summary);
		Share.startMarquee(this.synopsisMarquee, this.listMC.txt_synopsis, this.config.synopsisMarqueeConfig);
		
		// load thumbnail
		if (!Util.isBlank(media.thumbnail))
		{
			Share.loadThumbnail(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail, Share.getResourceURL(media.thumbnail), this.config.thumbnailConfig, 2, 2);
		}
		else
		{
			Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
			this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
		}
		
		var mediaStream:MediaElement = media.media[0];
		if (mediaStream != null && mediaStream != undefined)
		{
			// load audio codec logo
			if (mediaStream.audioCodec != null)
			{
				Share.loadMediaTag(this.listMC.mc_audioCodec, this.listMC.mc_audioCodec, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_AUDIO_CODEC, mediaStream.audioCodec), this.config.audioCodecSizeConfig);
			}
			else
			{
				Share.imageLoader.unload(this.listMC.mc_audioCodec._name, this.listMC.mc_audioCodec.mc_tag, null);
				this.listMC.mc_audioCodec.mc_tag.removeMovieClip();
			}
			
			// load aspect ratio logo
			if (mediaStream.aspectRatio != null)
			{
				Share.loadMediaTag(this.listMC.mc_aspectRatio, this.listMC.mc_aspectRatio, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_ASPECT_RATIO, mediaStream.aspectRatio), this.config.aspectRatioSizeConfig);
			}
			else
			{
				Share.imageLoader.unload(this.listMC.mc_aspectRatio._name, this.listMC.mc_aspectRatio.mc_tag, null);
				this.listMC.mc_aspectRatio.mc_tag.removeMovieClip();
			}
			
			// load video resolution logo
			if (mediaStream.videoResolution != null)
			{
				Share.loadMediaTag(this.listMC.mc_resolution, this.listMC.mc_resolution, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_VIDEO_RESOLUTION, mediaStream.videoResolution), this.config.videoResoultionSizeConfig);
			}
			else
			{
				Share.imageLoader.unload(this.listMC.mc_resolution._name, this.listMC.mc_resolution.mc_tag, null);
				this.listMC.mc_resolution.mc_tag.removeMovieClip();
			}
			
			// load audio channel logo
			if (mediaStream.audioChannel != null)
			{
				Share.loadMediaTag(this.listMC.mc_audioChannel, this.listMC.mc_audioChannel, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_AUDIO_CHANNELS, mediaStream.audioChannel), this.config.audioChannelSizeConfig);
			}
			else
			{
				Share.imageLoader.unload(this.listMC.mc_audioChannel._name, this.listMC.mc_audioChannel.mc_tag, null);
				this.listMC.mc_audioChannel.mc_tag.removeMovieClip();
			}
		}
		else
		{
			// clear all previous loaded logg
			Share.imageLoader.unload(this.listMC.mc_audioCodec._name, this.listMC.mc_audioCodec.mc_tag, null);
			Share.imageLoader.unload(this.listMC.mc_aspectRatio._name, this.listMC.mc_aspectRatio.mc_tag, null);
			Share.imageLoader.unload(this.listMC.mc_resolution._name, this.listMC.mc_resolution.mc_tag, null);
			Share.imageLoader.unload(this.listMC.mc_audioChannel._name, this.listMC.mc_audioChannel.mc_tag, null);
			
			this.listMC.mc_audioCodec.mc_tag.removeMovieClip();
			this.listMC.mc_aspectRatio.mc_tag.removeMovieClip();
			this.listMC.mc_resolution.mc_tag.removeMovieClip();
			this.listMC.mc_audioChannel.mc_tag.removeMovieClip();
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function clearImageLoad():Void
	{
		super.clearImageLoad();
		
		this.clearVideoImage();
	}
	
	private function clearVideoImage():Void
	{
		Share.imageLoader.unload(this.listMC.mc_thumbnail._name, this.listMC.mc_thumbnail.mc_thumb, null);
		Share.imageLoader.unload(this.listMC.mc_audioCodec._name, this.listMC.mc_audioCodec.mc_tag, null);
		Share.imageLoader.unload(this.listMC.mc_aspectRatio._name, this.listMC.mc_aspectRatio.mc_tag, null);
		Share.imageLoader.unload(this.listMC.mc_resolution._name, this.listMC.mc_resolution.mc_tag, null);
		Share.imageLoader.unload(this.listMC.mc_audioChannel._name, this.listMC.mc_audioChannel.mc_tag, null);
		
		
		this.listMC.mc_thumbnail.mc_thumb.removeMovieClip();
		this.listMC.mc_audioCodec.mc_tag.removeMovieClip();
		this.listMC.mc_aspectRatio.mc_tag.removeMovieClip();
		this.listMC.mc_resolution.mc_tag.removeMovieClip();
		this.listMC.mc_audioChannel.mc_tag.removeMovieClip();
	}
}