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
* Class Description: Base class for all kind deck presents on main menu
*
***************************************************/
import com.syabas.as2.plex.model.*;

import com.syabas.as2.common.Grid2;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.Marquee;

import mx.utils.Delegate;
class com.syabas.as2.plex.component.DeckBase
{
	public var overLeft:Function = null;			// Over left function called to return to main menu. Assign by MainMenuLayout.as
	public var onItemSelected:Function = null;		// On Enter function called to take action. Assign by MainMenuLayout.as
	public var loadFanartCB:Function = null;		// Function to load fanart. Assign by MainMenuLayout.as
	public var clearFanartCB:Function = null;		// Function to clear fanart. Assign by MainMenuLayout.as
	public var showLoadingMC:Function = null;		// Function to render a loading icon movie clip and return it
	
	public var homeMC:MovieClip = null;
	public var redMC:MovieClip = null;				// watched
	public var greenMC:MovieClip = null;			// green
	public var infoMC:MovieClip = null;
	
	private var deckMC:MovieClip = null;			// The deck movie clip
	private var loadingMC:MovieClip = null;			// The loading animation icon 
	private var pointerMC:MovieClip = null;			// The small triangle pointer movie clip
	
	private var config:Object = null;				// Configuration object for each deck's layout
	private var titleMarquee:Marquee = null;		// Marquee for title
	private var isShown:Boolean = false;			// A flag to tell whether the deck is shown
	
	public function destroy():Void
	{
		this.loadingMC.removeMovieClip();
		delete this.deckMC;
		delete this.loadingMC;
		
		this.titleMarquee.stop();
		delete this.titleMarquee;
		
		delete this.overLeft;
		delete this.onItemSelected;
		delete this.loadFanartCB;
		
		delete this.config;
		delete this.isShown;
		
		delete this.pointerMC;
	}
	
	public function DeckBase(mc:MovieClip)
	{
		this.deckMC = mc;
		this.titleMarquee = new Marquee();
	}
	
	/*
	 * Show the deck. To be implemented by sub classes
	 */
	public function showDeck(item:MediaModel, pointerMC:MovieClip):Void
	{
		
	}
	
	/*
	 * Hide the deck. To be implemented by sub classes
	 */
	public function hideDeck():Void
	{
		
	}
	
	/*
	 * Enable the deck navigation control. To be implemented by sub classes
	 */
	public function enable():Void
	{
		
	}
	
	/*
	 * Disable the deck navigation control. To be implemented by sub classes
	 */
	public function disable():Void
	{
		
	}
	
	/*
	 * To check whether this deck is available to be focused. To be overwritted by sub classes
	 */
	public function available():Boolean
	{
		return true;
	}

	
}