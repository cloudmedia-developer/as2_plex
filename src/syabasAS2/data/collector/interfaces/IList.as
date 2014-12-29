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
import syabasAS2.data.collector.interfaces.ICollectiveItem;
/**
 * ...
 * @author Ng Tong Sheng
 */
interface syabasAS2.data.collector.interfaces.IList extends ICollectiveItem
{
	/**
	 * add an item into the list at the end
	 * @param	item	any objext type
	 */
	public function add(item):Void;
	
	/**
	 * remove an item at first occurrence
	 * @param	item	any objext type
	 * @return	return true if successfully remove
	 */
	public function remove(item):Boolean;
	
	/**
	 * remove all item
	 * @param	item	any objext type
	 * @return	return true if successfully remove	
	 */
	public function removeAll(item):Boolean;
	
	/**
	 * check whether the item is exist or not
	 * @param	item	any objext type
	 * @return	return true if the item is exist in the list
	 */
	public function hasItem(item):Boolean;
	
	/**
	 * count number of item in the list
	 * @param	item	any objext type
	 * @return
	 */
	public function count(item):Number;
}
