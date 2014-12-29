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
* Class Description: Base class for all popup in the app
*
***************************************************/
import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.UI;

import com.syabas.as2.plex.Share;

import mx.utils.Delegate;
class com.syabas.as2.plex.component.Popup
{
	private var parentMC:MovieClip = null;			// The parent movie clip to attach the popup
	private var popupMC:MovieClip = null;			// The popup movie clip
	public var doneCB:Function = null;				// Callback when the process is done
	public var cancelCB:Function = null;			// Callback when the process is canceled
	private var config:Object = null;				// Configuration object
	
	private var grid:GridLite = null;
	private var marquee:Marquee = null;
	
	public function destroy():Void
	{
		this.grid.destroy();
		delete this.grid;
		this.grid = null;
		
		this.popupMC.removeMovieClip();
		delete this.popupMC;
		this.popupMC = null;
		
		delete this.doneCB;
		delete this.cancelCB;
		
		this.doneCB = null;
		this.cancelCB = null;
		
		delete this.config;
		delete this.parentMC;
		
		this.config = null;
		this.parentMC = null;
	}
	
	public function Popup(mc:MovieClip)
	{
		this.parentMC = mc;
		this.marquee = new Marquee();
	}
	
	/*
	 * Create the poup. To be implemented by sub classes
	 */
	public function createPopup(o:Object):Void
	{
		
	}
	
	//---------------------------------- Grid -----------------------------------
	private function createGrid():Void
	{
		var row:Number = this.config.row;
		
		this.grid = new GridLite();
		this.grid.xMCArray = UI.attachMovieClip( { parentMC:this.popupMC, rSize:row, cSize:1 } );
		this.grid.xWrapLine = false;
		this.grid.xWrap = false;
		this.grid.xHLStopTime = 1000;
		this.grid.hlCB = Delegate.create(this, this.hlCB);
		this.grid.onHLStopCB = Delegate.create(this, this.hlStopCB);
		this.grid.unhlCB = Delegate.create(this, this.unhlCB);
		this.grid.onItemClearCB = Delegate.create(this, this.clearCB);
		this.grid.onItemUpdateCB = Delegate.create(this, this.updateCB);
		this.grid.onEnterCB = Delegate.create(this, this.enterCB);
		this.grid.onKeyDownCB = Delegate.create(this, this.keyDownCB);
		this.grid.overTopCB = Delegate.create(this, this.overTopCB);
		this.grid.overBottomCB = Delegate.create(this, this.overBottomCB);
	}
	
	private function clearCB(o:Object):Void
	{
		o.mc.txt_title.text = "";
	}
	
	private function updateCB(o:Object):Void
	{
		o.mc.txt_title.htmlText = Share.returnStringForDisplay(o.data.title);
	}
	
	private function hlCB(o:Object):Void
	{
		o.mc.gotoAndStop("hl");
	}
	
	private function hlStopCB(o:Object):Void
	{
		Share.startMarquee(this.marquee, o.mc.txt_title, this.config.titleMarqueeConfig);
	}
	
	private function unhlCB(o:Object):Void
	{
		this.marquee.stop();
		o.mc.gotoAndStop("unhl");
	}
	
	private function enterCB(o:Object):Void
	{
		// let sub class to implement
	}
	
	private function keyDownCB(o:Object):Void
	{
		// return key close popup
		var keyCode:Number = o.keyCode;
		if (keyCode == Key.BACK)
		{
			this.cancelCB();
		}
	}
	
	/*
	 * To be implemented by sub classes
	 */
	private function overTopCB():Boolean
	{
		return true;
	}
	
	/*
	 * To be implemented by sub classes
	 */
	private function overBottomCB():Boolean
	{
		return true;
	}
}