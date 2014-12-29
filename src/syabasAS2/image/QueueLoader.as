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
import darien.debug.Tracer;
import syabasAS2.event.Caster;
import syabasAS2.event.LoadEvent;
import syabasAS2.image.SimpleLoader;
import syabasAS2.utils.Assign;

class syabasAS2.image.QueueLoader extends Caster {
	private var simpleloader		:SimpleLoader;
	private var count				:Number;
	private var queuelist			:Array;	
	public  var EVENT_INIT			:String = "loadInit";
	public  var EVENT_ERROR			:String = "loadError";
	public  var EVENT_COMPLETE		:String = "loadComplete";
	public  var EVENT_ALL_COMPLETE	:String = "loadAllComplete";
	
	public function QueueLoader() {
		super();
		this.count			= 0;
		this.queuelist		= new Array();
		this.simpleloader 	= new SimpleLoader();
		this.simpleloader.addEvent(this.EVENT_INIT, 	this, "init");
		this.simpleloader.addEvent(this.EVENT_ERROR, 	this, "error");
		this.simpleloader.addEvent(this.EVENT_COMPLETE,	this, "complete");
	}
	
	public function queue(url:String, mc:MovieClip):Void {
		this.queuelist.push( { url:url, mc:mc } );
	}
	
	public function start():Void {
		var length:Number = this.queuelist.length;
		for (var i:Number = 0; i < length; i++) {
			this.load(this.queuelist[i].url, this.queuelist[i].mc);
		}
		while (this.queuelist.length != 0) {
			this.queuelist.pop();
		}
	}
	
	public function load(url:String, mc:MovieClip):Void {
		this.count++;
		this.simpleloader.load(url, mc);
	}
	
	private function error(event:LoadEvent):Void {
		this.castEvent(new LoadEvent(this.EVENT_ERROR, 		event.content));
		this.check_count();
	}
	
	private function init(event:LoadEvent):Void {
		this.castEvent(new LoadEvent(this.EVENT_INIT, 		event.content));
		this.check_count();
	}
	
	private function complete(event:LoadEvent):Void {
		this.castEvent(new LoadEvent(this.EVENT_COMPLETE, 	event.content));
	}
	
	private function check_count():Void {
		this.count --;
		if (this.count == 0) {
			this.castEvent(new LoadEvent(this.EVENT_ALL_COMPLETE));
		}
	}
}