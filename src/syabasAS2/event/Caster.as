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
import syabasAS2.utils.Assign;

class syabasAS2.event.Caster {
	private var caster_func			:Object;
	private var caster_record		:Array;
	private var caster_is_casting	:Boolean = false;
	
	public function Caster() {
		this.caster_func 	= new Object();
		this.caster_record 	= new Array();
	}
	
	public function addEvent(event:String, reference, listener:String):Void {
		var event_name:String = "__caster__" + event;
		if (this.caster_is_casting) {
			this.caster_record.push( { event:event, listener:listener, type:"add", reference:reference } );
		}
		else {
			if (!this.caster_func[event_name]) {
				this.caster_func[event_name] 		= new Object();
			}
			this.caster_func[event_name][listener] 	= Assign.create(reference, reference[listener]);
		}
	}
	
	public function removeEvent(event:String, listener:String):Void {
		var event_name:String = "__caster__" + event;
		if (this.caster_is_casting) {
			this.caster_record.push( { event:event, listener:listener, type:"remove" } );
		}
		else {
			delete this.caster_func[event_name][listener];
		}
	}
	
	public function switchEvent(event:String, ref, oldListener:String, newListener:String):Void {
		this.removeEvent(event, oldListener);
		this.addEvent(event, ref, newListener);
	}
	
	public function castEvent(obj:Object):Void {
		var event_name:String 		= "__caster__" + obj.type;
		this.caster_is_casting 		= true;
		for (var listener:String in this.caster_func[event_name]) {
			this.caster_func[event_name][listener](obj)
		}
		this.caster_is_casting = false;
		if (this.caster_record.length != 0) {
			var target:Array 	= this.caster_record;
			var length:Number 	= target.length;
			for (var i:Number = 0; i < length; i++) {
				if (target[i].type == "add") {
					this.addEvent(target[i].event, target[i].reference, target[i].listener);
				}
				else if (target[i].type == "remove") {
					this.removeEvent(target[i].event, target[i].listener);
				}
			}
			while (target.length != 0) {
				target.pop();
			}
		}
	}
	
	private function _debug_trace():Void {
		for (var event:String in this.caster_func) 
		{
			trace("- event name: " + event);
			for (var listener:String in this.caster_func[event]) 
			{
				trace(listener);
			}
			trace("----------------------------------------------")
		}
	}
	
	public function exist(event:String, listener:String):Boolean {
		var event_name:String 		= "__caster__" + event;
		if (this.caster_func[event_name][listener] == undefined) {
			return false;
		}
		else {
			return true;
		}
	}
	
	public function getListeners(event:String):Object {
		var event_name:String 		= "__caster__" + event;
		return this.caster_func[event_name];
	}
}
	