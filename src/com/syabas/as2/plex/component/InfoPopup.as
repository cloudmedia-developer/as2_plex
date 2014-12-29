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
* Class Description: Base class for information popup
*
***************************************************/
import com.syabas.as2.plex.component.Popup;
import com.syabas.as2.plex.component.ComponentUtils;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.SettingModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.Marquee;

import mx.utils.Delegate;

class com.syabas.as2.plex.component.InfoPopup extends Popup
{
	private var media:MediaModel = null;					// The container of setting options
	private var container:ContainerModel = null;
	private var kl:Object = null;
	
	private var ratingMaskMC:MovieClip = null;
	private var ratingWidth:Number = null;
	
	private var synopsisMarquee:Marquee = null;
	
	public function destroy():Void
	{
		delete this.container;
		
		this.ratingMaskMC.removeMovieClip();
		delete this.ratingMaskMC;
		
		delete this.ratingWidth;
		
		Key.removeListener(this.kl);
		this.kl.onKeyDown = null;
		
		delete this.kl;
		
		this.synopsisMarquee.stop();
		delete this.synopsisMarquee;
		
		super.destroy();
	}
	
	public function InfoPopup(mc:MovieClip)
	{
		super(mc);
		this.synopsisMarquee = new Marquee();
	}
	
	/*
	 * Overwrite super class
	 */
	public function createPopup(media:MediaModel, container:ContainerModel):Void
	{
		this.container = container;
		this.createMC();
		
		ComponentUtils.fitTextInTextField(this.popupMC.mc_info.txt, Share.getString("closeInfo"));
		
		this.kl = new Object();
		this.kl.onKeyDown = Delegate.create(this, this.navi);
		
		Key.addListener(this.kl);
		
		this.updateInfo(media);
	}
	
	private function createMC():Void
	{
		this.popupMC.removeMovieClip();
		this.popupMC = this.parentMC.attachMovie("infoPopupMC", "mc_infoPopup", this.parentMC.getNextHighestDepth());
	}
	
	private function updateInfo(media:MediaModel):Void
	{
		//create mask for the thumbnail
		if (this.popupMC["mc_thumbnailMaskFor_mc_thumbnail"] == null || this.popupMC["mc_thumbnailMaskFor_mc_thumbnail"] == undefined)
		{
			Share.createMask(this.popupMC, this.popupMC.mc_thumbnail, this.config.thumbnailConfig);
		}
		
		// apply the mask to the rating
		this.ratingMaskMC = this.popupMC.mc_ratingStar.mc_mask;
		
		this.popupMC.mc_ratingStar.mc_star.setMask(this.ratingMaskMC);
		this.ratingWidth = this.ratingMaskMC._width;
	}
	
	private function navi():Void
	{
		var keyCode:Number = Key.getCode();
		
		if (keyCode == Key.INFO || keyCode == Key.BACK)
		{
			this.cancelCB();
		}
	}
}