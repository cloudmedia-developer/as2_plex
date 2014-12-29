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
import syabasAS2.event.LoadEvent;
import syabasAS2.image.QueueLoader;
import syabasAS2.utils.Assign;

class syabasAS2.image.QueueLoaderEX {
	private var queueloader			:QueueLoader;
	private var properties			:Object;
	private var allcompletefunc		:Function;
	public  var EVENT_INIT			:String = "loadInit";
	public  var EVENT_ERROR			:String = "loadError";
	public  var EVENT_COMPLETE		:String = "loadComplete";
	public  var EVENT_ALL_COMPLETE	:String = "loadAllComplete";
	
	public function QueueLoaderEX(reference, allcomplete:Function) {
		this.allcompletefunc 	= Assign.create(reference, allcomplete);
		this.properties			= new Object();
		this.queueloader 		= new QueueLoader();
		this.queueloader.addEvent(this.EVENT_ALL_COMPLETE, 	this, "all_complete");
		this.queueloader.addEvent(this.EVENT_INIT, 			this, "init");
		this.queueloader.addEvent(this.EVENT_COMPLETE, 		this, "complete");
	}
	
	public function load(url:String, mc:MovieClip, properties:Object):Void {
		this.properties[mc._target] = properties;
		this.queueloader.load(url, mc);
	}
	
	private function init(event:LoadEvent):Void {
		if (this.properties[event.content._target]) {
			for (var name:String in this.properties[event.content._target]) 
			{
				event.content[name]	= this.properties[event.content._target][name];
			}
			if (!this.properties[event.content._target]._alpha) 	event.content._alpha 	= 100;
			if (!this.properties[event.content._target]._visible) 	event.content._visible 	= true;
		}
	}
	
	private function complete(event:LoadEvent):Void {
		if (this.properties[event.content._target]) {
			event.content._alpha 	= 0;
			event.content._visible 	= false;
		}
	}
	
	private function all_complete(event:LoadEvent):Void {
		for (var name:String in this.properties) 
		{
			delete this.properties[name];
			this.properties[name] = null;
		}
		delete this.properties;
		this.properties = null;
		this.allcompletefunc();
	}
	
	public function single_error_callback(reference, listener:String):Void {
		this.queueloader.addEvent(this.EVENT_ERROR, reference, listener);
	}
}