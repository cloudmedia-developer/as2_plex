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
* Class Description: Plex API
*
***************************************************/

import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.Share;

import com.syabas.as2.common.Util;
import com.syabas.as2.common.JSONUtil;
import com.syabas.as2.common.URLLoader;

import mx.utils.Delegate;
import mx.xpath.XPathAPI;
class com.syabas.as2.plex.api.API
{
	private var loader:URLLoader = null;
	
	public function destroy():Void
	{
		this.loader.destroy();
		delete this.loader;
		this.loader = null;
	}
	
	public function API()
	{
		this.loader = new URLLoader(3);
	}
	
	/***********************************************
	 * Function : Clear all request queue in loader
	 ***********************************************/
	public function disposeAllRequest():Void
	{
		this.loader.emptyQueue();
	}
	
	/*************************************************
	 * Function : clear the request of specific id key
	 *************************************************/
	public function disposeRequest(key:String):Void
	{
		this.loader.skip(key);
	}
	
	
	/**************************************************************************************************
	 * Function : Load data from server
	 * 
	 * @param	key:String			- The key attributes [Required]
	 * @param	path:String			- The path of the parent directory [Optional]
	 * @param	userparams:Object	- Any object, which will be returned together [Optional]
	 * @param	callback:Function	- The callback functions, if any. If null, will callback through event listener [Optional]
	 * 										1. success:Boolean 		- Indicates the request loading status
	 * 										2. httpStatus:Number	- The HTTP Status Number received
	 * 										3. data:Object			- The parsed object
	 * 										4. userparams:Object	- The same userparams passed
	 * 
	 * 
	 **************************************************************************************************/
	
	public function load(key:String, path:String, server:String, userparams:Object, callback:Function, loadID:String):Void
	{
		loadXML(key, path, server, userparams, callback, loadID);
		return;
		
		if (loadID == null || loadID == undefined)
		{
			loadID = "" + new Date().getTime();
		}
		
		// Load using json. Currently not using it
		var url:String = this.getLoadURL(key, path, server);
		url = Util.escapeHTML(url);
		
		var req:LoadVars = new LoadVars();
		req.addRequestHeader("Accept", "application/json");
		
		var loadURLParam:Object = { target:"string", request:req, method:"POST", _callback:callback, _userparams:userparams };
		
		this.loader.load(loadID, url, Delegate.create(this, this.loadRequestOnLoad), loadURLParam);
	}
	
	public function loadXML(key:String, path:String, server:String, userparams:Object, callback:Function, loadID:String):Void
	{
		var url:String = this.getLoadURL(key, path, server);
		
		if (Util.startsWith(url, Share.MY_PLEX_BASE_URL))
		{
			if (!Util.isBlank(Share.MY_PLEX_TOKEN))
			{
				// Add Authentication token if the request is pointing to myPlex server
				url += (url.indexOf("?") > 0 ? "&" : "?") + "auth_token=" + Share.MY_PLEX_TOKEN;
			}
		}
		
		url = Util.escapeHTML(url);
		var request:XML = this.getMyPlexRequest(userparams.request);
		//var loadURLParam:Object = { request:request, timeout:45000, target:"xml", _callback:callback, _userparams:userparams, request:userparams.request, method:((userparams.request == null || userparams.request == undefined) ? "GET" : "POST") };
		var loadURLParam:Object = { request:request, timeout:45000, target:"xml", _callback:callback, _userparams:userparams, method:"POST" };
		
		this.loader.load(loadID, url, Delegate.create(this, this.loadRequestOnLoad), loadURLParam);
	}
	
	private function getLoadURL(key:String, path:String, server:String):String
	{
		if (Util.startsWith(key, "http://") || Util.startsWith(key, "https://")) 
		{
			// no need do any changes
			
			return key;
		}
		
		if (Util.startsWith(path, "http://") || Util.startsWith(path, "https://")) 
		{
			
			if (!Util.endsWith(path, "/"))
			{
				path += "/";
			}
			return path + key;
		}
		
		if (server == null || server == undefined || server.length < 1)
		{
			server = Share.systemGateway;
		}
		
		if (!Util.endsWith(server, "/"))
		{
			server = server + "/";
		}
		
		if (key.charAt(0) == "/")
		{
			key = key.substring(1);
			
			return server + key;
		}
		
		if (path.length > 0)
		{
			if (path.charAt(0) == "/")
			{
				path = path.substring(1);
			}
			
			if (!Util.endsWith(path, "/"))
			{
				path = path + "/";
			}
			
			return server + path + key;
			
		}
	}
	
	private function loadRequestOnLoad(success:Boolean, data:Object, o:Object):Void
	{
		var dataObj:Object = null;
		if (success)
		{
			if (o.o.target == "string")
			{
				dataObj = this.parseJSONToObject(data.toString());
			}
			else
			{
				dataObj = this.parseXMLToObject(data.firstChild);
			}
		}
		var userparams:Object = o.o._userparams;
		var cb:Function = o.o._callback;
		if (cb != null && cb != undefined)
		{
			cb(success, o.httpStatus, dataObj, userparams);
		}
	}
	
	private function parseJSONToObject(jsonString:String):Object
	{
		var json:Object = JSONUtil.parseJSON(jsonString);
		var container:ContainerModel = new ContainerModel();
		container.fromObject(json);
		
		return container;
	}
	
	/*************************************************************************************************************
	 * Function : Parse the XML Node into object
	 * @param 	xml:XMLNode			- The XML Node to be parsed
	 *************************************************************************************************************/
	private function parseXMLToObject(xml:XMLNode):ContainerModel
	{
		// All result start with a conatiner
		var container:ContainerModel = new ContainerModel();
		container.fromXML(xml);
		
		return container;
	}
	
	//----------------------------------------------- My Plex Login -----------------------------------------------
	
	public function getPlexLoginCode(callback:Function):Void
	{
		var url:String = Share.MY_PLEX_BASE_URL + "/pins.xml";
		var request:XML = new XML("<main/>");
		request = this.getMyPlexRequest(request);
		
		var loadURLParam:Object = { target:"xml", request:request, _callback:callback, method:"POST" };
		
		url = Util.escapeHTML(url);
		
		this.loader.load("" + new Date().getTime(), url, Delegate.create(this, this.authLoaded), loadURLParam);
	}
	
	public function pollLoginStatus(id:String, callback:Function):Void
	{
		var url:String = Share.MY_PLEX_BASE_URL + "/pins/" + id + ".xml";
		var request:XML = this.getMyPlexRequest();
		
		var loadURLParam:Object = { target:"xml", request:request, _callback:callback, method:"POST" };
		
		url = Util.escapeHTML(url);
		
		this.loader.load("" + new Date().getTime(), url, Delegate.create(this, this.authLoaded), loadURLParam);
	}
	
	public function checkLoginStatus(token:String, callback:Function):Void
	{
		var url:String = Share.MY_PLEX_BASE_URL + "/users/sign_in.xml?auth_token=" + token;
		var request:XML = new XML("<main/>");
		request = this.getMyPlexRequest(request);
		
		
		var loadURLParam:Object = { target:"xml", request:request, _callback:callback, method:"POST" };
		
		url = Util.escapeHTML(url);
		
		this.loader.load("" + new Date().getTime(), url, Delegate.create(this, this.authLoaded), loadURLParam);
	}
	
	private function authLoaded(success:Boolean, data:XML, o:Object):Void
	{
		var dataObj:Object = null;
		if (success)
		{
			var id:String = XPathAPI.selectSingleNode(data.firstChild, "/pin/id").firstChild.nodeValue.toString();
			var code:String = XPathAPI.selectSingleNode(data.firstChild, "/pin/code").firstChild.nodeValue.toString();
			var authToken:String = XPathAPI.selectSingleNode(data.firstChild, "/pin/auth_token").firstChild.nodeValue.toString();
			
			dataObj = { id:id, code:code, authToken:authToken };
		}
		else
		{
			
		}
		
		var cb:Function = o.o._callback;
		if (cb != null && cb != undefined)
		{
			cb(success, o.httpStatus, dataObj);
		}
	}
	
	private function getMyPlexRequest(request:XML):XML
	{
		if (request == null || request == undefined)
		{
			request = new XML();
		}
		
		request.addRequestHeader("X-Plex-Client-Identifier", Share.CLIENT_IDENTIFIER);
		request.addRequestHeader("X-Plex-Product", Share.CLIENT_PRODUCT);
		request.addRequestHeader("X-Plex-Platform", Share.CLIENT_PLATFORM);
		request.addRequestHeader("X-Plex-Client-Platform", Share.CLIENT_PLATFORM);
		request.addRequestHeader("X-Plex-Device", Share.CLIENT_DEVICE);
		request.addRequestHeader("X-Plex-Version", Share.CLIENT_VERSION);
		
		return request;
	}
	
	//------------------------------- Playback Progress -----------------------------------
	public function reportPlaybackProgress(server:String, key:String, identifier:String, time:Number, state:String):Void
	{
		this.load("/:/progress?key=" + escape(key) + "&identifier=" + escape(identifier) + "&time=" + (time * 1000) + "&state=" + state, null, server, null, null, null);
	}
	
	public function setWatched(server:String, key:String, identifier:String, callback:Function):Void
	{
		this.load("/:/scrobble?key=" + escape(key) + "&identifier=" + escape(identifier), null, server, null, callback, null);
	}
	
	public function setUnwatched(server:String, key:String, identifier:String, callback:Function):Void
	{
		this.load("/:/unscrobble?key=" + escape(key) + "&identifier=" + escape(identifier), null, server, null, callback, null);
	}
	
	public function pingTranscoder():Void
	{
		this.load("/video/:/transcode/universal/ping?session=" + escape(Share.CLIENT_IDENTIFIER), null, Share.systemGateway, null, null, null);
	}
	
	public function stopTranscoder():Void
	{
		this.load("/video/:/transcode/universal/stop?session=" + escape(Share.CLIENT_IDENTIFIER), null, Share.systemGateway, null, null, null);
	}
}