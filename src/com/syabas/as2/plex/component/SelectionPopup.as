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
* Class Description: Popup for multiple choice selection
*
***************************************************/
import com.syabas.as2.plex.component.PlaybackOptionPopup;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.UI;

import mx.utils.Delegate;
class com.syabas.as2.plex.component.SelectionPopup extends PlaybackOptionPopup
{
	private var container:ContainerModel = null;			// The container for the selection options
	
	public function destroy():Void
	{
		delete this.container;
		this.container = null;
		
		super.destroy();
	}
	
	public function SelectionPopup(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.selectionConfig;
	}
	
	/*
	 * Overwrite super class
	 */
	public function createPopup(container:ContainerModel):Void
	{
		this.container = container;
		
		super.createPopup(container.items);
	}
	
	private function createMC():Void
	{
		this.popupMC.removeMovieClip();
		this.popupMC = this.parentMC.attachMovie("selectionPopupMC", "mc_selectionPopup", this.parentMC.getNextHighestDepth());
		
		this.popupMC.txt_title.text = Share.getString("selection_popup_title");
		
		this.upIndicatorMC = this.popupMC.mc_up;
		this.downIndicatorMC = this.popupMC.mc_down;
	}
	
	/*
	 * Overwrite super class
	 */
	private function updateCB(o:Object):Void
	{
		if (o.data.isClose == true)
		{
			return;
		}
		var media:MediaModel = o.data;
		
		o.mc.txt_title.text = Share.returnStringForDisplay(media.title);
	}
	
}