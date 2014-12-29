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
/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.event.dispatcher.Caster
{
	
	private var eventListeners:Object;
	
	public function Caster() {
		this.eventListeners = new Object();
	}
	
	/**
	 * add an event listener
	 * @param	event				event type
	 * @param	reference			the listener reference	
	 * @param	eventListener		the listener function
	 */
	public function addEventListener(event:String, reference, eventListener:String):Void {
		if (!this.eventListeners[event]) {	
			this.eventListeners[event] = new Object();										
		}
		if (!this.eventListeners[event][eventListener]) {	
			this.eventListeners[event][eventListener] = Assign.create(reference, reference[eventListener]);
		}
	}
	
	/**
	 * remove an event listener
	 * @param	event				event type
	 * @param	eventListener		the listener function
	 */
	public function removeEventListener(event:String, eventListener:String):Void {
		if (this.eventListeners[event]) {
			if (this.eventListeners[event][eventListener]) {
				delete this.eventListeners[event][eventListener];
			}
		}
	}
	
	/**
	 * remove all event listener of a target event type
	 * @param	event				event type
	 */
	public function removeAllEventListener(event:String):Void {
		if (this.eventListeners[event]) {
			for (var eventListener:String in this.eventListeners[event]) {
				delete this.eventListeners[event][eventListener];
			}
		}
	}
	
	/**
	 * Cast an event 
	 * @param	event				event type
	 */
	public function castEvent(event:Object):Void {
		for (var eventListener:String in this.eventListeners[event.type]) {
			this.eventListeners[event.type][eventListener](event);
		}
	}
}
	