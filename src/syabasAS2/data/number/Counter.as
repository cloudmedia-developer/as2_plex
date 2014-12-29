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

/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.data.number.Counter extends Caster
{
	public 	var max			:Number = 0;
	private var index		:Number	= 0;
	public	var EVENT_MIN	:String = "eventMin";
	public 	var EVENT_MAX	:String = "eventMax";
	
	public function Counter(max:Number) {
		if (max != undefined) {
			this.max = max;
			trace("[NTS-DEBUG][Counter.as | Counter():void] this.max : " + this.max);
		}
	}
	
	public function plus():Void {
		if (this.max != 0 && this.max) {
			if (this.index < this.max - 1) {
				this.index ++;
			}
			else {
				this.castEvent( { type: this.EVENT_MAX } );
			}
		}
		else {
			this.index ++;
		}
	}
	
	public function minus():Void {
		this.index --;
		if (this.index == 0) {
			this.castEvent( { type: this.EVENT_MIN } );
		}
	}
}