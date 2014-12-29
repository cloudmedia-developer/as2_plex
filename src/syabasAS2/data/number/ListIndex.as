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
import syabasAS2.data.number.event.ListIndexEvent;
import syabasAS2.data.number.Index;
import syabasAS2.data.number.interfaces.IBasicIndexOperation;
import syabasAS2.event.dispatcher.Caster;
/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.data.number.ListIndex extends Caster implements IBasicIndexOperation
{
	private var _realIndex:Index;
	private var _displayIndex:Index;
	
	public function ListIndex() {
		this._realIndex 		= new Index();
		this._realIndex.addEventListener(IndexEvent.INDEX_CHANGE		, this, "dispatch_realIndex_events");
		this._realIndex.addEventListener(IndexEvent.INDEX_MIN			, this, "dispatch_realIndex_events");
		this._realIndex.addEventListener(IndexEvent.INDEX_MAX			, this, "dispatch_realIndex_events");
		
		this._displayIndex 		= new Index();
		this._displayIndex.addEventListener(IndexEvent.INDEX_CHANGE		, this, "dispatch_displayIndex_change");
		this._displayIndex.addEventListener(IndexEvent.INDEX_MIN		, this, "dispatch_displayIndex_min");
		this._displayIndex.addEventListener(IndexEvent.INDEX_MAX		, this, "dispatch_displayIndex_max");
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		INDEXS OPERATION					///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function plus(number:Number):Void {
		this._displayIndex.plus(number);
		this._realIndex.plus(number);
	}
	
	public function minus(number:Number):Void {
		this._displayIndex.minus(number);
		this._realIndex.minus(number);
	}
	
	public function reset():Void {
		this._displayIndex.reset();
		this._realIndex.reset();
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		DISPATCH EVENT						///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private function dispatch_realIndex_events(event:IndexEvent):Void {
		this.castEvent(event);
	}
	
	private function dispatch_displayIndex_change(event:IndexEvent):Void {
		this.castEvent(new ListIndexEvent(ListIndexEvent.DISPLAY_INDEX_CHANGE, this, event.currentIndex, event.previousIndex, event.direction));
	}
	
	private function dispatch_displayIndex_min(event:IndexEvent):Void {
		if (this._realIndex.index != 0) {
			this.castEvent(new ListIndexEvent(ListIndexEvent.DISPLAY_INDEX_MIN, this, event.currentIndex, event.previousIndex, event.direction));
		}
	}
	
	private function dispatch_displayIndex_max(event:IndexEvent):Void {
		if (this._realIndex.index != this._realIndex.total - 1) {
			this.castEvent(new ListIndexEvent(ListIndexEvent.DISPLAY_INDEX_MAX, this, event.currentIndex, event.previousIndex, event.direction));
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		GETTER AND SETTER					///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function set index(value:Number):Void {
		this._realIndex.index = value;
	}
	
	public function get index():Number {
		return this._realIndex.index;
	}
	
	public function set total(value:Number):Void {
		this._realIndex.total = value;
	}
	
	public function get total():Number {
		return this._realIndex.total;
	}
	
	public function set displayIndex(value:Number):Void {
		this._displayIndex.index = value
	}
	
	public function get displayIndex():Number {
		return this._displayIndex.index;
	}
	
	public function set displayTotal(value:Number):Void {
		this._displayIndex.total = value;
	}
	
	public function get displayTotal():Number {
		return this._displayIndex.total;
	}
	
}