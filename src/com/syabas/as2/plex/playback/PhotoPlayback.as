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
* Class Description: Photo Playback Module
*
***************************************************/
import com.syabas.as2.common.IMGLoader;
import com.syabas.as2.common.Util;

import caurina.transitions.Tweener;
import mx.utils.Delegate;
class com.syabas.as2.plex.playback.PhotoPlayback
{
	private var parentMC:MovieClip = null;
	private var imageMC_1:MovieClip = null;
	private var imageMC_2:MovieClip = null;
	private var statusMC:MovieClip = null;
	private var playStatusMC:MovieClip = null;
	private var playerMC:MovieClip = null;
	
	private var imgLoader:IMGLoader = null;
	
	private var playbackObject:Object = null;
	private var photoPlaybackKL:Object = null;
	private var playlist:Array = null;
	
	private var otherMediaCheckInterval:Number = null;
	private var playStatusInterval:Number = null;
	private var slideshowInterval:Number = null;
	private var loaderID:Number = 0;
	private var transitionTime:Number = 1.5;
	private var slideInterval:Number = 5000;
	private var otherMediaIndex:Number = -1;
	private var otherMediaOffset:Number = 0;
	private var currentMediaIndex:Number = -1;
	
	private var isPause:Boolean = false;
	private var isStop:Boolean = false;
	
	public function destroy():Void
	{
		clearInterval(this.slideshowInterval);
		clearInterval(this.otherMediaCheckInterval);
		clearInterval(this.playStatusInterval);
		
		this.statusMC.removeMovieClip();
		delete this.statusMC;
		
		delete this.parentMC;
		
		this.imgLoader.clear();
		this.imgLoader.destroy();
		delete this.imgLoader;
		
		this.imageMC_1.removeMovieClip();
		this.imageMC_2.removeMovieClip();
		
		delete this.imageMC_1;
		delete this.imageMC_2;
		
		Key.removeListener(this.photoPlaybackKL);
		this.photoPlaybackKL.onKeyDown = null;
		delete this.photoPlaybackKL;
		
		delete this.playlist;
		delete this.playbackObject;
	}
	
	public function clear():Void
	{
		this.imgLoader.unload("flashPOD", this.imageMC_1, null);
		this.imgLoader.unload("flashPOD", this.imageMC_2, null);
		this.loaderID = 0;
	}
	
	public function PhotoPlayback()
	{
		
	}
	
	public function startPlayback(mc:MovieClip, o:Object):Void
	{
		this.parentMC = mc;
		this.imgLoader = new IMGLoader(1);
		
		this.playerMC = mc.attachMovie("photoPlaybackMC", "mc_photoPlayback", 30);
		this.statusMC = this.playerMC.mc_status;
		this.statusMC._visible = false;
		
		this.playStatusMC = this.playerMC.mc_playStatus;
		this.playStatusMC._visible = false;
		
		this.playerMC.titleBtxt._visible = false;
		this.playerMC.titleWtxt._visible = false;
		
		this.playlist = o.mediaObj;
		
		this.photoPlaybackKL = new Object();
		Key.addListener(this.photoPlaybackKL);
		this.photoPlaybackKL.onKeyDown = Delegate.create(this, this.onKeyDown);
		
		var i:Number = new Number(o.slideInterval);
		var num:Number = 0;

		if (isNaN(new Number(i)) )
		{
			num = 5000;
		}
		else
		{
			num = (i + 3) * 1000;
		}
		
		this.slideInterval = num;
		
		this.playbackObject = o;
		
		this.currentMediaIndex = new Number(o.startIndex);
		if (isNaN(this.currentMediaIndex) || this.currentMediaIndex >= this.playlist.length || this.currentMediaIndex < 0)
		{
			this.currentMediaIndex = 0;
		}
		
		this.startPODPlayback(this.playlist[this.currentMediaIndex]);
	}
	
	//---------------------------------------- Photo Playback ---------------------------------------
	public function startPODPlayback(o:Object):Void
	{
		/*
		*	@param t title
		*	@param u URL
		*	@param i slide interval
		*	@param r Degree of rotation(rot0(or pass empty parameter), rot90, rot180,rot270)
		*	@param m To play the photo on background. Only applicable on flashlite.
					 bgrun = run background photo in swf
					 bghide = hide background photo in swf (Note: empty parameter will be bghide)
		*
		*/
		this.isPause = false;
		var t:String = o.title;
		var u:String = o.url;
		t = "untitled";
		
		var r:String = o.rotation;
		if(Util.isBlank(r))
			r = "";
		var m:String = "";
		if(o.isNativeInfo == true)
			m = "bghide";
		else
			m = "bgrun";

		var scaleMode:Number = o.scaleMode;
		if(scaleMode == undefined || scaleMode == null || scaleMode == NaN)
			scaleMode = 1;
		var center:Boolean = o.center;
		if(center == undefined || center == null)
			center = true;

		var imageMC:MovieClip = null;
		if(this.loaderID == 0)
		{
			this.imageMC_1 = this.parentMC.createEmptyMovieClip("imageMC_1", 10);
			imageMC = this.imageMC_1;
		}
		else
		{
			this.imageMC_2 = this.parentMC.createEmptyMovieClip("imageMC_2", 20);
			imageMC = this.imageMC_2;
		}
		imageMC._alpha = 0;
		
		this.imgLoader.load("flashPOD", u, imageMC , { doneCB:Delegate.create(this, this.startPODCallback), mcProps:null, lmcId:null, lmcProps:null, scaleMode:scaleMode, scaleProps: { center:center }} );
		this.playerMC.titleBtxt.text = (Util.isBlank(o.title) ? "" : o.title);
		this.playerMC.titleWtxt.text = (Util.isBlank(o.title) ? "" : o.title);
	}
	
	public function stop():Void
	{
		this.execStop();
	}
	
	private function startPODCallback():Void
	{
		var nMC:MovieClip = null;
		var oMC:MovieClip = null;
		if(this.loaderID ==0)
		{
			nMC = this.imageMC_1;
			oMC = this.imageMC_2;
			this.loaderID = 1;
		}
		else
		{
			nMC = this.imageMC_2;
			oMC = this.imageMC_1;
			this.loaderID = 0;
		}
		Tweener.addTween(nMC, {
			_alpha:100,
			time:this.transitionTime,
			transition:"linear",
			onComplete:Delegate.create(this, function()
							{
								clearInterval(this.slideshowInterval);
								this.slideshowInterval = null;
								
								if (!this.isStop && !this.isPause)
								{
									this.slideshowInterval = setInterval(Delegate.create(this, this.nextSlide), this.slideInterval);
								}
							})
		});
		
		if(oMC != null) // cater for 1st time
		{
			Tweener.addTween(oMC, {
				_alpha:0,
				transition:"linear",
				time:this.transitionTime,
				onComplete:Delegate.create(this,this.fadeOut),
				onCompleteParams:[oMC]
			});
		}
	}

	private function fadeOut(mc:MovieClip):Void
	{
		this.imgLoader.unload("flashPOD", mc, null);
	}

	/*
	* Stop playback.
	*/
	public function execStop():Void
	{
		this.imgLoader.unload("flashPOD", this.imageMC_1, null);
		this.imgLoader.unload("flashPOD", this.imageMC_2, null);
		
		this.isStop = true;
		this.playbackObject.completePlaybackCB(this.playbackObject);
	}

	/*
	* resume playback
	*/
	public function execResume():Void
	{
		this.isPause = false;
		clearInterval(this.slideInterval);
		this.slideshowInterval = setInterval(Delegate.create(this, this.nextSlide), this.slideInterval);
		
		this.playStatusMC._visible = true;
		this.playStatusMC.gotoAndStop("play");
		
		clearInterval(this.playStatusInterval);
		this.playStatusInterval = setInterval(Delegate.create(this, this.hidePlayStatus), 3000);
	}

	/*
	* pause playback
	*/
	public function execPause():Void
	{
		this.isPause = true;
		clearInterval(this.slideshowInterval);
		this.slideshowInterval = null;
		
		this.cancelOtherMedia();
		this.playStatusMC._visible = true;
		this.playStatusMC.gotoAndStop("pause");
		
		clearInterval(this.playStatusInterval);
		this.playStatusInterval = setInterval(Delegate.create(this, this.hidePlayStatus), 3000);
	}
	
	//------------------------------------ Slideshow ------------------------------------------
	private function nextSlide():Void
	{
		clearInterval(this.slideshowInterval);
		this.slideshowInterval = null;
		
		if (this.currentMediaIndex == this.playlist.length -1)
		{
			// no more 
			this.imgLoader.unload("flashPOD", this.imageMC_1, null);
			this.imgLoader.unload("flashPOD", this.imageMC_2, null);
			this.playbackObject.completePlaybackCB(this.playbackObject);
		}
		else
		{
			this.next();
		}
	}
	
	//----------------------------------- Other Media -----------------------------------------
	
	private function cancelOtherMedia():Void
	{
		clearInterval(this.otherMediaCheckInterval);
		this.otherMediaCheckInterval = null;
		
		this.otherMediaIndex = -1;
		this.otherMediaOffset = 0;
		
		this.statusMC.wText.text = "";
		this.statusMC.bText.text = "";
		
		this.statusMC.titleWtxt.text = "";
		this.statusMC.titleBtxt.text = "";
		
		this.statusMC._visible = false;
	}
	
	private function updateStatusBar(direction:Number):Void
	{
		this.statusMC._visible = true;
		
		clearInterval(this.otherMediaCheckInterval);
		this.otherMediaCheckInterval = null;
		
		var actualIndex:Number = this.otherMediaIndex + this.otherMediaOffset;
		var item:Object = this.playlist[actualIndex];
		
		if (direction == 0)
		{
			// left
			this.statusMC.gotoAndStop("prev");
		}
		else
		{
			// right
			this.statusMC.gotoAndStop("next");
		}
		
		var countText:String = (actualIndex + 1) + " / " + this.playlist.length;
		this.statusMC.wText.text = countText;
		this.statusMC.bText.text = countText;
			
		if (this.playbackObject.showOtherMediaTitle == true)
		{
			var title:String = (Util.isBlank(item.title) ? "" : item.title);
			this.statusMC.titleWtxt.text = title;
			this.statusMC.titleBtxt.text = title;
		}
		
		this.otherMediaCheckInterval = setInterval(Delegate.create(this, this.checkOtherMedia), 3000);
	}
	
	private function checkOtherMedia():Void
	{
		if (this.otherMediaOffset == 0)
		{
			// no need do anything
			
		}
		else
		{
			// do change
			this.currentMediaIndex = this.otherMediaIndex + this.otherMediaOffset;
			this.startPODPlayback(this.playlist[this.currentMediaIndex]);
		}
		
		this.cancelOtherMedia();
	}
	
	private function next():Void
	{
		clearInterval(this.slideshowInterval);
		this.slideshowInterval = null;
		
		if (this.otherMediaIndex < 0)
		{
			this.otherMediaIndex = this.currentMediaIndex;
		}
		
		if (this.otherMediaOffset + this.otherMediaIndex + 1 < this.playlist.length)
		{
			// can go
			this.otherMediaOffset ++;
		}
		
		this.updateStatusBar(1);
	}
	
	private function previous():Void
	{
		clearInterval(this.slideshowInterval);
		this.slideshowInterval = null;
		
		if (this.otherMediaIndex < 0)
		{
			this.otherMediaIndex = this.currentMediaIndex;
		}
		
		if (this.otherMediaOffset + this.otherMediaIndex - 1 > -1)
		{
			// can go
			this.otherMediaOffset --;
		}
		
		this.updateStatusBar(0);
	}
	
	//------------------------------ Key Listener ----------------------------------
	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();
		
		switch (keyCode)
		{
			case Key.NEXT:
				this.next();
				break;
			case Key.PREVIOUS:
				this.previous();
				break;
			case Key.PAUSE:
				if (!this.isPause)
				{
					this.execPause();
				}
				break;
			case Key.PLAY:
				if (this.isPause)
				{
					this.execResume();
				}
				break;
			case Key.INFO:
				this.playerMC.titleWtxt._visible = !this.playerMC.titleWtxt._visible;
				this.playerMC.titleBtxt._visible = !this.playerMC.titleBtxt._visible;
				break;
			case Key.BACK:
				if (this.playbackObject.disableBackKey == true)
				{
					return;
				}
			case Key.STOP:
				this.execStop();
				break;
		}
	}
	
	/*
	* This function will return original playerObj with additional properties.
	*
	* currentMediaTime:Number  - playback time (in seconds) of the current playback media.
	* totalMediaTime:Number    - total time (in seconds) of the current playback media.
	* currentMediaIndex:Number - current media index on the playlist (return only if PLAYLIST).
	* currentMediaUrl:String   - URL of the current playback media.
	* currentMediaTitle:String - title of the current playback media.
	*/
	public function getCurrentPlaybackInfo():Object
	{
		var o:Object = this.playbackObject;
		o.currentMediaTime = 0;
		o.totalMediaTime = 0;
		o.currentMediaIndex = this.currentMediaIndex;
		o.currentMediaUrl = this.playlist[this.currentMediaIndex].url;
		o.currentMediaTitle = this.playlist[this.currentMediaIndex].title;
		
		return o;
	}
	
	public function updatePlaylist(mediaObj:Array, currentIndex:Number):Void
	{
		this.playlist = mediaObj;
		this.currentMediaIndex = currentIndex;
		if (this.otherMediaIndex > -1)
		{
			this.otherMediaIndex = this.currentMediaIndex;
		}
	}
	
	//------------------------------------------------ Play Status ----------------------------------------------------
	private function hidePlayStatus():Void
	{
		clearInterval(this.playStatusInterval);
		this.playStatusInterval = null;
		this.playStatusMC._visible = false;
	}
}