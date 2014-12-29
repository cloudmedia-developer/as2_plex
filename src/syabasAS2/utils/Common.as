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
import syabasAS2.event.Caster;

class syabasAS2.utils.Common extends Caster {
	public function Common(){
	}
	/** 
		create Textfield 
	*/
	public function textfield(target:MovieClip, insname:String, depth:Number, obj0:Object, obj1:Object){
		var tField:TextField = target.createTextField(insname,depth,obj0._x,obj0._y,obj0._width,obj0._height);
		if(obj1){
			for(var i in obj1){tField[i] = obj1[i]}
		}
	//	tField.border = true;
		return tField;
	}
	
	/** 
		center Object to object
	*/
	
	public function center(target0:MovieClip, target1:MovieClip){
		target0._x = (target1._x+(target1._width/2)) - (target0._width/2);
		target0._y = (target1._y+(target1._height/2)) - (target0._height/2);
	}
	
	/** 
		draw square
	*/	
	
	public function drawSquare(target:MovieClip, x:Number, y:Number, w:Number, h:Number, c:Number, a:Number){
		target.beginFill((c == null ? 0xFFFFFF : c), (a == null ? 100 : a));
		target.moveTo(x,y);
		target.lineTo(x+w, y);
		target.lineTo(x+w, y+h);
		target.lineTo(x, y+h);
		target.lineTo(x, y);
		target.endFill();
		return target;
	}
	
	/** 
		draw rounded rectangle
	*/
	public function drawRoundedRectangle(mc:MovieClip, rectWidth:Number, rectHeight:Number, cornerRadius:Number, fillColor:Number, fillAlpha:Number, lineThickness:Number, lineColor:Number, lineAlpha:Number) {
	  with (mc) {
		beginFill(fillColor, fillAlpha);
		lineStyle(lineThickness, lineColor, lineAlpha);
		moveTo(cornerRadius, 0);
		lineTo(rectWidth - cornerRadius, 0);
		curveTo(rectWidth, 0, rectWidth, cornerRadius);
		lineTo(rectWidth, cornerRadius);
		lineTo(rectWidth, rectHeight - cornerRadius);
		curveTo(rectWidth, rectHeight, rectWidth - cornerRadius, rectHeight);
		lineTo(rectWidth - cornerRadius, rectHeight);
		lineTo(cornerRadius, rectHeight);
		curveTo(0, rectHeight, 0, rectHeight - cornerRadius);
		lineTo(0, rectHeight - cornerRadius);
		lineTo(0, cornerRadius);
		curveTo(0, 0, cornerRadius, 0);
		lineTo(cornerRadius, 0);
		endFill();
	  }
	  mc.cacheAsBitmap = true;
	}
	
	/** 
		convert duration to Hours, Minutes, Seconds
	*/	
	
	public function HHMMSS(duration:Number){
		if(duration){
			var minutes = Math.floor(duration/60);
			var hours = Math.floor(minutes/60);
				minutes = minutes%60;
			var seconds = Math.floor(duration%60);
			var hhmmss:String;
			if (seconds<10) {
				seconds = "0"+seconds;
			}
			if (minutes<10) {
				minutes = "0"+minutes;
			}
			if (hours<10) {
				hours = "0"+hours;
			}
			
			return((hours == 0 ? "" : hours+":")+minutes+":"+seconds);
		}else{
			return("00:00");
		}
	}
	
	/** 
		check null string
	*/
	public function notNull(str){
		if(str == "undefined" || str == null){
			return "";
		}else{
			return str;
		}
	}

	/** 
		add "..." to string
	*/
	public function dotdotdot(textF:TextField):Void{
		var my_str:String = new String(textF.htmlText);
		var format:TextFormat = textF.getTextFormat();
		while (textF.textWidth > textF._width){
			my_str = my_str.substr(0,my_str.length-1);
			textF.htmlText = my_str+"...";
			textF.setTextFormat(format);
		}
	}

	public function dotdotdot_vertical(textF:TextField):Void {
		var a:TextField = textF;
		if(a.maxscroll > 1){
			var my_str:String = new String(a.text);
			a.text = "";
			var my_array:Array = new Array();
			my_array = my_str.split(" ");
			var my_array_length:Number = my_array.length;
			for(var i=0; i<my_array_length; i++){
				if(a.maxscroll > 1){
					for(var i=0; i<my_array_length; i++){
						a.text = a.text.substr(0, -1);
						if(a.maxscroll == 1){
							break;
						}
					}
					a.text = a.text.substr(0, -3);
					a.text += "...";
					break;
				}else{
					a.text += my_array[i]+" ";
				}
			}
		}
	}
	
	/** 
		remove child movieclip
	*/
	public function removeClip(target:MovieClip):Void{
		for(var i in target){
			target[i].removeMovieClip();
		}
	}

	/** 
		set text to bold
	*/
	public function newTextFormat(target:TextField, apply, isStyle:Boolean):Void {
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
	//string replace
	function stringReplace(block:String, find:String, replace:String):String
	{
		return block.split(find).join(replace);
	}
	
	/** 
		pop length object of array
	*/
	public function pop(target:Array):Void{
		for(var i in target){
			target.pop();
		}
	}
}
