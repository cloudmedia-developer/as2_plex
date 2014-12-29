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
import syabasAS2.event.Event;
class syabasAS2.event.KeyEvent extends Event {
	private			var _char		:String;
	private 		var _keyCode	:Number;
	private 		var _charCode	:Number;
	private 		var _number:Number;
	
	static public var KEY_UP:String = "on_key_up";
	static public var KEY_DOWN:String = "on_key_down";
			
	public function get keyCode()	:Number 	{	return _keyCode;	}
	public function get charCode()	:Number 	{	return _charCode;	}
	public function get char()		:String 	{	return _char;		}
	public function get number()	:Number 	{ 	return _number; 	}
	
	public function KeyEvent( target:Object, type:String, keyCode:Number, charCode:Number ) {
		super(target, type);
		this._keyCode 				= keyCode;
		this._charCode 				= charCode;
	}
	
	public function set char(value:String):Void {
		this._char = value;
	}
	
	public function set number(value:Number):Void
	{
		this._number = value;
	}
}