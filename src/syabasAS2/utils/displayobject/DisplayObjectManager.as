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
import flash.display.BitmapData;
/**
 * ...
 * @author Darien Toh
 */
class syabasAS2.utils.displayobject.DisplayObjectManager
{
	private static var _instance:DisplayObjectManager;
	private static var _allowInstance:Boolean = false;
	
	public var CLASSNAME:String = "DisplayObjectManager";
	
	public function DisplayObjectManager() 
	{
		if (!_allowInstance) throw Error(CLASSNAME+" is a Singleton class, can be called using "+CLASSNAME+".instance");
	}
	
	public static function get instance():DisplayObjectManager {
		if (!DisplayObjectManager._instance) {
			_allowInstance = true;
			DisplayObjectManager._instance = new DisplayObjectManager();
			_allowInstance = false;
		}
		
		return DisplayObjectManager._instance;
	}
	
	///////////////////////////////////////////////////////////////////////
	// public function
	///////////////////////////////////////////////////////////////////////
	
	/**
	 * create new movieclip without worry/forgot depths
	 * @param	target
	 * @param	name
	 * @return
	 */
	public function createNewMovieclip(target:MovieClip, name:String):MovieClip
	{
		return target.createEmptyMovieClip(name, target.getNextHighestDepth());
	}
	
	/**
	 * create new textfield without worry/forgot depths
	 * @param	target
	 * @param	name
	 * @return
	 */
	public function createNewTextfield(target:MovieClip, name:String):TextField
	{
		return target.createTextField(name, target.getNextHighestDepth(), 0, 0, 150, 20);
	}
	
	public function attachLibraryMovieClip(target:MovieClip, linkage:String, name:String, init:Object):MovieClip
	{
		return target.attachMovie(linkage, name, target.getNextHighestDepth(), init);
	}
	
	/*public function createBitmapTextfield(target:MovieClip, name:String, text:String, width:Number, height:Number, textformat:TextFormat):MovieClip
	{
		var holder:MovieClip = this.createNewMovieclip(target, name);
		
		var txtf:TextField = this.createNewTextfield(holder, "temp_txtf");
		if (textformat) txtf.setTextFormat(textformat);
		txtf._width = width;
		txtf._height = height;
		txtf.text = text;
		txtf.embedFonts = true;
		txtf.antiAliasType = "advanced";
		
		var bdata:BitmapData = new BitmapData(width, height, true, 0x00000000);
		bdata.draw(txtf);
		txtf.removeTextField();
		
		
		holder.attachBitmap(bdata);
		
		
		
		return holder;
	}*/
}
