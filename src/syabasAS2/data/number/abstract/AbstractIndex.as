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
import syabasAS2.data.number.event.IndexEvent;
import syabasAS2.event.dispatcher.Caster;

class syabasAS2.data.number.abstract.AbstractIndex extends Caster {
	private var _total							:Number	= 0							;
	private var _index							:Number = 0							;
	private var _prevIndex						:Number								;
	private var direction						:String								;
	private var isCasting						:Boolean = true;
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		INDEX GETTER SETTER					///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function set index(value:Number):Void {
		this._prevIndex = this._index;
		if (value <= this._total-1 && value >= 0) {
			if (value >= this._index) 		this.direction = "down";
			else 							this.direction = "up";
			
			this._index = value;
			if (this.isCasting) {
				this.castEvent( new IndexEvent(IndexEvent.INDEX_CHANGE, this, this.index, this.previousIndex, this.direction) );
			}
		}
		else {
			if (this._index == this._total - 1) {
				if (this.isCasting) {
					this.castEvent( new IndexEvent(IndexEvent.INDEX_MAX, this, this.index, this.previousIndex, this.direction) );
				}
			}
			else if (this._index == 0) {
				if (this.isCasting) {
					this.castEvent( new IndexEvent(IndexEvent.INDEX_MIN, this, this.index, this.previousIndex, this.direction) );
				}
			}
		}
	}

	public function get index():Number {
		return this._index;
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		TOTAL GETTER SETTER					///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function set total(value:Number):Void {
		this._total = value >= 0 ? value : 0;
	}
	
	public function get total():Number {
		if (this._total == 0) {
			trace("[INDEX-ERROR] total is 0")
		}
		return this._total;
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		PREVIOUS INDEX GETTER				///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function get previousIndex():Number {
		return this._prevIndex;
	}
}