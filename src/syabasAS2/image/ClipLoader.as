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
import mx.utils.Delegate;
class syabasAS2.image.ClipLoader {
	private var prp:Object;
	private var cb:Function;
	private var df:String;
	private var mc
	private var loader:MovieClipLoader;
	private var count:Number = 0;
	
	public function ClipLoader(mClip:MovieClip, url:String, obj:Object, cback:Function, dfBg:String) {
		if(count){
			this.count = count;
		}
		prp = obj;
		cb = cback;
		df = dfBg;
		mc = mClip;
		loader = new MovieClipLoader();
		loader.addListener(this);
		if(url){
			loader.loadClip(url, mClip);
		}else{
			onLoadError();
		}
	}
	function load(mClip:MovieClip, url:String, obj:Object, dfBg:String):Void {
		count ++;
		new ClipLoader(mClip, url, obj, Delegate.create(this, onLoadInit) , dfBg)
	}  
	
	function onLoadStart():Void{}
	function onLoadError():Void {
		if(count == 0){
			if(df){
				loader.loadClip(df, mc);
			}else{
				if(cb){
					cb(true,mc);clearVar();
				}
			}
		}
	}
	function onLoadComplete():Void{}
	function onLoadProgress():Void{}
	function onLoadInit(target:MovieClip):Void {
		if(prp){
			for(var i in prp){target[i] = prp[i];}
		}
		if (count > 0) {
			count--;
		}
		if(count == 0){
			if(cb){cb(false, mc);clearVar();}
		}
	}
	public function clearVar(){
		delete prp;prp = null;
		delete cb;cb = null;
		delete loader;loader = null;
/*		prp = new Object();
		cb = new Function();
		loader = new MovieClipLoader();*/
	}
}
