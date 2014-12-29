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
import syabasAS2.data.collector.interfaces.IList;
/**
 * ...
 * @author Ng Tong Sheng
 */
interface syabasAS2.data.collector.interfaces.IArrayList extends IList
{
	/**
	 * assign any array into the array list
	 * @param	array	any array
	 */
	public function setArray(array:Array):Void;

	/**
	 * replace item at specific index
	 * @param	index	specific index
	 * @param	item	item to be replace
	 * @return 	return true if successfully replaced
	 */
	public function replaceAt(index:Number, item):Boolean;
	
	/**
	 * get item at specific index
	 * @param	index	specific index
	 */
	public function getAt(index:Number);
	
	/**
	 * get item at starting of the list
	 */
	public function getAtFirst();
	
	/**
	 * get item at ending of the list
	 */
	public function getAtLast();
	
	/**
	 * add item at specific index
	 * @param	index	specific index
	 * @param	item	item to be add
	 * @return	return the index added
	 */
	public function addAt(index:Number, item):Number;
	
	/**
	 * add item at the starting of the list
	 * @param	item	item to be add
	 * @return	return the 1st index
	 */
	public function addAtFirst(item):Number;
	
	/**
	 * add item at the ending of the list
	 * @param	item	item to be add
	 * @return	return the last index
	 */
	public function addAtLast(item):Number;
	
	/**
	 * remove item at specific index
	 * @param	index	specific index
	 */
	public function removeAt(index:Number):Boolean;
	
	/**
	 * remove item at the starting of the list
	 * @param	item	item to be add
	 * @return	return true if successfully removed
	 */
	public function removeAtFirst():Boolean;

	/**
	 * remove item at the ending of the list
	 * @param	item	item to be add
	 * @return	return true if successfully removed
	 */
	public function removeAtLast():Boolean;
}