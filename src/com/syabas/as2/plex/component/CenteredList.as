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
* Version 1.0.9
*
* Developer: Syabas Technology Sdn. Bhd.
*
* Class Description: List component which only highlight on the center item
*
***************************************************/

import mx.utils.Delegate;

class com.syabas.as2.plex.component.CenteredList
{
	//----------------------------- For Configuration ---------------------------------
	public var mcArrayBefore:Array = null;				// A single dimension array for movie clips before the centered item
	public var mcArrayAfter:Array = null;				// A single dimension array for movie clips after the centered item
	public var centerFocusMC:MovieClip = null;			// The centered item movie clip
	public var horizontal:Boolean = false;				// Whether the navigation is going horizontal. Default : false
	public var wrap:Boolean = false;					// Whether to wrap the items display
	public var data:Array = null;						// The data array
	
	public var onItemUpdateCB:Function = null;			// Callback when a movie clip is updating its content
	public var onItemClearCB:Function = null;			// Callback when a movie clip is clearing its content
	public var hlCB:Function = null;					// Callback when a movie clip is being focused / highlighted
	public var unhlCB:Function = null;					// Callback when a movie clip is losing focus / unhighlighted
	public var hlStopCB:Function = null;				// Callback when a movie clip after the navigation stopped for a certain time
	public var onOverLeftCB:Function = null;			// Callback when user is try to navigate out of the list toward left side
	public var onOverRightCB:Function = null;			// Callback when user is try to navigate out of the list toward right side
	public var onOverTopCB:Function = null;				// Callback when user is try to navigate out of the list toward top side
	public var onOverBottomCB:Function = null;			// Callback when user is try to navigate out of the list toward bottom side
	public var onEnterCB:Function = null;				// Callback when user is pressing enter on an item
	public var onKeyDownCB:Function = null;				// Callback when user is pressing any key besides : Direction key, Enter key
	
	public var dataLen:Number = null;					// The Length of data. Default : Length of data array
	public var hlStopTime:Number = 1000;				// The time to wait before fire hlStopCB
	//---------------------------------------------------------------------------------
	
	public var hl:Number = -1;					// NOTE: For ACCESS only, do not modify
	
	private var fn:Object = null;
	private var keyListener:Object = null;
	
	private var doUp:Function = null;
	private var doDown:Function = null;
	private var doLeft:Function = null;
	private var doRight:Function = null;
	
	private var klTimeout:Number = null;
	private var hlTimeout:Number = null;
	
	public function destroy():Void
	{
		Key.removeListener(this.keyListener);
		this.keyListener.onKeyDown = null;
		delete this.keyListener;
		
		_global["clearTimeout"](this.klTimeout);
		this.klTimeout = null;
		
		delete this.mcArrayBefore;
		delete this.mcArrayAfter;
		delete this.centerFocusMC;
		
		delete this.onItemUpdateCB;
		delete this.onItemClearCB;
		delete this.onOverLeftCB;
		delete this.onOverRightCB;
		delete this.onOverTopCB;
		delete this.onOverBottomCB;
		delete this.onEnterCB;
		delete this.onKeyDownCB;
		delete this.hlCB;
		delete this.fn;
		
		delete this.data;
		delete this.doUp;
		delete this.doDown;
		delete this.doLeft;
		delete this.doRight;
		
		this.mcArrayBefore = null;
		this.mcArrayAfter = null;
		this.centerFocusMC = null;
		
		this.onItemUpdateCB = null;
		this.onItemClearCB = null;
		this.onOverLeftCB = null;
		this.onOverRightCB = null;
		this.onOverTopCB = null;
		this.onOverBottomCB = null;
		this.onEnterCB = null;
		this.onKeyDownCB = null;
		this.fn = null;
		this.data = null;
		this.doUp = null;
		this.doDown = null;
		this.doLeft = null;
		this.doRight = null;
	}
	
	public function CenteredList()
	{
		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		
		this.fn = { onKeyDown:Delegate.create(this, this.onKeyDown), enableKeyListener:Delegate.create(this, this.enableKeyListener), doHLStop:Delegate.create(this, this.doHLStop) };
	}
	
	
	/*********************************************************************
	 * Function : Create the list and highlight an item
	 * - index:Number 			- The index of item to be highlighted
	 *********************************************************************/
	public function createUI(index:Number):Void
	{
		this.clear();
		
		if (this.centerFocusMC == null || this.centerFocusMC == undefined || this.mcArrayBefore == null || this.mcArrayBefore == undefined || this.mcArrayBefore.length < 1 || this.mcArrayAfter == null || this.mcArrayAfter == undefined || this.mcArrayAfter.length < 1)
		{
			return;
		}
		
		if (this.horizontal)
		{
			this.doUp = Delegate.create(this, this.left);
			this.doDown = Delegate.create(this, this.right);
			this.doLeft = Delegate.create(this, this.up);
			this.doRight = Delegate.create(this, this.down);
		}
		else
		{
			this.doUp = Delegate.create(this, this.up);
			this.doDown = Delegate.create(this, this.down);
			this.doLeft = Delegate.create(this, this.left);
			this.doRight = Delegate.create(this, this.right);
		}
		
		if (this.dataLen == null && this.data != null)
		{
			this.dataLen = this.data.length;
		}
		
		this.enable(index);
		this.updateAllMC();
		this.doHighlight();
	}
	
	/*
	* Get data. If dataIndex equals undefined or null then will return current highlighted data.
	*/
	public function getData(dataIndex:Number):Object
	{
		if (dataIndex == undefined || dataIndex == null)
			dataIndex = this.hl;
		if (dataIndex < 0)
			return null;

		var _dataArr:Array = this.data;
		var _data:Object = null;
		if (_dataArr == undefined || _dataArr == null)
			return null;

		if (dataIndex < _dataArr.length)
			_data = _dataArr[dataIndex];
		else
			return null;
		if (_data == undefined)
			return null;
		return _data;
	}
	
	/******************************************************************
	 * Function : Clear all contents from all movie clip
	 *****************************************************************/
	public function clear():Void
	{
		var cb:Function = this.onItemClearCB;
		if (cb == null)
		{
			return;
		}
		
		this.hl = -1;
		this.dataLen = null;
		var beforeLen:Number = this.mcArrayBefore.length;
		var afterLen:Number = this.mcArrayAfter.length;
		
		cb( { mc:this.centerFocusMC } );
		
		for (var i:Number = 0; i < beforeLen; i ++)
		{
			cb( { mc:this.mcArrayBefore[i] } );
		}
		
		for (var i:Number = 0; i < afterLen; i ++)
		{
			cb( { mc:this.mcArrayAfter[i] } );
		}
	}
	
	/*****************************************************************
	 * Function : Enable the key listener
	 * - index:Number			- The index to be selected
	 ****************************************************************/
	public function enable(index:Number):Void
	{
		var prevHL:Number = this.hl;
		if (isNaN(index) == true)
		{
			if (prevHL < 0)
			{
				index = 0;
			}
			else
			{
				index = prevHL;
			}
		}
		
		if (index > this.dataLen)
		{
			index = 0;
		}
		
		_global.clearTimeout(this.klTimeout);
		this.klTimeout = _global["setTimeout"](this.fn.enableKeyListener, 100);
		
		if (this.hl != index)
		{
			this.hl = index;
			this.updateAllMC();
		}
	}
	
	public function highlight(index:Number):Void
	{
		this.enable(index);
		this.doHighlight();
	}
	
	/****************************************************************
	 * Function : Disable the key listener
	 ***************************************************************/
	public function disable():Void
	{
		_global.clearTimeout(this.klTimeout);
		this.klTimeout = null;
		this.keyListener.onKeyDown = null;
	}
	
	private function enableKeyListener():Void
	{
		this.keyListener.onKeyDown = this.fn.onKeyDown;
	}
	
	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();
		var ascii:Number = Key.getAscii();
		
		switch(keyCode)
		{
			case Key.UP:
				this.doUp();
				break;
			case Key.DOWN:
				this.doDown();
				break;
			case Key.LEFT:
				this.doLeft();
				break;
			case Key.RIGHT:
				this.doRight();
				break;
			case Key.ENTER:
				if (this.onEnterCB != null)
				{
					this.onEnterCB( { mc:this.centerFocusMC, data:this.getData(), dataIndex:this.hl } );
				}
				break;
			default:
				if (this.onKeyDownCB != null)
				{
					this.onKeyDownCB( { keyCode:keyCode, asciiCode:ascii } );
				}
				break;
		}
	}
	
	private function up():Void
	{
		var _hl:Number = this.hl - 1;
		
		if (_hl < 0)
		{
			if (this.wrap)
			{
				_hl = this.data.length + _hl;
			}
			else 
			{
				var _cb:Function = (this.horizontal ? this.onOverLeftCB : this.onOverTopCB);
				var r:Boolean = _cb();
				
				if (!(r || r == null || r == undefined))
				{
					// disable
					this.disable();
					return;
				}
			}
			
			
		}
		
		this.hl = _hl;
		
		this.swapMC(2);
	}
	
	private function down():Void
	{
		var _hl:Number = this.hl + 1;
		
		if (_hl >= this.data.length)
		{
			if (this.wrap)
			{
				_hl = _hl - this.data.length;
			}
			else 
			{
				var _cb:Function = (this.horizontal ? this.onOverRightCB : this.onOverBottomCB);
				var r:Boolean = _cb();
				
				if (!(r || r == null || r == undefined))
				{
					// disable
					this.disable();
					return;
				}
			}
		}
		
		this.hl = _hl;
		this.swapMC(1);
	}
	
	private function left():Void
	{
		var _cb:Function = (this.horizontal ? this.onOverTopCB : this.onOverLeftCB);
		var r:Boolean = _cb();
		
		if (!(r || r == null || r == undefined))
		{
			// disable
			this.disable();
			return;
		}
	}
	
	private function right():Void
	{
		var _cb:Function = (this.horizontal ? this.onOverBottomCB : this.onOverRightCB);
		var r:Boolean = _cb();
		
		if (!(r || r == null || r == undefined))
		{
			// disable
			this.disable();
			return;
		}
	}
	
	private function doHighlight():Void
	{
		//this.updateMC();
		
		if (this.hlCB != null)
		{
			this.hlCB( { mc:this.centerFocusMC, data:this.getData(), dataIndex:this.hl } );
		}
		
		clearInterval(this.hlTimeout);
		if (this.hlStopCB != null && this.hlStopCB != undefined)
		{
			this.hlTimeout = setInterval(this.fn.doHLStop, this.hlStopTime);
		}
	}
	
	private function doHLStop():Void
	{
		clearInterval(this.hlTimeout);
		if (this.hlStopCB != null && this.hlStopCB != undefined)
		{
			this.hlStopCB( { mc:this.centerFocusMC, data:this.getData(), dataIndex:this.hl } );
		}
	}
	
	private function updateAllMC():Void
	{
		if (this.hl >= 0)
		{
			var _data:Object = this.getData();
			if (_data != null && _data != undefined)
			{
				if (this.onItemUpdateCB != null)
				{
					this.onItemUpdateCB( { data:_data, mc:this.centerFocusMC, dataIndex:this.hl } );
				}
				
				var prevLen:Number = this.mcArrayBefore.length;
				var nextLen:Number = this.mcArrayAfter.length;
				var index:Number = 0;
				
				for (var i:Number = 0; i < prevLen; i ++)
				{
					index = this.getIndex(0 - i - 1);
					
					_data = this.getData(index);
					if (_data == null || _data == undefined)
					{
						if (this.onItemClearCB != null)
						{
							this.onItemClearCB( { mc:this.mcArrayAfter[i] } );
						}
					}
					else
					{
						if (this.onItemUpdateCB != null)
						{
							this.onItemUpdateCB( { data:_data, mc:this.mcArrayBefore[i], dataIndex:index } );
						}
					}
				}
				
				for (var i:Number = 0; i < nextLen; i ++)
				{
					index = this.getIndex(i + 1);
					
					_data = this.getData(index);
					
					if (_data == null || _data == undefined)
					{
						if (this.onItemClearCB != null)
						{
							this.onItemClearCB( { mc:this.mcArrayAfter[i] } );
						}
					}
					else 
					{
						if (this.onItemUpdateCB != null)
						{
							this.onItemUpdateCB( { data:_data, mc:this.mcArrayAfter[i], dataIndex:index } );
						}
					}
				}
			}
		}
	}
	
	private function swapMC(direction:Number):Void
	{
		if (direction == 1)
		{
			// up
			var beforeLen:Number = this.mcArrayBefore.length;
			var afterLen:Number = this.mcArrayAfter.length;
			
			var mc1:MovieClip = null;
			var mc2:MovieClip = null;
			
			
			mc2 = this.mcArrayAfter[this.mcArrayAfter.length - 1];
			
			var tempX:Number = mc2._x;
			var tempY:Number = mc2._y;
			
			for (var i:Number = afterLen - 1; i > 0 ; i --)
			{
				mc1 = this.mcArrayAfter[i - 1];
				
				this.moveMCLocation(mc2, mc1);
				
				mc2 = mc1;
			}
			
			this.moveMCLocation(mc2, this.centerFocusMC);
			mc2 = this.centerFocusMC;
			
			for (var i:Number = 0; i < beforeLen; i ++)
			{
				mc1 = this.mcArrayBefore[i];
				
				this.moveMCLocation(mc2, mc1);
				
				mc2 = mc1;
			}
			
			mc2._x = tempX;
			mc2._y = tempY;
			
			this.mcArrayAfter.push(this.mcArrayBefore.pop());
			this.mcArrayBefore.unshift(this.centerFocusMC);
			this.centerFocusMC = MovieClip(this.mcArrayAfter.shift());
			
			// unhighlight previous mc
			if (this.unhlCB != null)
			{
				this.unhlCB( { dataIndex:this.getIndex(this.hl - this.mcArrayBefore.length - 1), mc:this.mcArrayBefore[0] } );
			}
			
			this.doHighlight();
		}
		else if (direction == 2)
		{
			// down
			var beforeLen:Number = this.mcArrayBefore.length;
			var afterLen:Number = this.mcArrayAfter.length;
			
			var mc1:MovieClip = null;
			var mc2:MovieClip = null;
			
			mc2 = this.mcArrayBefore[this.mcArrayBefore.length - 1];
			
			var tempX:Number = mc2._x;
			var tempY:Number = mc2._y;
			
			for (var i:Number = beforeLen - 1; i > 0; i --)
			{
				mc1 = this.mcArrayBefore[i - 1];
				
				this.moveMCLocation(mc2, mc1);
				
				mc2 = mc1;
			}
			
			this.moveMCLocation(mc2, this.centerFocusMC);
			mc2 = this.centerFocusMC;
			
			for (var i:Number = 0; i < afterLen; i ++)
			{
				
				mc1 = this.mcArrayAfter[i];
				this.moveMCLocation(mc2, mc1);
				
				mc2 = mc1;
			}
			
			mc2._x = tempX;
			mc2._y = tempY;
			
			this.mcArrayBefore.push(this.mcArrayAfter.pop());
			this.mcArrayAfter.unshift(this.centerFocusMC);
			this.centerFocusMC = MovieClip(this.mcArrayBefore.shift());
			
			// unhighlight previous mc
			if (this.unhlCB != null)
			{
				this.unhlCB( { dataIndex:this.getIndex(this.hl + 1), mc:this.mcArrayAfter[0] } );
			}
			
			this.doHighlight();
		}
		
		// update the last mc data
		this.updateMC(direction);
	}
	
	private function moveMCLocation(mc1:MovieClip, mc2:MovieClip)
	{
		var tempX:Number = mc1._x;
		var tempY:Number = mc1._y;
		mc1._x = mc2._x;
		mc1._y = mc2._y;
		
		mc2._x = tempX;
		mc2._y = tempY;
	}
	
	private function updateMC(direction:Number):Void
	{
		if (direction == 1)
		{
			//update the last item
			var mc:MovieClip = this.mcArrayAfter[this.mcArrayAfter.length - 1];
			var dataIndex:Number = this.getIndex(this.mcArrayAfter.length);
			
			var data:Object = this.getData(dataIndex);
			if (data != null)
			{
				if (this.onItemUpdateCB != null)
				{
					this.onItemUpdateCB( { dataIndex:dataIndex, data:data, mc:mc } );
				}
			}
			else
			{
				if (this.onItemClearCB != null)
				{
					this.onItemClearCB( { mc:mc } );
				}
			}
			
			// TODO: load data if not enough data
			
		}
		else if (direction == 2)
		{
			//update the last item
			var mc:MovieClip = this.mcArrayBefore[this.mcArrayBefore.length - 1];
			var dataIndex:Number = this.getIndex(0 - this.mcArrayBefore.length);
			var data:Object = this.getData(dataIndex);
			
			if (data != null)
			{
				if (this.onItemUpdateCB != null)
				{
					this.onItemUpdateCB( { dataIndex:dataIndex, data:data, mc:mc } );
				}
			}
			else
			{
				if (this.onItemClearCB != null)
				{
					this.onItemClearCB( { mc:mc } );
				}
			}
			
			// TODO: load data if not enough data
		}
	}
	
	private function getIndex(offset:Number):Number
	{
		var index:Number = this.hl + offset;
		
		if (this.wrap)
		{
			while (index < 0)
			{
				index += this.dataLen;
			}
			while (index >= this.dataLen)
			{
				index -= this.dataLen;
			}
		}
		
		return index;
	}
}