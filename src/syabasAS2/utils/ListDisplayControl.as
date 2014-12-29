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
import syabasAS2.image.ClipLoader;
import syabasAS2.utils.ListDisplay;

class syabasAS2.utils.ListDisplayControl extends ListDisplay{
	private var isMainControl:Boolean;
	
	public function ListDisplayControl(isMainControl:Boolean) {
		this.isMainControl 	= isMainControl;
		
	}
	
	//-----------------------------------------------------------------------------------------------------------
	/**
	 * - Key Navigate Control
	 */
	//-----------------------------------------------------------------------------------------------------------	
	public function press_up():Void {
		unfocus();
		if(hlIndex > 0){
			hlIndex --;
		}else{
			if(index > 0){
				this.listContent[this.maxSize-1]._y = this.listContent[0]._y-this.gap;
				this.listContent.unshift(this.listContent[this.maxSize-1]);
				this.listContent.pop();
				this.listContent[0].text = this.listData[this.index - 1];
				if(this.listContent[0] instanceof TextField){
					this.listContent[0].htmlText = this.listData[this.index - 1];
				}else {
					this.listContent[0].clear();
					new ClipLoader(this.listContent[0], this.listData[this.index - 1])
				}

				this.index--;
				if(this.isMainControl){
					indicator_status();
				}
				if(this.isMainControl){
					this.mc._y += this.gap;
				}
			}
		}
		//trace("index:" + (this.hlIndex + this.index));
		//this.pageIndex = Math.floor(this.index  / this.maxSize);
		focus();
	}
	
	public function press_down():Void {
		unfocus();
		if (this.hlIndex < this.maxSize-1 && this.hlIndex < this.total-1) {
			this.hlIndex ++;
		}else{
			if(this.maxSize+this.index < this.total){
				this.listContent[0]._y = this.listContent[this.maxSize-1]._y+this.gap;
				this.listContent.push(this.listContent[0]);
				this.listContent.shift();
				if(this.listContent[this.maxSize-1] instanceof TextField){
					this.listContent[this.maxSize-1].htmlText = this.listData[this.maxSize + this.index];
				}else {
					this.listContent[this.maxSize-1].clear();
					new ClipLoader(this.listContent[this.maxSize-1], this.listData[this.maxSize + this.index])
				}
				
				this.index++;
				if(this.isMainControl){
					indicator_status();
				}
				if (this.isMainControl) {
					this.mc._y -= this.gap;
				}
				
			}
		}
		//trace("index:" + (this.hlIndex + this.index));
		focus();
	}
	
	public function press_pgdown():Void {
		unfocus();
		empty_text_image();
		//------------------------------------------------------------------------
		this.pageIndex = Math.floor(this.index / maxSize) + 1;
		var startIndex:Number = pageIndex * this.maxSize;

		if (startIndex+maxSize > this.total) {
			startIndex -= ((startIndex+maxSize) - this.total);
		}
		this.index = startIndex;
		
		for (var i = 0; i < this.maxSize; i++) {
			if (this.type == "image") {
				new ClipLoader(this.listContent[i], this.listData[startIndex+i]);
			}else {
				this.listContent[i].text = this.listData[startIndex+i];
			}
			trace(this.listData[startIndex+i]);
		}
		//------------------------------------------------------------------------	
		focus();
		indicator_status();
	}
	
	public function press_pgup():Void {
		unfocus();
		empty_text_image();
		//------------------------------------------------------------------------
		this.pageIndex--;
		
		if (pageIndex > 0) {
			var startIndex:Number = pageIndex * this.maxSize;
		}else {
			var startIndex:Number = 0;
			this.pageIndex = 0;
			this.index = 0;
		}

		for (var i = 0; i < this.maxSize; i++) {
			if (this.type == "image") {
				new ClipLoader(this.listContent[i], this.listData[startIndex+i]);
			}else {
				this.listContent[i].text = this.listData[startIndex+i];
			}
			trace(this.listData[startIndex+i]);
		}
		//------------------------------------------------------------------------
		focus();
		indicator_status();
	}
	
	public function press_enter():Void {
		this.unfocus();
	}
	
	public function indicator_status():Void {
		this.indicator(this.idc, (this.maxSize - 1), this.index,  this.total);
	}
	
	/**
	 * load highlight bar
	 * @param	url
	 */
	public function load_hl(mc:MovieClip, url:String, callback:Function):Void {
		trace("[ADREN-DEBUG][ListDisplay.as | load_hl():void]");
		hl 			= mc.createEmptyMovieClip("hl", mc.getNextHighestDepth());
		hl._alpha 	= 0;
		hl._x 		= this.leftPadding_hl;
		new ClipLoader(hl, url.toString(),null,callback);
	}
	
	/** load page indicator */
	public function load_page_indicator(mc:MovieClip, prevImageURL:String, nextImageURL:String, prevOnImageURL:String, nextOnImageURL:String):Void {
		mc.createEmptyMovieClip("prev", mc.getNextHighestDepth());
		mc.createEmptyMovieClip("next", mc.getNextHighestDepth());
		mc.createEmptyMovieClip("prev_on", mc.getNextHighestDepth());
		mc.createEmptyMovieClip("next_on", mc.getNextHighestDepth());
		
		mc.prev._alpha	= 0;
		mc.next._alpha	= 0;		
		mc.prev_on._alpha	= 0;
		mc.next_on._alpha	= 0;	
		
		this.idc[0] = mc.prev_on;
		this.idc[1] = mc.next_on;		
		this.idc[2] = mc.prev;
		this.idc[3] = mc.next;
				
		new ClipLoader(mc.prev, 	prevImageURL, 	{_x:-20	,_y:0});
		new ClipLoader(mc.next, 	nextImageURL, 	{_x:0	,_y:0});
		new ClipLoader(mc.prev_on, 	prevOnImageURL, {_x:-20	,_y:0});
		new ClipLoader(mc.next_on, 	nextOnImageURL, { _x:0	, _y:0 } );
	}
	
	/** focus content*/
	public function focus():Void {
		this.hl._y = this.topPadding_hl + (this.hlIndex * this.gap_hl);
		this.hl._alpha = 100;
		if (this.listContent[this.hlIndex] instanceof TextField) {
			this.listContent[this.hlIndex].textColor = colorOn;
		}else {
			var my_color:Color = new Color(this.listContent[this.hlIndex]);
			my_color.setRGB(colorOn);
		}
	}
	
	/** unfocus content*/
	public function unfocus():Void {
		this.hl._alpha = 0;
		if (this.listContent[this.hlIndex] instanceof TextField) {
			this.listContent[this.hlIndex].textColor = colorOff;
		}else {
			var my_color:Color = new Color(this.listContent[this.hlIndex]);
			my_color.setRGB(colorOff);
		}
	}
	
	/** override : kill */
	public function kill():Void 
	{
		super.kill();
		
		this.hl.removeMovieClip();
	}
}