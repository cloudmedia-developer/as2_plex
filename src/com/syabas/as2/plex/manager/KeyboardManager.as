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
* Class Description: Class managing the keyboard
***************************************************/

import com.syabas.as2.plex.Share;

import com.syabas.as2.common.JSONUtil;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.VKMain;

import mx.utils.Delegate;

class com.syabas.as2.plex.manager.KeyboardManager
{
	private var keyboardMC:MovieClip = null;
	private var keyboardMain:VKMain = null;
	private var keyboardData:Object = null;
	private var numericData:Object = null;
	
	private var doneCB:Function = null;
	private var cancelCB:Function = null;
	
	public function KeyboardManager(mc:MovieClip)
	{
		this.keyboardMC = mc;
		
		
		Util.loadURL("data/search_keyboard_data.json", Delegate.create(this, this.keyboadDataLoaded), { isNumeric:false } );
		Util.loadURL("data/numeric_keyboard_data.json", Delegate.create(this, this.keyboadDataLoaded), { isNumeric:true } );
	}
	
	/*
	 * Show the keyboard and start inputing
	 */
	public function startKeyboard(doneCB:Function, cancelCB:Function, title:String, initialText:String, isPassword:Boolean, isNumeric:Boolean):Void
	{
		this.doneCB = doneCB;
		this.cancelCB = cancelCB;
		
		var keyboardObject:Object = new Object();
		keyboardObject.onDoneCB = Delegate.create(this, this.onKeyInputDone);
		keyboardObject.onCancelCB = Delegate.create(this, this.onKeyboardInputCancel);
		keyboardObject.showPassword = isPassword;
		keyboardObject.title = title;
		keyboardObject.initValue = initialText;
		keyboardObject.parentPath = Share.APP_LOCATION_URL;
		keyboardObject.keyboard_data = (isNumeric ? this.numericData : this.keyboardData);
		keyboardObject.isNumeric = isNumeric;
		
		if (this.keyboardMain == null)
		{
			this.keyboardMain = new VKMain();
			this.keyboardMain.startVK(this.keyboardMC, keyboardObject);
		}
		else
		{
			this.keyboardMain.restartVK(keyboardObject);
		}
	}
	
	//------------------------------------------- Callbacks -----------------------------------------------
	private function keyboadDataLoaded(success:Boolean, data:String, o:Object):Void
	{
		if (success)
		{
			if (o.o.isNumeric)
			{
				this.numericData = JSONUtil.parseJSON(data).keyboard_data;
			}
			else
			{
				this.keyboardData = JSONUtil.parseJSON(data).keyboard_data;
			}
		}
	}
	
	private function onKeyInputDone():Void
	{
		var displayText:String = this.keyboardMain.getDisplayText();
		var actualText:String = this.keyboardMain.getText();
		
		this.doneCB( { text:actualText, display:displayText } );
		this.keyboardMain.hideVK();
	}
	
	private function onKeyboardInputCancel():Void
	{
		this.keyboardMain.hideVK();
		this.cancelCB();
	}
}