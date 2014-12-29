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
import syabasAS2.event.dispatcher.Caster;
import syabasAS2.event.dispatcher.interfaces.ICaster;
import syabasAS2.image.common.SimpleLoader;
import syabasAS2.loader.data.LoaderContent;
import syabasAS2.loader.event.LoaderErrorEvent;
import syabasAS2.loader.event.LoaderEvent;
import syabasAS2.loader.interfaces.ILoader;
import syabasAS2.utils.ts.Bagus;

/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.loader.image.ImageLoader extends Caster implements ILoader
{
	private var loader							:SimpleLoader						;
	private var content							:LoaderContent						;
	
	public function ImageLoader() {
		this.loader = new SimpleLoader();
		this.loader.addEventListener(this.loader.EVENT_INIT		, this, "onComplete"	);
		this.loader.addEventListener(this.loader.EVENT_ERROR	, this, "onError"		);
	}
	
	/**
	 * load image
	 * @param	url			url of image
	 * @param	content		loader content object
	 */
	public function load(url:String, content:LoaderContent):Void {
		this.content = content;
		this.loader.load(url, content.target);
	}

	public function kill():Void {
		delete this.loader;
	}
	
	public function onComplete(event:LoaderEvent):Void {
		event.content.extra = this.content.extra;
		this.castEvent(new LoaderEvent(LoaderEvent.COMPLETE, event.target, event.content));
	}
	
	public function onError(event:LoaderErrorEvent):Void {
		this.castEvent(new LoaderErrorEvent(LoaderEvent.ERROR, event.target, null, event.content));
	}
	
}