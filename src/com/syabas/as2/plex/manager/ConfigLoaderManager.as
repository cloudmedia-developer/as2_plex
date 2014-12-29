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
* Class Description: Class managing loading and testing config.xml
***************************************************/
import com.syabas.as2.common.Util;

import com.syabas.as2.plex.Share;
import com.syabas.as2.plex.api.ListNetworkContent;
import com.syabas.as2.plex.api.ListNetworkResource;
import com.syabas.as2.plex.api.FileOperation;
import com.syabas.as2.plex.component.ComponentUtils;
import com.syabas.as2.plex.manager.PlaybackManager;

import syabasAS2.pch.component.minibrowser.Minibrowser;

import mx.utils.Delegate;

class com.syabas.as2.plex.manager.ConfigLoaderManager
{
	private var testingBaseMC:MovieClip = null;
	private var currentMC:MovieClip = null;
	private var cb:Function = null;
	
	private var testPaths:Array = null;
	private var testResults:Array = null;
	private var klObject:Object = null;
	
	private var miniBrowser:Minibrowser = null;
	
	public function ConfigLoaderManager(mc:MovieClip)
	{
		this.testingBaseMC = mc;
	}
	
	public function showConfigBrowser(cb:Function):Void
	{
		if (cb != null)
		{
			this.cb = cb;
		}
		// show mini file browser to browse the config.xml
		
		this.clear();
		this.currentMC = this.testingBaseMC.createEmptyMovieClip("mc_miniBrowserBase", this.testingBaseMC.getNextHighestDepth());
		this.currentMC.attachMovie("loadingMC", "mc_loading", this.currentMC.getNextHighestDepth(), { _x:640, _y:360 } );
		
		var browserMC:MovieClip = this.currentMC.createEmptyMovieClip("mc_miniBrowser", this.currentMC.getNextHighestDepth());
		
		this.miniBrowser = new Minibrowser();
		
		this.miniBrowser.addEventListener(this.miniBrowser.EVENT_INIT , this, "miniBrowserInit");
		this.miniBrowser.addEventListener(this.miniBrowser.EVENT_CANCEL	, this, "miniBrowserCancel");
		this.miniBrowser.addEventListener(this.miniBrowser.EVENT_DONE , this, "miniBrowserDone");
		
		this.miniBrowser.load("components/miniBrowser/main.swf", browserMC, true, true, "browse");
	}
	
	private function miniBrowserInit():Void
	{
		this.currentMC.mc_loading.removeMovieClip();
	}
	
	private function miniBrowserCancel():Void
	{
		this.closeAll();
	}
	
	private function miniBrowserDone(o:Object):Void
	{
		var path:String = null;
		if (o.path.__proto__ == Array.prototype)
		{
			path = o.path[0];
		}
		else
		{
			path = o.path;
		}
		
		if (!Util.endsWith(path, "/"))
		{
			path += "/";
		}
		path += "config.xml";
		
		var fileAPI:FileOperation = new FileOperation();
		fileAPI.getXML(Delegate.create(this, this.onGetFilePath), path, { } );
		
		this.clear();
	}
	
	private function onGetFilePath(success:Boolean, obj:Object, param:Object):Void
	{
		if (success)
		{
			if (!Util.isBlank(obj.path))
			{
				this.loadConfig(obj.path);
			}
			else if (!Util.isBlank(obj.name))
			{
				this.loadConfig(obj.name);
			}
			else
			{
				Share.POPUP.showMessagePopup(Share.getString("config_load_error_title"), Share.getString("config_load_error"), Delegate.create(this, this.closeAll));
			}
		}
		else
		{
			Share.POPUP.showMessagePopup(Share.getString("config_load_error_title"), Share.getString("config_load_error"), Delegate.create(this, this.closeAll));
		}
	}
	
	public function testCurrentConfig(cb:Function):Void
	{
		if (cb != null)
		{
			this.cb = cb;
		}
		
		this.clear();
		
		this.currentMC = this.testingBaseMC.createEmptyMovieClip("mc_testingBase", this.testingBaseMC.getNextHighestDepth());
		
		var mc:MovieClip = this.currentMC.attachMovie("configTestResultMC", "mc_configTestResult", this.currentMC.getNextHighestDepth());
		mc.txt_title.text = Share.getString("test_config_title");
		
		mc.attachMovie("loadingMC", "mc_loading", mc.getNextHighestDepth(), { _x:640, _y:360 } );
		
		ComponentUtils.fitTextInTextField(mc.mc_back.txt, Share.getString("close"));
		
		this.testPaths = PlaybackManager.playbackConfig.getAllPath();
		this.testResults = [];
		
		this.startTesting( { index:-1 } );
	}
	
	public function loadConfig(path:String, cb:Function):Void
	{
		if (cb != null)
		{
			this.cb = cb;
		}
		// load config xml and parse
		Util.loadURL(path, Delegate.create(this, this.onConfigLoaded), { target:"xml", timeout:6000 } );
		this.currentMC = this.testingBaseMC.createEmptyMovieClip("mc_loadConfig", this.testingBaseMC.getNextHighestDepth());
		this.currentMC.attachMovie("loadingMC", "mc_loading", this.currentMC.getNextHighestDepth(), { _x:640, _y:360 } );
	}
	
	private function onConfigLoaded(success:Boolean, xml:XML, o:Object):Void
	{
		this.clear();
		if (success)
		{
			Share.PLAYER.setupPlaybackConfig(xml);
			this.testCurrentConfig();
		}
		else
		{
			// unable to load config
			Share.POPUP.showMessagePopup(Share.getString("config_load_error_title"), Share.getString("config_load_error"), Delegate.create(this, this.closeAll));
		}
	}
	
	
	private function clear():Void
	{
		this.miniBrowser.kill();
		delete this.miniBrowser;
		this.miniBrowser = null;
		
		this.currentMC.removeMovieClip();
		delete this.currentMC;
		
		delete this.testPaths;
		delete this.testResults;
		
		Key.removeListener(this.klObject);
		delete this.klObject.onKeyDown;
		delete this.klObject;
	}
	
	private function startTesting(param:Object):Void
	{
		var index:Number = param.index + 1;
		if (index >= this.testPaths.length)
		{
			// finish testing
			this.renderTestResult();
			return;
		}
		
		param.index = index;
		var testItem:Object = this.testPaths[index];
		var path:String = testItem.path;
		var username:String = testItem.user;
		var password:String = testItem.pass;
		var fromPath:String = testItem.from;
		if (Util.isBlank(username))
		{
			username = "";
		}
		if (Util.isBlank(password))
		{
			password = "";
		}
		
		if (Util.startsWith(path, "nfs://") || Util.startsWith(path, "smb://"))
		{
			var serverSlashIndex:Number = path.indexOf("/", 6);
			if (serverSlashIndex < 0)
			{
				serverSlashIndex = path.length;
			}
			
			var lastSlashIndex:Number = path.lastIndexOf("/", serverSlashIndex + 1);
			
			if (lastSlashIndex < 0)
			{
				lastSlashIndex = path.length;
			}
			
			var serverPath:String = path.substring(0, serverSlashIndex + 1);
			var mountPath:String = path.substring(serverSlashIndex + 1);
			
			param.path = path;
			param.server = serverPath;
			param.mount = mountPath;
			param.from = fromPath;
			
			if (Util.isBlank(mountPath) || mountPath.length == 1)
			{
				// use resource
				var lncapi:ListNetworkResource = new ListNetworkResource();
				lncapi.getXML(Delegate.create(this, this.onMount), serverPath, username, password, param);
			}
			else
			{
				var lncapi:ListNetworkContent = new ListNetworkContent();
				lncapi.getXML(Delegate.create(this, this.onMount), serverPath, mountPath, username, password, param);
			}
			
		}
		else
		{
			// not recognized path
			this.testResults.push( { path:path, result:-1 } );
			//param.index ++;
			this.startTesting(param);
		}
	}
	
	private function onMount(success:Boolean, returnValue:String, param:Object):Void
	{
		if (success)
		{
			if (parseInt(returnValue) == 0)
			{
				// fine
				this.testResults.push( { path:param.path, serverPath:param.server, mountPath:param.mount, from:param.from, result:0 } );
			}
			else
			{
				this.testResults.push( { path:param.path, serverPath:param.server, mountPath:param.mount, from:param.from, result:returnValue } );
			}
		}
		else
		{
			this.testResults.push( { path:param.path, serverPath:param.server, mountPath:param.mount, from:param.from, result:-2 } );
		}
		
		this.startTesting(param);
	}
	
	private function renderTestResult():Void
	{
		var mc:MovieClip = this.currentMC.mc_configTestResult;
		mc.mc_loading.removeMovieClip();
		
		var result:String = "";
		var str:String = null;
		var len:Number = this.testResults.length;
		var item:Object = null;
		for (var i:Number = 0; i < len; i ++)
		{
			item = this.testResults[i];
			if (Util.isBlank(item.from))
			{
				// server login
				str = Share.getString("test_config_server_item");
				str = Util.replaceAll(str, "|SERVER_PATH|", Share.returnStringForDisplay(item.path));
			}
			else
			{
				str = Share.getString("test_config_replace_item");
				str = Util.replaceAll(str, "|TO_PATH|", Share.returnStringForDisplay(item.path));
				str = Util.replaceAll(str, "|FROM_PATH|", Share.returnStringForDisplay(item.from));
			}
			
			result += str + "\n";
			
			str = Share.getString("test_config_result");
			if (item.result == 0)
			{
				// success
				str = Util.replaceAll(str, "|RESULT|", Share.getString("test_config_success"));
			}
			else if (item.result == -1)
			{
				// invalid path
				str = Util.replaceAll(str, "|RESULT|", Share.getString("test_config_error_not_real_path"));
			}
			else if (item.result == -2)
			{
				// timeout
				str = Util.replaceAll(str, "|RESULT|", Share.getString("test_config_error_timeout"));
			}
			else
			{
				// check whether got specific error message
				var error:String = Share.getString("test_config_error_" + item.result);
				if (Util.isBlank(error))
				{
					// do not have specific error message, use generic error message
					str = Util.replaceAll(str, "|RESULT|", Util.replaceAll(Share.getString("test_config_error"), "|ERROR_CODE|", item.result));
				}
				else
				{
					// have specific error message
					str = Util.replaceAll(str, "|RESULT|", error);
				}
			}
			
			result += str + "\n-----------\n";
		}
		
		mc.txt_result.htmlText = result;
		
		// enable listener
		this.klObject = new Object();
		this.klObject.onKeyDown = Delegate.create(this, this.navi);
		Key.addListener(this.klObject);
	}
	
	private function closeAll():Void
	{
		this.clear();
		var _cb = this.cb;
		this.cb = null;
		
		_cb();
	}
	
	private function navi():Void
	{
		var keyCode:Number = Key.getCode();
		
		switch (keyCode)
		{
			case Key.UP:
				this.currentMC.mc_configTestResult.txt_result.scroll --;
				break;
			case Key.DOWN:
				this.currentMC.mc_configTestResult.txt_result.scroll ++;
				break;
			case Key.BACK:
				this.closeAll();
				break;
		}
	}
}