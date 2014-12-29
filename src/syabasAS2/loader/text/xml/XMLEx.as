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
import syabasAS2.loader.data.LoaderContent;
import syabasAS2.loader.event.LoaderErrorEvent;
import syabasAS2.loader.event.LoaderEvent;
import syabasAS2.loader.interfaces.ILoader;
import syabasAS2.loader.text.xml.XMLHunt;
import syabasAS2.loader.text.xml.XMLLite;
import syabasAS2.utils.Destructor;

class syabasAS2.loader.text.xml.XMLEx extends Caster implements ILoader {
	private var xmlhunt			:XMLHunt;
	private var extra			:Object;
	
	public function XMLEx() {
		
	}
	
	public function load(url:String, content:LoaderContent):Void {
		this.extra = content.extra;
		new XMLLite(url, this, onComplete, onError);
	}
	
	public function kill():Void {
		this.xmlhunt.kill();
		Destructor.kill(this);
	}
	
	public function onComplete(event:LoaderEvent):Void {
		this.xmlhunt = new XMLHunt(event.target.data);
		this.castEvent(new LoaderEvent(LoaderEvent.COMPLETE, this, new LoaderContent(LoaderContent.TYPE_XML, event.target.data, this.extra, this.xmlhunt)));
		this.kill();
	}
	
	public function onError(event:LoaderErrorEvent):Void {
		this.castEvent(new LoaderErrorEvent(LoaderEvent.ERROR, this, null));
		this.kill();
	}
}