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
* Class Description: Popup for confirmation
*
***************************************************/

import com.syabas.as2.plex.component.Popup;
import com.syabas.as2.plex.Share;

class com.syabas.as2.plex.component.ConfirmationPopup extends Popup
{
	public function ConfirmationPopup(mc:MovieClip)
	{
		super(mc);
		this.config = { row:1 };
	}
	
	public function createPopup(title:String, message:String):Void
	{
		this.createMC();			// Attach the movie clip
		this.createGrid();			// Create the grid object
		
		this.popupMC.txt_title.htmlText = Share.returnStringForDisplay(title);				// Set the header title
		this.popupMC.txt_message.htmlText = Share.returnStringForDisplay(message);			// Set the message
		
		this.grid.xMCArray = [ [ this.popupMC.btn_confirm, this.popupMC.btn_cancel ] ];		// Set the movie clips to grid
		this.grid.data = [ { title:Share.getString("btn_ok") }, { title:Share.getString("btn_cancel") } ];		// Set the data
		
		this.grid.createUI();
		this.grid.highlight();
	}
	
	private function createMC():Void
	{
		this.popupMC.removeMovieClip();
		this.popupMC = this.parentMC.attachMovie("confirmationPopupMC", "mc_confirmationPopup", this.parentMC.getNextHighestDepth());
	}
	
	// Overwrite the enterCB from parent class
	private function enterCB(o:Object):Void
	{
		if (o.dataIndex == 0)
		{
			this.doneCB();
		}
		else
		{
			this.cancelCB();
		}
	}
}
