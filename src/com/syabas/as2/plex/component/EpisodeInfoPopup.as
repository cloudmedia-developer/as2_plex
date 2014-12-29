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
* Class Description: Popup for episode information
*
***************************************************/
import com.syabas.as2.plex.component.InfoPopup;
import com.syabas.as2.plex.component.Popup;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.MediaElement;
import com.syabas.as2.plex.model.SettingModel;
import com.syabas.as2.plex.model.Constants;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;

class com.syabas.as2.plex.component.EpisodeInfoPopup extends InfoPopup
{
	private var media:MediaModel = null;					// The container of setting options
	private var kl:Object = null;
	
	public function destroy():Void
	{
		Share.imageLoader.unload(this.popupMC.mc_audioCodec._name, this.popupMC.mc_audioCodec.mc_tag, null);
		Share.imageLoader.unload(this.popupMC.mc_aspectRatio._name, this.popupMC.mc_aspectRatio.mc_tag, null);
		Share.imageLoader.unload(this.popupMC.mc_resolution._name, this.popupMC.mc_resolution.mc_tag, null);
		Share.imageLoader.unload(this.popupMC.mc_audioChannel._name, this.popupMC.mc_audioChannel.mc_tag, null);
		Share.imageLoader.unload(this.popupMC.mc_contentRating._name, this.popupMC.mc_contentRating.mc_tag, null);
		Share.imageLoader.unload(this.popupMC.mc_thumbnail._name, this.popupMC.mc_thumbnail.mc_thumb, null);
		Share.imageLoader.unload(this.popupMC.mc_studio._name, this.popupMC.mc_studio.mc_tag, null);
		
		this.popupMC.mc_audioCodec.mc_tag.removeMovieClip();
		this.popupMC.mc_aspectRatio.mc_tag.removeMovieClip();
		this.popupMC.mc_resolution.mc_tag.removeMovieClip();
		this.popupMC.mc_audioChannel.mc_tag.removeMovieClip();
		this.popupMC.mc_contentRating.mc_tag.removeMovieClip();
		this.popupMC.mc_thumbnail.mc_thumb.removeMovieClip();
		this.popupMC.mc_studio.mc_tag.removeMovieClip();
		
		super.destroy();
	}
	
	public function EpisodeInfoPopup(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.episodeInfoPopupConfig;
	}
	
	private function createMC():Void
	{
		this.popupMC.removeMovieClip();
		this.popupMC = this.parentMC.attachMovie("episodeInfoPopupMC", "mc_infoPopup", this.parentMC.getNextHighestDepth());
	}
	
	private function updateInfo(media:MediaModel):Void
	{
		super.updateInfo(media);
		
		var episodeNumberText:String = Share.getString("episode_count_format");
		var showTitle:String = this.container.grandParentTitle;
		
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
		
		this.popupMC.txt_seasonTitle.htmlText = Share.returnStringForDisplay(showTitle);
		this.popupMC.txt_date.htmlText = Share.returnStringForDisplay(media.originalAirDate);
		this.popupMC.txt_synopsis.text = Share.returnStringForDisplay(media.summary);
		
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
		
		this.popupMC.txt_episodeNumber.htmlText = episodeNumberText;
		
		
		if (media.studio != null)
		{
			Share.loadMediaTag(this.popupMC.mc_studio, this.popupMC.mc_studio, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_STUDIO, media.studio), this.config.studioSizeConfig);
		}
		else
		{
			
		}
		
		// load the content rating logo
		if (media.contentRating != null)
		{
			Share.loadMediaTag(this.popupMC.mc_contentRating, this.popupMC.mc_contentRating, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_CONTENT_RATING, media.contentRating), this.config.contentRatingSizeConfig);
		}
		else
		{
			
		}
		
		var rating:Number = media.rating / 10;
		if (!isNaN(rating))
		{
			this.ratingMaskMC._width = rating * this.ratingWidth;
		}
		else
		{
			this.ratingMaskMC._width = 0;
		}
		
		// load thumbnail
		if (!Util.isBlank(media.thumbnail))
		{
			Share.loadThumbnail(this.popupMC.mc_thumbnail._name, this.popupMC.mc_thumbnail, Share.getResourceURL(media.thumbnail), this.config.thumbnailConfig, 2, 2);
		}
		else
		{
			
		}
		
		var mediaStream:MediaElement = media.media[0];
		if (mediaStream != null && mediaStream != undefined)
		{
			// load audio codec logo
			if (mediaStream.audioCodec != null)
			{
				Share.loadMediaTag(this.popupMC.mc_audioCodec, this.popupMC.mc_audioCodec, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_AUDIO_CODEC, mediaStream.audioCodec), this.config.audioCodecSizeConfig);
			}
			else
			{
				Share.imageLoader.unload(this.popupMC.mc_audioCodec._name, this.popupMC.mc_audioCodec.mc_tag, null);
				this.popupMC.mc_audioCodec.mc_tag.removeMovieClip();
			}
			
			// load aspect ratio logo
			if (mediaStream.aspectRatio != null)
			{
				Share.loadMediaTag(this.popupMC.mc_aspectRatio, this.popupMC.mc_aspectRatio, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_ASPECT_RATIO, mediaStream.aspectRatio), this.config.aspectRatioSizeConfig);
			}
			else
			{
				Share.imageLoader.unload(this.popupMC.mc_aspectRatio._name, this.popupMC.mc_aspectRatio.mc_tag, null);
				this.popupMC.mc_aspectRatio.mc_tag.removeMovieClip();
			}
			
			// load video resolution logo
			if (mediaStream.videoResolution != null)
			{
				Share.loadMediaTag(this.popupMC.mc_resolution, this.popupMC.mc_resolution, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_VIDEO_RESOLUTION, mediaStream.videoResolution), this.config.videoResoultionSizeConfig);
			}
			else
			{
				Share.imageLoader.unload(this.popupMC.mc_resolution._name, this.popupMC.mc_resolution.mc_tag, null);
				this.popupMC.mc_resolution.mc_tag.removeMovieClip();
			}
			
			// load audio channel logo
			if (mediaStream.audioChannel != null)
			{
				Share.loadMediaTag(this.popupMC.mc_audioChannel, this.popupMC.mc_audioChannel, Share.getMediaTagURL(this.container, Constants.TAG_TYPE_AUDIO_CHANNELS, mediaStream.audioChannel), this.config.audioChannelSizeConfig);
			}
			else
			{
				Share.imageLoader.unload(this.popupMC.mc_audioChannel._name, this.popupMC.mc_audioChannel.mc_tag, null);
				this.popupMC.mc_audioChannel.mc_tag.removeMovieClip();
			}
		}
		else
		{
			// clear all previous loaded logo
			
		}
		
		Share.startMarquee(this.synopsisMarquee, this.popupMC.txt_synopsis, this.config.synopsisMarqueeConfig);
	}
}