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
* Version 1.0.0
*
* Developer: Syabas Technology Sdn. Bhd.
***************************************************/
import flash.display.BitmapData;
import syabasAS2.loader.event.LoaderErrorEvent;
import syabasAS2.loader.event.LoaderEvent;
import syabasAS2.event.dispatcher.Caster;
import syabasAS2.loader.data.LoaderContent;
import syabasAS2.loader.image.ImageLoader;
import syabasAS2.loader.interfaces.ILoader;
import syabasAS2.utils.Destructor;

/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.loader.image.BitmapLoader extends Caster implements ILoader
{
	private var loader:ImageLoader;
	private var bitmap:BitmapData;
	
	public function BitmapLoader() {
		this.loader = new ImageLoader();
	}
	
	/**
	 * load bitmap
	 * @param	url			url of image
	 * @param	content		loader content object
	 */
	public function load(url:String, content:LoaderContent):Void {
		var temp:MovieClip 				= _root.createEmptyMovieClip("___temp_mc___" + _root.getNextHighestDepth(), _root.getNextHighestDepth());
		var bmpcontainer:MovieClip		= temp;
		content.target = bmpcontainer;
		this.loader.addEventListener(LoaderEvent.COMPLETE		, this, "onComplete");
		this.loader.addEventListener(LoaderEvent.ERROR			, this, "onError");
		this.loader.load(url, content);
	}
	
	public function kill():Void {
		Destructor.kill(this);
	}
	
	public function onComplete(event:LoaderEvent):Void {
		this.bitmap	= new BitmapData(event.content.target._width, event.content.target._height, true, null);
		this.bitmap.draw(event.content.target);
		Destructor.cleanMC(event.content.target);
		event.content.target = this.bitmap;
		this.castEvent(event);
		this.kill();
	}
	
	public function onError(event:LoaderErrorEvent):Void {
		this.castEvent(event);
		this.kill();
	}
}