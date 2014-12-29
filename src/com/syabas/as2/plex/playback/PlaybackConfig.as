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
* Class Description: Class managing playback URL replace policy
***************************************************/

import com.syabas.as2.common.Util;
import com.syabas.as2.plex.Share;

import mx.xpath.XPathAPI;
class com.syabas.as2.plex.playback.PlaybackConfig
{
	private var policies:Array = null;
	private var serverLogin:Array = null;
	public function PlaybackConfig()
	{
		if (Share.appSO.data.config != null && Share.appSO.data.config != undefined)
		{
			this.fromObject(Share.appSO.data.config);
		}
	}
	
	public function fromObject(obj:Object):Void
	{
		this.policies = obj.policies;
		this.serverLogin = obj.login;
	}
	
	public function toObject():Object
	{
		return { policies:this.policies, login:this.serverLogin };
	}
	
	public function fromXML(xml:XML):Void
	{
		delete this.policies;
		this.policies = [];
		
		delete this.serverLogin;
		this.serverLogin = [];
		
		if (xml == null)
		{
			return;
		}
		
		var policyNodes:Array = XPathAPI.selectNodeList(xml.firstChild, "config/playback/replace_policy/replace");
		var len:Number = policyNodes.length;
		var node:XMLNode = null;
		for (var i:Number = 0; i < len; i ++)
		{
			node = policyNodes[i];
			
			var from:String = node.attributes.from.toString();
			var to:String = node.attributes.to.toString();
			
			if (!Util.isBlank(from) && !Util.isBlank(to))
			{
				this.policies.push( { from:from, to:to } );
			}
		}
		
		var serverNodes:Array = XPathAPI.selectNodeList(xml.firstChild, "config/playback/login/server");
		var serverlen:Number = serverNodes.length;
		var serverNode:XMLNode = null;
		for (var i:Number = 0; i < serverlen; i ++)
		{
			serverNode = serverNodes[i];
			
			var user:String = serverNode.attributes.username.toString();
			var pass:String = serverNode.attributes.password.toString();
			var path:String = serverNode.attributes.path.toString();
			
			if (Util.isBlank(pass))
			{
				pass = "";
			}
			
			if (Util.isBlank(user))
			{
				user = "";
			}
			
			if (!Util.isBlank(path))
			{
				this.serverLogin.push( { username:user, password:pass, path:path } );
			}
		}
	}
	
	public function replace(url:String):String
	{
		if (this.policies.length < 1)
		{
			return null;
		}
		
		var len:Number = this.policies.length;
		var replace:Object = null;
		for (var i:Number = 0; i < len; i ++)
		{
			replace = this.policies[i];
			if (url.indexOf(replace.from) > -1)
			{
				return Util.replaceAll(url, replace.from, replace.to);
			}
		}
		
		return null;
	}
	
	public function checkLogin(url:String):Object
	{
		if (this.serverLogin.length < 1)
		{
			return null;
		}
		
		var len:Number = this.serverLogin.length;
		var server:Object = null;
		for (var i:Number = 0; i < len; i ++)
		{
			server = this.serverLogin[i];
			if (Util.startsWith(url, server.path))
			{
				return server;
			}
		}
	}
	
	public function getAllPath():Array
	{
		var result:Array = [];
		var len:Number = 0;
		
		len = this.serverLogin.length;
		for (var i:Number = 0; i < len; i ++)
		{
			result.push( { path:this.serverLogin[i].path, user:this.serverLogin[i].username, pass:this.serverLogin[i].password } );
		}
		
		len = this.policies.length;
		for (var i:Number = 0; i < len; i ++)
		{
			result.push( { path:this.policies[i].to, from:this.policies[i].from } );
		}
		
		return result;
	}
}