/***************************************************
* Module name: GetMacAddress.as
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
* Version 1.0.0
*
* Developer: Syabas Technology Sdn. Bhd.
*
* Class Description: API to mount password protected server
*
***************************************************/

import mx.xpath.XPathAPI;
import com.syabas.as2.common.Util;
import mx.utils.Delegate;
class com.syabas.as2.plex.api.ListNetworkContent
{
	
	private var callback:Function = null;
	
	public function ListNetworkContent()
	{
	}
	
	public function getXML(callback:Function, server:String, path:String, username:String, password:String, obj:Object):Void
	{
		this.callback = callback;
		var url:String = "http://127.0.0.1:8008/network_browse?arg0=list_network_content&arg1=" + escape(server) + "&arg2=" + escape(path) + "&arg3=" + escape(username) + "&arg4=" + escape(password) + "&arg5=&arg6=1&arg7=&arg8=&arg9=&arg10=";
		
		Util.loadURL(url, Delegate.create(this, this.parseXML), { target:"xml", param:obj, timeout:45000 } );
	}
	
	private function parseXML(success:Boolean, xml:XML, o:Object):Void
	{
		o.o.param.httpStatus = o.httpStatus;
		if (success)
		{
			var response:String = XPathAPI.selectSingleNode(xml.firstChild, "theDavidBox/returnValue").firstChild.nodeValue;
			this.callback(success, response, o.o.param);
		  
			response = null;
		}
		else
		{
			this.callback(success, null, o.o.param);
		}	
		
		xml = null;
		
	}
	
}
