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
* Class Description: Popup for resume selection
*
***************************************************/
import com.syabas.as2.plex.component.Popup;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Util;

class com.syabas.as2.plex.component.PlaybackResumePopup extends Popup
{
	private var time:Number = null;			// The resume point in milli seconds
	
	public function destroy():Void
	{
		delete this.time;
		this.time = null;
		
		super.destroy();
	}
	
	public function PlaybackResumePopup(mc:MovieClip)
	{
		super(mc);
		this.config = { row:2 };
	}
	
	/*
	 * Overwrite super class
	 */
	public function createPopup(timeInMillis:Number):Void
	{
		this.time = timeInMillis;
		this.createMC();
		this.createGrid();
		
		this.grid.xMCArray.unshift([this.popupMC.btn_close]);
		
		var data:Array = [ { isClose:true }, { resume:true, title:Share.returnStringForDisplay(Util.replaceAll(Share.getString("resume_from_bookmark"), "|TIME|", Share.convertTime(timeInMillis))) }, 
							{ resume:false, title:Share.returnStringForDisplay(Share.getString("start_from_beginning")) } ];
		
		this.grid.data = data;
		this.grid.createUI();
		this.grid.highlight(1);
	}
	
	private function createMC():Void
	{
		this.popupMC.removeMovieClip();
		this.popupMC = this.parentMC.attachMovie("resumePopupMC", "mc_resumePopup", this.parentMC.getNextHighestDepth());
		
		this.popupMC.txt_title.text = Share.getString("selection_popup_title");
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
		super.updateCB(o);
	}
	
	/*
	 * Overwrite super class
	 */
	private function enterCB(o:Object):Void
	{
		if (o.data.isClose == true)
		{
			this.cancelCB();
			return;
		}
		this.doneCB(o.data.resume);
	}
}