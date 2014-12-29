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
* Class Description: Setting
*
***************************************************/

import com.syabas.as2.plex.model.ModelBase;


class com.syabas.as2.plex.model.SettingModel extends ModelBase
{
	public static var SETTING_TYPE_ENUM:String = "enum";
	public static var SETTING_TYPE_BOOLEAN:String = "bool";
	public static var SETTING_TYPE_TEXT:String = "text";
	public static var SETTING_TYPE_BUTTON:String = "button";
	
	public static var SETTING_OPTION_HIDDEN:String = "hidden";
	
	public var secure:Boolean = false;
	public var values:Array = null;
	public var value:String = null;
	public var type:String = null;
	public var defaultValue:String = null;
	public var option:String = null;
	public var label:String = null;
	
	public function fromObject(dataObj:Object):Void
	{
		super.fromObject(dataObj);
		
		readSettingAttributes(dataObj);
	}
	
	public function fromXML(dataObj:XMLNode):Void
	{
		super.fromXML(dataObj);
		readSettingAttributes(dataObj.attributes);
	}
	
	private function readSettingAttributes(attributes:Object):Void
	{
		if (attributes.secure != null && attributes.secure != undefined)
		{
			secure = (attributes.secure == "true");
		}
		
		if (attributes.values != null && attributes.values != undefined)
		{
			values = attributes.values.split("|");
		}
		
		if (attributes.type != null && attributes.type != undefined)
		{
			type = attributes.type.toString();
		}
		
		if (attributes["default"] != null && attributes["default"] != undefined)
		{
			defaultValue = attributes["default"].toString();
		}
		
		if (attributes.value != null && attributes.value != undefined)
		{
			value = attributes.value.toString();
		}
		
		if (attributes.option != null && attributes.option != undefined)
		{
			option = attributes.option.toString();
		}
		
		if (attributes.label != null && attributes.label != undefined)
		{
			label = attributes.label.toString();
		}
	}
}