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
import syabasAS2.data.collector.interfaces.IArrayList;
import syabasAS2.data.collector.interfaces.IIterator;
import syabasAS2.data.collector.iterators.ArrayIterator;
/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.data.collector.Collector implements IArrayList
{
	private var array:Array;
	
	public function Collector(array:Array) {
		if (array) {
			this.setArray(array);
		}
		else {
			this.array = new Array();
		}
	}
	
	public function setArray(array:Array):Void {
		this.array = array;
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		GET ITEM							///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function getAt(index:Number) {
		return this.array[index]
	}
	
	public function getAtFirst() {
		return this.getAt(0);
	}
	
	public function getAtLast() {
		return this.getAt(this.array.length - 1);
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		ADD ITEM							///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function add(item):Void {
		this.array.push(item);
	}
	
	public function addAt(index:Number, item):Number {
		if (index < this.array.length) {
			this.array.splice(index, 0, item);
			return index;
		} 
		else {
			return this.array.push(item) - 1;
		}
	}
	
	public function addAtFirst(item):Number {
		return this.addAt(0, item);
	}
	
	public function addAtLast(item):Number {
		return this.addAt(this.array.length, item);
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		REMOVE ITEM							///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function remove(item):Boolean {
		var length:Number = this.array.length;
		for (var i:Number = 0; i < length; i++) {
			if (this.array[i] == item) {
				this.array.splice(i, 1);
				break;
			}
		}
		return (length != this.array.length)
	}
	
	public function removeAll(item):Boolean {
		var length:Number = this.array.length;
		for (var i:Number = 0; i < length; i++) {
			if (this.array[i] == item) {
				this.array.splice(i, 1);
				i --;
			}
		}
		return (length != this.array.length)
	}
	
	public function removeAt(index:Number):Boolean {
		if (this.array[index]) {
			this.array.splice(index, 1);
			return true;
		}
		else {
			return false;
		}
	}
	
	public function removeAtFirst():Boolean {
		return this.removeAt(0);
	}
	
	public function removeAtLast():Boolean {
		return this.removeAt(this.array.length - 1);
	}
	
	public function clear():Void {
		var length:Number = this.array.length;
		for (var i:Number = 0; i < length; i++) {
			this.array[i].removeMovieClip();
		}
		this.array = new Array();
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		REPLACE ITEM						///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function replaceAt(index:Number, item):Boolean {
		if (index < this.array.length) {
			if (this.array[index] == item) {
				return false;
			}
			this.array[index] = item;
			return true;
		}
		return false;
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		UTILITIES							///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function toArray():Array {
		return this.array.concat();
	}
	
	public function toIterator(cursor:Number):IIterator {
		return new ArrayIterator(this.array, cursor);
	}
	
	public function hasItem(item):Boolean {
		var length:Number = this.array.length;
		for (var i:Number = 0; i < length; i++) {
			if (this.array[i] == item) {
				return true;
			}
		}
		return false;
	}
	
	public function length():Number {
		return this.array.length;
	}
	
	public function count(item):Number {
		var n:Number = 0;
		var length:Number = this.array.length;
		for (var i:Number = 0; i < length; i++) {
			if (this.array[i] == item) {
				n ++;
			}
		}
		return n;
	}
}