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
* Class Description: Class managing the popup
***************************************************/

import com.syabas.as2.plex.component.ConfirmationPopup;
import com.syabas.as2.plex.component.EpisodeInfoPopup;
import com.syabas.as2.plex.component.MovieInfoPopup;
import com.syabas.as2.plex.component.Popup;
import com.syabas.as2.plex.component.SelectionPopup;
import com.syabas.as2.plex.component.PlaybackOptionPopup;
import com.syabas.as2.plex.component.PlaybackResumePopup;
import com.syabas.as2.plex.component.MessagePopup;
import com.syabas.as2.plex.component.SettingPopup;
import com.syabas.as2.plex.component.ShowInfoPopup;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Util;

import mx.utils.Delegate;

class com.syabas.as2.plex.manager.PopupManager
{
	private var popupHolderMC:MovieClip = null;			// The holder movie clip to attach popup
	private var popup:Popup = null;
	private var doneCB:Function = null;
	private var cancelCB:Function = null;
	
	private var fn:Object = null;
	
	public function destroy():Void
	{
		this.clearPopup();
		delete this.popupHolderMC;
		delete this.doneCB;
		delete this.cancelCB;
		
		delete this.fn;
	}
	
	public function isShowingPopup():Boolean
	{
		return !(this.popup == null)
	}
	
	public function PopupManager(mc:MovieClip)
	{
		this.popupHolderMC = mc;
		this.fn = { doneCB:Delegate.create(this, this.onPopupDone), cancelCB:Delegate.create(this, this.onPopupCancel) };
	}
	
	public function showMessagePopup(title:String, message:String, cb:Function):Void
	{
		this.clearPopup();
		
		this.doneCB = cb;
		this.cancelCB = cb;
		
		var msgPopup:MessagePopup = new MessagePopup(this.popupHolderMC);
		
		this.popup = msgPopup;
		this.popup.doneCB = this.fn.doneCB;
		this.popup.cancelCB = this.fn.cancelCB;
		
		msgPopup.createPopup(title, message);
	}
	
	public function showConfirmationPopup(title:String, message:String, doneCB:Function, cancelCB:Function):Void
	{
		this.clearPopup();
		
		this.doneCB = doneCB;
		this.cancelCB = cancelCB;
		
		var confirmationPopup:ConfirmationPopup = new ConfirmationPopup(this.popupHolderMC);
		
		this.popup = confirmationPopup;
		this.popup.doneCB = this.fn.doneCB;
		this.popup.cancelCB = this.fn.cancelCB;
		
		confirmationPopup.createPopup(title, message);
	}
	
	public function showSettingPopup(container:ContainerModel, doneCB:Function, cancelCB:Function):Void
	{
		this.clearPopup();
		this.doneCB = doneCB;
		this.cancelCB = cancelCB;
		
		var settingPopup:SettingPopup = new SettingPopup(this.popupHolderMC);
		this.popup = settingPopup;
		this.popup.doneCB = this.fn.doneCB;
		this.popup.cancelCB = this.fn.cancelCB;
		
		settingPopup.createPopup(container);
	}
	
	public function showSelectionPopup(container:ContainerModel, doneCB:Function, cancelCB:Function):Void
	{
		this.clearPopup();
		this.doneCB = doneCB;
		this.cancelCB = cancelCB;
		
		var selectionPopup:SelectionPopup = new SelectionPopup(this.popupHolderMC);
		this.popup = selectionPopup;
		this.popup.doneCB = this.fn.doneCB;
		this.popup.cancelCB = this.fn.cancelCB;
		
		selectionPopup.createPopup(container);
	}
	
	public function showPlaybackResumePopup(timeInMillis:Number, doneCB:Function, cancelCB:Function):Void
	{
		this.clearPopup();
		this.doneCB = doneCB;
		this.cancelCB = cancelCB;
		
		var resumePopup:PlaybackResumePopup = new PlaybackResumePopup(this.popupHolderMC);
		this.popup = resumePopup;
		this.popup.doneCB = this.fn.doneCB;
		this.popup.cancelCB = this.fn.cancelCB;
		
		resumePopup.createPopup(timeInMillis);
	}
	
	public function showPlaybackOptionPopup(streamArray:Array, doneCB:Function, cancelCB:Function):Void
	{
		this.clearPopup();
		this.doneCB = doneCB;
		this.cancelCB = cancelCB;
		
		var optionPopup:PlaybackOptionPopup = new PlaybackOptionPopup(this.popupHolderMC);
		this.popup = optionPopup;
		this.popup.doneCB = this.fn.doneCB;
		this.popup.cancelCB = this.fn.cancelCB;
		
		optionPopup.createPopup(streamArray);
	}
	
	public function showMovieInfoPopup(media:MediaModel, container:ContainerModel, cancelCB:Function):Void
	{
		this.clearPopup();
		this.doneCB = null;
		this.cancelCB = cancelCB;
		
		var movieInfoPopup:MovieInfoPopup = new MovieInfoPopup(this.popupHolderMC);
		this.popup = movieInfoPopup;
		this.popup.doneCB = this.fn.doneCB;
		this.popup.cancelCB = this.fn.cancelCB;
		
		movieInfoPopup.createPopup(media, container);
	}
	
	public function showShowInfoPopup(media:MediaModel, container:ContainerModel, cancelCB:Function):Void
	{
		this.clearPopup();
		
		this.doneCB = null;
		this.cancelCB = cancelCB;
		
		var showInfoPopup:ShowInfoPopup = new ShowInfoPopup(this.popupHolderMC);
		this.popup = showInfoPopup;
		this.popup.doneCB = this.fn.doneCB;
		this.popup.cancelCB = this.fn.cancelCB;
		
		showInfoPopup.createPopup(media, container);
	}
	
	public function showEpisodeInfoPopup(media:MediaModel, container:ContainerModel, cancelCB:Function):Void
	{
		this.clearPopup();
		
		this.doneCB = null;
		this.cancelCB = cancelCB;
		
		var episodeInfoPopup:EpisodeInfoPopup = new EpisodeInfoPopup(this.popupHolderMC);
		this.popup = episodeInfoPopup;
		this.popup.doneCB = this.fn.doneCB;
		this.popup.cancelCB = this.fn.cancelCB;
		
		episodeInfoPopup.createPopup(media, container);
	}
	
	private function clearPopup():Void
	{
		this.popup.destroy();
		delete this.popup;
		this.popup = null;
	}
	
	private function onPopupDone():Void
	{
		this.clearPopup();
		this.doneCB.apply(null, arguments);
	}
	
	private function onPopupCancel():Void
	{
		this.clearPopup();
		this.cancelCB();
	}
}