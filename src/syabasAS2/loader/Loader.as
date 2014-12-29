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
import syabasAS2.data.collector.Collector;
import syabasAS2.data.number.Counter;
import syabasAS2.event.dispatcher.Caster;
import syabasAS2.loader.data.LoaderContent;
import syabasAS2.loader.event.LoaderErrorEvent;
import syabasAS2.loader.event.LoaderEvent;
import syabasAS2.loader.image.BitmapLoader;
import syabasAS2.loader.image.ImageLoader;
import syabasAS2.loader.interfaces.ILoader;
import syabasAS2.loader.text.JSONLoader;
import syabasAS2.loader.text.xml.XMLLoader;
import syabasAS2.utils.Destructor;
/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.loader.Loader extends Caster
{
	private var loader:ILoader;
	private var counter:Counter;
	private var isDebugging:Boolean = true;
	public 	var zzzz:Boolean = true;
	
	public function Loader(isDebugging:Boolean) {
		if (isDebugging != undefined) {
			this.isDebugging = isDebugging;
		}
		this.counter 		= new Counter();
		this.counter.addEventListener(this.counter.EVENT_MIN, this, "onAllComplete");
	}
	
	/**
	 * load multiple type of content
	 * @param	url			url of image / xml / api / phf name
	 * @param	content		loader content object
	 */
	public function load(url:String, content:LoaderContent):Void {
		switch (content.type) {
			case LoaderContent.TYPE_IMAGE		: 	this.loader = new ImageLoader();		break;
			case LoaderContent.TYPE_BITMAP		: 	this.loader = new BitmapLoader();		break;
			case LoaderContent.TYPE_XML			:	this.loader = new XMLLoader();			break;
			case LoaderContent.TYPE_JSON		:	this.loader = new JSONLoader();			break;
		}
		this.loader.addEventListener(LoaderEvent.COMPLETE		, this, "onComplete"	);
		this.loader.addEventListener(LoaderEvent.ERROR			, this, "onError"		);
		this.loader.load(url, content);
		this.counter.plus();
	}
	
	private function kill():Void {
		Destructor.kill(this)
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		EVENT								///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private function onComplete(event:LoaderEvent):Void {
		this.castEvent(event);
		this.counter.minus();
	}
	
	private function onAllComplete(event:LoaderEvent):Void {
		this.castEvent(new LoaderEvent(LoaderEvent.ALL_COMPLETE));
		this.kill();
	}
	
	private function onError(event:LoaderErrorEvent):Void {
		this.castEvent(event);
		this.counter.minus();
		this.kill();
	}
}