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
import syabasAS2.data.collector.content.DictionaryIdValidator;
import syabasAS2.data.collector.interfaces.IDictionary;
import syabasAS2.data.collector.interfaces.IIterator;
import syabasAS2.data.collector.iterators.ArrayIterator;
import syabasAS2.data.collector.iterators.DictionaryIterator;
import syabasAS2.utils.InstanceType;
/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.data.collector.Dictionary implements IDictionary
{
	private var keys:Object;
	private var items:Object;
	private var total:Number;
	
	public function Dictionary() {
		this.clear();
	}
	
	public function add(id, item):Boolean {
		var v:DictionaryIdValidator 	= new DictionaryIdValidator(id);
		var valid:Boolean 				= v.validate();
		if (valid) {
			if (this.keys[id] == undefined) {
				this.total ++;
			}
			else if (this.keys[id] && this.items[id]) {
				return false;
			}
			this.items[id] 	= item;
			this.keys[id] 	= id;
			return true;
		}
		else {
			return false
		}
	}
	
	public function replace(id, item):Boolean {
		var v:DictionaryIdValidator 	= new DictionaryIdValidator(id);
		var valid:Boolean 				= v.validate();
		if (valid) {
			if (this.keys[id] == undefined || this.keys[id] != id) {
				return false;
			}
			if (this.items[id] == item) {
				return false;
			}
			this.items[id] = item;
			return true;
		}
		else {
			return false
		}
	}
	
	public function remove(id):Boolean {
		var v:DictionaryIdValidator 	= new DictionaryIdValidator(id);
		var valid:Boolean 				= v.validate();
		if (valid) {
			if (this.keys[id] == undefined || this.keys[id] != id) {
				return false;
			}
			delete this.items[id];
			delete this.keys[id];
			this.total --;
			return true;
		}
		else {
			return false
		}
	}
	
	public function hasId(id):Boolean {
		var v:DictionaryIdValidator 	= new DictionaryIdValidator(id);
		var valid:Boolean 				= v.validate();
		if (valid) {
			return this.keys[id] != undefined && this.keys[id] == id;
		}
		else {
			return false;
		}
	}
	
	public function getById(id) {
		var v:DictionaryIdValidator 	= new DictionaryIdValidator(id);
		var valid:Boolean 				= v.validate();
		if (valid) {
			if (this.keys[id] === undefined || this.keys[id] !== id) {
				return undefined;
			}
			return this.items[id];
		}
		else {
			return undefined;
		}
	}
	
	public function toIdArray():Array {
		var array:Array = new Array();
		var i:Number = 0;
		for (var name in this.keys) {
			array[i++] = this.keys[name];
		}
		return array;
	}
	
	public function toArray():Array {
		var array:Array = new Array();
		var i:Number = 0;
		for (var name in this.items) {
			array[i++] = this.items[name];
		}
		return array;
	}
	
	public function toIterator(cursor:Number):IIterator {
		return new ArrayIterator(this.toArray(), cursor);
	}
	
	public function toIdIterator(cursor:Number):IIterator {
		return new ArrayIterator(this.toIdArray(), cursor);
	}
	
	public function toDictionaryIterator(cursor:Number):DictionaryIterator {
		return new DictionaryIterator(this, cursor);
	}
	
	public function clear():Void {
		this.keys 	= new Object;
		this.items	= new Object;
		this.total	= 0;
	}
	
	public function length():Number {
		return this.total;
	}
}