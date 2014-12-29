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
* Class Description: API to get board MAC Address
*
***************************************************/

import mx.xpath.XPathAPI;
import com.syabas.as2.common.Util;
import mx.utils.Delegate;
class com.syabas.as2.plex.api.GetMacAddress
{
	
	private var callback:Function = null;
	
	public function GetMacAddress()
	{
	}
	
	public function getXML(callback:Function):Void
	{
		this.callback = callback;
		var url:String = "http://127.0.0.1:8008/system?arg0=get_board_id";
		
		Util.loadURL(url, Delegate.create(this, this.parseXML), { target:"xml", timeout:45000 } );
	}
	
	private function parseXML(success:Boolean, xml:XML, o:Object):Void
	{
		o.o.param.httpStatus = o.httpStatus;
		if (success)
		{
			var macAdd:String = XPathAPI.selectSingleNode(xml.firstChild, "theDavidBox/response/boardId").firstChild.nodeValue;
			this.callback(success, macAdd);
		  
			macAdd = null;
		}
		else
		{
			this.callback(success, null);
		}	
		
		xml = null;
		
	}
	
}
