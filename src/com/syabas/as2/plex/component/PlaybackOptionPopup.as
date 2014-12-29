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
* Class Description: Popup for playback stream option
*
***************************************************/
import com.syabas.as2.plex.component.Popup;
import com.syabas.as2.plex.model.MediaElement;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.UI;

import mx.utils.Delegate;
class com.syabas.as2.plex.component.PlaybackOptionPopup extends Popup
{
	private var streamArray:Array = null;				// The array of stream for selection
	private var klObject:Object = null;					// The key listener for close button
	private var upIndicatorMC:MovieClip = null;			// The up arrow movie clip
	private var downIndicatorMC:MovieClip = null;		// The down arrown movie clip
	
	public function destroy():Void
	{
		delete this.streamArray;
		this.streamArray = null;
		
		Key.removeListener(this.klObject);
		this.klObject.onKeyDown = null;
		delete this.klObject;
		this.klObject = null;
		
		delete this.upIndicatorMC;
		delete this.downIndicatorMC;
		
		this.upIndicatorMC = null;
		this.downIndicatorMC = null;
		
		super.destroy();
	}
	
	public function PlaybackOptionPopup(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.playbackOptionConfig;
		this.klObject = new Object();
		Key.addListener(this.klObject);
	}
	
	/*
	 * Overwrite super class
	 */
	public function createPopup(streamArray:Array):Void
	{
		this.streamArray = streamArray;
		this.createMC();
		this.createGrid();
		
		this.grid.data = this.filterStreamArray(streamArray);
		this.grid.createUI();
		this.grid.highlight();
	}
	
	private function filterStreamArray(streamArray:Array):Array
	{
		var len:Number = streamArray.length;
		var stream:MediaElement = null;
		var newStreamArray:Array = new Array();
		for (var i:Number = 0; i < streamArray.length; i ++)
		{
			stream = streamArray[i];
			if (stream.container != "flv")
			{
				newStreamArray.push(stream);
			}
		}
		
		return newStreamArray;
	}
	
	private function createMC():Void
	{
		this.popupMC.removeMovieClip();
		this.popupMC = this.parentMC.attachMovie("playbackOptionPopupMC", "mc_playbackOptionPopup", this.parentMC.getNextHighestDepth());
		
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
			// the close button
			return;
		}
		
		var mediaStream:MediaElement = o.data;
		var resNumber:Number = new Number(mediaStream.videoResolution);
		var title:String = "";
		
		if (isNaN(resNumber))
		{
			title = mediaStream.videoResolution;
		}
		else
		{
			title = resNumber + "P";
		}
		
		title += " " + Share.returnStringForDisplay(mediaStream.videoCodec);
		
		o.mc.txt_title.text = title;
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
		this.doneCB(o.data);
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlCB(o:Object):Void
	{
		super.hlCB(o);
		
		if (this.grid._top > 0)
		{
			this.upIndicatorMC.gotoAndStop("on");
		}
		else
		{
			this.upIndicatorMC.gotoAndStop("off");
		}
		
		if (this.grid._len > this.grid._top + this.grid._size)
		{
			this.downIndicatorMC.gotoAndStop("on");
		}
		else
		{
			this.downIndicatorMC.gotoAndStop("off");
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function keyDownCB(o:Object):Void
	{
		var keyCode:Number = o.keyCode;
		if (keyCode == undefined)
		{
			keyCode = Key.getCode();
		}
		
		if (o == null || o == undefined)
		{
			o = new Object();
		}
		
		switch (keyCode)
		{
			case Key.DOWN:
				this.popupMC.btn_close.gotoAndStop("unhl");
				this.klObject.onKeyDown = null;
				this.grid.highlight();
				break;
			case Key.ENTER:
				this.cancelCB();
				break;
			case Key.BACK:
				this.cancelCB();
				break;
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function overTopCB():Boolean
	{
		this.popupMC.btn_close.gotoAndStop("hl");
		this.klObject.onKeyDown = Delegate.create(this, this.keyDownCB);
		return false;
	}
}