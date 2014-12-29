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
***************************************************/
import darien.debug.Tracer;
import nmj.api.core.APIGet;
import syabasAS2.event.Caster;
import syabasAS2.pch.api.core.APICore;
import syabasAS2.utils.Assign;

class syabasAS2.data.SocketHandler extends Caster {
	private var xmlSocket				:XMLSocket;
	private var retryCount				:Number		= 0;
	private var retryMax				:Number 	= 3;
	private var retryOnError			:Boolean 	= true;
	private var port					:Number		= 8118;
	private var host:String;
	//----------------------------------------------------------------------------------------------------------
	public  var EVENT_CONNECTED			:String 	= "socketConnected";
	public  var EVENT_ERROR_CONNECTION	:String 	= "socketError";
	public  var EVENT_CLOSE				:String 	= "socketClose";
	public  var EVENT_GET_DATA			:String 	= "socketGetXMLData";
	
	public function SocketHandler(host:String, retryOnError:Boolean) {
		this.retryOnError = retryOnError;
		this.host = host;
		this.init();
		this.socket_connect();
		trace("*********************************************************************************************************");
		trace("*********************************************************************************************************");
		trace("")
		trace("SOCKET CONNECT TO HOST: " + this.host + ", PORT: " + port);
		trace("");
		
	}
	
	private function init():Void
	{
		this.xmlSocket 				= new XMLSocket();
		this.xmlSocket.onConnect 	= Assign.create(this, socket_onConnect);
		this.xmlSocket.onXML		= Assign.create(this, socket_onXML);
		this.xmlSocket.onData		= Assign.create(this, socket_onXML);
		this.xmlSocket.onClose 		= Assign.create(this, socket_onClose);
	}

	private function socket_connect():Void {
		//trace("[NTS-DEBUG][SocketHandler.socket_connect] connect attemp: " + (this.retryCount + 1));
		this.xmlSocket.connect(this.host, this.port);
	}
	
	private function socket_onConnect(success:Boolean):Void {
		//trace("[NTS-DEBUG][SocketHandler.socket_onConnect()] success : " + success);
		if (success) {
			/*trace("[NTS-DEBUG][SocketHandler.socket_onConnect] SUCCESS CONNECTED");
			trace("")
			trace("*********************************************************************************************************");
			trace("*********************************************************************************************************");*/
			this.castEvent( { type: this.EVENT_CONNECTED } );
		}
		else {
			if (this.retryOnError) {
				if (this.retryCount == this.retryMax) {
					//trace("[NTS-DEBUG][SocketHandler.socket_onConnect] ERROR CONNECTED RETRY: " + (this.retryCount + 1) + " TIMES");
					this.castEvent( { type: this.EVENT_ERROR_CONNECTION } );
				}
				else {
					this.retryCount ++;
					this.socket_connect();
				}
			}
			else {
				//trace("[NTS-DEBUG][SocketHandler.socket_onConnect] ERROR CONNECTED NO RETRY");
				this.castEvent( { type: this.EVENT_CONNECTED } );
			}
		}
	}
	
	private function socket_onXML(xmlObject:XML):Void {
		this.castEvent( { type: this.EVENT_GET_DATA, xmlString: xmlObject.toString() } );
	}
	
	private function socket_onClose():Void {
		//Tracer.self.error(["SocketHandler socket_onClose():", "Socket blasted! Reconnecting in attempt"]);
		this.init();
		this.socket_connect();
		
		this.castEvent( { type: this.EVENT_CLOSE } );
	}
	
	public function close():Void {
		trace("[NTS-DEBUG][SocketHandler.close]");
		this.xmlSocket.close();
	}
	
	public function set retry_number(value:Number):Void {
		this.retryMax = value;
	}
}