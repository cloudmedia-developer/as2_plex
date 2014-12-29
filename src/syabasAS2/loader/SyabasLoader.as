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
import syabasAS2.data.collector.interfaces.IIterator;
import syabasAS2.loader.data.LoaderContent;
import syabasAS2.loader.event.LoaderEvent;
import syabasAS2.loader.QueueLoader;
import syabasAS2.loader.text.api.APILoader;
import syabasAS2.loader.text.api.PHFLoader;

/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.loader.SyabasLoader extends QueueLoader
{
	
	public function SyabasLoader(isDebugging:Boolean) {
		super(isDebugging);
	}
	
	public function load(url:String, content:LoaderContent):Void {
		switch (content.type) {
			case LoaderContent.TYPE_SYABAS_API	:	this.loader = new APILoader();			break;
			case LoaderContent.TYPE_SYABAS_PHF	:	this.loader = new PHFLoader();			break;
			default:
				super.load(url, content);
				return;
				break;
		}
		this.loader.addEventListener(LoaderEvent.COMPLETE	, this, "onComplete"	);
		this.loader.addEventListener(LoaderEvent.ERROR		, this, "onError"		);
		this.loader.load(url, content);
		this.counter.plus();
	}
	
	public function loadQueue():Void {
		var iter:IIterator = this.collection.toIterator();
		while (iter.hasNext()) {
			var loadobj:Object = iter.getNext();
			this.load(loadobj.url, loadobj.content);
		}
	}
}