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

import mx.utils.Delegate;

class syabasAS2.utils.ListScrolling {
	private var mc:MovieClip;
	private var startIndex:Number;
	private var index:Number;
	private var hlIndex:Number;
	private var gap:Number;
	private var rowPerPage:Number;
	private var total:Number;
	private var totalCache:Number;
	private var itmAttrTotal:Number;
	public var tweenIndex:Number;
	private var prevTimer:Number = 0;
	private var txtFieldArr:Array;
	private var txtFieldName:Array;
	private var iconNameArr:Array;
	private var iconRefArr:Array;
	public function ListScrolling(target:MovieClip,gap:Number,rowPerPage:Number,totalData:Number,txtFieldArr:Array,txtFieldName:Array)
	{
		trace("[LWC-DEBUG][ListScrolling.as | ListScrolling():void] target : " + target);
		trace("[LWC-DEBUG][ListScrolling.as | ListScrolling():void] gap : " + gap);
		trace("[LWC-DEBUG][ListScrolling.as | ListScrolling():void] rowPerPage : " + rowPerPage);
		trace("[LWC-DEBUG][ListScrolling.as | ListScrolling():void] totalData : " + totalData);
		trace("[LWC-DEBUG][ListScrolling.as | ListScrolling():void] txtFieldArr : " + txtFieldArr);
		trace("[LWC-DEBUG][ListScrolling.as | ListScrolling():void] txtFieldName : " + txtFieldName);
		
		mc = target;
		this.gap = gap;
		this.rowPerPage = rowPerPage;
		total = totalData;
		totalCache = rowPerPage + 2;
		//this.itmAttrTotal = itmAttrTotal;
		this.txtFieldArr = txtFieldArr;
		this.txtFieldName = txtFieldName;
	}
	private function setStartIndex(lastFocusIndex:Number):Void {
		if (lastFocusIndex < total)
		{
			if (lastFocusIndex >= rowPerPage)
			{	
				index = lastFocusIndex;
				startIndex = (lastFocusIndex + 1) - rowPerPage;
				hlIndex = rowPerPage;
			}
			else
			{
				index = lastFocusIndex;
				startIndex = 0;
				hlIndex = (lastFocusIndex == 0 ? 1 :lastFocusIndex+1);
			}
		}
		else
		{
			index = 0;
			hlIndex = 1;
			startIndex = 1;
		}
		trace("startIndex" + index)
		trace("hlIndex"+hlIndex)
	}
	
	public function get focusIndex():Number
	{
	  return hlIndex;
	}
	
	public function get itmIndex():Number
	{
	  return index;
	}
	
	public function writeData(itm:Array,lastIndex:Number, isIconOn:Boolean)
	{
		// totalCache extra 2 for row per page
		//hlIndex = 1;
		setStartIndex(lastIndex);
		tweenIndex = 0;
		var sIndex = (startIndex == 0 ? 1 : 0);
		for (var i = sIndex; i < totalCache; i++) 
		{
			emptyTxtField(txtFieldArr[i]);
			emptyIcon(txtFieldArr[i]);
			if (i - 1 < total) 
			{	
				addInTxt(txtFieldName, txtFieldArr[i], itm[(i - 1) + startIndex]);
				addInIcon(iconNameArr, txtFieldArr[i], itm[(i - 1) + startIndex]);
			}
		}
	}
	
	public function writeImg(iconNameArr:Array,iconRefArr:Array):Void
	{
		this.iconNameArr = new Array();
		this.iconNameArr = iconNameArr;
		
		this.iconRefArr = new Array();
		this.iconRefArr = iconRefArr;
	
	}
	
	private function emptyTxtField(txt)
	{
		for(var i:String in txt)
			{
				txt[i].htmlText = "";
			}
	}
	
	private function emptyIcon(txt)
	{
		for(var i:String in iconNameArr)
			{
				txt[iconNameArr[i]]._visible= false;
			}
	}
	
	public function scrollUp(itm:Array) 
	{
		if ((index + 1) > 1)
		{
			index --;
			if (hlIndex == 1)
			{
				unshiftPop(itm);
				tweenIndex--;
				tweenByRow();
			}else 
			{
				hlIndex --;
			}
		}
		return hlIndex;
	}
	
	public function scrollDown(itm:Array) 
	{
		if ((index + 1) < total)
		{
			index++;
			if (hlIndex < rowPerPage)
			{
					hlIndex ++;
			}else
			{
					shiftPush(itm);
					tweenIndex++;
					tweenByRow();			
			}
		}
		return hlIndex;
	}
	private function shiftPush(itmArr:Array):Void 
	{
		//trace(mx.data.binding.ObjectDumper.toString(txtFieldName));
		emptyTxtField(txtFieldArr[0]);
		txtFieldArr[0]._y = txtFieldArr[rowPerPage + 1]._y + gap;
		txtFieldArr.push(txtFieldArr[0]);
		txtFieldArr.shift();

		if ((index + 1) < total)
		{
			addInTxt(txtFieldName, txtFieldArr[rowPerPage + 1], itmArr[(index + 1)]);
			addInIcon(iconNameArr, txtFieldArr[rowPerPage + 1], itmArr[(index + 1)]);
			/*var totalTxtField:Number = txtFieldName.length;
			for(var i in txtFieldName)
			{
				txtFieldArr[rowPerPage + 1][txtFieldName[i]].htmlText = itmArr[(index + 1)][txtFieldName[i]];
			}*/
		}
	}
	
	private function unshiftPop(itmArr:Array):Void
	{
		emptyTxtField(txtFieldArr[rowPerPage+1]);
		txtFieldArr[rowPerPage + 1]._y = txtFieldArr[0]._y - gap;
		txtFieldArr.unshift(txtFieldArr[rowPerPage + 1]);
		txtFieldArr.pop();
		
		if ((index + 1) > 1)
		{
			addInTxt(txtFieldName, txtFieldArr[0], itmArr[(index + 1) - 2]);
			addInIcon(iconNameArr, txtFieldArr[0], itmArr[(index + 1) - 2]);
			/*var totalTxtField:Number = txtFieldName.length;
			for(var i in txtFieldName)
			{
				txtFieldArr[0][txtFieldName[i]].htmlText = itmArr[(index+1)-2][txtFieldName[i]];
			}*/
		}
	}
	private function addInTxt(txtFieldName:Array,txtField:MovieClip, itmSlot:Array):Void
	{
		var totalTxtField:Number = txtFieldName.length;
		for(var i in txtFieldName)
		{
			txtField[txtFieldName[i]].htmlText = itmSlot[txtFieldName[i]];
		}
	
	}
	
	private function addInIcon(iconNameArr:Array,txtField:MovieClip, itmSlot:Array):Void
	{
/*		for(var i in iconNameArr)
		{
			trace(iconNameArr);
			trace("itmSlot.sIcon" + itmSlot.sIcon);
			if (itmSlot[iconRefArr[0]]  == iconNameArr[i]) {
				trace(i+"-TRUE" + txtField[itmSlot[iconRefArr[0]]]);
				txtField[itmSlot[iconRefArr[0]]]._visible= true;
			}
			else
			{
				trace(i+"_FALSE" + txtField[iconNameArr[i]]);
				txtField[iconNameArr[i]]._visible= false;
			}
		}*/
		for(var i in iconNameArr)
		{
			txtField[iconNameArr[i]]._visible= false;
			
		}
		for (var j in iconRefArr)
			{
				txtField[itmSlot[iconRefArr[j]]]._visible= true;
				
			}
	}
	public function chgIcon(itm:Array, iconArr:Array):Void {
/*		for(var i in iconNameArr)
		{
			if (iconArr[0] == iconNameArr[i]) {
				txtFieldArr[hlIndex][iconArr[0]]._visible= true;
			}
			else
			{
				txtFieldArr[hlIndex][iconNameArr[i]]._visible= false;
			}
		}*/
		
		for(var i in iconNameArr)
		{
			for(var j in iconArr)
			{
				txtFieldArr[hlIndex][iconNameArr[i]]._visible= false;
				txtFieldArr[hlIndex][iconArr[j]]._visible = true;
			
				/*if (iconArr[j] == iconNameArr[i]) {
					trace(j+"TRUE -[MEIAI-DEBUG][ListScroll.as | chgIcon():void] txtFieldArr[hlIndex][iconArr[j]] : " + txtFieldArr[hlIndex][iconArr[j]]);
					txtFieldArr[hlIndex][iconArr[j]]._visible= true;
				}
				else
				{
					txtFieldArr[hlIndex][iconNameArr[i]]._visible= false;
				}*/
			}
		}		
	}
	
	/*private function arrAttrData(itmArr:Array)
	{
		//trace(mx.data.binding.ObjectDumper.toString(itmArr));
		var attrTotal = (itmAttrTotal!=undefined ? itmAttrTotal : 100)
		var dataArr:Array = new Array;
		var j = 0;
		for (var prop in itmArr)
		{   
			if(j<attrTotal){
				dataArr[j] = itmArr[prop];
			}
			j++;
		}
		return dataArr.reverse();
	}*/
	private function tweenByRow():Void 
	{
		//var currentTimer:Number = getTimer();
		
		mc.stopTween();
		/*if(currentTimer - prevTimer > 250){
			mc.tween("_y", tweenIndex * -gap, 0.5, "easeOutQuint", 0);
		}else {*/
			mc._y = tweenIndex * -gap;
		//}
		//prevTimer = currentTimer;
	}
	private function clearAll()
	{
		trace("clearAll");
		for (var i = 1; i < totalCache; i++) 
		{
			txtFieldArr[i].removeTextField();
		}
	}
	public function rmvItem(itm:Array, callback)
	{
		total --;	
		var i = 0;
		/*var dataArr:Array = new Array;*/
		if(total > 0){
			if (total < rowPerPage && (index+1) == total+1) 
			{
				trace("condition 0");
				emptyTxtField(txtFieldArr[hlIndex]);
				itm.pop();
				if (itm.length == 1)
				{
					clearAll();
				}
				hlIndex --;
				index --;
				callback();
				//resume();
			}
			else if (total >= rowPerPage && (index+1) + (rowPerPage - hlIndex) >= (total + 1) && (index+1) == (total + 1))
			{
				
				trace("condition 1");
				txtFieldArr[rowPerPage + 1]._y = txtFieldArr[0]._y - gap;
				txtFieldArr.unshift(txtFieldArr[rowPerPage + 1]);
				txtFieldArr.pop();
				itm.pop();
				if (itm[(index + 1) - (rowPerPage + 2)]) {
					addInTxt(txtFieldName, txtFieldArr[0], itm[(index+1) - (rowPerPage + 2)]);
					/*dataArr = arrAttrData(itm[(index+1) - (rowPerPage + 2)]);
					for(Object in txtFieldArr[0])
					{
						txtFieldArr[0][Object].htmlText = dataArr[i];
						i ++ ;
					}*/
				}else 
				{
					emptyTxtField(txtFieldArr[0]);
				}
				tweenIndex --;
				index --;
				mc._y = tweenIndex * -gap;
				emptyTxtField(txtFieldArr[rowPerPage + 1]);
				callback();
				//resume();			
			}
			else if (total > rowPerPage && (index+1) + (rowPerPage - hlIndex) >= (total + 1) && (index+1) != (total + 1))
			{
				trace("condition 1-A");
				txtFieldArr[hlIndex]._y = txtFieldArr[0]._y - gap;
				txtFieldArr.unshift(txtFieldArr[hlIndex]);
				txtFieldArr.splice(hlIndex+1, 1);
				itm.splice(index, 1);
				if (itm[(index + 1) - (rowPerPage + 2)]) {
					addInTxt(txtFieldName, txtFieldArr[0], itm[(index+1) - (rowPerPage + 2)]);
					/*dataArr = arrAttrData(itm[(index+1) - (rowPerPage + 2)]);
					for(Object in txtFieldArr[0])
					{
						txtFieldArr[0][Object].htmlText = dataArr[i];
						i ++ ;
					}*/
				}else {
					emptyTxtField(txtFieldArr[0]);
				}
				index --;
				for(var m=0; m<hlIndex+1; m++){
					txtFieldArr[m]._y = txtFieldArr[i]._y+gap;
				}
				callback();
				//resume();			
			}else {
				// in last page
				trace("condition 2");
				txtFieldArr[hlIndex]._y = txtFieldArr[rowPerPage + 1]._y + gap;
				txtFieldArr.push(txtFieldArr[hlIndex]);
				txtFieldArr.splice(hlIndex, 1);
				itm.splice(index, 1);
				if (itm[getNextIndex()])
				{
					addInTxt(txtFieldName, txtFieldArr[rowPerPage + 1], itm[getNextIndex()]);
					/*
					dataArr = arrAttrData(itm[getNextIndex()]);
					for(Object in txtFieldArr[rowPerPage + 1])
					{
						txtFieldArr[rowPerPage + 1][Object].htmlText = dataArr[i];
						i ++ ;
					}*/
				}else {
					emptyTxtField(txtFieldArr[rowPerPage + 1]);
				}
				
				txtFieldArr[hlIndex].tween("_y", txtFieldArr[hlIndex]._y - gap, 0.3, "linear", 0, Delegate.create(this, callback));
				
				txtFieldArr[hlIndex].onTweenUpdate = Delegate.create(this, move_XY_center);	
			}
		}else {
			//DetailMenu.self.rmv_Complete();
		}
		return hlIndex;
	}
	private function getNextIndex()
	{
		return ((index+1) + (rowPerPage-hlIndex));
	}
	
	private function move_XY_center():Void 
	{
		for(var i=hlIndex+1; i<totalCache; i++){
			txtFieldArr[i]._y = txtFieldArr[i-1]._y+gap;
		}
	}

}
