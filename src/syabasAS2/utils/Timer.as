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
import syabasAS2.event.Caster;
import syabasAS2.event.TimerEvent;

class syabasAS2.utils.Timer extends Caster {
	private var delay					:Number;
	private var count					:Number;
	private var repeat					:Number;
	private var interval				:Number;
	private var isTimerRunning			:Boolean;
	public  var EVENT_TIMER				:String		= "timer";
	public  var EVENT_TIMER_COMPLETE	:String		= "timerComplete";
	
	public function Timer(delay:Number, repeat:Number, autoStart:Boolean) {
		this.count 		= 0;
		this.delay 		= delay;
		this.repeat 	= repeat;
		if (autoStart)	this.start();
	}

	public function get currentCount()	:Number 	{	return this.count;			}
	public function get currentIndex()	:Number 	{	return this.count - 1;		}
	public function get delayInterval()	:Number 	{	return this.delay;			}
	public function get repeatCount()	:Number 	{	return this.repeat;			}
	public function get isRunning()		:Boolean 	{	return this.isTimerRunning;	}
	
	public function set delayTime(delay:Number):Void {
		this.delay = delay;
	}

	public function set repeatCount(repeat:Number):Void {
		if (isFinite(repeat) && repeat >= 0) {
			this.repeat = repeat;
		}
		else {
			throw new Error("Repeat must be more than or equal to 0");
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public function reset():Void {
		this.count = 0;
	}
	
	public function stopReset(){
		this.stop();
		this.reset();
	}
	
	public function start():Void {
		if (!this.isTimerRunning) {
			clearInterval(this.interval);
			this.interval 			= setInterval(this, "onTimerStart", this.delay);
			this.isTimerRunning 	= true;
		}
	}

	public function stop():Void {
		clearInterval(this.interval);
		this.isTimerRunning = false;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	private function onTimerStart():Void {
		this.count ++;
		this.castEvent(new TimerEvent(this, this.EVENT_TIMER));
		if (this.repeat!= 0) {
			if (this.count == this.repeat) {
				this.stop();
				this.castEvent(new TimerEvent(this, this.EVENT_TIMER_COMPLETE));
			}
		}
	}
}