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
* Class Description: The login deck class
*
***************************************************/
import com.syabas.as2.plex.api.API;
import com.syabas.as2.plex.component.DeckBase;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Grid2;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
class com.syabas.as2.plex.component.LoginDeck extends DeckBase
{
	private var klObject:Object = null;				// The key listener object
	private var pollInterval:Number = null;			// The interval ID for polling the login status
	
	private var loginCode:String = null;			// The code to be displayed
	private var loginID:String = null;				// The ID to be used to poll login status
	
	
	public function destroy():Void
	{
		clearInterval(this.pollInterval);
		this.pollInterval = null;
		
		Key.removeListener(this.klObject);
		this.klObject.onKeyDown = null;
		delete this.klObject;
		this.klObject = null;
		
		this.loginCode = null;
		this.loginID = null;
		
		super.destroy();
	}
	
	public function LoginDeck(mc:MovieClip)
	{
		super(mc);
		
		this.klObject = new Object();
		Key.addListener(this.klObject);
		
		mc.btn_newCode.txt_title.htmlText = Share.getString("btn_new_code");
		mc.txt_title.htmlText = Share.getString("login_instruction");
	}
	
	/*
	 * Overwrite super class
	 */
	public function enable():Void
	{
		this.klObject.onKeyDown = Delegate.create(this, this.onKeyDown);
	}
	
	/*
	 * Overwrite super class
	 */
	public function disable():Void
	{
		this.klObject.onKeyDown = null;
		
		clearInterval(this.pollInterval);
		this.pollInterval = null;
		
		this.loginCode = null;
		this.loginID = null;
		this.deckMC.txt_code.text = "";
		
		this.loadingMC.removeMovieClip();
		delete this.loadingMC;
		this.loadingMC = null;
	}
	
	/*
	 * Overwrite super class
	 */
	public function showDeck():Void
	{
		this.isShown = true;
		this.deckMC._visible = true;
		
		// start getting the code
		this.getCode();
	}
	
	/*
	 * Overwrite super class
	 */
	public function hideDeck():Void
	{
		this.isShown = false;
		this.deckMC._visible = false;
	}
	
	/*
	 * Overwrite super class
	 */
	public function available():Boolean
	{
		return true;
	}
	
	
	/*
	 * Get the login code
	 */
	private function getCode():Void
	{
		this.klObject.onKeyDown = null;
		
		clearInterval(this.pollInterval);
		this.pollInterval = null;
		
		this.showLoading(true);
		this.deckMC.btn_newCode.gotoAndStop("unhl");
		
		Share.api.getPlexLoginCode(Delegate.create(this, this.onCodeLoaded));
	}
	
	private function onCodeLoaded(success:Boolean, httpStatus:Number, data:Object):Void
	{
		if (success)
		{
			this.showLoading(false);
			
			this.loginCode = data.code;
			this.loginID = data.id;
			
			this.deckMC.txt_code.text = data.code;
			this.deckMC.btn_newCode.gotoAndStop("hl");
			
			// Activate the key listener
			this.klObject.onKeyDown = Delegate.create(this, onKeyDown);
			
			// start polling process
			this.pollInterval = setInterval(Delegate.create(this, poll), 3000);
			
		}
		else
		{
			//Show error
			
			if (httpStatus < 100 || httpStatus == null || httpStatus == undefined)
			{
				// no connection
				Share.POPUP.showMessagePopup(Share.getString("error_no_connection_title"), Share.getString("error_no_connection"), Delegate.create(this, this.closeLoginDeck));
			}
			else
			{
				// Other unknown error
				Share.POPUP.showMessagePopup(Share.getString("error_unknown_title"), Share.getString("error_unknown"), Delegate.create(this, this.closeLoginDeck));
			}
		}
	}
	
	private function poll():Void
	{
		Share.api.pollLoginStatus(loginID, Delegate.create(this, onPollLoaded));
	}
	
	private function onPollLoaded(success:Boolean, httpStatus:Number, data:Object):Void
	{
		if (success)
		{
			var authToken:String = data.authToken;
			
			if (authToken != null && authToken != undefined && authToken.length > 0)
			{
				// Login confirmed 
				Share.MY_PLEX_TOKEN = authToken;
				Share.saveSharedObject();
				
				this.overLeft(true);
				this.disable();
				this.hideDeck();
			}
		}
	}
	
	public function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();
		
		switch (keyCode)
		{
			case Key.LEFT:
				// return back to menu and close this deck
				this.closeLoginDeck();
				break;
			case Key.ENTER:
				// get new code
				this.getCode();
				break;
		}
	}
	
	private function closeLoginDeck():Void
	{
		this.overLeft();
		this.disable();
		this.hideDeck();
	}
	
	private function showLoading(show:Boolean):Void
	{
		if (show)
		{
			if (this.loadingMC == null)
			{
				this.loadingMC = this.deckMC.attachMovie("loadingMC", "mc_loading", this.deckMC.getNextHighestDepth(), { _x:this.deckMC.txt_code._x + (this.deckMC.txt_code._width / 2), _y:this.deckMC.txt_code._y + (this.deckMC.txt_code._height / 2) } );
			}
		}
		else
		{
			this.loadingMC.removeMovieClip();
			delete this.loadingMC;
			this.loadingMC = null;
		}
	}
}