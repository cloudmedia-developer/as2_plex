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
import syabasAS2.utils.Destructor;

class syabasAS2.utils.ListDisplay{
	private var index		:Number = 0;
	private var hlIndex		:Number = 0;
	private var total		:Number = 0;
	private var pageTotal	:Number = 0;
	private var pageIndex	:Number = 0;
	private var gap			:Number = 0;
	
	public var topPadding:Number 		= 139;
	public var leftPadding:Number 		= 222;
	public var textfieldWidth:Number 	= 450;
	public var textfieldHeight:Number 	= 50;
	public var maxSize:Number 			= 10;
	public var leftPadding_hl			= 0;
	public var topPadding_hl			= 0;
	public var gap_hl					= 0;
		
	private var listData	:Array;
	private var listContent	:Array;
	private var idc:Array;
	private var mc			:MovieClip;
	private var hl			:MovieClip;
	
	private var colorOn		:Number;
	private var colorOff	:Number;
	private var type:String = "";
	
	//init
	public function ListDisplay() {
		this.idc 			= new Array();
		this.listContent 	= new Array();
	}
	
	public function get current_index():Number {
		return index+hlIndex;
	}
	/**
	 * data Array ["title0", "title1", "title2"] or ["a0.jpg", "a1.jpg", "a2.jpg"]
	 * */
	public function set data(data:Array):Void {
		this.index 			= 0;
		this.hlIndex		= 0;
		this.pageIndex		= 0;
		this.listData 	 	= data;
		this.total 			= this.listData.length;
		this.pageTotal	 	= (Math.floor((this.total - 1) / this.maxSize));
	}
	
	/**
	 * Display Perperty
	 * @param	leftPadding			Left Padding
	 * @param	topPadding			Top Padding
	 * @param	textfieldWidth		Textfield Width
	 * @param	textfieldHeight		Textfield Height
	 */
	public function set_display_property(leftPadding:Number, topPadding:Number, textfieldWidth:Number, textfieldHeight:Number, gap:Number, maxSize:Number):Void {
		this.leftPadding		= leftPadding;
		this.topPadding			= topPadding;
		this.textfieldWidth		= textfieldWidth;
		this.textfieldHeight	= textfieldHeight;
		this.gap				= gap;
		this.maxSize			= maxSize;
	}

	/**
	 * HL Display Perperty
	 * @param	leftPadding_hl			Left Padding
	 * @param	topPadding_hl			Top Padding
	 * @param	gap_hl					gap
	 * @param	colorOn					Color code
	 * @param   colorOff				Color code
	 */	
	public function set_hl_property(leftPadding_hl:Number, topPadding_hl:Number, gap_hl:Number, colorOn:Number, colorOff:Number):Void {
		this.leftPadding_hl		= leftPadding_hl;
		this.topPadding_hl		= topPadding_hl;
		this.gap_hl				= gap_hl;
		this.colorOn			= colorOn;
		this.colorOff			= colorOff;
	}
	
	/** 
	 * Loop textfield
	 * @param mc				MovieClip
	 * @param propDisplay 		{_x:,_y:,_width:,_height:,...}
	 * @param propTextfield		{html:,autoSize:,border:,...}
	 * @param style				{color:,size:,align:,...}
	 * @param loopBy 			"vertical" or "horizontal"
	 * */
	 public function loop_textfield(mc:MovieClip, propTextfield:Object, style:Object, loopBy:String):Void {
		this.type = "textfield";
		this.mc = mc;
		for (var i:Number = 0; i < this.maxSize; i++) {
			var depth:Number = this.mc.getNextHighestDepth();
			var textfield:TextField = this.textfield(this.mc, "textfield" + depth, depth, { _x:0, _y:0, _width:this.textfieldWidth, _height:this.textfieldHeight }, propTextfield);
			this.listContent[i] = textfield;
			//this.set_content_position(loopBy, i);
			this.newTextFormat(textfield, style);
			//textfield.htmlText = this.listData[i].toString();
		}
		if(this.idc.length > 0 && pageTotal > 0){
			this.indicator(this.idc, (this.maxSize - 1), this.index,  this.total);
		}
	}
	
	/** 
	 * loop image
	 * @param mc				MovieClip
	 * @param loopBy 			"vertical" or "horizontal"
	 * */
	public function loop_image(mc:MovieClip, loopBy:String):Void {
		this.type = "image";
		this.mc = mc;
		for (var i:Number = 0; i < this.maxSize; i++) {
			var depth:Number = this.mc.getNextHighestDepth();
			var image:MovieClip = this.mc.createEmptyMovieClip("image" + depth, depth);
			this.listContent[i] = image;
			
			//this.set_content_position(loopBy, i);
			//new ClipLoader(image, this.listData[i].toString());
		}
		if(this.idc.length > 0 && pageTotal > 0){
			this.indicator(this.idc, (this.maxSize - 1), this.index,  this.total);
		}
	}
	
	/** Set Content Position*/
	private function set_content_position(loopBy:String, loopIndex:Number):Void {
		if (loopBy == "horizontal") {
			listContent[loopIndex]._x = this.topPadding + (listContent[loopIndex-1]._x+listContent[loopIndex-1]._width);
		}else {
			listContent[loopIndex]._x = this.leftPadding;
			listContent[loopIndex]._y = this.topPadding + (loopIndex * this.gap);
		}
	}
	
	/**
	 * List Indicator
	 * @param	image			["on.png", "off.png"]
	 * @param	rowIndex		row index
	 * @param	resultsTotal  	total
	 */
	private function indicator(image:Array, max:Number , rowIndex:Number, resultsTotal:Number):Void {
		if (max > resultsTotal-1){
			image[0]._alpha = 0;
			image[1]._alpha = 0;
			image[2]._alpha = 0;
			image[3]._alpha = 0;
		}else{
			if (max+rowIndex < resultsTotal-1) {
				image[1]._alpha = 100;
				image[0]._alpha = 100;
			}else {
				image[1]._alpha = 0;
				image[0]._alpha = 100;
			}
			if (rowIndex == 0){
				image[0]._alpha = 0;
			}
			image[2]._alpha = 100;
			image[3]._alpha = 100;
		}
	}	
	
	//empty textfield "" and loaded image
	private function empty_text_image():Void {
		this.mc._y = 0;

		for (var i:Number = 0; i < this.maxSize; i++) {
			set_content_position("vertical", i)
		}
		
		for (var i = 0; i < this.maxSize; i++) {
			if (this.listContent[i] instanceof TextField) {
				this.listContent[i].text = "";
			}else {
				unloadMovie(this.listContent[i]);
			}
		}
	}
	
	//reload
	public function reload():Void {
		this.empty_text_image();
		for (var i:Number = 0; i < Math.min(this.total, this.maxSize); i++) {
			if(this.type == "textfield"){
				this.listContent[i].htmlText = this.listData[i].toString();
			}else {
				new ClipLoader(this.listContent[i], this.listData[i].toString());
			}
		}
		if(this.idc.length > 0){
			this.indicator(this.idc, (this.maxSize - 1), this.index,  this.total);
		}
		
	}
	
	/**
	 * load highlight bar
	 * @param	url
	 */
/*	public function load_hl(mc:MovieClip, url:String):Void {
		trace("[ADREN-DEBUG][ListDisplay.as | load_hl():void]");
		hl 			= mc.createEmptyMovieClip("hl", mc.getNextHighestDepth());
		hl._alpha 	= 0;
		hl._x 		= this.leftPadding_hl;
		new ClipLoader(hl, url.toString());
	}*/
		
	/** focus content*/
/*	public function focus():Void {
		this.hl._y = this.topPadding_hl + (index * gap_hl);
		this.hl._alpha = 100;
		if (this.listContent[index] instanceof TextField) {
			this.listContent[index].textColor = colorOn;
		}else {
			var my_color:Color = new Color(this.listContent[index]);
			my_color.setRGB(colorOn);
		}
	}*/
	
	/** unfocus content*/
/*	public function unfocus():Void {
		this.hl._alpha = 0;
		if (this.listContent[index] instanceof TextField) {
			this.listContent[index].textColor = colorOff;
		}else {
			var my_color:Color = new Color(this.listContent[index]);
			my_color.setRGB(colorOff);
		}
	}*/
	
	/** common utils*/
	private function textfield(target:MovieClip, insname:String, depth:Number, obj0:Object, obj1:Object){
		var tField:TextField = target.createTextField(insname,depth,obj0._x,obj0._y,obj0._width,obj0._height);
		if(obj1){
			for(var i in obj1){tField[i] = obj1[i]}
		}
	//	tField.border = true;
		return tField;
	}
	
	/** common utils*/
	private function notNull(str){
		if(str == "undefined" || str == null){
			return "";
		}else{
			return str;
		}
	}
	
	/** common utils*/
	private function newTextFormat(target:TextField, apply, isStyle:Boolean):Void {
		if(isStyle){
			target.setNewTextFormat(apply);
		}else {
			var my_fmt:TextFormat = new TextFormat();
			for(var i in apply){
				my_fmt[i] = apply[i];
			}
			target.setNewTextFormat(my_fmt);
		}
	}
	
	public function kill():Void {
		Destructor.cleanMC(this.mc);
		Destructor.popArray(this.listContent);
	}
}

