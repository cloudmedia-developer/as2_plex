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
class syabasAS2.image.RoundedRect {
	private var color:Number = 0x000000;
	private var alpha:Number = 100;
	
	public function RoundedRect(color:Number, alpha:Number) {
		if (color) this.color = color;
		if (alpha) this.alpha = alpha;
	}
	
	public function roundedHorizontalBar(mc:MovieClip, width:Number, height:Number, cacheAsBitmap:Boolean):Void {
		var r:Number 	= height / 2;
		var c1:Number 	= r * (Math.SQRT2 - 1);
		var c2:Number 	= r * Math.SQRT2 / 2;
		var x:Number 	= r;
		mc.beginFill(color, alpha);
		mc.moveTo(x, r + r);
		mc.curveTo(x - c1, r + r, x - c2, r + c2);
		mc.curveTo(x - r, r + c1, x - r, r);
		mc.curveTo(x - r, r - c1, x - c2, r - c2);
		mc.curveTo(x - c1, 0, x, 0);
		mc.lineTo(width - r, 0)
		x 				= width - r;
		mc.curveTo(x + c1, 0, x + c2, r - c2);
		mc.curveTo(x + r, r - c1, x + r, r);
		mc.curveTo(x + r, r + c1, x + c2, r + c2);
		mc.curveTo(x + c1, r + r, x, r + r);
		mc.endFill();
	}
	
	public function roundedVerticalBar(mc:MovieClip, width:Number, height:Number):Void {
		var r:Number 	= width / 2;
		var c1:Number 	= r * (Math.SQRT2 - 1);
		var c2:Number 	= r * Math.SQRT2 / 2;
		var x:Number 	= r;
		mc.beginFill(color, alpha);
		mc.moveTo(x, r + r);
		mc.curveTo(x - r, r - c1, x - c2, r - c2);
		mc.curveTo(x - c1, 0, x, 0);
		mc.curveTo(x + c1, 0, x + c2, r - c2);
		mc.curveTo(x + r, r - c1, x + r, r);
		
		mc.lineTo(width, height - r)
		x 				= width - r;
		
		mc.curveTo(x + r, r + c1, x + c2, r + c2);
		mc.curveTo(x + c1, r + r, x, r + r);
		mc.curveTo(x - c1, r + r, x - c2, r + c2);
		mc.curveTo(x - r, r + c1, x - r, r);
		mc.endFill();
	}
}