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
import syabasAS2.utils.Timer;

class syabasAS2.utils.Marquee extends Caster{
	public static var self:Marquee;
//----------------------------------------------------------------------------------------------------------	
	private var target				:TextField;
	private var targetBK			:TextField;
	private var textFormat			:TextFormat;
//----------------------------------------------------------------------------------------------------------
	private var targetLength		:Number;
	private var milispeed			:Number;
	private var count				:Number;
	private var allocateSize		:Number;
	private var speed				:Number 	= 2;
	private var delay				:Number 	= 2;
	private var targetText			:String 	= " ";
	private var tempstr				:String;
//----------------------------------------------------------------------------------------------------------	
	private var isInit				:Boolean 	= false;
	private var callback			:Function
	private var timer				:Timer;
//----------------------------------------------------------------------------------------------------------
	public  var EVENT_NO_MARQUEE	:String 	= "marqueeNotStarted";
	public  var EVENT_REPEAT		:String 	= "marqueeRepeat";
	
	
	public function Marquee() {
		Marquee.self 			= this;
		this.milispeed			= this.speed * 100;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public function start(tf:TextField):Void {
		if (this.targetBK == tf || this.target == tf) {
			tf.text 				= this.targetText;
			this.resetFormat();
			this.targetBK 			= null;
			this.target 			= null;
			this.targetText 		= undefined;
		}
		if (this.targetText 		!= " " 				&& 
			this.targetText 		!= undefined 		&& 
			String(this.targetText) != "undefined") {
				this.target.text 	= this.targetText;
				this.resetFormat();
		}
		if (this.isInit) {
			this.stopTimer();
		}
//----------------------------------------------------------------------------------------------------------
		this.timer.stop();
		this.isInit 				= true;
		this.count 					= 0;
		this.target 				= tf;
		this.targetBK 				= tf;
		this.targetText 			= this.target.text;
		this.textFormat 			= this.target.getTextFormat();
//----------------------------------------------------------------------------------------------------------
		if ((this.target.textWidth+4) > this.target._width) {
			this.tempstr 			= this.targetText;
			while (this.target.textWidth > this.target._width) {
				this.target.text 	= this.target.text.substr(0, this.target.length - 1);
				this.resetFormat();
			}
			this.allocateSize 		= this.target.length;
			this.target.text 		= this.tempstr;
			this.resetFormat();
			for (var i = 0; i < this.allocateSize; i++) {
				this.target.text 	+= " ";
				this.resetFormat();
			}
			this.targetLength 		= this.target.length;
			this.countdown_timer_start();
		}
		else {
			this.castEvent( { type: this.EVENT_NO_MARQUEE } );
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public function stop():Void {
		this.start(null);
	}

	public function set marqueeSpeed(value:Number):Void {
		this.speed 		= value;
		this.milispeed 	= this.speed * 100;
	}

	public function set delayTime(value:Number):Void {
		this.delay 		= value;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	private function countdown_timer_start():Void {
		delete 		this.timer;
		this.timer 	= new Timer(1000, this.delay, true);
		this.timer.addEvent(this.timer.EVENT_TIMER_COMPLETE, this, "marquee_start");
	}

	private function marquee_start():Void {
		delete 		this.timer;
		this.timer 	= new Timer(milispeed, 0, true);
		this.timer.addEvent(this.timer.EVENT_TIMER, this, "marquee_ticking");
	}
	
	private function stopTimer():Void {
		this.timer.removeEvent(this.timer.EVENT_TIMER, 				"marquee_ticking");
		this.timer.removeEvent(this.timer.EVENT_TIMER_COMPLETE, 	"marquee_start");
		this.timer.stop(); 
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	private function marquee_ticking():Void {
		this.target.text = target.text.substr(1, target.text.length - 1) + target.text.substr(0, 1);
		this.resetFormat();
		this.count ++;
		if (this.count == targetLength) {
			this.target.text = targetText;
			this.resetFormat();
			this.castEvent( { type: this.EVENT_REPEAT } );
			this.start(this.target);
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	private function resetFormat():Void {
		this.target.setTextFormat(this.textFormat);
		if (this.targetBK.textColor != 0) {
			this.target.textColor = this.targetBK.textColor;
		}
	}
}