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
* Version: 1.0.13
*
* Developer: Syabas Technology Sdn. Bhd.
*
* Class Description: Grid2 component.
*
***************************************************/

import mx.utils.Delegate;

class com.syabas.as2.common.Grid2
{
	public static var SCROLL_LINE:Number = 0; // scroll by line.
	public static var SCROLL_PAGE:Number = 1; // scroll by page.

	// **WARNING: variables below are READ ONLY for public, they should not be changed outside of this class.
	//			It is for performance tuning. Accessing variable directly is faster than going through getter function.
	public var _hl:Number = -1;       // highlight data index.
	public var _len:Number = -1;      // total record.
	public var _cSize:Number = -1;    // column size.
	public var _rSize:Number = -1;    // row size.
	public var _size:Number = -1;     // cSize * rSize.
	public var _top:Number = -1;      // UI 1st item data index.

	// **WARNING: variables below are ONE TIME WRITE ONLY for public, they should not be changed after set.
	//			It is for performance tuning. Accessing variable directly is faster than going through getter function.
	public var xMCArray:Array = null;         // 2 dimesional array of movieClip for the Grid. Default is null.
	public var xHoriz:Boolean = false;        // true to scroll Horizontally. Default is false(Vertical).
	public var xWrap:Boolean = true;          // true to wrap from last to 1st, and 1st to last line. Default is true.
	public var xWrapLine:Boolean = true;      // true to wrap from line to line (e.g. For vertical, go right on last column will go to
                                                    //next line, go left on 1st column will go to previous line). Default is true.
	public var xHLStopTime:Number = 0;        // how many milliseconds the highlight navigation stop before calling to the hlStopCB callback function. Default is 0(disable).
	public var xLoadSize:Number = 0;          // total number of page per load. Default is -1 (meaning loading all data at first load).
	public var xMaxLoad:Number = -1;          // maximum number of load to keep/cache.
	public var xScroll:Number = 0             // Grid.SCROLL_PAGE = Scroll page by page, Grid.SCROLL_LINE = Scroll line by line. Default is Grid.SCROLL_LINE.
	public var xEnablePageMove:Boolean = false;  // Enable remote control page up and page down control. Default is false.

	public var up:Function = null;		// function to move up.
	public var down:Function = null;	// function to move down.
	public var left:Function = null;	// function to move left.
	public var right:Function = null;	// function to move right.

	// total record.
	public var totalRecord:Number = null;

	private var loads:Object = null; 			// object to store each load of data.
	private var toDisplayList:Object = null;	// object to store item waiting to display.
	private var updateList:Object = null;       // object to store item waiting to update.
	private var loadIndex:Number = null;        // current loading index.
	private var q:Array = null;                 // array to store request to load data.
	private var loadTotal:Number = -1;
	private var indexList:Array = null;
	private var toDisplayTimeoutID:Number = 0;

	/*
	*   1.  onItemShowCB:Function - callback function to be called when showing item's movieClip . (Data may be null, can use to show preload). Default is null.
	*                               Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   2.  onItemUpdateCB:Function - callback function to Update the data on the movieClip. Default is null.
	*                                 Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   3.  onItemClearCB:Function - callback function to Clear the movieClip. Default is null.
	*                                Arguments: {mc:MovieClip}
	*   4.  hlCB:Function - callback function to highlight the movieClip. Default is null.
	*                       Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   5.  unhlCB:Function - callback function to remove highlight from the movieClip. Default is null.
	*                         Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   6.  onHLStopCB:Function - callback function to be called when highlight stop for hlStopTime milliseconds. Default is null.
	*                             Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   7.  overTopCB:Function - callback function to be called when highlight go above the top most data row. Default is null.
	*                            Return: true to remain in the grid, else will unhighlight.
	*   8.  overBottomCB:Function - callback function to be called when highlight go below the bottom most data row. Default is null.
	*                               Return: true to remain in the grid, else will unhighlight.
	*   9.  overLeftCB:Function - callback function to be called when highlight go to the left over left most data column. Default is null.
	*                             Return: true to remain in the grid, else will unhighlight.
	*   10. overRightCB:Function - callback function to be called when highlight go to the right over right most data column. Default is null.
	*                              Return: true to remain in the grid, else will unhighlight.
	*   11. onEnterCB:Function - callback function to be called when enter key is pressed. Default is null.
	*                            Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   12. onKeyDownCB:Function - callback function to be called when key other than up/down/left/right/enter is called. Default is null.
	*                              Arguments: o:Object {keyCode:Number, asciiCode:Number, mc:MovieClip, data:Object, dataIndex:Number}
	*   13. loadDataCB:Function - callback function to load new data. Arguments:
	*       a. startIndex:Number - index of the first data.
	*       b. loadSize:Number   - number of data to be loaded.
	*       onLoadDataCB() function should be called after data is loaded successfully.
	*/
	public var onItemShowCB:Function = null;
	public var onItemUpdateCB:Function = null;
	public var onItemClearCB:Function = null;
	public var hlCB:Function = null;
	public var unhlCB:Function = null;
	public var onHLStopCB:Function = null;
	public var overTopCB:Function = null;
	public var overBottomCB:Function = null;
	public var overLeftCB:Function = null;
	public var overRightCB:Function = null;
	public var onEnterCB:Function = null;
	public var onKeyDownCB:Function = null;
	public var loadDataCB:Function = null;

	private var fn:Object = null;
	private var keyListener:Object = null;
	private var keyDown:Function = null;
	private var klTimeout:Number = 0;
	private var hlStopTimeoutId:Number = 0;

	private var c:Number = -1;          // highlight column. row if horizontal.
	private var r:Number = -1;          // highlight row. column if horizontal.
	private var lastTop:Number = -1;	// last page 1st item data index.
	private var lastC:Number = -1;		// last item column.
	private var lastR:Number = -1;		// last item row.

	public function Grid2()
	{
		this.fn = {
			onEnableKeyListener:Delegate.create(this, this.onEnableKeyListener),
			onHLStop:Delegate.create(this, this.onHLStop),
   			updateAllMC:Delegate.create(this, this.updateAllMC),
			verticalMCArrayUp:Delegate.create(this, this.verticalMCArrayUp),
			verticalMCArrayDown:Delegate.create(this, this.verticalMCArrayDown)
		};

		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		this.keyDown = Delegate.create(this, this.onKeyDown);
	}

	/*
	* Destroy all global variables.
	*/
	public function destroy():Void
	{
		this.clear();
		this.keyListener.onKeyDown = null;
		Key.removeListener(this.keyListener);

		this._cSize = 1;
		this._rSize = 1;
		this._size = 0;
		this.xWrap = true;
		this.xWrapLine = true;
		this.xHoriz = false;

		this.xMCArray = null;

		this.fn = null;
		this.keyListener = null;
		this.keyDown = null;
		this.klTimeout = 0;

		this._hl = -1;
		this.hlStopTimeoutId = 0;
		this.xHLStopTime = 0;
		this._len = -1;
		this._top = -1;
		this.c = -1;
		this.r = -1;
		this.lastTop = -1;
		this.lastC = -1;
		this.lastR = -1;
		this.xLoadSize = 0;
		this.xMaxLoad = -1;

		this.up = null;
		this.down = null;
		this.left = null;
		this.right = null;
	}

	/*
	* Destroy all MC.
	*/
	public function destroyMCArray():Void 
	{
		for (var i:String in this.xMCArray)
			for (var j:String in this.xMCArray[i])
				this.xMCArray[i][j].removeMovieClip();
		this.xMCArray = new Array();
	}

	/*
	* Clear data in all MC.
	*/
	public function clear():Void
	{
		this._hl = -1;
		this._len = -1;
		this._top = -1;
		this.c = -1;
		this.r = -1;
		this.lastTop = -1;
		this.lastC = -1;
		this.lastR = -1;

		this.loadTotal = -1;
		delete this.indexList;
		this.indexList = null

		delete this.q;
		this.q = null;

		this.loadIndex = null;
		delete this.loads;
		this.loads = null;

		_global.clearTimeout(this.toDisplayTimeoutID);
		delete this.toDisplayList;
		this.toDisplayList = null;
		delete this.updateList;
		this.updateList = null;

		var onItemClearCB:Function = this.onItemClearCB;
		if (onItemClearCB == null)
			return;
		var cSize:Number = this._cSize;
		var rSize:Number = this._rSize;
		var mcArray:Array = this.xMCArray;

		for (var i:Number=0; i<rSize; i++)
			for (var j:Number=0; j<cSize; j++)
				onItemClearCB({mc:mcArray[i][j]});
	}

	/*
	* Refresh the Grid.
	*/
	public function refresh():Void
	{
		this.updateAllMC();
	}

	/*
	* Create UI. Will clear all MC before create.
	* hl:Number - If hl(data index) equals undefined or null then will load data from index 0.
	*/
	public function createUI(hl:Number):Void
	{
		if (this.xMCArray == undefined || this.xMCArray == null || this.xMCArray.length < 1)
			return;
		this.clear();

		if (this._size == -1)
		{
			this._rSize = this.xMCArray.length;
			var temp:Number = this.xMCArray[0].length;
			this._cSize = (temp != undefined && temp != null ? temp : 1);
			this.up = this.verticalUp;
			this.down = this.verticalDown;
			this.left = this.verticalLeft;
			this.right = this.verticalRight;
			if(this.xHoriz == true)
				this.configHoriz();
			this._size = this._rSize * this._cSize;
		}
		if(this.totalRecord !== null)
			this.setLength(this.totalRecord);

		this.setHL(hl, false);
	}

	/*
	* Get column value. If dataIndex equals undefined or null then will return current highlighted column value.
	*/
	public function getC(dataIndex:Number):Number
	{
		if (dataIndex == undefined || dataIndex == null)
			return (this.xHoriz ? this.r : this.c);
		if(dataIndex < this._top || dataIndex >= this._top + this._size)
			return null;

		var cSize:Number = this._cSize;
		var mcHL:Number = (dataIndex - this._top);
		var c:Number = mcHL % cSize;
		var r:Number = Math.floor((mcHL / cSize));
		return (this.xHoriz ? r : c);
	}

	/*
	* Get row value. If dataIndex equals undefined or null then will return current highlighted row value.
	*/
	public function getR(dataIndex:Number):Number
	{
		if (dataIndex == undefined || dataIndex == null)
			return (this.xHoriz ? this.c : this.r);
		if(dataIndex < this._top || dataIndex >= this._top + this._size)
			return null;

		var cSize:Number = this._cSize;
		var mcHL:Number = (dataIndex - this._top);
		var c:Number = mcHL % cSize;
		var r:Number = Math.floor((mcHL / cSize));
		return (this.xHoriz ? c : r);
	}

	/*
	* Get movieClip.
	*
	* If both column and row is undefined or null then will get current highlighted movieClip.
	* If column is undefined or null then column=0.
	* If row is undefined or null then row=0.
	* If column or row is less than 0 then will return null.
	*/
	public function getMC(column:Number, row:Number):MovieClip
	{
		if (column == undefined || column == null)
		{
			if (row == undefined || row == null)
			{
				if (this._top < 0)
					return null;

				column = this.c;
				row = this.r;
			}
			else
				column = 0;
		}
		else if (row == undefined || row == null)
			row = 0;

		if (column < 0 || row < 0)
			return null;
		return this.xMCArray[row][column];
	}

	/*
	* Get current page number. Start from 1.
	*/
	public function getPage():Number
	{
		if (this._top < 0)
			return -1;
		return Math.floor((this._hl / this._size)) + 1;
	}

	/*
	* Get data. If dataIndex equals undefined or null then will return current highlighted data.
	*/
	public function getData(dataIndex:Number):Object
	{
		if (dataIndex == undefined || dataIndex == null)
			dataIndex = this._hl;
		if (dataIndex < 0)
			return null;

		if (this.loads == null)
			return null;

		var index:Number = (this.xLoadSize > 0 ? Math.floor((dataIndex / this.xLoadSize)) : 0); // find which loads contains the data.

		var data:Array = this.loads[index].data;
		if (data == undefined || data == null)
			return null;

		index = (this.xLoadSize > 0 ? (dataIndex % this.xLoadSize) : dataIndex);
		if (index < data.length)
			data = data[index];
		else
			return null;
		if (data == undefined)
			return null;
		return data;
	}

	/*
	 * ADDED : KHLEE (20/06/2013)
	 * Set / update data in a particular index. If dataIndex equals undefined or null then will update current highlighted data.
	 */
	public function setData(data:Object, dataIndex:Number):Void
	{
		if (data == null || data == undefined)
		{
			return;
		}
		
		if (dataIndex == undefined || dataIndex == null)
			dataIndex = this._hl;
		if (dataIndex < 0)
			return;

		if (this.loads == null)
			return;

		var index:Number = (this.xLoadSize > 0 ? Math.floor((dataIndex / this.xLoadSize)) : 0); // find which loads contains the data.

		var _data:Array = this.loads[index].data;
		if (_data == undefined || _data == null)
			return;

		index = (this.xLoadSize > 0 ? (dataIndex % this.xLoadSize) : dataIndex);
		if (index < _data.length)
		{
			// hit
			_data[index] = data;
		}
	}
	
	/*
	 * ADDED : KHLEE (20/06/2013)
	 * Check whether this grid contains any valid data.
	 */
	public function hasData():Boolean
	{
		for (var i:String in this.loads)
		{
			if (this.loads[i].data != null && this.loads[i].data != undefined && this.loads[i].data.length > 0)
			{
				return true;
			}
		}
		
		return false;
	}

	/*
	* Highlight with the hl(data index) specified and enable the keyListener.
	*/
	public function highlight(hl:Number):Void
	{
		this.setHL(hl, true);
	}

	/*
	* Disable the keyListener and remove the highlight.
	*/
	public function unhighlight():Void
	{
		this.disableKeyListener();
		this.removeHighlight();
	}

	/*
	* Configure grid for horizontal layout.
	*/
	private function configHoriz():Void
	{
		var tempT:Function = this.overTopCB;
		var tempB:Function = this.overBottomCB;
		var tempL:Function = this.overLeftCB;
		var tempR:Function = this.overRightCB;
		this.overTopCB = tempL;
		this.overBottomCB = tempR;
		this.overLeftCB = tempT;
		this.overRightCB = tempB;

		var tempRs:Number = this._rSize;
		var tempCs:Number = this._cSize;
		var tempArr:Array = new Array();

		this._cSize = tempRs;
		this._rSize = tempCs;
		this.up = this.verticalLeft;
		this.down = this.verticalRight;
		this.left = this.verticalUp;
		this.right = this.verticalDown;

		for (var j:Number=0; j<this._rSize; j++)
		{
			tempArr.push(new Array());
			for (var i:Number=0; i<this._cSize; i++)
				tempArr[j].push(this.xMCArray[i][j]);
		}
		this.xMCArray = tempArr;
	}

	private function removeHighlight():Void
	{
		if (this.unhlCB == null || this._top < 0)
			return;
		_global.clearTimeout(this.hlStopTimeoutId);
		this.unhlCB({mc:this.xMCArray[this.r][this.c], data:this.getData(), dataIndex:this._hl});
	}

	private function setHL(hl:Number, showHighlight:Boolean):Void
	{
		var prevHL:Number = this._hl;
		if (isNaN (new Number (hl)) == true) // if hl is not a number.
		{
			if (prevHL < 0) // if hl not set before.
				hl = 0;
			else // remain the previously set hl because new hl is empty.
			{
				this.showHighlight(showHighlight);
				return;
			}
		}
		else if (prevHL >= 0 && hl == prevHL) // new hl is same as previously set hl.
		{
			this.showHighlight(showHighlight);
			return;
		}

		var len:Number = this._len;
		if (hl < 0)
			hl = 0;
		else if (hl >= len && len > 0)
			hl = len - 1;
		this._hl = hl;

		var cSize:Number = this._cSize;
		var size:Number = this._size;
		var top:Number = 0;
		
		// EDIT : KHLEE (25/06/2013) uncommented
		if (this._hl >= this._top && this._hl < this._top + size && this._top >= 0)
			top = this._top;
		else
		{
			if (hl >= size) // 2nd page onwards.
			{
				if (this.xScroll == Grid2.SCROLL_PAGE)
					top = (Math.floor((hl / size)) * size);
				else
					top = ((Math.floor((hl / cSize)) - this._rSize + 1) * cSize);
			}
		}

		var mcHL:Number = (hl - top);
		this.c = mcHL % cSize;
		this.r = Math.floor((mcHL / cSize));

		this.setTop(top, showHighlight);
	}

	private function setTop(top:Number, showHighlight:Boolean):Void
	{
		var prevTop:Number = this._top;
		if (top != prevTop)
		{
			this._top = top;
			if (top < 0)
				return;

			var onLoadData:Function = this.fn.updateAllMC;
			if (prevTop > -1) // not the first entry.
			{
				if (top == (prevTop - this._cSize)) // go to previous line.
					onLoadData = this.fn.verticalMCArrayDown;
				else if (top == (prevTop + this._cSize)) // go to next line.
					onLoadData = this.fn.verticalMCArrayUp;
			}

			onLoadData();
			_global.clearTimeout(this.toDisplayTimeoutID);
			this.toDisplayTimeoutID = _global.setTimeout(Delegate.create(this, this.showDisplayList), 1000);
		}
		this.showHighlight(showHighlight);
	}

	private function showHighlight(showHighlight:Boolean):Void
	{
		if (showHighlight == false)
			return;

		if (this.hlCB != null && this._top >= 0)
		{
			var obj:Object = this.getData(this._hl);
			var stop:Boolean = true;

			this.hlCB({mc:this.xMCArray[this.r][this.c], data:this.getData(), dataIndex:this._hl});

			if (this.onHLStopCB != null && this.xHLStopTime > 0)
			{
				_global.clearTimeout(this.hlStopTimeoutId);
				this.hlStopTimeoutId = _global.setTimeout(this.fn.onHLStop, this.xHLStopTime);
			}
		}

		this.enableKeyListener();
	}

	private function onHLStop():Void
	{
		_global.clearTimeout(this.hlStopTimeoutId);
		this.onHLStopCB({mc:this.xMCArray[this.r][this.c], data:this.getData(), dataIndex:this._hl});
	}

	public function isKeyListenerEnabled():Boolean
	{
		return (this.keyListener.onKeyDown != null);
	}

	private function enableKeyListener():Void
	{
		if (this.keyListener.onKeyDown != null)
			return;
		_global.clearTimeout(this.klTimeout);
		this.klTimeout = null;
		this.klTimeout = _global.setTimeout(this.fn.onEnableKeyListener, 100); // delay abit to prevent getting the previously press key.
	}

	private function onEnableKeyListener():Void
	{
		_global.clearTimeout(this.klTimeout);
		this.klTimeout = null;
		this.keyListener.onKeyDown = this.keyDown;
	}

	private function disableKeyListener():Void
	{
		_global.clearTimeout(this.klTimeout);
		this.klTimeout = null;
		this.keyListener.onKeyDown = null;
	}

	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();

		switch (keyCode)
		{
			case Key.LEFT:
				this.left();
				break;
			case Key.RIGHT:
				this.right();
				break;
			case Key.UP:
				this.up();
				break;
			case Key.DOWN:
				this.down();
				break;
			case Key.PGDN:
				if(this.xEnablePageMove == true)
					this.pageDown();
				break;
			case Key.PGUP:
				if(this.xEnablePageMove == true)
					this.pageUp();
				break;
			case Key.ENTER:
				if (this.onEnterCB != null)
					this.onEnterCB({mc:this.xMCArray[this.r][this.c], data:this.getData(), dataIndex:this._hl});
				break;
			default:
				if (this.onKeyDownCB != null)
					this.onKeyDownCB({keyCode:keyCode, asciiCode:Key.getAscii(), mc:this.xMCArray[this.r][this.c], data:this.getData(), dataIndex:this._hl});
				break;
		}
	}

	private function pageUp():Void
	{
		if (this.r > 0) // to handler call page down when not highlight on first row
		{
			this.removeHighlight();
			this.r = 0;
			this._hl = this._top + this.c;
		}
		
		if (this._top == 0)
		{
			this.removeHighlight();
			this.c = Math.min(this.c, this.lastC);
			this.r = this.lastR;
			this._hl = this.lastTop + (this.r * this._cSize) + this.c;
			this.setTop(this.lastTop, true);
		}
		else
		{
			// go to previous page.
			this.removeHighlight();
			this.r = this._rSize - 1;
			this._hl = this._hl - this._cSize; // highlight up one row.
			this.setTop((this._top - this._size), true);
		}
	}

	private function pageDown():Void
	{
		if (this._top == this.lastTop)// last data row.
		{
			this.removeHighlight();
			// go to first page.
			this.r = 0;
			this._hl = this.c;
			this.setTop(0, true);
		}
		else
		{
			if (this.r !== this._rSize - 1) // to handler call page down when not highlight on last row
			{
				this.removeHighlight();
				this.r = this._rSize - 1;
				this._hl = this._top + ((this._rSize - 1) * this._cSize) + this.c;
			}
			
			this.removeHighlight();
			this.r = 0;
			this._hl = this._hl + this._cSize; // highlight down one row.
			if(this._hl >  this._len - 1)
			{
				this._hl = this._len - 1; // highlight last data.
				this.c = this.lastC;
			}
			this.setTop((this._top + this._size), true);
		}
	}

	private function verticalUp():Void // or left for horizontal.
	{
		if (this.r == 0) // first row.
		{
			if (this._top == 0) // first page.
			{
				if (this.overTopCB != null)
				{
					var b:Boolean = this.overTopCB();
					if (!b || b == null || b == undefined)
					{
						this.disableKeyListener();
						this.removeHighlight();
						return;
					}
				}

				if (this.xWrap)
				{
					// go to last page.
					this.removeHighlight();
					this.c = Math.min(this.c, this.lastC);
					this.r = this.lastR;
					this._hl = this.lastTop + (this.r * this._cSize) + this.c;
					this.setTop(this.lastTop, true);
					return;
				}
				else
					return;
			}
			else // page 2 or line 2 onwards.
			{
				if (this.xScroll == Grid2.SCROLL_PAGE)
				{
					this.pageUp();
					return;
				}
				else
				{
					this.removeHighlight();
					this._hl = this._hl - this._cSize;
					this.setTop((this._top - this._cSize), true);
					return;
				}
			}
		}
		else // not first row.
		{
			this.removeHighlight();
			this.r--;// highlight up one row.
			this._hl = this._hl - this._cSize;
		}

		this.showHighlight();
	}

	private function verticalDown():Void // or right for horizontal.
	{
		if (this._top == this.lastTop && this.r == this.lastR) // last data row.
		{
			if (this.overBottomCB != null)
			{
				var b:Boolean = this.overBottomCB();
				if (!b || b == null || b == undefined)
				{
					this.disableKeyListener();
					this.removeHighlight();
					return;
				}
			}

			if (this.xWrap)
			{
				this.removeHighlight();
				// go to first page.
				this.r = 0;
				this._hl = this.c;
				this.setTop(0, true);
				return;
			}
			else
				return;
		}
		else if (this.r == this._rSize - 1) // last ui row.
		{
			if (this.xScroll == Grid2.SCROLL_PAGE)
			{
				this.pageDown();
				return;
			}
			else
			{
				this.removeHighlight();
				this._hl = this._hl + this._cSize;// down one row.
				if(this._hl >  this._len - 1)
				{
					this._hl = this._len - 1; // highlight last data.
					this.c = this.lastC;
				}
				this.setTop((this._top + this._cSize), true);
				return;
			}
		}
		else // not last row.
		{
			this.removeHighlight();
			// highlight down one row.
			this.r++;
			this._hl = this._hl + this._cSize;
		}

		if (this._top == this.lastTop && this.r == this.lastR && this.c > this.lastC) // check column is not over last data column.
		{
			this._hl = this._len - 1; // highlight last data.
			this.c = this.lastC;
		}

		this.showHighlight();
	}

	private function verticalLeft():Void // or up for horizontal.
	{
		if (this.c == 0) // first column.
		{
			if (this.overLeftCB != null)
			{
				var b:Boolean = this.overLeftCB();
				if (!b || b == null || b == undefined)
				{
					this.disableKeyListener();
					this.removeHighlight();
					return;
				}
			}

			if (this.xWrapLine) // highlight previous row last column.
			{
				this.removeHighlight();
				if (this._hl - this._cSize < 0 && this.xWrap == false)
					this.showHighlight();
				else
				{
					this.c = this._cSize - 1;
					this._hl = this._hl + this.c; // move highlight to last column before moving up.
					this.verticalUp();
				}
				return;
			}
			else if (this._cSize > 1 && this.xWrap)
			{
				this.removeHighlight();
				if (this._top == this.lastTop && this.r == this.lastR) // if it is last data row.
				{
					this.c = this.lastC;
					this._hl = this._len - 1; // highlight last data.
				}
				else
				{
					this.c = this._cSize - 1;
					this._hl = this._hl + this.c; // move highlight to last column.
				}
			}
			else
				return;
		}
		else // not first column.
		{
			this.removeHighlight();
			this.c--;
			this._hl--;
		}

		this.showHighlight();
	}

	private function verticalRight():Void // or down for horizontal.
	{
		if ((this.c == this._cSize - 1) // last column.
			|| (this._top == this.lastTop && this.r == this.lastR && this.c == this.lastC))
		{
			if (this.overRightCB != null)
			{
				var b:Boolean = this.overRightCB();
				if (!b || b == null || b == undefined)
				{
					this.disableKeyListener();
					this.removeHighlight();
					return;
				}
			}

			if (this.xWrapLine) // highlight next row first column.
			{
				this.removeHighlight();
				if (this._hl == this._len - 1 && this.xWrap == false)
					this.showHighlight();
				else
				{
					this._hl = this._hl - this.c; // move highlight to first column before moving down.
					this.c = 0;
					this.verticalDown();
				}
				return;
			}
			else if (this._cSize > 1 && this.xWrap)
			{
				this.removeHighlight();
				this._hl = this._hl - this.c; // move highlight to first column.
				this.c = 0;
			}
			else if (this.xHoriz == true && this.getC() > 0 && this.getR() < this._cSize - 1 && this._hl == this._len - 1)
			{
				this.removeHighlight();
				this._hl = this._hl - this._cSize + 1;
				this.r = this.r - 1;
				this.c = this.c + 1;
			}
			else
				return;
		}
		else // not last column.
		{
			this.removeHighlight();
			this.c++;
			this._hl++;
		}

		this.showHighlight();
	}

	/*
	* Move all the movieClips one line up.  And move the first movieClip to the last.
	*/
	private function verticalMCArrayUp():Void // or move left for horizontal.
	{
		var cSize:Number = this._cSize;
		var rSize:Number = this._rSize;
		var mcArray:Array = this.xMCArray;
		var mcBelow:MovieClip = null;
		var mcAbove:MovieClip = null;
		var last:Object = null;
		var lastRow:Number = this._top + ((rSize-1)*cSize);

		for (var i:Number=0; i<cSize; i++) // do for every column.
		{
			mcBelow = mcArray[rSize-1][i];
			last = {x:mcBelow._x, y:mcBelow._y}; // keep the last mc properties so the 1st mc can move to last.

			for (var j:Number=rSize-2; j>=0; j--) // move from last mc up until 1st mc.
			{
				mcAbove = mcArray[j][i];
				mcBelow._x = mcAbove._x;
				mcBelow._y = mcAbove._y;
				mcBelow = mcAbove; // mcAbove will be the next to move up.
			}

			// moving the 1st mc to last. (mcBelow already reached the 1st mc because of the loop j above)
			mcBelow._x = last.x;
			mcBelow._y = last.y;

			this.updateMC(mcBelow, lastRow + i); // update the last mc with new data.
		}

		// move 1st row to last row.
		var firstRow:Object = mcArray.shift();
		mcArray.push(firstRow);
	}

	/*
	* Move all the movieClips one line down.  And move the last movieClip to the first.
	*/
	private function verticalMCArrayDown():Void // or move right for horizontal.
	{
		var cSize:Number = this._cSize;
		var rSize:Number = this._rSize;
		var mcArray:Array = this.xMCArray;
		var mcAbove:MovieClip = null;
		var mcBelow:MovieClip = null;
		var first:Object = null;
		var top:Number = this._top;

		for (var i:Number=0; i<cSize; i++) // do for every column.
		{
			mcAbove = mcArray[0][i];
			first = {x:mcAbove._x, y:mcAbove._y}; // keep the 1st mc properties so the last mc can move to 1st.

			for (var j:Number=1; j<rSize; j++) // move from 1st mc down until last mc.
			{
				mcBelow = mcArray[j][i];
				mcAbove._x = mcBelow._x;
				mcAbove._y = mcBelow._y;
				mcAbove = mcBelow; // mcBelow will be the next to move down.
			}

			// moving the last mc to 1st. (mcAbove already reached the last mc because of the loop j above)
			mcAbove._x = first.x;
			mcAbove._y = first.y;

			this.updateMC(mcAbove, top + i); // update the 1st mc with new data.
		}

		// move last row to 1st row.
		var lastRow:Object = mcArray.pop();
		mcArray.unshift(lastRow);
	}

	/*
	* Set length of the data and calculate needed value.
	*/
	private function setLength(len:Number):Void
	{
		if (len == undefined || len == null)
			len = 0;
		this._len = len;
		this.loadTotal = Math.floor(len / this.xLoadSize);
		if(len % this.xLoadSize !== 0)
			this.loadTotal += 1;

		// calculate lastTop, lastR, lastC.
		this.lastTop = -1;
		this.lastR = -1;
		this.lastC = -1;
		var cSize:Number = this._cSize;
		var rSize:Number = this._rSize;

		var lastDataRow:Number = Math.floor(((len - 1) / cSize));
		var lastC:Number = (len - 1) % cSize;
		var lastR:Number = lastDataRow;
		if (this.xScroll == Grid2.SCROLL_PAGE)
			lastR = lastR % rSize;
		else if (lastR > (rSize - 1))
			lastR = rSize - 1;

		this.lastTop = (lastDataRow - lastR) * cSize;
		this.lastC = lastC;
		this.lastR = lastR;
	}

	/*
	* Update all the MC.
	*/
	private function updateAllMC():Void
	{
		var mcArray:Array = this.xMCArray;
		var cSize:Number = this._cSize;
		var rSize:Number = this._rSize;
		var top:Number = this._top;

		for (var i:Number=0; i<rSize; i++)
			for (var j:Number=0; j<cSize; j++)
				this.updateMC(mcArray[i][j], (i * cSize) + top + j);
	}

	/*
	* Update the MC.
	*/
	private function updateMC(mc:MovieClip, dataIndex:Number):Void
	{
		if (dataIndex < 0)
			return;
		if (dataIndex >= this._len) // clear if index is over the data length.
		{
			if (this.onItemClearCB != null)
				this.onItemClearCB({mc:mc});
			delete this.updateList[mc._name];
			delete this.toDisplayList[mc._name];
		}
		else
		{
			if (this.onItemShowCB != null)
				this.onItemShowCB({mc:mc, dataIndex:dataIndex, data:this.getData(dataIndex)});
			if (this.onItemUpdateCB != null)
			{
				if(this.toDisplayList == null)
					this.toDisplayList = new Object();
				this.toDisplayList[mc._name] = {mc:mc, dataIndex:dataIndex};
			}
		}
	}

	private function showDisplayList():Void
	{
		_global.clearTimeout(this.toDisplayTimeoutID);
		var o:Object = null;
		var data:Object = null;
		for(var str:String in this.toDisplayList)
		{
			o = this.toDisplayList[str];
			data = this.getData(o.dataIndex);
			if(data == null)
			{
				if (o.dataIndex >= this._len)
				{
					if (this.onItemClearCB != null)
						this.onItemClearCB({mc:o.mc});
					delete this.toDisplayList[str];
				}
				else
					this.loadData({mc:o.mc, dataIndex:o.dataIndex});
			}
			else
			{
				this.onItemUpdateCB({mc:o.mc, data:data, dataIndex:o.dataIndex});
				delete this.toDisplayList[str];
			}
		}
	}

	/*
	* Callback function that should be called after data loaded successfully.
	*
	* data - the new data.
	* len  - [optional]the new total number of data.
	*/
	public function onLoadDataCB(dataList:Array, totalRecord:Number):Void
	{
		if (dataList != undefined && dataList != null && dataList.length > 0) // if success and data is not empty.
		{
			if (totalRecord != undefined && totalRecord != null)
			{
				this.totalRecord = totalRecord;
			}

			this.loads[this.loadIndex].data = dataList;
			this.loads[this.loadIndex].loading = false
			var o:Object = null;
			var data:Object = null;
			for(var str:String in this.updateList)
			{
				o = this.updateList[str];
				data = this.getData(o.dataIndex);
				if (data == null)
				{
					if (o.dataIndex >= this.totalRecord ||
						(this.loadIndex*this.xLoadSize <= o.dataIndex && o.dataIndex < (this.loadIndex+1)*this.xLoadSize))
					{
						this.onItemClearCB({mc:o.mc});
					}
					else
						continue;
				}
				if (o.dataIndex < this.totalRecord && o.dataIndex >= this._top && o.dataIndex < this._top + this._size)
					this.onItemUpdateCB({mc:o.mc, data:data, dataIndex:o.dataIndex});
				delete this.updateList[str];
			}

			if (totalRecord != undefined && totalRecord != null)
			{
				this.setLength(totalRecord);
				if (this._hl >= this.totalRecord)
				{
					this.removeHighlight();
					this.setHL(this.totalRecord - 1, true);
				}
			}

			if(this.xMaxLoad > 0)
			{
				var maxLoad:Number = this.xMaxLoad;
				if(this.indexList == null)
					this.indexList = new Array();
				this.indexList.push({index:this.loadIndex, diff:0})
				var l:Number = this.indexList.length;

				if(l > maxLoad)
				{
					var d1:Number = -1;
					var d2:Number = -1;
					var total:Number = this.loadTotal + this.loadIndex + 1;
					for(var j:Number = 0; j < l; j++)
					{
						d1 = Math.abs(Number(this.loadIndex - this.indexList[j].index));
						d2 = Math.abs(Number(total - this.indexList[j].index));
						this.indexList[j].diff = Math.min(d1, d2);
					}
					if(l > 1)
						this.indexList.sortOn("diff");
					l = this.indexList.length;
					for(var k:Number = maxLoad; k < l; k++)
					{
						delete this.loads[this.indexList[k].index];
						this.indexList.splice(k,1);
					}
				}
			}

			this.loadIndex = null;
		}
		else
		{
			var o:Object = null;
			for(var str:String in this.updateList)
			{
				o = this.updateList[str];
				if (data == null)
				{
					if (this.loadIndex*this.xLoadSize <= o.dataIndex && o.dataIndex < (this.loadIndex+1)*this.xLoadSize)
						this.onItemClearCB({mc:o.mc});
					else
						continue;
				}
				delete this.updateList[str];
			}
		}
		if(this.loadIndex !== null)
			return;

		this.skipLoadData();
	}

	public function skipLoadData():Void
	{
		this.loads[loadIndex].loading = false;
		this.loadIndex = null;
		var len:Number = this.q.length;
		var o:Object = null;
		for(var i:Number = 0; i < len; i++)
		{
			o = this.q.shift();
			if(o.startIndex < this._top && o.startIndex >= this._top + this._size)
			{
				this.loads[o.loadIndex].loading = false;
				continue;
			}

			this.loadIndex = o.loadIndex;
			this.loadDataCB(o.startIndex, o.loadSize);
			break;
		}
	}

	private function loadData(loadObj:Object):Void
	{
		if(this.updateList == null)
			this.updateList = new Object();
		this.updateList[loadObj.mc._name] = loadObj;

		if (this.loadDataCB == null) // for dynamic data loading.
			return;

		var loadSize:Number = this.xLoadSize;
		var loadIndex:Number = (loadSize > 0 ? Math.floor((loadObj.dataIndex / loadSize)) : 0);
		var data:Array = null;

		if(this.loads[loadIndex].loading == true)
			return;

		var startIndex:Number = 0;
		if (loadSize > 0)
		{
			startIndex = loadIndex * loadSize;
			var endIndex:Number = startIndex + loadSize - 1;
			if (endIndex >= this._len)
				loadSize = this._len - startIndex + 1;
		}
		if (this.loads == null)
			this.loads = new Object();

		this.loads[loadIndex] = {};
		this.loads[loadIndex].loading = true;
		if(this.loadIndex == null)
		{
			this.loadIndex = loadIndex;
			this.loadDataCB(startIndex, loadSize);
		}
		else
		{
			loadObj.startIndex = startIndex;
			loadObj.loadSize = loadSize;
			loadObj.loadIndex = loadIndex;
			if(this.q == null)
				this.q = new Array();
			this.q.unshift(loadObj);
		}
	}
}