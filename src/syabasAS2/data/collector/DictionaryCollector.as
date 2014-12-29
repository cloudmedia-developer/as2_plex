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
import syabasAS2.data.collector.Collector;
import syabasAS2.data.collector.content.DictionaryContent;
import syabasAS2.data.collector.Dictionary;

/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.data.collector.DictionaryCollector extends Dictionary {
	
	private var collector:Collector;
	private var keydictionary:Dictionary;
	
	public function DictionaryCollector() {
		super();
		this.keydictionary 	= new Dictionary();
		this.collector 		= new Collector();
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		ADD									///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function add(id, item):Boolean {
		var success:Boolean = super.add(id, item);
		if (success) {
			this.collector.add(new DictionaryContent(id, item));
			this.keydictionary.add(id, (this.collector.length() - 1));
		}
		return success;
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		REPLACE								///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function replace(id, item):Boolean {
		var success:Boolean = super.replace(id, item);
		if (success) {
			var index:Number = this.keydictionary.getById(id);
			this.collector.replaceAt(index, new DictionaryContent(id, item));
		}
		return success;
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		REMOVE								///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function remove(id):Boolean {
		var success:Boolean = super.remove(id);
		if (success) {
			var index:Number = this.keydictionary.getById(id);
			this.collector.removeAt(index);
			this.keydictionary.remove(id);
		}
		return success;
	}
	
	public function removeAt(index:Number):Boolean {
		var content:DictionaryContent = this.collector.getAt(index);
		var success:Boolean = this.remove(content.id);
		return success;
	}
	
	public function removeAtLast():Boolean {
		return this.removeAt(this.collector.length() - 1);
	}
	
	public function removeAtFirst():Boolean {
		return this.removeAt(0);
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		GET	ID								///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function getIdAt(index:Number) {
		var content:DictionaryContent = this.collector.getAt(index);
		return content.id;
	}
	
	public function getIdAtLast() {
		return this.getIdAt(this.collector.length() - 1);
	}
	
	public function getIdAtFirst() {
		return this.getIdAt(0);
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		GET	ITEM							///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function getItemAt(index:Number) {
		var content:DictionaryContent = this.collector.getAt(index);
		return content.item;
	}
	
	public function getItemAtLast() {
		return this.getItemAt(this.collector.length() - 1);
	}
	
	public function getItemAtFirst() {
		return this.getItemAt(0);
	}
	
	public function toArray():Array {
		var length:Number 	= this.collector.length();
		var array:Array		= new Array();
		for (var i:Number = 0; i < length; i++) {
			var content:DictionaryContent = this.collector.getAt(i);
				array[i] = content.item;
		}
		return array;
	}
}