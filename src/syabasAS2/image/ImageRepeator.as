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
import syabasAS2.data.collector.abstract.AbstractList;
import syabasAS2.manager.bitmap.BitmapManager;
import syabasAS2.manager.media.MediaManager;
import syabasAS2.ui.list.HorizontalDisplayList;
import syabasAS2.ui.list.VerticalDisplayList;
import syabasAS2.utils.Destructor;
import syabasAS2.utils.ts.Bagus;
/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.image.ImageRepeator
{
	private var list		:AbstractList;
	private var container	:MovieClip;
	private var bitmap		:BitmapData;
	
	public function ImageRepeator(container:MovieClip) {
		this.container 	= container;
		
	}
	
	public function repeatX(bitmap:BitmapData, repeatation:Number):Void {
		this.list = new HorizontalDisplayList();
		if (repeatation) {
			var length:Number = repeatation;
			for (var i:Number = 0; i < length; i++) {
				var repo:MovieClip = MediaManager.self.createMovieClip("repo" + i, this.container);
				BitmapManager.self.attach(bitmap, repo);
				this.list.add(repo);
			}
		}
		else {
			Bagus.self.error("[ImageRepeator][ERROR]", "please specify the repo")
		}
		this.redrawBitmap();
	}
	
	public function repeatXById(bitmapId:String, repeatation:Number):Void {
		this.list = new HorizontalDisplayList();
		if (repeatation) {
			var length:Number = repeatation;
			for (var i:Number = 0; i < length; i++) {
				var repo:MovieClip = MediaManager.self.createMovieClip("repo" + i, this.container);
				BitmapManager.self.attachById(bitmapId, repo);
				this.list.add(repo);
			}
		}
		else {
			Bagus.self.error("[ImageRepeator][ERROR]", "please specify the repo")
		}
		this.redrawBitmap();
	}
	
	public function repeatY(bitmap:BitmapData, repeatation:Number):Void {
		this.list = new VerticalDisplayList();
		if (repeatation) {
			var length:Number = repeatation;
			for (var i:Number = 0; i < length; i++) {
				var repo:MovieClip = MediaManager.self.createMovieClip("repo" + i, this.container);
				BitmapManager.self.attach(bitmap, repo);
				this.list.add(repo);
			}
		}
		else {
			Bagus.self.error("[ImageRepeator][ERROR]", "please specify the repo")
		}
		this.redrawBitmap();
	}
	
	public function repeatYById(bitmapId:String, repeatation:Number):Void {
		this.list = new VerticalDisplayList();
		if (repeatation) {
			var length:Number = repeatation;
			for (var i:Number = 0; i < length; i++) {
				var repo:MovieClip = MediaManager.self.createMovieClip("repo" + i, this.container);
				BitmapManager.self.attachById(bitmapId, repo);
				this.list.add(repo);
			}
		}
		else {
			Bagus.self.error("[ImageRepeator][ERROR]", "please specify the repo")
		}
		this.redrawBitmap();
	}
	
	public function repeatXY(bitmap:BitmapData, repeatationX:Number, repeatationY:Number):Void {
		if (repeatationX && repeatationY) {
			this.repeatX(bitmap, repeatationX);
			Destructor.cleanMC(this.container, true);
			this.repeatY(this.bitmapData, repeatationY)
		}
		else {
			Bagus.self.error("[ImageRepeator][ERROR]", "please specify the repo")
		}
		this.redrawBitmap();
	}
	
	public function repeatXYById(bitmapId:String, repeatationX:Number, repeatationY:Number):Void {
		if (repeatationX && repeatationY) {
			this.repeatXById(bitmapId, repeatationX);
			Destructor.cleanMC(this.container, true);
			this.repeatY(this.bitmapData, repeatationY)
		}
		else {
			Bagus.self.error("[ImageRepeator][ERROR]", "please specify the repo")
		}
		this.redrawBitmap();
	}
	
	private function redrawBitmap():Void {
		this.bitmap = new BitmapData(this.container._width, this.container._height, true, null);
		this.bitmap.draw(this.container);
		Destructor.cleanMC(this.container, true);
		delete this.list; this.list = null;
		this.container.attachBitmap(this.bitmap, 0);
	}
	
	public function get target():MovieClip {
		return this.container;
	}
	
	public function set target(value:MovieClip):Void {
		this.container = value;
	}
	
	public function get bitmapData():BitmapData {
		return this.bitmap;
	}
}