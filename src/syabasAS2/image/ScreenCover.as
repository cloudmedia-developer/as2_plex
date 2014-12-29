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
import syabasAS2.action.PercentTween;

class syabasAS2.image.ScreenCover {
	private var cover					:MovieClip;
	private var coverContainer			:MovieClip;
	private var callback				:Function;
	private var color					:Number	= 0x000000;
	private var alpha					:Number	= 100;
	private var screenWidth				:Number = 1280;
	private var screenHeight			:Number = 720;
	private var animationSpeed			:Number = 700;
//----------------------------------------------------------------------------------------------------------
	public  var ANIMATION_FADE			:String = "animationFade";
	public	var ANIMATION_SLIDE_UP		:String = "animationSlideUp";
	public	var ANIMATION_SLIDE_DOWN	:String = "animationSlideDown";
	public	var ANIMATION_SLIDE_LEFT	:String = "animationSlideLeft";
	public	var ANIMATION_SLIDE_RIGHT	:String = "animationSlideRight";

	public function ScreenCover(coverContainer:MovieClip) {
		this.coverContainer = coverContainer;
	}
	
	public function create(callback:Function, animationType:String):Void {
		this.callback 		= callback;
		this.cover 			= this.create_cover_mc();
		switch (animationType) {
			case this.ANIMATION_FADE		:	
				this.cover._alpha = 0;
				this.fade_in();			
				break;
			case this.ANIMATION_SLIDE_UP	:	this.slide_up_in();		break;
			case this.ANIMATION_SLIDE_DOWN	:	this.slide_down_in();	break;
			case this.ANIMATION_SLIDE_LEFT	:	this.slide_left_in();	break;
			case this.ANIMATION_SLIDE_RIGHT	:	this.slide_right_in();	break;
			default:							this.callback();		break;
		}
	}
	
	private function create_complete():Void {
		this.callback();
	}
	
	public function end(callback:Function, animationType:String):Void {
		this.callback = callback;
		switch (animationType) {
			case this.ANIMATION_FADE		:	this.fade();		break;
			case this.ANIMATION_SLIDE_UP	:	this.slide_up();	break;
			case this.ANIMATION_SLIDE_DOWN	:	this.slide_down();	break;
			case this.ANIMATION_SLIDE_LEFT	:	this.slide_left();	break;
			case this.ANIMATION_SLIDE_RIGHT	:	this.slide_right();	break;
			default:							this.complete();	break;
		}
	}
	
	private function complete():Void {
		this.cover.removeMovieClip();
		this.callback();
	}
	
	private function slide_up()		:Void 	{	new PercentTween(5, "easeOut").forward(this.animationSpeed, this, slide_up_change, 		complete);	}
	private function slide_down()	:Void 	{	new PercentTween(5, "easeOut").forward(this.animationSpeed, this, slide_down_change, 	complete);	}
	private function slide_left()	:Void 	{	new PercentTween(5, "easeOut").forward(this.animationSpeed, this, slide_left_change, 	complete);	}
	private function slide_right()	:Void 	{	new PercentTween(5, "easeOut").forward(this.animationSpeed, this, slide_right_change, 	complete);	}
	private function fade()			:Void 	{	new PercentTween(5, "easeOut").forward(this.animationSpeed, this, fade_change, 			complete);	}
	
	private function slide_up_in()		:Void 	{	new PercentTween(5, "easeOut").backward(this.animationSpeed, this, slide_up_change, 	create_complete);	}
	private function slide_down_in()	:Void 	{	new PercentTween(5, "easeOut").backward(this.animationSpeed, this, slide_down_change, 	create_complete);	}
	private function slide_left_in()	:Void 	{	new PercentTween(5, "easeOut").backward(this.animationSpeed, this, slide_left_change, 	create_complete);	}
	private function slide_right_in()	:Void 	{	new PercentTween(5, "easeOut").backward(this.animationSpeed, this, slide_right_change, 	create_complete);	}
	private function fade_in()			:Void 	{	new PercentTween(5, "easeOut").backward(this.animationSpeed, this, fade_change, 		create_complete);	}
	
	private function slide_up_change(num:Number):Void {
		this.cover._y = num * -this.screenHeight;
	}
	
	private function slide_down_change(num:Number):Void {
		this.cover._y = num * this.screenHeight;
	}
	
	private function slide_left_change(num:Number):Void {
		this.cover._x = num * -this.screenWidth;
	}
	
	private function slide_right_change(num:Number):Void {
		this.cover._x = num * this.screenWidth;
	}
	
	private function fade_change(num:Number):Void {
		this.cover._alpha = this.alpha * (1 - num);
	}
	
	private function create_cover_mc():MovieClip {
			var mc:MovieClip = this.coverContainer.createEmptyMovieClip("cover", this.coverContainer.getNextHighestDepth());
				mc.beginFill(this.color);
				mc.moveTo(0, 			0);
				mc.lineTo(screenWidth, 	0);
				mc.lineTo(screenWidth, 	screenHeight);
				mc.lineTo(0, 			screenHeight);
				mc.lineTo(0, 			0);
				mc.endFill();
				mc.cacheAsBitmap = true;
		return 	mc;
	}
	
	public function set speed(value:Number)		:Void 	{	this.animationSpeed = value; 	}
	public function set paneColor(value:Number)	:Void 	{	this.color 			= value;	}
	public function set paneAlpha(value:Number)	:Void 	{	this.alpha 			= value;	}
	public function set width(value:Number)		:Void 	{	this.screenWidth	= value;	}
	public function set height(value:Number)	:Void 	{	this.screenHeight	= value;	}
}