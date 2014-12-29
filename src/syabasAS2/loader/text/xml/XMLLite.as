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
import syabasAS2.event.common.XMLEvent;
import syabasAS2.utils.Destructor;
import syabasAS2.utils.Assign;

class syabasAS2.loader.text.xml.XMLLite {
	private var xml				:XML;
	private var xmlloaded		:Function;
	private var xmlerror		:Function;
	private var EVENT_COMPLETE	:String 	= "xmlComplete";
	private var EVENT_ERROR		:String		= "xmlError";
	
	public function XMLLite(url:String, ref, loaded:Function, error:Function) {
		if (ref) {
			if (loaded)				this.xmlloaded 		= Assign.create(ref, loaded);
			if (error)				this.xmlerror 		= Assign.create(ref, error);
		}
		this.xml					= new XML();
		this.xml.ignoreWhite 		= true;
		this.xml.onLoad 			= Assign.create(this, xmlLoaded);
		this.xml.load(url);
	}

	public function get data():Object {
		return this.xml.firstChild;
	}
	
	private function xmlLoaded(success:Boolean) {
		if (success) 		this.xmlloaded(new XMLEvent(this, this.EVENT_COMPLETE));
		else				this.xmlerror(new XMLEvent(this, this.EVENT_ERROR));
		this.kill();
	}
	
	private function kill():Void {
		Destructor.kill(this.xml.firstChild);
		Destructor.kill(this.xml.lastChild);
		Destructor.kill(this.xml);
		Destructor.kill(this);
	}
}