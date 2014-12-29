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
* Class Description: Popup for plugin / channel setting
*
***************************************************/
import com.syabas.as2.plex.component.Popup;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.SettingModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.GridLite;

import mx.utils.Delegate;

class com.syabas.as2.plex.component.SettingPopup extends Popup
{
	private var buttonGrid:GridLite = null;							// The grid for button navigation
	private var multiValueGrid:GridLite = null;						// The grid for multi value navigation
	private var container:ContainerModel = null;					// The container of setting options
	
	public function destroy():Void
	{
		this.buttonGrid.destroy();
		delete this.buttonGrid;
		this.buttonGrid = null;
		
		this.multiValueGrid.destroy();
		delete this.multiValueGrid;
		this.multiValueGrid = null;
		
		delete this.container;
		
		super.destroy();
	}
	
	public function SettingPopup(mc:MovieClip)
	{
		super(mc);
		this.config = Share.APP_SETTING.settingConfig;
	}
	
	/*
	 * Overwrite super class
	 */
	public function createPopup(container:ContainerModel):Void
	{
		this.container = container;
		this.createMC();
		this.createGrid();
		this.createButtonGrid();
		
		this.grid.data = container.items;
		this.grid.createUI();
		this.grid.highlight();
	}
	
	private function createMC():Void
	{
		this.popupMC.removeMovieClip();
		this.popupMC = this.parentMC.attachMovie("settingPopupMC", "mc_settingPopup", this.parentMC.getNextHighestDepth());
	}
	
	/*
	 * Overwrite super class
	 */
	private function hlCB(o:Object):Void
	{
		var setting:SettingModel = o.data;
		
		if (setting.type == SettingModel.SETTING_TYPE_ENUM)
		{
			// create the multivalue grid
			this.createMultiValueGrid(o.mc.mc_multiValue);
			this.multiValueGrid.createUI();
			this.multiValueGrid.highlight();
		}
		else if (setting.type == SettingModel.SETTING_TYPE_TEXT)
		{
			o.mc.mc_input.gotoAndStop("hl");
		}
		else if (setting.type == SettingModel.SETTING_TYPE_BOOLEAN)
		{
			var boolValue:Boolean = (setting.value.toLowerCase() == "true");
			o.mc.mc_checkBox.gotoAndStop((boolValue ? "hlSelected" : "hl"));
		}
	}
	
	private function hlStopCB(o:Object):Void
	{
		
	}
	
	/*
	 * Overwrite super class
	 */
	private function unhlCB(o:Object):Void
	{
		this.marquee.stop();
		var setting:SettingModel = o.data;
		
		if (setting.type == SettingModel.SETTING_TYPE_ENUM)
		{
			// destroy the multi value grid
			this.multiValueGrid.unhighlight();
			this.multiValueGrid.destroy();
			delete this.multiValueGrid;
			this.multiValueGrid = null;
		}
		else if (setting.type == SettingModel.SETTING_TYPE_TEXT)
		{
			o.mc.mc_input.gotoAndStop("unhl");
		}
		else if (setting.type == SettingModel.SETTING_TYPE_BOOLEAN)
		{
			var boolValue:Boolean = (setting.value.toLowerCase() == "true");
			o.mc.mc_checkBox.gotoAndStop((boolValue ? "unhlSelected" : "unhl"));
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function clearCB(o:Object):Void
	{
		o.mc._visible = false;
	}
	
	/*
	 * Overwrite super class
	 */
	private function updateCB(o:Object):Void
	{
		o.mc._visible = true;
		var setting:SettingModel = o.data;
		o.mc.txt_title.htmlText = Share.returnStringForDisplay(setting.label);
		
		if (setting.type == SettingModel.SETTING_TYPE_ENUM)
		{
			o.mc.gotoAndStop("multiValue");
			o.mc.mc_multiValue.txt_title.htmlText = Share.returnStringForDisplay(setting.values[setting.value]);
		}
		else if (setting.type == SettingModel.SETTING_TYPE_TEXT)
		{
			o.mc.gotoAndStop("input");
			var output:String = setting.value;
			if (setting.option == SettingModel.SETTING_OPTION_HIDDEN)
			{
				var len:Number = output.length;
				output = "";
				for (var i:Number = 0; i < len; i ++)
				{
					output += "*";
				}
			}
			
			o.mc.mc_input.txt_title.htmlText = Share.returnStringForDisplay(output);
		}
		else if (setting.type == SettingModel.SETTING_TYPE_BOOLEAN)
		{
			o.mc.gotoAndStop("checkBox");
			var boolValue:Boolean = (setting.value.toLowerCase() == "true");
			o.mc.mc_checkBox.gotoAndStop((boolValue ? "unhlSelected" : "unhl"));
		}
	}
	
	/*
	 * Overwrite super class
	 */
	private function enterCB(o:Object):Void
	{
		var setting:SettingModel = o.data;
		
		if (setting.type == SettingModel.SETTING_TYPE_TEXT)
		{
			// open keyboard
			Share.KEYBOARD.startKeyboard(Delegate.create(this, this.keyboardDone), Delegate.create(this, this.keyboardCancel), setting.label, setting.value, (setting.option == SettingModel.SETTING_OPTION_HIDDEN), false);
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
	}
	
	/*
	 * Overwrite super class
	 */
	private function overBottomCB():Boolean
	{
		this.buttonGrid.highlight();
		return false;
	}
	
	
	//----------------------------------------- Button Grid ----------------------------------
	private function createButtonGrid():Void
	{
		this.buttonGrid = new GridLite();
		
		var buttonData:Array = new Array();
		buttonData.push( { title:Share.getString("btn_ok") } );
		buttonData.push( { title:Share.getString("btn_cancel") } );
		buttonData.push( { title:Share.getString("btn_default") } );
		
		this.buttonGrid.xMCArray = [[this.popupMC.btn_confirm, this.popupMC.btn_cancel, this.popupMC.btn_default]];
		this.buttonGrid.data = buttonData;
		this.buttonGrid.xWrapLine = false;
		this.buttonGrid.xWrap = false;
		this.buttonGrid.hlCB = Delegate.create(this, this.buttonHLCB);
		this.buttonGrid.unhlCB = Delegate.create(this, this.buttonUnHLCB);
		this.buttonGrid.onItemClearCB = Delegate.create(this, this.buttonClearCB);
		this.buttonGrid.onItemUpdateCB = Delegate.create(this, this.buttonUpdateCB);
		this.buttonGrid.onEnterCB = Delegate.create(this, this.buttonEnterCB);
		this.buttonGrid.onKeyDownCB = Delegate.create(this, this.keyDownCB);
		this.buttonGrid.overTopCB = Delegate.create(this, this.buttonOverTopCB);
		
		this.buttonGrid.createUI();
	}
	
	private function buttonHLCB(o:Object):Void
	{
		o.mc.gotoAndStop("hl");
	}
	
	private function buttonUnHLCB(o:Object):Void
	{
		o.mc.gotoAndStop("unhl");
	}
	
	private function buttonClearCB(o:Object):Void
	{
		o.mc.txt_title.text = "";
	}
	
	private function buttonUpdateCB(o:Object):Void
	{
		o.mc.txt_title.text = o.data.title;
	}
	
	private function buttonEnterCB(o:Object):Void
	{
		if (o.dataIndex == 0)
		{
			// confirm
			this.doneCB(this.container);
		}
		else if (o.dataIndex == 1)
		{
			// cancel
			this.cancelCB();
		}
		else if (o.dataIndex == 2)
		{
			// default
			this.resetDefaultValue();
		}
	}
	
	private function buttonOverTopCB():Boolean
	{
		this.grid.highlight();
		return false;
	}
	
	
	//------------------------------------------ Multi Value Grid ----------------------------------------
	private function createMultiValueGrid(mc:MovieClip):Void
	{
		this.multiValueGrid = new GridLite();
		
		var mvData:Array = new Array();
		mvData.push( { } );
		mvData.push( { } );
		
		this.multiValueGrid.xMCArray = [[mc.mc_previous, mc.mc_next]];
		this.multiValueGrid.data = mvData;
		this.multiValueGrid.xWrapLine = false;
		this.multiValueGrid.xWrap = false;
		this.multiValueGrid.hlCB = Delegate.create(this, this.mvHLCB);
		this.multiValueGrid.unhlCB = Delegate.create(this, this.mcUnHLCB);
		this.multiValueGrid.onItemClearCB = Delegate.create(this, this.mvClearCB);
		this.multiValueGrid.onItemUpdateCB = Delegate.create(this, this.mvUpdateCB);
		this.multiValueGrid.onEnterCB = Delegate.create(this, this.mvEnterCB);
	}
	
	private function mvHLCB(o:Object):Void
	{
		o.mc.gotoAndStop("hl");
	}
	
	private function mcUnHLCB(o:Object):Void
	{
		o.mc.gotoAndStop("unhl");
	}
	
	private function mvClearCB(o:Object):Void
	{
		
	}
	
	private function mvUpdateCB(o:Object):Void
	{
		
	}
	
	private function mvEnterCB(o:Object):Void
	{
		var setting:SettingModel = SettingModel(this.grid.getData());
		var len:Number = setting.values.length;
		var itemNumber:Number = new Number(setting.value);
		if (o.dataIndex == 0)
		{
			// previous -1
			itemNumber --;
			if (itemNumber < 0)
			{
				itemNumber += len;
			}
		}
		else if (o.dataIndex == 1)
		{
			// next +1
			itemNumber = (itemNumber + 1) % len;
		}
		
		setting.value = itemNumber + "";
		
		var mc:MovieClip = this.grid.getMC();
		mc.mc_multiValue.txt_title.htmlText = Share.returnStringForDisplay(setting.values[itemNumber]);
	}
	
	//------------------------------------------- Keyboard ------------------------------------------
	private function keyboardDone(o:Object):Void
	{
		var text:String = o.text;
		var setting:SettingModel = SettingModel(this.grid.getData());
		setting.value = text;
		
		if (setting.option == SettingModel.SETTING_OPTION_HIDDEN)
		{
			// Password type. Show "*"
			text = o.display;
		}
		
		this.grid.getMC().mc_input.txt_title.text = text;
		this.grid.highlight();
	}
	
	private function keyboardCancel():Void
	{
		this.grid.highlight();
	}
	//------------------------------------------------------------------------------------------------
	
	
	private function resetDefaultValue():Void
	{
		var len:Number = this.container.items.length;
		var setting:SettingModel = null;
		for (var i:Number = 0; i < len; i ++)
		{
			setting = this.container.items[i];
			setting.value = setting.defaultValue;
		}
		
		this.grid.clear();
		this.grid.createUI();
		
		this.buttonGrid.unhighlight();
		this.grid.highlight();
	}
}