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
* Class Description: Main Class for the App
*
***************************************************/

import com.syabas.as2.plex.api.GetLanguage;
import com.syabas.as2.plex.api.GetMacAddress;
import com.syabas.as2.plex.api.GetFirmwareVersion;
import com.syabas.as2.plex.manager.BrowseManager;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Util;
import com.syabas.as2.common.UI;
import com.syabas.as2.common.JSONUtil;

import mx.utils.Delegate;

class com.syabas.as2.plex.PlexMain
{
	private static var rootMC:MovieClip = null;				// The stage movie clip
	private static var lib:MovieClip = null;				// The library.swf
	private var browseManager:BrowseManager = null;
	
	/****************************************************
	 * Function : Entry Point
	 ***************************************************/
	public static function main(_rootMC:MovieClip):Void
	{
		rootMC = _rootMC;
		
		Share.init();
		Share.APP_LOCATION_URL = _rootMC._url;
		
		SharedObject.addListener("plexCore", SOHandler);
		SharedObject.getLocal("plexCore");
	}
	
	/*********************************************************
	 * Function: SharedObject callback handler
	 *********************************************************/
	private static function SOHandler(so:SharedObject):Void
	{
		Share.appSO = so;
		
		//do any shared object value getting procress
		if (so.data.gateway != null && so.data.gateway != undefined)
		{
			Share.systemGateway = so.data.gateway;
		}
		
		if (so.data.token != null && so.data.token != undefined)
		{
			Share.MY_PLEX_TOKEN = so.data.token;
		}
		
		if (so.data.useNativePlayer != null && so.data.useNativePlayer != undefined)
		{
			Share.useNativePlayer = so.data.useNativePlayer;
		}
		
		if (so.data.hideBG != null && so.data.hideBG != undefined)
		{
			Share.hideBG = so.data.hideBG;
		}
		
		if (so.data.movieDisplayType != null && so.data.movieDisplayType != undefined)
		{
			Share.movieDisplayType = so.data.movieDisplayType;
		}
		
		if (so.data.tvShowDisplayType != null && so.data.tvShowDisplayType != undefined)
		{
			Share.tvShowDisplayType = so.data.tvShowDisplayType;
		}
		
		if (so.data.useSMB != null && so.data.useSMB != undefined)
		{
			Share.useSMB = so.data.useSMB;
		}
		
		//start the app
		var main:PlexMain = new PlexMain();
	}
	
	
	private function PlexMain()
	{
		if (Share.MY_PLEX_TOKEN != null)
		{
			// check the token for validity
			Share.api.checkLoginStatus(Share.MY_PLEX_TOKEN, Delegate.create(this, this.checkLoginStatusLoaded));
		}
		
		// Get the mac address for my plex account linking process
		var getMacAddress:GetMacAddress = new GetMacAddress();
		getMacAddress.getXML(Delegate.create(this, this.macAddressLoaded));
		
		var getFirmwareVersion:GetFirmwareVersion = new GetFirmwareVersion();
		getFirmwareVersion.getXML(Delegate.create(this, this.firmwareVersionLoaded));
		
		var getLanguage:GetLanguage = new GetLanguage();
		getLanguage.getXML(Delegate.create(this, this.languageLoaded));
		
		// read the plugin filter list
		Util.loadURL("data/plugin_checklist.json", Delegate.create(this, this.pluginFilterListLoaded), { } );
	}
	
	private function checkLoginStatusLoaded(success:Boolean, httpStatus:Number, data:ContainerModel, userparams:Object):Void
	{
		if (!success)
		{
			if (httpStatus > 399)
			{
				// not valid token anymore
				Share.MY_PLEX_TOKEN = null;
				Share.saveSharedObject();
			}
		}
	}
	
	private function macAddressLoaded(success:Boolean, macAddress:String):Void
	{
		if (success)
		{
			macAddress = Util.replaceAll(macAddress, ":", "_");
			Share.CLIENT_IDENTIFIER = macAddress;
		}
	}
	
	private function firmwareVersionLoaded(success:Boolean, fwVersion:String):Void
	{
		if (success)
		{
			var boardType:String = fwVersion.substr(fwVersion.indexOf("POP-"), 7);
			var fwDateString:String = fwVersion.split("-")[2];
			var boardTypeNum:Number = new Number(fwVersion.split("-")[5]);
			
			Share.FIRMWARE_DATE = parseInt(fwDateString);
			Share.BOARD_TYPE = boardType;
			
			if (boardType == "POP-408")
			{
				Share.CLIENT_DEVICE = "PCH-C200";
			}
			else if (boardType == "POP-411")
			{
				Share.CLIENT_DEVICE = "PCH-A200";
			}
			else if (boardType == "POP-412")
			{
				Share.CLIENT_DEVICE = "Popbox";
			}
			else if (boardType == "POP-415")
			{
				Share.CLIENT_DEVICE = "Asiabox";
			}
			else if (boardType == "POP-417")
			{
				Share.CLIENT_DEVICE = "Asiabox2";
			}
			else if (boardType == "POP-418")
			{
				Share.CLIENT_DEVICE = "Popbox V8";
			}
			else if (boardType == "POP-420")
			{
				Share.CLIENT_DEVICE = "PCH-C300";
			}
			else if (boardType == "POP-421")
			{
				Share.CLIENT_DEVICE = "PCH-A300";
			}
			else if (boardType == "POP-422")
			{
				Share.CLIENT_DEVICE = "PCH-A400";
			}
			else
			{
				Share.CLIENT_DEVICE = "PCH Device";
			}
		}
		
		Share.initCapability();
		Util.loadURL("data/playback_capability.json", Delegate.create(this, this.playbackCapabilityLoaded), { } );
		
		if (boardTypeNum >= 888)
		{
			// cavian, close up SMB and Native player
			Share.useNativePlayer = false;
			Share.useSMB = false;
			
			Share.saveSharedObject();
		}
	}
	
	private function languageLoaded(success:Boolean, language:String):Void
	{
		var langFile:String = "lang/" + language + ".txt";
		Share.loadLanguageFile(langFile);
		
		// load the library.swf
		var _lib:MovieClip = rootMC.createEmptyMovieClip("mc_lib", rootMC.getNextHighestDepth());
		
		var loader:MovieClipLoader = new MovieClipLoader();
		var listener:Object = new Object();
		listener.onLoadInit = Delegate.create(this, onLibraryLoaded);
		
		loader.addListener(listener);
		loader.loadClip("library.swf", _lib);
		
		lib = _lib;
	}
	
	private function pluginFilterListLoaded(success:Boolean, data:String, o:Object):Void
	{
		if (success)
		{
			Share.PLUGIN_FILTER_LIST = JSONUtil.parseJSON(data).filter;
		}
	}
	
	private function playbackCapabilityLoaded(success:Boolean, data:String, o:Object):Void
	{
		if (success)
		{
			var obj:Object = JSONUtil.parseJSON(data);
			var playbackConfigArr:Array = obj[Share.BOARD_TYPE];
			var playbackConfig:Object = null;
			
			if (playbackConfigArr == null || playbackConfigArr == undefined)
			{
				playbackConfigArr = obj["default"];
			}
			
			var len:Number = playbackConfigArr.length;
			var selectedDate:Number = 0;
			var tempDate:Number = null;
			var date:String = null;
			for (var i:Number = 0; i < len; i ++)
			{
				date = playbackConfigArr[i].date;
				tempDate = parseInt(date);
				if (date == "default")
				{
					Share.PLAYBACK_CONFIG = playbackConfigArr[i];
				}
				else if (tempDate < Share.FIRMWARE_DATE)
				{
					if (tempDate > selectedDate)
					{
						selectedDate = tempDate;
						
						playbackConfig = playbackConfigArr[i];
					}
				}
			}
			
			if (playbackConfig != null && playbackConfig != undefined)
			{
				Share.PLAYBACK_CONFIG = playbackConfig;
			}
		}
	}
	
	private function onLibraryLoaded():Void
	{
		// Init the browsing manager
		this.browseManager = new BrowseManager(lib);
	}
}