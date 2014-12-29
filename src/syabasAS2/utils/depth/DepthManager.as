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
/**
 * ...
 * @author Darien Toh
 */
class syabasAS2.utils.depth.DepthManager
{
	/**
	 * managing depths
	 */
	public function DepthManager() 
	{
		
	}
	
	/**
	 * swap depth in multiple display object
	 * first in array will be the highest depth among all
	 * @param	displayObjects
	 */
	public function manage(displayObjects:Array):Void
	{
		var depthNums:Array = [];
		var i:Number = 0;
		//push all depth number into depthNums for sorting
		while (i < displayObjects.length) 
		{
			var current:MovieClip = displayObjects[i];
			depthNums.push(current.getDepth());
			i++;
		}
		
		//Tracer.self.trace(["DepthManager manage():", depthNums]);
		
		//sort by number
		depthNums.sort(16); //depthNums.sort(Array.NUMERIC);
		depthNums.reverse();
		
		//Tracer.self.trace(["DepthManager manage():", depthNums]);
		
		//swap depth
		i = 0;
		while (i < displayObjects.length) 
		{
			var current:MovieClip = displayObjects[i];
			current.swapDepths(depthNums[i]);
			i++;
		}
	}
	
	/**
	 * swap depth between two display objects
	 * @param	displayObject1	
	 * @param	displayObject2
	 */
	public function swap(displayObject1:MovieClip, displayObject2:MovieClip):Void
	{
		var depth1:Number = displayObject1.getDepth();
		var depth2:Number = displayObject2.getDepth();
		displayObject2.swapDepths(depth1);
		displayObject1.swapDepths(depth2);
	}
	
}