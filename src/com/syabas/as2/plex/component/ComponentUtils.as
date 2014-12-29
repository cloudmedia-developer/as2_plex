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
* Class Description: Ultilities for components
*
***************************************************/
class com.syabas.as2.plex.component.ComponentUtils
{
	/***********************************************************************************************************************************
	 * Function : Draw a rectangle
	 * >@mc 			: Base movie clip to draw the rectangle
	 * >@rectObject		: Object contains the information to draw the rectangel
	 * 		1. 	>x:Number			- specifies the x value for the starting point of the rectangle (top-left point)
	 * 		2. 	>y:Number			- specifies the y value for the starting point of the rectangle (top-left point)
	 * 		3.	>width:Number		- specifies the width of the rectangle
	 * 		4.	>height:Number		- specifies the height of the rectangle
	 * 		5.	roundness:Number	- specifies the roundness of the bending point [default : 0]	
	 * @lineObject		: Object contains the line properties
	 * 		1.  thickness:Number		- the thickness of the line
	 * 		2.  color:Number			- the color code of the line
	 * 		3.	alpha:Number			- the alpha for the line (0 - 100)
	 * 		4.	pixelHinting:Boolean	- specifies whether to hint strokes to full pixels
	 * 		5.	noScale:String			- specifies how to scale a stroke ("normal" [default], "none", "vertical", "horizontal")
	 * 		6.	capsStyle:String		- specifies the type of caps at the end of lines ("none", "round" [default], "squate")
	 * 		7.	jointStyle:String		- specifies the type of joint appearance used at angles ("miter", "round" [default], "bevel")
	 * 		8.	miterLimit:Number		- indicates the limit at which a miter is cut off (1 - 255) (Applies to "miter" jointStyle)
	 * @fillObject		: Object contains the fill properties
	 * 		1.	color:Number[Array]				- specifies the color of the fill (treat as array of colors for gradient fill)
	 * 		2.	alpha:Number[Array]				- specifies the alpha of the fill (treat as array of alphas for gradient fill)
	 * 		3.	**fillType:String				- specifies the type of gradient fill ("linear", "radial")
	 * 		4.	**ratios:Array					- specifies the ratio point where each color will be rendered at 100%
	 * 		5.	**matrix:Object					- specifies a transformation
	 * 		6.	**spreadMethod:String			- controls the mode of the gradient fill ("pad" [default], "repeat", "reflect")
	 * 		7.	**interpolationMethod:String	- ("RGB" [default], "linearRGB")
	 * 		8.	**focalPointRatio:String		- control the focus point for radial gradient (-1 - 1)
	 * @isGradient		: Tell whether the rectangle is filled with gradient color (default : false)
	 * 
	 * NOTE:	** 	specifies parameters only for gradient fill
	 * 			> 	specifies mandatory parameters (required field)
	 * 			
	 * References :
	 * 1. line style : http://docs.brajeshwar.com/as2/MovieClip.html#lineStyle()
	 * 2. gradient fill : http://docs.brajeshwar.com/as2/MovieClip.html#beginGradientFill()
	 **********************************************************************************************************************************/
	public static function drawRect(mc:MovieClip, rectObject:Object, lineObject:Object, fillObject:Object, isGradient:Boolean):Void
	{
		if (lineObject != null && lineObject != undefined)
			mc.lineStyle(lineObject.thickness, lineObject.color, lineObject.alpha, lineObject.pixelHinting, lineObject.noScale, lineObject.capsStyle, lineObject.jointStyle, lineObject.miterLimit);
		
		if (fillObject != null && fillObject != undefined)
		{
			if (isGradient == true)
			{
				mc.beginGradientFill(fillObject.fillType, fillObject.color, fillObject.alpha, fillObject.ratios, fillObject.matrix, fillObject.spreadMethod, fillObject.interpolationMethod)
			}
			else
			{
				mc.beginFill(fillObject.color, fillObject.alpha);
			}
		}
		
		var roundness:Number = rectObject.roundness;
		var x:Number = rectObject.x;
		var y:Number = rectObject.y;
		var width:Number = rectObject.width;
		var height:Number = rectObject.height;
		
		if (roundness < 0 || roundness == null || roundness == undefined || roundness > width || roundness > height)
			roundness = 0;
		if (roundness == 0)
		{
			mc.moveTo(x, y);
			mc.lineTo(x + width, y);
			mc.lineTo(x + width, y + height);
			mc.lineTo(x, y + height);
			mc.lineTo(x, y);
		}
		else
		{
			mc.moveTo(x + roundness, y);
			mc.lineTo(x + width - roundness, y);
			mc.curveTo(x + width, y, x + width, y + roundness);
			mc.lineTo(x + width, y + height - roundness);
			mc.curveTo(x + width, y + height, x + width - roundness, y + height);
			mc.lineTo(x + roundness, y + height);
			mc.curveTo(x, y + height, x - 0.0, y + height - roundness);
			mc.lineTo(x - 0.0, y + roundness);
			mc.curveTo(x, y, x + roundness, y); 
		}
		
		mc.endFill();
		
		//cleanup
		roundness = null;
		x = null;
		y = null;
		width = null;
		height = null;
	}
	
	
	/***********************************************************************************************************************************
	 * Function : Draw a circle
	 * >@mc 			: Base movie clip to draw the rectangle
	 * >@circleObject	: Object contains the information to draw the rectangel
	 * 		1. 	>x:Number			- specifies the x value for the center point of the circle 
	 * 		2. 	>y:Number			- specifies the y value for the center point of the circle 
	 * 		3.	>r:Number			- radius of the circle	
	 * @lineObject		: Object contains the line properties
	 * 		1.  thickness:Number		- the thickness of the line
	 * 		2.  color:Number			- the color code of the line
	 * 		3.	alpha:Number			- the alpha for the line (0 - 100)
	 * 		4.	pixelHinting:Boolean	- specifies whether to hint strokes to full pixels
	 * 		5.	noScale:String			- specifies how to scale a stroke ("normal" [default], "none", "vertical", "horizontal")
	 * 		6.	capsStyle:String		- specifies the type of caps at the end of lines ("none", "round" [default], "squate")
	 * 		7.	jointStyle:String		- specifies the type of joint appearance used at angles ("miter", "round" [default], "bevel")
	 * 		8.	miterLimit:Number		- indicates the limit at which a miter is cut off (1 - 255) (Applies to "miter" jointStyle)
	 * @fillObject		: Object contains the fill properties
	 * 		1.	color:Number[Array]				- specifies the color of the fill (treat as array of colors for gradient fill)
	 * 		2.	alpha:Number[Array]				- specifies the alpha of the fill (treat as array of alphas for gradient fill)
	 * 		3.	**fillType:String				- specifies the type of gradient fill ("linear", "radial")
	 * 		4.	**ratios:Array					- specifies the ratio point where each color will be rendered at 100%
	 * 		5.	**matrix:Object					- specifies a transformation
	 * 		6.	**spreadMethod:String			- controls the mode of the gradient fill ("pad" [default], "repeat", "reflect")
	 * 		7.	**interpolationMethod:String	- ("RGB" [default], "linearRGB")
	 * 		8.	**focalPointRatio:String		- control the focus point for radial gradient (-1 - 1)
	 * @isGradient		: Tell whether the rectangle is filled with gradient color
	 * 
	 * NOTE:	** 	specifies parameters only for gradient fill
	 * 			> 	specifies mandatory parameters (required field)
	 * 			
	 * References :
	 * 1. line style : http://docs.brajeshwar.com/as2/MovieClip.html#lineStyle()
	 * 2. gradient fill : http://docs.brajeshwar.com/as2/MovieClip.html#beginGradientFill()
	 **********************************************************************************************************************************/
	public static function drawCircle(mc:MovieClip, circleObject:Object, lineObject:Object, fillObject:Object, isGradient:Boolean):Void 
	{
		if (lineObject != null && lineObject != undefined)
			mc.lineStyle(lineObject.thickness, lineObject.color, lineObject.alpha, lineObject.pixelHinting, lineObject.noScale, lineObject.capsStyle, lineObject.jointStyle, lineObject.miterLimit);
		
		if (fillObject != null && fillObject != undefined)
		{
			if (isGradient)
			{
				mc.beginGradientFill(fillObject.fillType, fillObject.color, fillObject.alpha, fillObject.ratios, fillObject.matrix, fillObject.spreadMethod, fillObject.interpolationMethod)
			}
			else
			{
				mc.beginFill(fillObject.color, fillObject.alpha);
			}
		}
		
		var r:Number = circleObject.r;
		var x:Number = circleObject.x;
		var y:Number = circleObject.y;
		
		mc.moveTo(x + r, y);
		mc.curveTo(r + x, Math.tan(Math.PI / 8) * r + y, Math.sin(Math.PI / 4) * r + x, Math.sin(Math.PI / 4) * r + y);
		mc.curveTo(Math.tan(Math.PI / 8) * r + x, r + y, x, r + y);
		mc.curveTo(-Math.tan(Math.PI / 8) * r + x, r + y, -Math.sin(Math.PI / 4) * r + x, Math.sin(Math.PI / 4) * r + y);
		mc.curveTo(-r + x, Math.tan(Math.PI / 8) * r + y, -r + x, y);
		mc.curveTo(-r + x, -Math.tan(Math.PI / 8) * r + y, -Math.sin(Math.PI / 4) * r + x, -Math.sin(Math.PI / 4) * r + y);
		mc.curveTo(-Math.tan(Math.PI / 8) * r + x, -r + y, x, -r + y);
		mc.curveTo(Math.tan(Math.PI / 8) * r + x, -r + y, Math.sin(Math.PI / 4) * r + x, -Math.sin(Math.PI / 4) * r + y);
		mc.curveTo(r + x, -Math.tan(Math.PI / 8) * r + y, r + x, y);
		
		mc.endFill();
		
		//cleanup
		r = null;
		x = null;
		y = null;
	}
	
	/***************************************************************************************************************************
	 * Function : Create a text field
	 * @parentMC 	: the parent movie clip to host the text field
	 * @id			: a unique id for this text field
	 * @depth		: the depth to insert the text field (will insert the text field at current top most position if this parameter is invalid)
	 * @tfObject	: Object contains the text field properties
	 * 		1.	>x:Number			- the x position to put the text field
	 * 		2. 	>y:Number			- the y position to put the text field
	 * 		3.	>width:Number		- the width of the text field
	 * 		4.	>height:Number		- the height of the text field (will define as 1 line space when not specified)
	 * 		5.	size:Number			- the text size
	 * 		6.	color:Number		- specifies the text color
	 * 		7.	align:String		- the horizontal alignment ("left" [default], "center", "right")
	 * 		8.	bold:Boolean		- specifies whether to bold the text
	 * 		9.	italic:Boolean		- specifies whether to italizise the text
	 * 		10.	multiline:Boolean	- specifies whether to allow multiline [default : "false"]
	 * 		11.	wordWrap:Booelan	- specifies whether the text will wrap to new line when reach the end of text field
	 * 		12.	**maxline:Number	- specifies the number of lines to be visible
	 * 		13.	embededFont:Boolean	- specifies whether to use embeded font [default : "false"]
	 * 		14. fontID:String		- likage ID of specific embeded font in FLA library (applies if emberdedFont is "true")
	 * 		15.	bgColor:Number		- specifies the background color for the text field
	 * 		16.	borderColor:Number	- specifies the border color for the text field
	 * 
	 * NOTE:
	 * 			**	This parameter will overwrite the height (parameter 4) specified
	 * 			>	specifies mandatory parameters (required field)
	 **************************************************************************************************************************/
	public static function createTextField(parentMC:MovieClip, id:String, depth:Number, tfObject:Object):TextField
	{
		if (isNaN(depth) || (parentMC.getInstanceAtDepth(depth) != null && parentMC.getInstanceAtDepth(depth) != undefined) ) 
			depth = parentMC.getNextHighestDepth();
		
		if (isNaN(Number(tfObject.width)) )
			tfObject.width = 10;
		if (isNaN(Number(tfObject.height)) )
		{
			tfObject.height = 10;
			if ( isNaN(Number(tfObject.maxline)) )
				tfObject.maxline = 1;
		}
		if (isNaN(Number(tfObject.x)) )
			tfObject.x = 0;
		if (isNaN(Number(tfObject.y)) )
			tfObject.y = 0;
		
		
		
		var tf:TextField = parentMC.createTextField(id, depth, tfObject.x, tfObject.y, tfObject.width, tfObject.height);
		ComponentUtils.setTextFieldProperties(tf, tfObject);

		return tf;
	}
	
	public static function setTextFieldProperties(tf:TextField, tfObject:Object):Void
	{
		tf._x = tfObject.x;
		tf._y = tfObject.y;
		tf._width = tfObject.width;
		tf._height = tfObject.height;
		
		tfObject.embededFont = (tfObject.embededFont == true);
		
		var tformat:TextFormat = tf.getTextFormat();
		
		var isNew:Boolean = tformat.color == null;
		
		if ( !isNaN(Number(tfObject.size)) )
			tformat.size = tfObject.size;
		
		if (tfObject.align != null && tfObject.align != undefined)
			tformat.align = tfObject.align;
		
		if ( !isNaN(Number(tfObject.color)) )
			tformat.color = tfObject.color;
		
		if ( !isNaN(Number(tfObject.bgColor)) )
		{
			tf.background = true;
			tf.backgroundColor = tfObject.bgColor;
		}
		else
		{
			tf.background = false;
		}
		
		if ( !isNaN(Number(tfObject.borderColor)) )
		{
			tf.border = true;
			tf.borderColor = tfObject.borderColor;
		}
		else
		{
			tf.border = false;
		}
		
		tformat.bold = tfObject.bold;
		tformat.italic = tfObject.italic;
		tformat.leading = 0;
		tf.multiline = tfObject.multiline;
		tf.wordWrap = tfObject.wordWrap;
		tf.embededFont = tfObject.embededFont;
		tf.html = true;
		
		if (tfObject.embededFont == true)
			tformat.font = tfObject.fontID;
		
		if (isNew)
			tf.setNewTextFormat(tformat);
		else
			tf.setTextFormat(tformat);
		
		if ( !isNaN(Number(tfObject.maxline)) )
		{
			var oriText:String = tf.htmlText;
			tf.multiline = true;
			tf.text = "a";
			for (var i:Number = 1; i < tfObject.maxline; i ++)
			{
				tf.text += "\na";
			}
			
			tf._height = tf.textHeight + 4;
			tf.text = "";
			
			tf.htmlText = oriText;
			if (tfObject.maxline > 1)
			{
				tf.multiline = true;
				tf.wordWrap = true;
			}
		}
		
		oriText = null;
		tformat = null;
		isNew = null;
	}
	
	/****************************************************************************************************************
	 * Function : Load an image into a movie clip
	 * @mc 				- the movie clip used to load image
	 * @url				- the image url
	 * @onLoadFunction	- the callback function when the image is loaded
	 ***************************************************************************************************************/
	public static function loadImage(mc:MovieClip, url:String, onLoadFunction:Function):Void
	{
		var mcLoader:MovieClipLoader = new MovieClipLoader();
		var listener:Object = new Object();
		
		listener.onLoadInit = onLoadFunction;
		listener.onLoadError = function(targetMC:MovieClip, errorCode:String, httpStatus:Number)
		{
			if (errorCode == "LoadNeverCompleted" && !( httpStatus > 399 && httpStatus < 500) )
			{
				//reload
				_global["setTimeout"](function ()
				{
					ComponentUtils.loadImage(mc, url, onLoadFunction);
				}, 5000);
			}
		}
		
		mcLoader.addListener(listener);
		mcLoader.loadClip(url, mc);
		
		//cleanup
		mcLoader = null;
		listener = null;
	}
	
	/****************************************************************************************************************
	 * Function : Resize an image and keep the aspect ratio
	 * @mc 				- the movie clip to be resized
	 * @maxWidth		- the maximum width allowed
	 * @maxHeight		- the maximum height allowed
	 ***************************************************************************************************************/
	public static function resizeKeepRatio(mc:MovieClip, maxWidth:Number, maxHeight:Number):Void
	{
		if (maxWidth == null || maxWidth == undefined || maxHeight == null || maxHeight == undefined)
			return;
		var maxRatio:Number = maxWidth / maxHeight;
		var ratio:Number = mc._width / mc._height;
		
		var newW:Number = mc._width;
		var newH:Number = mc._height;
		if (mc._width > maxWidth || mc._height > maxHeight)
		{
			if (mc._width == mc._height)
			{
				//square
				newW = Math.min(maxWidth, maxHeight);
				newH = newW;
				
			}
			else if (ratio >= maxRatio)
			{
				newW = maxWidth;
				newH = 1 / ratio * maxWidth;
			}
			else
			{
				newH = maxHeight;
				newW = ratio * maxHeight;
			}
		}
		
		mc._width = newW;
		mc._height = newH;
		
		mc._x += ((maxWidth - newW) / 2);
		mc._y += ((maxHeight - newH) / 2);
		
		maxRatio = null;
		ratio = null;
		newW = null;
		newH = null;
	}
	
	/********************************************************************************************
	 * Function : Align components 
	 * @componentList			- A list of components to be aligned
	 * @alignObj				- Object specifying parameters for aligning
	 * 		1.	vgap:Number				- Vertiacl gap between 2 components (default : 5)
	 * 		2.	hgap:Number				- Horizontal gap between 2 components (default : 5)
	 * 		3.	**itemPerLine:Number	- Number of item per row (column if align vertically), will calculate from width / height limit if do not present
	 * 		4.	startingX:Number		- X position of the starting point (default: 0)
	 * 		5.	startingY:Number		- Y position of the starting point (default: 0)
	 * 		6.	**alignVertical:Boolean	- Flag to tell whether to align those components vertically
	 * 		7.	**widthLimit:Number		- specifies the maximum width allowed for these components
	 * 		8.	**heightLimit:Number	- specifies the maximum height allowed for these components
	 * 		9.	itemWidth:Number		- specifies the width of these components (only specify when these components are of the same size)
	 * 		10.	itemHeight:Number		- specifies the height of these components (only specify when these components are of the same size)
	 * 
	 * Note:
	 * 			** 	Theses parameters can have 3 combination:
	 * 					- itemPerLine presents
	 * 					- heightLimit presents and alignVertical=true, itemPerLine will be calculated automatically
	 * 					- widthLimit presents and alignVertical=false (or do not specify), itemPerLine will be calculated automatically
	 * 				The above scenarios are prioritized from top to bottom, meaning if all 3 parameters are specified, will take the top most scenario.
	 * 				If parameters do not match any of above 3 combinations, alignment will be carried on without CR to 2nd line
	 * 
	 * *******************************************************************************************/
	public static function alignComponents(componentList:Array, alignObj:Object):Void
	{
		var vgap:Number = alignObj.vgap;
		var hgap:Number = alignObj.hgap;
		
		var itemPerLine:Number = Number(alignObj.itemPerLine);
		var widthLimit:Number = Number(alignObj.widthLimit);
		var heightLimit:Number = Number(alignObj.heightLimit);
		var startingX:Number = Number(alignObj.startingX);
		var startingY:Number = Number(alignObj.startingY);
		
		var itemWidth:Number = Number(alignObj.itemWidth); 
		var itemHeight:Number = Number(alignObj.itemHeight);
		
		var totalComponent:Number = componentList.length;
		var alignVertical:Boolean = alignObj.alignVertical;
		var isWidthSpecified:Boolean = true;
		var isHeightSpecified:Boolean = true;
		
		if ( isNaN(itemWidth) )
		{
			itemWidth = componentList[0]._width;
			isWidthSpecified = false;
		}
		
		if ( isNaN(itemHeight) )
		{
			itemHeight = componentList[0]._height;
			isHeightSpecified = false;
		}
		
		if (isNaN(vgap))
		{
			vgap = 5;
		}
		
		if (isNaN(hgap))
		{
			hgap = 5;
		}
		
		if (isNaN(startingX))
		{
			startingX = 0;
		}
		
		if (isNaN(startingY))
		{
			startingY = 0;
		}
		
		if (isNaN(itemPerLine))
		{
			if (alignVertical == true && !isNaN(heightLimit)) 
				itemPerLine = Math.floor(1 + ( (heightLimit - itemHeight) / (itemHeight + vgap) ) );
			else if (!isNaN(widthLimit) && alignVertical != true) 
				itemPerLine = Math.floor(1 + ( (widthLimit - itemWidth) / (itemWidth + hgap) ) );
			else
				itemPerLine = -1;
		}
		
		var tempX:Number = startingX;
		var tempY:Number = startingY;
		for (var i:Number = 0; i < totalComponent; i ++)
		{
			if (componentList[i].skip == true)
			{
				continue;
			}
			
			componentList[i]._x = tempX;
			componentList[i]._y = tempY;
			
			if (!isHeightSpecified)
			{
				itemHeight = componentList[i]._height;
			}
			
			if (!isWidthSpecified)
			{
				itemWidth = componentList[i]._width;
			}
			
			if (alignVertical == true)
				tempY += (itemHeight + vgap);
			else
				tempX += (itemWidth + hgap);
			
			if (itemPerLine == -1)
				continue;
			if (i % itemPerLine == itemPerLine - 1)
			{
				if (alignVertical == true)
				{
					tempY = startingY;
					tempX += (itemWidth + hgap);
				}
				else
				{
					tempX = startingX;
					tempY += (itemHeight + vgap);
				}
			}
		}
		
		//cleanup
		tempX = null;
		tempY = null;
		startingX = null;
		startingY = null;
		itemWidth = null;
		itemHeight = null;
		hgap = null;
		vgap = null;
		widthLimit = null;
		heightLimit = null;
		itemPerLine = null;
		totalComponent = null;
		alignVertical = null;
		isWidthSpecified = null;
		isHeightSpecified = null;
	}
	
	public static function fitTextInTextField(tf:TextField, text:String, isHTML:Boolean)
	{
		tf.multiline = false;
		tf.wordWrap = false;
		
		if (isHTML == true)
		{
			tf.htmlText = text;
		}
		else
		{
			tf.text = text;
		}
		
		tf._width = tf.textWidth + 4;
	}
}