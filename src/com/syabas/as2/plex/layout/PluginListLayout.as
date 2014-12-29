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
* Class Description: Plugin List
*
***************************************************/

import com.syabas.as2.plex.layout.ListLayout;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Util;
class com.syabas.as2.plex.layout.PluginListLayout extends ListLayout
{
	private var mediaType:Number = null;
	
	public function PluginListLayout(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.pluginListConfig;
	}
	
	public function setMediaType(mediaType:Number):Void
	{
		this.mediaType = mediaType;
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
		this.listMC = this.parentMC.attachMovie("pluginListMC", "mc_pluginList", this.parentMC.getNextHighestDepth());
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
		
		
		if (o.data != null && o.data != undefined)
		{
			var url:String = o.data.thumbnail;
			
			// create mask for thumbnail
			if (o.mc["mc_thumbnailMaskFor_" + o.mc.mc_thumbnail._name] == null || o.mc["mc_thumbnailMaskFor_" + o.mc.mc_thumbnail._name] == undefined)
			{
				Share.createMask(o.mc, o.mc.mc_thumbnail, this.config.itemThumbnailConfig);
			}
			
			// load thumbnail
			if (!Util.isBlank(url))
			{
				Share.loadThumbnail(o.mc._name, o.mc.mc_thumbnail, Share.getResourceURL(url), this.config.itemThumbnailConfig);
			}
			
			if (o.data.isDisabled == null || o.data.isDisabled == undefined)
			{
				o.data.isDisabled = Share.isPluginDisabled(MediaModel(o.data), this.mediaType);
			}
			
			if (o.data.isDisabled == true)
			{
				o.mc.mc_disabled._visible = true;
			}
			else
			{
				o.mc.mc_disabled._visible = false;
			}
		}
		
		super.updateCB(o);
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
		o.mc.mc_disabled._visible = false;
		
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
	private function enterCB(o:Object):Void
	{
		if (o.data.isDisabled == true)
		{
			return;
		}
		
		super.enterCB(o);
	}
}