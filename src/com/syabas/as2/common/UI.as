﻿/***************************************************
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
* Version: 1.1.1
*
* Developer: Syabas Technology Sdn. Bhd.
*
* Class Description: UI functions.
*
***************************************************/

class com.syabas.as2.common.UI
{
	private static var ACTUAL_SIZE:Number = 1;
	private static var FIT_TO_SCREEN:Number = 2;
	private static var FULL_SCREEN:Number = 3;

	/*
	* Load Image from a specific URL.
	*
	* url: the image URL.
	* parentMC: parent movieClip to attach the new image movieClip.
	* mcId: instance Id of the image movieClip.
	* o: extra arguments Object with properties:
	*   1. mcProps:Object      - properties of the image movieClip.
	*   2. lmcId:String        - id of the loading animation movieClip. New movieClip instance id is "loadingMC".
	*   3. lmcProps:Object     - properties of the loading movieClip.
	*   4. retry:Number        - retry how many time when failed.
	*   5. scaleMode:Number    - mode to scale after image loaded. 1=Actual Size, 2=Fit To Screen, 3=Full Screen. Default is 1.
	*   6. scaleProps:object   - properties of the scaling process.
	*      a. center:Boolean   - keep image at center of parent movieclip.
	*      b. width:Number     - width of the image to scale. Default is 1280.
	*      c. height:Number	   - height of the image to scale. Default is 720.
	*      d. actualSizeOption:Number - use when loaded image more then width or height and scaleMode is 1. 1=Fit to Screen, 2=Full Screen, 3=no change. Default is 1.
	*   7. doneCB:Function     - callback function when image is loaded or failed. Arguments:
	*      a. success:Boolean.
	*      b. o:Object         - extra object to pass back.
	*         i. url:String    - same as the url pass to this load function.
	*         ii. o:Object     - same as the "o" Object pass to this loadImage function.
	*
	* Resulting movieClips:
	*
	* parentMC
	*   |-- <mcId>
	*          |-- loadingMC
	*          |-- imgMC
	*/
	public static function loadImage(url:String, parentMC:MovieClip, mcId:String, o:Object):Void
	{
		var retry:Number = o.retry;
		if (retry == undefined || retry == null || retry == "" || isNaN(retry) || typeof(retry) != "number" || retry < 1)
			o.retry = 0;
		var doneCB:Function = o.doneCB;
		if (doneCB == undefined)
			doneCB = null;

		parentMC[mcId].removeMovieClip();

		var imgBaseMC:MovieClip = parentMC.createEmptyMovieClip(mcId, parentMC.getNextHighestDepth());
		var imgMC:MovieClip = imgBaseMC.createEmptyMovieClip("imgMC", imgBaseMC.getNextHighestDepth());
		var imgLoader:MovieClipLoader = new MovieClipLoader();
		var imgLoaderListener:Object = new Object();
		var loadingMC:MovieClip = null;

		if (o.lmcId != undefined && o.lmcId != null)
		{
			loadingMC = imgBaseMC.attachMovie(o.lmcId, "loadingMC", imgBaseMC.getNextHighestDepth());
			var lmcProps:Object = o.lmcProps;
			for (var prop:String in lmcProps)
				loadingMC[prop] = lmcProps[prop];
		}

		imgLoader.addListener(imgLoaderListener);

		imgLoaderListener.onLoadInit = function(targetMC:MovieClip)
		{
			var width:Number = o.scaleProps.width;
			var height:Number = o.scaleProps.height;
			if(width == undefined || width == null)
				width = 1280;
			if(height == undefined || height == null)
				height = 720;
			
			var scaleMode:Number = o.scaleMode;
			if(scaleMode == undefined || scaleMode == null)
				scaleMode = 1;

			switch(scaleMode)
			{
				case UI.FIT_TO_SCREEN:
					UI.scaleImage(targetMC, width, height);
				break;
				case UI.FULL_SCREEN:
					UI.stretchImage(targetMC, width, height);
				break;
				case UI.ACTUAL_SIZE:
				default:
					if (targetMC._width > width || targetMC._height > height)
					{
						var op:Number = o.scaleProps.actualSizeOption;
						if(op == undefined || op == null)
							op = 1;
						switch(op)
						{
							default:
							case 1: // fit to screen
								UI.scaleImage(targetMC, width, height);
							break;
							case 2: // full screen
								UI.stretchImage(targetMC, width, height);
							break;
							case 3: // actual size, do nothing.
							break;
						}
					}
				break;
			}
			if(o.scaleProps.center == true)
			{
				targetMC._x = (width - targetMC._width) / 2;
				targetMC._y = (height - targetMC._height) / 2;
			}

			var mcProps:Object = o.mcProps;
			for (var prop:String in mcProps)
				targetMC[prop] = mcProps[prop];

			if (loadingMC != null)
				loadingMC.removeMovieClip();

			if (doneCB != null)
				doneCB(true, {url:url, o:o}); // callback.
		};

		imgLoaderListener.onLoadError = function()
		{
			if (loadingMC != null)
				loadingMC.removeMovieClip();

			if (o.retry > 0)
			{
				o.retry--;
				UI.loadImage(url, parentMC, mcId, o);
			}
			else if (doneCB != null)
				doneCB(false, {url:url, o:o}); // callback.
		};

		imgLoader.loadClip(url, imgMC);
	}

	private static function scaleImage(mc:MovieClip, width:Number, height:Number):Void
	{
		var mcWidth:Number = mc._width;
		var mcHeight:Number = mc._height;

		if ((width * mcHeight) > (height * mcWidth)) // (width / height) > (mcWidth / mcHeight)
		{
			mc._height = height;
			mc._width = (height / mcHeight) * mcWidth;
		}
		else
		{
			mc._width = width;
			mc._height = (width / mcWidth) * mcHeight;
		}
	}

	private static function stretchImage(mc:MovieClip, width:Number, height:Number):Void
	{
		mc._width = width;
		mc._height = height;
	}

	/*
	* Mask Movie Clip by coding.
	*
	* baseMC:MovieClip    - parent movieClip of mcToMask.
	* mcToMask:MovieClip  - movieclip which ready to mask.
	* x:Number            - x position to start masking.
	* y:Number            - y position to start masking.
	* width:Number        - width for the masking area.
	* height:Number       - height for the masking area.
	*/
	public static function createMask(baseMC:MovieClip, mcToMask:MovieClip, x:Number, y:Number, width:Number, height:Number):MovieClip
	{
		var maskMC:MovieClip = baseMC.createEmptyMovieClip("layoutMask", baseMC.getNextHighestDepth());
		maskMC.beginFill(0xFFFFFF, 0);
		maskMC.moveTo(x, y);
		maskMC.lineTo(x + width, x);
		maskMC.lineTo(x + width, y + height);
		maskMC.lineTo(x, y + height);
		maskMC.lineTo(x, y);
		maskMC.endFill();

		mcToMask.setMask(maskMC);
		return maskMC;
	}

	/*
	* Remove Masked Movie Clip by coding. Timeline masking is not applicable.
	*
	* mcToMask:MovieClip - movieclip which masked;
	*/
	public static function removeMask(mcToMask:MovieClip):Void
	{
		mcToMask.setMask(null);
	}

	/*
	* Align UI.
	*
	* symbolList:Array    -list of array which content:
	*   1. symbol         - symbol(Movie Clip, Textfield, button) which ready to align.
	*   2. gap:Number     - [optional] Default will use value gap in prop.
	* prop: extra arguments Object with properties:
	*   1. halign:String  - left(Left-align content), right(Right-align content), center(Center-align content), justify(Stretches the lines so that each line has equal width).
	*   2. valign:String  - top(Top-align content), middle(Center-align content), bottom(Bottom-align content).
	*   3. layout:String  - vertical or horizontal. Default is horizontal.
	*   4. gap:Number     - Gap between symbols. Default is 0.
	*   5. x:Number	      - Starter x Position. Default is 0.
	*   6. y:Number	      - Starter y Position. Default is 0.
	*   7. width:Number   - Width to align. Default is 1280.
	*   8. height:Number  - Height to align. Default is 720
	*/
	public static function align(symbolList:Array, prop:Object):Void
	{
		var len:Number = symbolList.length;		
		if (isNaN (new Number (len)))
			return;
		if(prop == undefined || prop == null)
			return;
		if((prop.halign == undefined || prop.halign == null) && (prop.valign == undefined || prop.valign == null))
			return;

		if(prop.layout == undefined || prop.layout == null)
			prop.layout = "horizontal";
		if (isNaN (new Number (prop.gap)))
			prop.gap = 0;
		if (isNaN (new Number (prop.x)))
			prop.x = 0;
		if (isNaN (new Number (prop.y)))
			prop.y = 0;
		if (isNaN (new Number (prop.width)))
			prop.width = 1280;
		if (isNaN (new Number (prop.height)))
			prop.height = 720;

		var gap:Number = 0;
		var w:Number = 0;
		var tW:Number = 0;
		var temp:Number = 0;
		if(prop.halign !== null || prop.halign !== "null" || prop.halign !== undefined || prop.halign !== "undefined" || prop.halign !== "")
		{
			if(prop.halign.toLowerCase() !== "justify")
			{
				if(prop.layout == "horizontal")
					symbolList[0].symbol._x = prop.x;
				else if(prop.layout == "vertical")
					symbolList[0].symbol._y = prop.y;
				else
					return;
				for(var i:Number = 0; i < len; i++)
				{
					if(prop.layout == "horizontal")
						w = symbolList[i-1].symbol._width;
					else
						w = symbolList[i-1].symbol._height;

					if (isNaN (new Number (symbolList[i-1].gap)))
						gap = prop.gap;
					else
						gap = symbolList[i-1].gap;
					if(prop.layout == "horizontal")
						symbolList[i].symbol._x = symbolList[i-1].symbol._x + w + gap;
					else
						symbolList[i].symbol._y = symbolList[i-1].symbol._y + w + gap;
				}

				if(prop.layout == "horizontal")
				{
					w = symbolList[len-1].symbol._width;
					tW = (symbolList[len-1].symbol._x + w + gap) - prop.x;
				}
				else
				{
					w = symbolList[len-1].symbol._height;
					tW = (symbolList[len-1].symbol._y + w + gap) - prop.y;
				}
			}

			switch(prop.halign.toLowerCase())
			{
				case "left": // do nothing
				break;
				case "right":
					if(prop.layout == "horizontal")
					{
						temp = prop.width - tW;
						for(var j:Number = 0; j < len; j++)
							symbolList[j].symbol._x += temp;
					}
					else
					{
						temp = prop.height - tW;
						for(var j:Number = 0; j < len; j++)
							symbolList[j].symbol._y += temp;
					}					
				break;
				case "center":
					if(prop.layout == "horizontal")
					{
						temp = (prop.width - tW)/2;
						for(var j:Number = 0; j < len; j++)
							symbolList[j].symbol._x += temp;
					}
					else
					{
						temp = (prop.height - tW)/2;
						for(var j:Number = 0; j < len; j++)
							symbolList[j].symbol._y += temp;
					}
				break;
				case "justify":
					for(var i:Number = 0; i < len; i++)
					{
						if(prop.layout == "horizontal")
							w = symbolList[i].symbol._width;
						else if(prop.layout == "vertical")
							w = symbolList[i].symbol._height;
						else
							return;
						tW += w;
					}
					if(tW > prop.width)
						return;

					if(prop.layout == "horizontal")
					{
						symbolList[0].symbol._x = prop.x;
						temp = prop.width - tW;
					}
					else
					{
						symbolList[0].symbol._y = prop.y;
						temp = prop.height - tW;
					}
					gap = temp/(len - 1);
					for(var j:Number = 1; j < len; j++)
					{
						if(prop.layout == "horizontal")
						{
							w = symbolList[j-1].symbol._width;
							symbolList[j].symbol._x = symbolList[j - 1].symbol._x + w + gap;
						}
						else
						{
							w = symbolList[j-1].symbol._height;
							symbolList[j].symbol._y = symbolList[j - 1].symbol._y + w + gap;
						}
					}
				break;
			}
		}

		if(prop.valign !== null || prop.valign !== "null" || prop.valign !== undefined || prop.valign !== "undefined" || prop.valign !== "")
		{
			switch(prop.valign.toLowerCase())
			{
				case "top":
					for (var i:Number = 0; i < len; i++)
					{
						if(prop.layout == "horizontal")
							symbolList[i].symbol._y = prop.y;
						else if(prop.layout == "vertical")
							symbolList[i].symbol._x = prop.x;
						else
							return;
					}
				break;
				case "middle":
					if(prop.layout == "horizontal")
						temp = prop.height/2;
					else if(prop.layout == "vertical")
						temp = prop.width/2;
					else
						return;
					for (var i:Number = 0; i < len; i++)
					{
						if(prop.layout == "horizontal")
						{
							w = symbolList[i].symbol._height;
							symbolList[i].symbol._y = prop.y + (temp - (w/2))
						}
						else if(prop.layout == "vertical")
						{
							w = symbolList[i].symbol._width;
							symbolList[i].symbol._x = prop.x + (temp - (w/2))
						}
					}
				break;
				case "bottom":
					for (var i:Number = 0; i < len; i++)
					{
						if(prop.layout == "horizontal")
						{
							w = symbolList[i].symbol._height;
							symbolList[i].symbol._y = (prop.y + prop.height) - w;
						}
						else if(prop.layout == "vertical")
						{
							w = symbolList[i].symbol._width;
							symbolList[i].symbol._x = (prop.x + prop.width) - w;
						}
						else
							return;
					}
				break;
			}
		}
	}

	public static function attachMovieClip(prop:Object):Array
	{
		if(prop == undefined || prop == null)
			return null;
		if(prop.parentMC == undefined || prop.parentMC == null)
			return null;
		var mcArray:Array = new Array();
		var mc:MovieClip = null;

		if(prop.mcName == undefined || prop.mcName == null)
			prop.mcName = null;
		if(prop.mcPrefix == undefined || prop.mcPrefix == null)
			prop.mcPrefix = "item";
		var x:Number = prop.x;
		if (isNaN (new Number (x)) == true)
		{
			prop.x = 0;
			x = 0;
		}
		var y:Number = prop.y;
		if (isNaN (new Number (y)) == true)
			y = 0;
		if (isNaN (new Number (prop.rSize)) == true)
			prop.rSize = 1;
		if (isNaN (new Number (prop.cSize)) == true)
			prop.cSize = 1;
		if (isNaN (new Number (prop.hgap)) == true)
			prop.hgap = 0;
		if (isNaN (new Number (prop.vgap)) == true)
			prop.vgap = 0;

		for (var i:Number=0; i<prop.rSize; i++)
		{
			mcArray.push(new Array());
			for (var j:Number=0; j<prop.cSize; j++)
			{
				if (prop.mcName != null)
				{
					mc = prop.parentMC.attachMovie(prop.mcName, prop.mcPrefix + "_" + i + "_" + j,
						prop.parentMC.getNextHighestDepth(), {_x:x, _y:y});
					x = x + mc._width + prop.hgap;
				}
				else
					mc = prop.parentMC[prop.mcPrefix + "_" + i + "_" + j];
				mcArray[i].push(mc);
			}
			x = prop.x;
			y = y + mc._height + prop.vgap;
		}

		return mcArray;
	}
}