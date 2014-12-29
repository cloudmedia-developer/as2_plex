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
import com.adobe.stagecraft.FastJSON;
import syabasAS2.loader.event.LoaderErrorEvent;
import syabasAS2.loader.event.LoaderEvent;
import syabasAS2.event.dispatcher.Caster;
import syabasAS2.loader.data.LoaderContent;
import syabasAS2.loader.interfaces.ILoader;
import syabasAS2.loader.text.TextLoader;
import syabasAS2.utils.ts.StopWatch;
/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.loader.text.JSONLoader extends Caster implements ILoader
{
	
	public function JSONLoader() {
		
	}
	
	/**
	 * load xml
	 * @param	url			url of json
	 * @param	content		loader content object
	 */
	public function load(url:String, content:LoaderContent):Void {
		var loader:TextLoader = new TextLoader();
			loader.addEventListener(LoaderEvent.COMPLETE	, this, "onComplete");
			loader.addEventListener(LoaderEvent.ERROR		, this, "onError");
			loader.load(url, content);
	}
	
	public function kill():Void {
		
	}
	
	public function onComplete(event:LoaderEvent):Void {
		event.content.target = new FastJSON().turboParse(event.content.target);
		this.castEvent(event);
	}
	
	public function onError(event:LoaderErrorEvent):Void {
		this.castEvent(event);
	}
}