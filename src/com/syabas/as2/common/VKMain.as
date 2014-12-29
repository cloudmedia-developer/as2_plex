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
* Version 3.3.3
*
* Developer: Syabas Technology Sdn. Bhd.
*
* Class Description:
* This class can be used to ease loading of vk3.swf for text input.
*
***************************************************/

import mx.utils.Delegate;

class com.syabas.as2.common.VKMain
{
	private var vkMC:MovieClip = null;
	private var vkObj:Object = null;
	private var vkListener:Object = null;

	public function VKMain()
	{
		this.vkListener = new Object();
		this.vkListener.onLoadInit = Delegate.create(this, this.vkLoaded);
		this.vkListener.onLoadError = Delegate.create(this, this.vkError);
	}

	/*
	* Destroying the global objects.
	*/
	public function destroy():Void
	{
		this.vkMC.destroy();
		this.vkMC = null;
		this.vkObj = null;
		delete this.vkListener;
		this.vkListener = null;
	}

	/*
	* vk3.swf will be loaded before allowing text input.
	*
	* vkMC: the vk3.swf will be loaded into this movieClip.
	* vkObj: object containing all the configuration properties as below:
	*   1. 	onDoneCB:Function       		- [Required] callback function to be called when OK Function Button is pressed. Default is null.
	*                                 			Arguments: str:String - input value.
	*   2. 	onCancelCB:Function	    		- [Required] callback function to be called when Cancel Function button is pressed. Default is null.
	*                                 			Arguments: str:String - initial value.
	* 	3. 	keyboard_data:Object			- [Required] The data of keysets and language for the keyboard
	* 	4.	parentPath:String				- [Required] The path of the app swf. Usually is _url of the root movie clip
	* 	5.	onSuggUpdateCB:Function			- [Optional] callback function when there is a need to load suggestion list
	* 								  			Arguments: str:String - Current input string
	* 												- function "updateSuggestion" need to be called to update the suggestion list
	* 										   				Arguments: 	suggList:Array			- The suggestion list, an array of strings
	* 										   							referenceWord:String	- The string that is need to be replaced. null to replace the whole input string
	* 	6. 	initValue:String				- [Optional] initial value to be shown on the input field. Default is blank string.
	*	7.	disableSpace:Boolean			- [Optional] Pass "true" to disable space in the input.
	* 	8.	title:String					- [Optional] The title of this input.
	* 	9.	showPassword:Boolean			- [Optional] Pass "true" to indicate the input is for password. Default is false.
	* 	10. defaultPasswordMask:Boolean		- [Optional] Pass "false" to disable password masking when show keyboard. Default is true.
	* 	11.	maxLength:Number				- [Optional] Maximum number of characters allow for the input. Default is 100.
	* 	12.	isNumeric:Boolean				- [Optional] Set to true to use a simplified numeric keyboard. Default is false.
	* 	13. defaultInput:String				- [Optional] Initial input method to use. Possible values : "num_lock" , "abc" [Default], "ABC".
	* 
	* 	14. disablePopupKeyboard:Boolean	- [Optional] Set this flag to "true" to disable the popup style keyboard. Default is false.
	* 	15. inputTF:TextField				- [*Required] The text field for input. Only required if "disablePopupKeyboard" is turned on.
	* 	16. inputCursor:MovieClip			- [*Required] The blinking cursor for input text filed. Only required if "disablePopupKeyboard" is turned on.
	* 
	* 	17. toggleInputCB:Function			- [Optional] The callback to be called when input method is toggled between "num_lock", "abc", and "ABC".
	* 												Arguments: 	inputMethod:String 				- the input method which is currently using.
	* 	18. onTextUpdateCB:Function			- [Optional] The callback to be called when the text on the input text field changes.
	* 												Arguments: 	newText:String 					- The newly updated text.
	* 															newDisplayText:String			- The newly updated text in display. A string of "*" will be returned for password field.
	* 	19. ***onCharInputCB:Function		- [Optional] The callback used to verify whether a character is valid to be input.
	* 												Arguments: 	char:String 						- The character to be input
	* 															ascii:Number						- The ASCII value for the character
	* 												Returns: valid:Boolean		- A flag whether the character is valid. Default is true.
	* 	20. onSuggEnterCB:Function 			- [Optional] The callback to be called when user select a suggestion.
	* 												Arguments:	sugg:String						- The suggestion selected
	* 	21. suggList:Array					- [Optional] The constant suggestion list.
	* 	22.	showCaps:Boolean				- [Optional] Set to true if want to show Capital keypad on show. Default is false.
	* 	23. backgroundAlpha:Number			- [Optional] The alpha value for the black background. Valid value from 0 - 100. Default is 95.
	* 	24.	skipRelayout:Boolean 			- [Optional] Set to false if want to re-render the keyboard cell. Default is true.
	* 
	* 
	* 	NOTE:
	*			[*Required] 		- ONLY Required if "disablePopupKeyboard" flag is turned on.
	* 			*** 				- This callback will only be called if the character is key in by USB keyboard keystroke / Remote Controll 0 - 9 keystroke. Space is not included in this callback.
	*/
	public function startVK(vkMC:MovieClip, vkObj:Object):Void
	{
		this.vkMC = vkMC;
		this.vkObj = this.checkConfigObject(vkObj);
		this.vkMC._lockroot = true;

		var vkPath:String = VKMain.getFullPath(vkObj.parentPath) + "vk3.swf";

		var vkMCLoader:MovieClipLoader = new MovieClipLoader();
		vkMCLoader.addListener(this.vkListener);
		vkMCLoader.loadClip(vkPath, vkMC);
	}

	/*
	* Reconfigure the keyboard and start input again. Note that this function can only be called after "startVK"
	*
	* vkObj:Object - The new Virtual Keyboard Configuration
	*/
	public function restartVK(vkObj:Object):Void
	{
		if (this.vkMC == null)
			return;
			
		this.vkObj = this.checkConfigObject(vkObj);
		this.vkMC.startVK(vkObj);
	}

	/*
	* Get the position of the caret (blinking stick during input)
	*/
	public function getCaretPosition():Number
	{
		return this.vkMC.getCaretPosition();
	}

	/*
	* Update a list of suggestion word to the virtual keyboard
	*
	* suggList:Array - The list of suggestion word. An array of strings.
	*/
	public function updateSuggestion(suggList:Array):Void
	{
		this.vkMC.updateSugguestion(suggList);
	}

	/*
	* Hide and stop keyboard input
	*/
	public function hideVK():Void
	{
		this.vkMC.hideVK();
	}

	/*
	* Show and start keyboard input
	*/
	public function showVK():Void
	{
		this.vkMC.showVK();
	}

	/*
	* Get the text typed by user
	*/
	public function getText():String
	{
		return this.vkMC.getText();
	}
	
	/*
	* Get the text displayed on input text field
	* NOTE : Password input will return a string of "*" using this function
	*/
	public function getDisplayText():String
	{
		return this.vkMC.getDisplayText();
	}

	/*
	* Get the current selected language's index 
	* NOTE : This function only return the index, but not the language object specified in keyboard_data object
	*/
	public function getCurrentLanguageIndex():Number
	{
		return this.vkMC.getCurrentLanguageIndex();
	}

	/*
	 * Move the blinking cursor to left
	 * NOTE : ONLY work if "disablePopupKeyboard" is turned on
	 */
	public function moveCursorLeft():Void
	{
		this.vkMC.moveCursorLeft();
	}

	/*
	 * Move the blinking cursor to right
	 * NOTE : ONLY work if "disablePopupKeyboard" is turned on
	 */
	public function moveCursorRight():Void
	{
		this.vkMC.moveCursorRight();
	}

	/*
	 * Adding text from cursor position
	 * NOTE : Not workable for numeric
	 */
	public function insertText(text:String):Void
	{
		this.vkMC.insertText(text);
	}

	/*
	 * Clear all text in the input text field
	 * NOTE : Not workable for numeric
	 */
	public function clearText():Void
	{
		this.vkMC.clearText();
	}

	/*
	 * Delete a single character before the blinking cursor
	 * NOTE : Not workable for numeric
	 */
	public function deleteText():Void
	{
		this.vkMC.deleteText();
	}

	/*
	 * Toggle the password mask option.
	 * - maskPassword - True to mask password (all text shown in "*"), false to show real text, null to toggle
	 */
	public function togglePasswordMask(maskPassword:Boolean):Void
	{
		this.vkMC.togglePasswordMask(maskPassword);
	}
	
	public function isPasswordMasked():Boolean
	{
		return this.vkMC.isPasswordMasked();
	}

	private function vkError(targetMC:MovieClip, errorCode:String, httpStatus:Number):Void
	{
		trace("targetMC " + targetMC);
		trace("errorCode " + errorCode);
		trace("httpStatus " + httpStatus);
	}

	private function vkLoaded(targetMC:MovieClip):Void
	{
		targetMC.startVK(this.vkObj);
	}

	private static function getFullPath(path:String):String
	{
		var pathLen:Number = path.lastIndexOf("/", path.length) + 1;
		return path.substring(0, pathLen);
	}

	private function checkConfigObject(obj:Object):Object
	{
		if (obj.onSuggEnterCB == null || obj.onSuggEnterCB == undefined)
		{
			obj.onSuggEnterCB = Delegate.create(this, this.defSuggEnterCB);
		}

		return obj;
	}

	private function defSuggEnterCB(sugg:String):Void
	{
		this.clearText();
		this.insertText(sugg);
	}
}