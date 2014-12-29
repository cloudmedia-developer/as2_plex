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
* Version 3.3.10
*
* Developer: Syabas Technology Sdn. Bhd.
*
* Class Description:
* This class can be used to ease loading of player.swf to play media.
*
***************************************************/

import mx.utils.Delegate;

class com.syabas.as2.common.PlayerMain
{
	private var playerMC:MovieClip = null;
	private var playerObj:Object = null;
	private var playerListener:Object = null;

	public function PlayerMain()
	{
		this.playerListener = new Object();
		this.playerListener.onLoadInit = Delegate.create(this, this.playerLoaded);
		this.playerListener.onLoadError = Delegate.create(this, this.playerError);
	}

	/*
	* Destroying the global objects.
	*/
	public function destroy():Void
	{
		this.playerMC = null;
		this.playerObj = null;
		delete this.playerListener;
		this.playerListener = null;
	}

	/*
	* player.swf will be loaded before start playback based on the playerObj configuration.
	*
	* playerMC: the player.swf will be loaded into this movieClip.
	* playerObj: object containing all the configuration properties as below:
	*   1.  >playMode:Number - This value will be used if playMode value is empty in mediaObj. 1=Adobe Netstream, 2=Native POD, 3=Native VOD, 4=Native AOD, 5=Youtube Embeded Player, 6=Flash POD, 7=Adobe Sound
	*   2.  >mediaObj:Object - an object (single media/NO PLAYLIST) or array of objects (multiple media/WITH PLAYLIST) containing:
	*       a. title:String          - Video Title.
	*       b. url:String            - Video URL. (For playMode 5, is Youtube video ID)
	*       c. info:String           - [Optional] Extra info to show on playlist.
	*       d. serverUrl:String      - [Optional] Only required for Netstream RTMP streaming. if empty, player will try to split the url. (i.e. when playMode=1).
	*       e. playMode:Number       - [Optional] If empty, will use default playMode. 1=Adobe Netstream, 2=Native POD, 3=Native VOD, 4=Native AOD, 5=Youtube Embeded Player, 6=Flash POD, 7=Adobe Sound
	*       f. subtitle:Array        - [Optional] List of object which content info for subtitle.
	*          i.   startTime:Number        - start time to display this content.
	*          ii.  subtitleDuration:Number - duration to display this content.
	*          iii. content:String          - subtitle text.
	*       g. subtitleTimeOffset:Number    - [Optional] Only required if subtitle not null. Time offset to start subtitle.
	*       h. **prebuf:Number       - [Optional] Video pre-buffering size. Only required for Native VOD streaming (i.e. when playMode=3).
	*       i. videoQuality:String   - [Optional] Only required for Youtube Embeded Player streaming. Quality to play. Default is medium. Available value: small, medium, large, hd720, hd1080.
	*       j. extraInfo:String      - [Optional] Extra info to show on InfoPanel.
	*       k. totalTime:Number      - [Optional] Only required for Native AOD playback. Total time for AOD file.
	*       l. ...                   - you can add any extra property (e.g. 'id'), so it can be passed back to your callback functions.
	*   3.  >parentPath:String       - application swf path (i.e. the stage MovieClip URL: stageMC._url) used to get the full path to load player.swf.
	*   4.  **prebuf:Number          - Video pre-buffering size. This value will be used if prebuf value is empty in mediaObj. Default is empty.
	*   5.  **showBuffer:Boolean     - true to retrieve and show buffer percentage (for playMode=3 only). Default is false.
	*   6.  startIndex:Number        - start from which media on the playlist. Default is 0.
	*   7.  startFrom:Number         - start media from a specific time (in seconds). Default is 0.
	*   8.  *enableTrickMode:Boolean - enable/disable trick mode (fast forward/rewind). Default is false.
	*   9.  *enableSeek:Boolean      - enable/disable time seek (using left/right arrow keys or through INFO panel). Default is false.
	*   10. disablePause:Boolean     - true to disable pause function. Default is false(enable pause).
	*   11. disableAutoSkip:Boolean  - true to disable auto skip to next media in the playlist when playback fail/error/stop by the machine itself. Default is false.
	*   12. retryInterval:Number     - retry in milliseconds the current "Could not play" media. Default will skip to next media.
	*   13. otherMediaCB:Function    - callback function that will be called when next/previous media has started (for playlist only). Argument:
	*       a. obj:Object            - same as the object return by getCurrentPlaybackInfo() function below.
	*   14. showOtherMediaTitle:Boolean  - true to show the Title at the top right corner when next/previous media has started. Default is false.
	*   15. >completePlaybackCB:Function - callback function that will be called when media playback is completed. Argument:
	*       a. obj:Object                - same as the object return by getCurrentPlaybackInfo() function below.
	*   16. >userActionStopPlaybackCB:Function - callback function that will be called when video playback is stopped by user. Argument:
	*       a. obj:Object                - same as the object return by getCurrentPlaybackInfo() function below.
	*   17. getLatestPlaylist:Function   - callback function that will be called to update the playlist when playlist is showed. Arguments:
	*       a. mediaObj:Array            - same as the original playerObj.mediaObj.
	*       b. currentMediaIndex:Number  - current media index on the playlist.
	*       c. playlistReturnCB:Function - callback function to pass the results back to the player. Arguments:
	*          i.  newMediaObj:Array
	*          ii. newCurrentMediaIndex:Number
	*   18. configDisplayTxt:Object  - [Optional] for multilanguage support. Object containing:
	*       a. skipTo:"Skip to"      - when time seeking.
	*       b. goTo:"Go to"          - when time seek using numeric keys (0=0%, 1=10%, 2=20%, 3=30%, ..., 9=90%)
	*       c. playlist:"Playlist"   - title on the playlist panel.
	*       d. infoPanel:"Info"      - title on the info panel.
	*       e. couldNotPlay:"Could not play"    - will be shown when media is unable to play
	*       f. **downloadSpeed:"Download Speed" - label for download speed. (when playmode is 3 and showDownloadSpeed=true)
	*       g. videoQuality:"Video Quality"     - label for video quality. (when playmode is 5)
	*       h. connectionStatus:"Connecting to media..." - show at the very beginning when connecting to the media.
	*       i. bufferingStatus:"Buffering..."   - show at the very beginning when buffering after connecting.
	*       j. ttInfo:"Info"         - tooltip for button info on infobar.
	*       k. ttPlaylist:"Playlist" - tooltip for button playlist on infobar.
	*       l. ttSeek:"Time Seek"    - tooltip for button time seek on infobar.
	*       m. noInfo:"No Information Available."  - will be shown in infoPanel when no information available.
	*       n. audio:"Audio"  - will be shown in status panel when switch audio track.
	*       o. audioSwitch:"Switch Audio"  - will be shown in infobar when more than one audio track available.
	*       p. **videoBitrate:"Video Bitrate" - label for video bitrate. (when playmode is 3 and showVideoBitrate=true)
	*   19. **showDownloadSpeed:Boolean - true to show Download Speed when buffering. Default is false.
	*   20. showPlaybackStatus:Boolean  - true to show connectionStatus and bufferingStatus. Default is false.
	*   21. liveStream:Boolean          - true disable all action live not applicable such as time progress, pause, seek, trick mode and etc. Default is false.
	*   22. rotation:String             - [Optional] Only required for Native POD and Flash POD streaming. Degree of rotation, available value is rot0, rot90, rot180, and rot270. Default is rot0.
	*   23. slideInterval:Number        - [Optional] Only required for Native POD and Flash POD streaming. Slide show interval. Default is 5000 miliseconds.
	*   24. enableRepeat:Boolean        - [Optional] Only required for Native POD and Flash POD streaming. Continue play first photo when the slide show end. Default is false.
	*   25. transitionTime:Number       - [Optional] Only required for Flash POD streaming. Transition time between 2 images. Default is 1.5.
	*   26. scaleMode:Number            - [Optional] Only required for Flash POD streaming. Mode to scale after image loaded. 1=Actual Size, 2=Fit To Screen, 3=Full Screen. Default is 1.
	*   27. center:Boolean              - [Optional] Only required for Flash POD streaming. Keep image at center screen. Default is true.
	*   28. playbackEventCB:Function    - [Optional] callback function that will be called on event:
	*       a. obj:Object               - an object which content:
	*          i.   event:String
	*          ii.  errorCode:String    - Only return when event "playback error".
	*          iii. errorMessage:String - Only return when event "playback error".
	*          iv.  time:Number         - Only return when event "playback on seek".
	*   29. disableInfoKey:Boolean      - [Optional] Disable INFO Key code to bring up infobar. Default is false.
	*   30. extraInfo:String            - [Optional] Extra info to show on InfoPanel. This value will be used if extraInfo value is empty in mediaObj. Default is empty.
	*   31. videoQuality:String         - [Optional] Only required for Youtube Embeded Player streaming. Quality to play. This value will be used if videoQuality value is empty in mediaObj. Default is medium. Available value: small, medium, large, hd720, hd1080.
	*   32. startPlayCB:Function        - [Optional] callback function that will be called before start play a media. Player will not auto start playback if this callback function is set. Arguments :
	*       a. obj:Object               - an object which content:
	*          i.   currentMediaIndex:Number  - current media index on the playlist.
	*          ii.  mediaObj:Array            - same as the original playerObj.mediaObj. 
	*   33. disableBackKey:Boolean      - [Optional] Disable BACK Key code to stop playback. Default is false.
	*   34. enableZoom:Boolean          - [Optional] Zoom video. Increase 50 percent for each time zoom key on press.(for playMode=3 only). Default is false.
	*   35. playlistHLStopCB:Function   - [Optional] callback function that will be called when highlight stop on playlist. Arguments :
	*       a. obj:Object               - an object which content :
	*          i.   mediaIndex:Number   - current media index on the playlist.
	*          ii.  mediaObj:Array      - same as the original playerObj.mediaObj.
	*   36. autoHideInfobar:Number      - auto hide infobar after value for this parameter which in millisecond.
	*   37. resumeFrom:Number           - same as startFrom except it will start playback from beginning and seek to value of this parameter. Default is 0.
	*   38. enableUpDownSkip:Boolean	- Remote control up key perform skip to previous media file and down key perform skip to next media file.
	*   39. enableTrickAsSeek:Boolean   - perform remote control key "REV" and "FWD" same as key "LEFT" and "RIGTH" which will seek 30 seconds.
	*   40. isDownloadSpeedInByte:Boolean   - download speed return in unit byte. Default is in bit.
	*   41. **showVideoBitrate:Boolean - true to show Video Bitrate in info panel. Default is false.
	*   42. ** enableAudioSwitch:Boolean    - true to checking available audio track for the video. Default is false.
	*   43. totalRetryCount:Number      - total retry count when retryInterval not empty or zero. Default is unlimited retry.
	*   44. disableOtherMediaIcon:Boolean   - true to hide the icon on status bar during next/previous media file. Default is false.
	*
	* (> is required. The rest are all optional.)
	* (* this feature may not be available, because some media may not support the feature.)
	* (** this feature may not be available, because some firmware may not support the feature.)
	*
	*  InfoPanel layout:
	*     - Player Ver.
	*     - [Optional] Download Speed
	*     - [Optional] Video Quality
	*     - [Optional] Extra Information
	*     - [Optional] Runtime Information
	*/
	public function startPlayback(playerMC:MovieClip, playerObj:Object):Void
	{
		this.playerMC = playerMC;
		this.playerObj = playerObj;
		this.playerMC._lockroot = true;

		var playerPath:String = PlayerMain.getFullPath(playerObj.parentPath) + "player.swf"

		var playerMCLoader:MovieClipLoader = new MovieClipLoader();
		playerMCLoader.addListener(this.playerListener);
		playerMCLoader.loadClip(playerPath, playerMC);
	}

	/*
	* This function will return player version.
	*/
	public function getPlayerVersion():String
	{
		return this.playerMC.getPlayerVersion();
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
		return this.playerMC.getCurrentPlaybackInfo();
	}

	/*
	* To update the current playlist in the currently running player.
	*
	* mediaObj: same structure with the playerObj.mediaObj when calling to the startPlayback.
	* currentIndex: new current media index starting from 0.
	*/
	public function updatePlaylist(mediaObj:Array, currentIndex:Number):Void
	{
		this.playerMC.updatePlaylist(mediaObj, currentIndex);
	}

	/*
	* To update the runtime information to show on InfoPanel.
	*
	* runtimeInfo:String.
	*/
	public function updateRuntimeInfo(runtimeInfo:String):Void
	{
		this.playerMC.updateRuntimeInfo(runtimeInfo);
	}

	/*
	* To update the media object base on media ID.
	*
	* id:Number - media id.
	* o:Object  - an object for single media.
	*       a. title:String          - Video Title.
	*       b. url:String            - Video URL. (For playMode 5, is Youtube video ID)
	*       c. info:String           - [Optional] Extra info to show on playlist.
	*       d. serverUrl:String      - Only required for Netstream RTMP streaming (i.e. when playMode=1).
	*       e. playMode:Number       - [Optional] If empty, will use default playMode. 1=Adobe Netstream, 2=Native POD, 3=Native VOD, 4=Native AOD, 5=Youtube Embeded Player, 6=Flash POD, 7=Adobe Sound
	*       f. subtitle:Array        - [Optional] List of object which content info for subtitle.
	*          i.   startTime:Number        - start time to display this content.
	*          ii.  subtitleDuration:Number - duration to display this content.
	*          iii. content:String          - subtitle text.
	*       g. subtitleTimeOffset:Number    - [Optional] Only required if subtitle not null. Time offset to start subtitle.
	*       h. **prebuf:Number       - [Optional] Video pre-buffering size. Only required for Native VOD streaming (i.e. when playMode=3).
	*       i. videoQuality:String   - [Optional] Only required for Youtube Embeded Player streaming. Quality to play. Default is medium. Available value: small, medium, large, hd720, hd1080.
	*       j. extraInfo:String      - [Optional] Extra info to show on InfoPanel.
	*       k. ...                   - you can add any extra property (e.g. 'id'), so it can be passed back to your callback functions.
	*/
	public function updateMediaObj(id:Number, o:Object):Void
	{
		this.playerMC.updateMediaObj(id, o);
	}

	/*
	* To stop playback (same function as PLAYER.stop(), backward compatible.)
	*/
	public function stopPlayback():Void
	{
		this.playerMC.stopPlayback();
	}

	/*
	* To stop playback (same function as PLAYER.pause() and PLAYER.resume(), backward compatible.)
	*
	* doPause:Boolean - true to pause, false to resume.
	*/
	public function pausePlayback(doPause:Boolean):Void
	{
		this.playerMC.pausePlayback(doPause);
	}

	/*
	* To start playback base on media ID.
	*
	* id:Number.
	*/
	public function play(id:Number):Void
	{
		this.playerMC.play(id);
	}

	/*
	* To switch audio for current playback media. If no audio track available, will show invalid action OSD.
	*/
	public function switchAudio():Void
	{
		this.playerMC.switchAudio();
	}

	/*
	* To resume current playback media.
	*/
	public function resume():Void
	{
		this.playerMC.resume();
	}

	/*
	* To pause current playback media.
	*/
	public function pause():Void
	{
		this.playerMC.pause();
	}

	/*
	* To stop current playback media.
	*/
	public function stop():Void
	{
		this.playerMC.stop();
	}

	/*
	* To seek current playback media.
	*
	* time:Number - target time to seek.
	*/
	public function seek(time:Number):Void
	{
		this.playerMC.seek(time);
	}

	/*
	* To next current playback media.
	*/
	public function next():Void
	{
		this.playerMC.next();
	}

	/*
	* To previous current playback media.
	*/
	public function previous():Void
	{
		this.playerMC.previous();
	}

	/*
	* To disable key listener for player.
	*/
	public function disableKeyListener():Void
	{
		this.playerMC.disableKeyListener();
	}

	/*
	* To enable key listener for player.
	*/
	public function enableKeyListener():Void
	{
		this.playerMC.enableKeyListener();
	}

	private function playerError(targetMC:MovieClip, errorCode:String, httpStatus:Number):Void
	{
		trace("targetMC " + targetMC);
		trace("errorCode " + errorCode);
		trace("httpStatus " + httpStatus);
	}

	private function playerLoaded(targetMC:MovieClip):Void
	{
		targetMC.startPlayback(this.playerObj);
		// var obj:Object = targetMC.stopPlayback();
		// trace(targetMC.getPlayerVersion());
	}

	private static function getFullPath(path:String):String
	{
		var pathLen:Number = path.lastIndexOf("/", path.length) + 1;
		return path.substring(0, pathLen);
	}
}