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
* Class Description: The preference setting deck class
*
***************************************************/
import com.syabas.as2.plex.api.API;
import com.syabas.as2.plex.component.DeckBase;
import com.syabas.as2.plex.manager.BrowseManager;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.SettingModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
class com.syabas.as2.plex.component.PreferenceDeck extends DeckBase
{
	private var grid:GridLite = null;
	
	public function destroy():Void
	{
		this.grid.destroy();
		super.destroy();
	}
	
	public function PreferenceDeck(mc:MovieClip)
	{
		super(mc);
		this.createGrid();
		this.grid.createUI();
	}
	
	/*
	 * Overwrite super class
	 */
	public function enable():Void
	{
		this.grid.highlight();
	}
	
	/*
	 * Overwrite super class
	 */
	public function disable():Void
	{
		this.grid.unhighlight();
	}
	
	/*
	 * Overwrite super class
	 */
	public function showDeck():Void
	{
		this.deckMC._visible = true;
	}
	
	/*
	 * Overwrite super class
	 */
	public function hideDeck():Void
	{
		this.deckMC._visible = false;
	}
	
	/*
	 * Overwrite super class
	 */
	public function available():Boolean
	{
		return true;
	}
	
	//------------------------------------------ Grid --------------------------------------------
	private function createGrid():Void
	{
		var boardTypeNumber:Number = new Number(Share.BOARD_TYPE.substring(4));
		
		var xmlStr:String = '<MediaContainer machineIdentifier="">';
		xmlStr += '<Setting key="ip" type="' + SettingModel.SETTING_TYPE_TEXT + '" value="' + Share.stripServerAddress(Share.systemGateway) + '" label="' + Share.getString("preference_label_server_address") + '" />';
		xmlStr += '<Setting key="port" type="' + SettingModel.SETTING_TYPE_TEXT + '" value="' + Share.stripServerPort(Share.systemGateway) + '" label="' + Share.getString("preference_label_server_port") + '" />';
		
		if (boardTypeNumber < 888)
		{
			xmlStr += '<Setting key="useNativePlayer" type="' + SettingModel.SETTING_TYPE_BOOLEAN + '" value="' + Share.useNativePlayer + '" label="' + Share.getString("preference_label_native_player") + '" />';
			xmlStr += '<Setting key="useSMB" type="' + SettingModel.SETTING_TYPE_BOOLEAN + '" value="' + Share.useSMB + '" label="' + Share.getString("preference_label_use_smb") + '" />';
		}
		
		xmlStr += '<Setting key="hideBG" type="' + SettingModel.SETTING_TYPE_BOOLEAN + '" value="' + Share.hideBG + '" label="' + Share.getString("preference_label_disable_bg") + '" />';
		
		if (boardTypeNumber < 888)
		{
			xmlStr += '<Setting key="config" type="' + SettingModel.SETTING_TYPE_BUTTON + '" value="" label="' + Share.getString("preference_label_config") + '" />';
		}
		xmlStr += '</MediaContainer>';
		
		var xml:XML = new XML(xmlStr);
		var container:ContainerModel = new ContainerModel();
		container.fromXML(xml.firstChild);
		
		this.grid = new GridLite();
		this.grid.xMCArray = UI.attachMovieClip( { parentMC:this.deckMC, rSize:6, cSize:1 } );
		this.grid.data = container.items;
		this.grid.xWrapLine = false;
		this.grid.xWrap = false;
		this.grid.hlCB = Delegate.create(this, this.hlCB);
		this.grid.unhlCB = Delegate.create(this, this.unhlCB);
		this.grid.onItemClearCB = Delegate.create(this, this.clearCB);
		this.grid.onItemUpdateCB = Delegate.create(this, this.updateCB);
		this.grid.onEnterCB = Delegate.create(this, this.enterCB);
		this.grid.onKeyDownCB = Delegate.create(this, this.keyDownCB);
		this.grid.overLeftCB = Delegate.create(this, this.overLeftCB);
		
		delete xml.idMap;
		
		xml = null;
		xmlStr = null;
		container = null;
	}
	
	private function clearCB(o:Object):Void
	{
		o.mc._visible = false;
		o.mc.txt_title.text = "";
		o.mc.mc_input.txt_title.text = "";
	}
	
	private function updateCB(o:Object):Void
	{
		o.mc._visible = true;
		var setting:SettingModel = o.data;
		o.mc.txt_title.htmlText = Share.returnStringForDisplay(setting.label);
		
		if (setting.type == SettingModel.SETTING_TYPE_TEXT)
		{
			o.mc.mc_input.txt_title.htmlText = Share.returnStringForDisplay(setting.value);
		}
		else if (setting.type == SettingModel.SETTING_TYPE_BOOLEAN)
		{
			var boolValue:Boolean = (setting.value.toLowerCase() == "true");
			o.mc.mc_checkBox.gotoAndStop((boolValue ? "unhlSelected" : "unhl"));
		}
	}
	
	private function hlCB(o:Object):Void
	{
		var setting:SettingModel = o.data;
		
		if (setting.type == SettingModel.SETTING_TYPE_TEXT)
		{
			o.mc.mc_input.gotoAndStop("hl");
		}
		else if (setting.type == SettingModel.SETTING_TYPE_BOOLEAN)
		{
			var boolValue:Boolean = (setting.value.toLowerCase() == "true");
			o.mc.mc_checkBox.gotoAndStop((boolValue ? "hlSelected" : "hl"));
		}
		else
		{
			o.mc.gotoAndStop("hl");
		}
	}
	
	private function unhlCB(o:Object):Void
	{
		var setting:SettingModel = o.data;
		
		if (setting.type == SettingModel.SETTING_TYPE_TEXT)
		{
			o.mc.mc_input.gotoAndStop("unhl");
		}
		else if (setting.type == SettingModel.SETTING_TYPE_BOOLEAN)
		{
			var boolValue:Boolean = (setting.value.toLowerCase() == "true");
			o.mc.mc_checkBox.gotoAndStop((boolValue ? "unhlSelected" : "unhl"));
		}
		else
		{
			o.mc.gotoAndStop("unhl");
		}
	}
	
	private function enterCB(o:Object):Void
	{
		var setting:SettingModel = o.data;
		
		if (setting.type == SettingModel.SETTING_TYPE_TEXT)
		{
			// open keyboard
			Share.KEYBOARD.startKeyboard(Delegate.create(this, this.textEntered), Delegate.create(this, this.textCanceled), setting.label, setting.value, (setting.option == SettingModel.SETTING_OPTION_HIDDEN), (o.dataIndex == 1));
			this.grid.unhighlight();
		}
		else if (setting.type == SettingModel.SETTING_TYPE_BOOLEAN)
		{
			// toggle status
			var boolValue:Boolean = (setting.value.toLowerCase() == "true");
			boolValue = !boolValue;
			setting.value = boolValue + "";
			o.mc.mc_checkBox.gotoAndStop((boolValue ? "hlSelected" : "hl"));
		}
		else
		{
			this.grid.unhighlight();
			
			var container:ContainerModel = new ContainerModel();
			container.items = new Array();
			
			var chooseConfigFolder:MediaModel = new MediaModel();
			chooseConfigFolder.key = "_chooseConfig";
			chooseConfigFolder.title = Share.getString("choose_config");
			
			var testConfig:MediaModel = new MediaModel();
			testConfig.key = "_testConfig";
			testConfig.title = Share.getString("test_config");
			
			container.items.push(chooseConfigFolder);
			container.items.push(testConfig);
			
			Share.POPUP.showSelectionPopup(container, Delegate.create(this, this.configSelection), Delegate.create(this, this.enable));
		}
	}
	
	private function keyDownCB(o:Object):Void
	{
		var keyCode:Number = o.keyCode;
		
		if (keyCode == null || keyCode == undefined)
		{
			keyCode = Key.getCode();
		}
		
		if (keyCode == Key.BACK)
		{
			// save setting and return to menu
			this.overLeftCB();
			this.grid.unhighlight();
		}
	}
	
	private function overLeftCB():Boolean
	{
		this.saveSetting();
		
		this.hideDeck();
		
		BrowseManager.RELAUNCH();
		return false;
	}
	
	private function appendServerAddress(gateway:String, port:String):String
	{
		if (gateway == null || gateway == undefined || gateway.length == 0)
		{
			return null;
		}
		if (!Util.startsWith(gateway, "http://") && !Util.startsWith(gateway, "https://"))
		{
			gateway = "http://" + gateway;
		}
		
		if (!Util.isBlank(port))
		{
			gateway += ":" + port;
		}
		
		if (!Util.endsWith(gateway, "/"))
		{
			gateway += "/";
		}
		
		return gateway;
	}
	
	private function saveSetting():Void
	{
		var newGateway:String = this.appendServerAddress(this.grid.getData(0).value, this.grid.getData(1).value);
		if (!Util.isBlank(newGateway))
		{
			Share.systemGateway = newGateway;
		}
		
		var dataLen:Number = this.grid.data.length;
		var data:SettingModel = null;
		for (var i:Number = 2; i < dataLen; i ++)
		{
			data = this.grid.data[i];
			switch (data.key)
			{
				case "useNativePlayer":
					Share.useNativePlayer = (data.value.toLowerCase() == "true");
					break;
				case "hideBG":
					Share.hideBG = (data.value.toLowerCase() == "true");
					break;
				case "useSMB":
					Share.useSMB = (data.value.toLowerCase() == "true");
					break;
			}
		}
		
		Share.saveSharedObject();
	}
	
	private function textEntered(o:Object):Void
	{
		var text:String = o.text;
		var mc:MovieClip = this.grid.getMC();
		this.grid.getData().value =  text;
		mc.mc_input.txt_title.htmlText = text;
		
		this.grid.highlight();
	}
	
	private function textCanceled():Void
	{
		this.grid.highlight();
	}
	
	private function configSelection(data:MediaModel):Void
	{
		if (data.key == "_chooseConfig")
		{
			Share.CONFIG_LOADER.showConfigBrowser(Delegate.create(this, this.enable));
		}
		else if (data.key == "_testConfig")
		{
			Share.CONFIG_LOADER.testCurrentConfig(Delegate.create(this, this.enable));
		}
		else
		{
			this.enable();
		}
	}
}