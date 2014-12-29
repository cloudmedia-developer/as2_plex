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
* Class Description: Share item among the app
***************************************************/

import com.syabas.as2.plex.api.API;
import com.syabas.as2.plex.component.ComponentUtils;
import com.syabas.as2.plex.manager.ConfigLoaderManager;
import com.syabas.as2.plex.manager.KeyboardManager;
import com.syabas.as2.plex.manager.PopupManager;
import com.syabas.as2.plex.manager.PlaybackManager;
import com.syabas.as2.plex.model.ContainerModel;
import com.syabas.as2.plex.model.MediaModel;

import com.syabas.as2.common.IMGLoader;
import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.Util;

class com.syabas.as2.plex.Share
{	
	/************************************************************************
	 * Content of Shared Object:
	 * 1. gateway:String			- The last used gateway 
	 * 2. token:String 				- My Plex Authentication Token
	 * 3. useNativePlayer:Boolean	- Setting value
	 * 4. hideBG:Boolean			- Setting value
	 * 5. movieDisplayType:Number	- The display layout for movie
	 * 6. tvShowDisplayType:Number	- The display layout for TV Show
	 * 7. useSMB:Boolean			- Setting value
	 * 8. config:Object				- The config object
	 ************************************************************************/
	
	public static var MOVIE_DISPLAY_TYPE_INFO:Number = 0;
	public static var MOVIE_DISPLAY_TYPE_WALL:Number = 1;
	public static var MOVIE_DISPLAY_TYPE_LIST:Number = 2;
	public static var MOVIE_DISPLAY_TYPE_WALL_WITH_TITLE:Number = 3;
	
	public static var TV_SHOW_DISPLAY_TYPE_INFO:Number = 0;
	public static var TV_SHOW_DISPLAY_TYPE_WALL:Number = 1;
	public static var TV_SHOW_DISPLAY_TYPE_LIST:Number = 2;
	public static var TV_SHOW_DISPLAY_TYPE_WALL_WITH_TITLE:Number = 3;
	public static var TV_SHOW_DISPLAY_TYPE_BANNER:Number = 4;
	
	public static var MOVIE_DISPLAY_ARRAY:Array = [ { type:MOVIE_DISPLAY_TYPE_WALL, key:"indicator_switch_wall" }, { type:MOVIE_DISPLAY_TYPE_INFO, key:"indicator_switch_info" }, { type:MOVIE_DISPLAY_TYPE_LIST, key:"indicator_switch_list" }, { type:MOVIE_DISPLAY_TYPE_WALL_WITH_TITLE, key:"indicator_switch_wall_with_title" } ];
	public static var TV_DISPLAY_ARRAY:Array = [ { type:TV_SHOW_DISPLAY_TYPE_WALL, key:"indicator_switch_wall" }, { type:TV_SHOW_DISPLAY_TYPE_BANNER, key:"indicator_switch_banner" }, { type:TV_SHOW_DISPLAY_TYPE_INFO, key:"indicator_switch_info" }, { type:TV_SHOW_DISPLAY_TYPE_LIST, key:"indicator_switch_list" }, { type:TV_SHOW_DISPLAY_TYPE_WALL_WITH_TITLE, key:"indicator_switch_wall_with_title" } ];
	
	//--------------------------------- My Plex ------------------------------------
	public static var CLIENT_IDENTIFIER:String = "abc1234";
	public static var CLIENT_PRODUCT:String = "Plex for Popcorn Hour";
	public static var CLIENT_PLATFORM:String = "Popcorn Hour";
	public static var CLIENT_DEVICE:String = "";
	public static var CLIENT_VERSION:String = "1.0.2";
	
	public static var MY_PLEX_BASE_URL:String = "https://my.plexapp.com";
	public static var MY_PLEX_TOKEN:String = null;
	
	//------------------------------ Runtime Assignment ---------------------------
	public static var appSO:SharedObject = null;
	public static var useNativePlayer:Boolean = true;
	public static var systemGateway:String = null;
	public static var APP_LOCATION_URL:String = null;
	public static var APP_SETTING:Object = null;
	public static var PLUGIN_FILTER_LIST:Array = null;
	public static var BOARD_TYPE:String = null;
	public static var FIRMWARE_DATE:Number = null;
	public static var PLAYBACK_CONFIG:Object = null;
	public static var hideBG:Boolean = false;
	public static var movieDisplayType:Number = 1;
	public static var tvShowDisplayType:Number = 1;
	
	public static var movieDisplayToChange:Number = null;				// Temporary type
	public static var tvShowDisplayToChange:Number = null;				// Temporary type
	
	public static var useSMB:Boolean = true;
	
	//------------------------------------------ Configuration ------------------------------
	public static var FANART_SWITCH_TIME:Number = 10000;
	public static var LAYOUT_DATA_PRELOAD_SIZE:Number = 50;
	public static var SEPARATOR_CHARACTER:String = "\u2022";
	
	public static var WEBKIT_BITRATE:Number = 3000; 			// { "64", "96", "208", "320", "720", "1500", "2000", "3000", "4000", "8000", "10000", "12000", "20000", "40000" };
	public static var WEBKIT_QUALITY:Number = 75;				// { "10", "20", "30", "30", "40", "60", "60", "75", "100", "60", "75", "90", "100", "100" };
	public static var WEBKIT_VIDEO_WIDTH:Number = 1280;			// { "220x180", "220x128", "284x160", "420x240", "576x320", "720x480", "1024x768", "1280x720", "1280x720", "1920x1080", "1920x1080", "1920x1080", "1920x1080", "1920x1080" };
	public static var WEBKIT_VIDEO_HEIGHT:Number = 720;
	
	//----------------------------------- Manager ------------------------------
	public static var KEYBOARD:KeyboardManager = null;
	public static var POPUP:PopupManager = null;
	public static var PLAYER:PlaybackManager = null;
	public static var CONFIG_LOADER:ConfigLoaderManager = null;
	public static var imageLoader:IMGLoader = null;
	public static var api:API = null;
	
	public static function init():Void
	{
		api = new API();
		imageLoader = new IMGLoader(5);
		initStringMap();
	}
	
	public static function saveSharedObject():Void
	{
		appSO.data.gateway = systemGateway;
		appSO.data.token = MY_PLEX_TOKEN;
		appSO.data.useNativePlayer = useNativePlayer;
		appSO.data.hideBG = hideBG;
		appSO.data.useSMB = useSMB;
		appSO.data.movieDisplayType = movieDisplayType;
		appSO.data.tvShowDisplayType = tvShowDisplayType;
		
		appSO.flush();
	}
	
	public static function initCapability():Void
	{
		// For future if any capability of board need to change
	}
	
	
	//---------------------------------------------- Util -------------------------------------------
	public static function getResourceURL(path:String):String
	{
		if (path.charAt(0) == "/")
		{
			return systemGateway + (Util.endsWith(systemGateway, "/") ? "" : "/") + (Util.startsWith(path, "/") ? path.substring(1) : path);
		}
		else
		{
			return path;
		}
	}
	
	public static function getPhotoTranscodeURL(url:String, width:Number, height:Number):String
	{
		return systemGateway + (Util.endsWith(systemGateway, "/") ? "" : "/") + "photo/:/transcode?width=" + width + "&height=" + height + "&url=" + escape(url) + "&upscale=1";
	}
	
	private static var stringMap:Object = null;
	private static var languageMap:Object = null;
	
	private static function initStringMap():Void
	{
		stringMap = new Object();
		
		stringMap.exit = "Exit";
		stringMap.back = "Back";
		stringMap.backToHome = "Home";
		
		stringMap.on_deck = "On Deck";
		stringMap.recently_added = "Recently Added";
		stringMap.recently_used = "Recently Used";
		stringMap.video_channel = "Video Channels";
		stringMap.music_channel = "Music Channels";
		stringMap.photo_channel = "Photo Channels";
		stringMap.my_queue = "My Queue";
		stringMap.logout = "Logout";
		stringMap.login = "Login";
		stringMap.search = "Search";
		stringMap.plex_online = "Channel Directory";
		stringMap.preference_setting = "Preference";
		
		stringMap.movie = "Movies";
		stringMap.tv_show = "TV Shows";
		stringMap.episode = "Episodes";
		stringMap.artist = "Artists";
		stringMap.album = "Albums";
		stringMap.track = "Tracks";
		stringMap.actor = "Actors";
		
		stringMap.item_count_movie = "Movie";
		stringMap.item_count_track = "Song";
		stringMap.item_count_album = "Album";
		stringMap.item_count_photo = "Photo";
		stringMap.item_count_episode = "Episode";
		stringMap.item_count_show = "TV Show";
		stringMap.item_count_artist = "Artist";
		stringMap.item_count_season = "Season";
		stringMap.item_count_file = "File";
		stringMap.item_count_object = "Object";
		
		stringMap.episode_count_format = "<FONT COLOR='#FF9B26'>Season |SEASON_NUMBER|, Episode |EPISODE_NUMBER| : </FONT>|EPISODE_TITLE|";
		stringMap.season_count_format = "|TOTAL_EPISODE_COUNT| Episodes / |UNWATCHED_EPISODE_TITLE| Unwatched";
		
		stringMap.search_episode_count_format = "Seaason |SEASON_NUMBER| Episode |EPISODE_NUMBER|";
		
		stringMap.movie_label_director = "Director";
		stringMap.movie_label_writer = "Writer";
		stringMap.movie_label_cast = "Cast";
		
		stringMap.show_label_air_date = "First Aired";
		stringMap.show_label_genre = "Genre";
		stringMap.show_label_duration = "Duration";
		stringMap.show_label_episode = "Episode";
		stringMap.show_label_watched = "Watched";
		stringMap.show_label_unwatched = "Unwatched";
		
		stringMap.resume_from_bookmark = "Resume from |TIME|";
		stringMap.start_from_beginning = "Start from beginning";
		
		stringMap.btn_ok = "OK";
		stringMap.btn_cancel = "Cancel";
		stringMap.btn_default = "Default";
		stringMap.btn_new_code = "New Code";
		
		stringMap.selection_popup_title = "Menu";
		
		stringMap.error_no_data_title = "No Data Found";
		stringMap.error_no_data = "No data was found in this directory.";
		
		stringMap.error_no_connection_title = "Cannot Connect To Server";
		stringMap.error_no_connection = "We are currently unable to connect to the server. Please try again later.";
		
		stringMap.error_unknown_title = "Unknown Error";
		stringMap.error_unknown = "Unknown error has occurred.";
		
		stringMap.error_no_play_link_title = "No Playback URL";
		stringMap.error_no_play_link = "No Playback URL can be found.";
		
		stringMap.login_instruction = "Please login to <FONT COLOR='#FF9B26' SIZE='31'>https://my.plexapp.com/pin</FONT> and enter below";
		
		stringMap.logout_confirmation_title = "Logout";
		stringMap.logout_confirmation = "You are about to remove access to your myPlex account. Do you want to continue?";
		
		stringMap.logout_done_title = "Logout Completed";
		stringMap.logout_done = "Access to your myPlex account is removed. Please visit <FONT COLOR='#FF9B26'>https://my.plexapp.com/devices</FONT> to completely revoke the granted access.";
		
		stringMap.preference_label_server_address = "Media Server IP Address";
		stringMap.preference_label_server_port = "Media Server Port";
		stringMap.preference_label_native_player = "Use Native Player";
		stringMap.preference_label_disable_bg = "Disable Background Image";
		stringMap.preference_label_use_smb = "Use SMB Path";
		stringMap.preference_label_config = "Configuration File";		// new
		
		stringMap.indicator_mark_watched = "Mark as Watched";
		stringMap.indicator_mark_unwatched = "Mark as Unwatched";
		stringMap.indicator_switch_info = "Info Panel";
		stringMap.indicator_switch_list = "Info List";
		stringMap.indicator_switch_wall = "Wall View";
		stringMap.indicator_switch_wall_with_title = "Wall View With Title";
		stringMap.indicator_switch_banner = "Banner View";
		stringMap.indicator_switch_layout = "Switch Layout";
		
		
		stringMap.message_mark_watched = "Are you sure you want to mark all episodes as watched?\n(NOTE: All resume time will be removed)";
		stringMap.message_mark_unwatched = "Are you sure you want to mark all episodes as unwatched?\n(NOTE: All resume time will be removed)";
		
		stringMap.error_cannot_connect_media_server_title = "Cannot Connect to Media Server";
		stringMap.error_cannot_connect_media_server = "We are currently unable to connect to Media Server. Please confirm the server address and port is correct.";
		
		stringMap.no_data = "No Data";
		stringMap.loading = "Loading...";
		stringMap.showHideTitle = "Show/Hide Title";
		stringMap.showInfo = "Show Info";
		stringMap.closeInfo = "Close Info";
		stringMap.close = "Close";		// new
		
		stringMap.choose_config = "Choose Configuration Folder";
		stringMap.test_config = "Test Current Configuration";
		
		stringMap.config_load_error_title = "Unable to Load Configuration";
		stringMap.config_load_error = "Unable to load configuration file.";
		stringMap.test_config_title = "Test Configuration (UP / DOWN to scroll)";
		stringMap.test_config_replace_item = "Replace From: |FROM_PATH|, To: |TO_PATH|";
		stringMap.test_config_server_item = "Login Server Path: |SERVER_PATH|";
		stringMap.test_config_result = "Result: |RESULT|";
		stringMap.test_config_success = "SUCCESS";
		stringMap.test_config_error = "ERROR |ERROR_CODE|";
		stringMap.test_config_error_timeout = "Timeout";
		stringMap.test_config_error_not_real_path = "Skipped. Path not recognized. Path should start with \"smb://\" or \"nfs://\".";	// new
		stringMap.test_config_error_901 = "Access Denied (901)";
		stringMap.test_config_error_904 = "Failed to resolve host name (904)";
		stringMap.test_config_error_905 = "Share not exist (905)";
		stringMap.test_config_error_910 = "Login required (910)";
		stringMap.test_config_error_912 = "Host is unreachable (912)";
	}
	
	public static function loadLanguageFile(path:String):Void
	{
		Util.loadURL(path, onLoadLanguage, { target:"loadvars" });
	}
	
	private static function onLoadLanguage(success:Boolean, data:Object, o:Object):Void
	{
		if (success)
		{
			languageMap = data;
		}
	}
	
	public static function getString(key:String):String
	{
		var result:String = languageMap[key];
		
		if (result == null || result == undefined)
		{
			result = stringMap[key];
			if (result == null || result == undefined)
			{
				return "";
			}
		}
		
		return result;
	}
	
	public static function returnStringForDisplay(str:String):String
	{
		if (Util.isBlank(str))
		{
			return "";
		}
		
		return str;
	}
	
	public static function convertTime(timeInMillis:Number):String
	{
		var _timeInMillis:Number = new Number(timeInMillis);
		if (isNaN(_timeInMillis))
		{
			return "";
		}
		
		var seconds:Number = Math.floor(_timeInMillis / 1000);
		var minutes:Number = Math.floor(seconds / 60);
		var hours:Number = Math.floor(minutes / 60);
		
		seconds %= 60;
		minutes %= 60;
		
		var result:String = "";
		if (hours > 0)
		{
			result += hours + ":";
		}
		if (minutes > 9 || hours == 0)
		{
			result += minutes + ":";
		}
		else if (minutes > 0)
		{
			result += "0" + minutes + ":";
		}
		
		if (seconds > 9)
		{
			result += seconds + "";
		}
		else
		{
			result += "0" + seconds;
		}
		
		return result;
	}
	
	public static function loadThumbnail(id:String, thumbnailMC:MovieClip, url:String, config:Object, valign:Number, halign:Number):Void
	{
		if (thumbnailMC == null || thumbnailMC == undefined)
		{
			return;
		}
		if (valign == null || valign == undefined)
		{
			valign = 1;
		}
		if (halign == null || halign == undefined)
		{
			halign = 2;
		}
		
		var thumbMC:MovieClip = thumbnailMC.mc_thumb;
		Share.imageLoader.unload(id, thumbMC);
		
		thumbMC.removeMovieClip();
		thumbMC = thumbnailMC.createEmptyMovieClip("mc_thumb", thumbnailMC.getNextHighestDepth());
		
		url = Share.getPhotoTranscodeURL(url, config.width + 40, config.height + 40);
		
		Share.imageLoader.load(id, Share.getResourceURL(url), thumbMC, { scaleMode:4, scaleProps: { actualSizeOption:4, width:config.width, height:config.height }, valign:valign, halign:halign } );
		
	}
	
	public static function loadMediaTag(mc:MovieClip, tagMC:MovieClip, url:String, config:Object, valign:Number, halign:Number):Void
	{
		if (tagMC == null || tagMC == undefined)
		{
			return;
		}
		
		if (valign == null || valign == undefined)
		{
			valign = 2;
		}
		if (halign == null || halign == undefined)
		{
			halign = 2;
		}
		
		var _tagMC:MovieClip = tagMC.mc_tag;
		Share.imageLoader.unload(mc._name, _tagMC);
		
		_tagMC.removeMovieClip();
		_tagMC = tagMC.createEmptyMovieClip("mc_tag", tagMC.getNextHighestDepth());
		
		url = Share.getPhotoTranscodeURL(url, config.width, config.height);
		Share.imageLoader.load(mc._name, Share.getResourceURL(url), _tagMC, { scaleMode:1, scaleProps: { actualSizeOption:1, width:config.width, height:config.height }, valign:halign, halign:valign } );
		
	}
	
	public static function createMask(mc:MovieClip, thumbnailMC:MovieClip, config:Object):Void
	{
		if (config == null || config == undefined || mc == null || mc == undefined || thumbnailMC == null || thumbnailMC == undefined)
		{
			return;
		}
		var maskMC:MovieClip = mc.createEmptyMovieClip("mc_thumbnailMaskFor_" + thumbnailMC._name, mc.getNextHighestDepth());
		
		ComponentUtils.drawRect(maskMC, { x:thumbnailMC._x, y:thumbnailMC._y, width:config.width, height:config.height, roundness:config.radius }, null, { color:0xFFFFFF, alpha:100 } );
		
		thumbnailMC.setMask(maskMC);
	}
	
	public static function startMarquee(marquee:Marquee, tf:TextField, config:Object):Void
	{
		marquee.start(tf, { delayInMillis:config.delay, endGap:config.endGap, vertical:(config.vertical == true), framePerMove:config.framePerStep, stepPerMove:config.step } );
	}
	
	public static function getPaginationKey(key:String, startIndex:Number, numberOfLoad:Number):String
	{
		if (key.indexOf("?") > 0)
		{
			key += "&";
		}
		else
		{
			key += "?";
		}
		
		key += "X-Plex-Container-Start=" + startIndex + "&X-Plex-Container-Size=" + numberOfLoad;
		
		return key;
	}
	
	public static function getMediaTagURL(container:ContainerModel, tagType:String, tagValue:String):String
	{
		var version:String = container.mediaTagVersion;
		var tagPrefix:String = container.mediaTagPrefix;
		if (Util.startsWith(tagPrefix, "/"))
		{
			tagPrefix = tagPrefix.substring(1);
		}
		
		var url:String = systemGateway + (Util.endsWith(systemGateway, "/") ? "" : "/") + tagPrefix + (Util.endsWith(tagPrefix, "/") ? "" : "/") + tagType + "/" + tagValue + "?t=" + version;
		
		return url;
	}
	
	public static function getVideoTranscodeURL(url:String, quality:Number, bitrate:Number, width:Number, height:Number, webkit:Boolean, otherParams:String):String
	{
		return systemGateway + (Util.endsWith(systemGateway, "/") ? "" : "/") + "video/:/transcode/universal/start.m3u8?protocol=hls&videoResolution=" + width + "x" + height + "&directStream=1" + 
			"&maxVideoBitrate=" + bitrate + "&subtitleSize=100&videoQuality=" + quality + "&fastSeek=1&session=" + escape(CLIENT_IDENTIFIER) + "&path=" + escape(url) + "&audioBoost=100&directPlay=0" + 
			"&X-Plex-Platform-Version=" + escape(CLIENT_VERSION) + "&X-Plex-Product=" + escape(CLIENT_PRODUCT) + "&X-Plex-Platform=" + escape(CLIENT_PLATFORM) + "&X-Plex-Device=" + escape(CLIENT_DEVICE)
			+ (webkit == true ? "&webkit=1" : "") + (Util.isBlank(otherParams) ? "" : otherParams);;
	}
	
	public static function isPluginDisabled(plugin:MediaModel, type:Number):Boolean
	{
		var id:String = Util.replaceAll(plugin.identifier, ".", "_");
		var flag:String = PLUGIN_FILTER_LIST[type][id];
		
		if (Util.isBlank(flag))
		{
			return false;
		}
		
		if (flag.toLowerCase() == "all")
		{
			return true;
		}
		
		if (flag.indexOf(BOARD_TYPE) > -1)
		{
			if (Util.startsWith(flag, "all but"))
			{
				return false;
			}
			else
			{
				return true;
			}
			//return true;
		}
		else
		{
			
			if (Util.startsWith(flag, "all but"))
			{
				return true;
			}
			else
			{
				return false;
			}
			
			return false;
		}
		
	}
	
	public static function stripServerAddress(gateway:String):String
	{
		if (Util.isBlank(gateway))
		{
			return "";
		}
		
		if (Util.startsWith(gateway, "http://"))
		{
			gateway = gateway.substring(7);
		}
		else if (Util.startsWith(gateway, "https://"))
		{
			gateway = gateway.substring(8);
		}
		
		if (Util.endsWith(gateway, "/"))
		{
			gateway = gateway.substring(0, gateway.length - 1);
		}
		
		var indexOfColon:Number = gateway.indexOf(":");
		if (indexOfColon < 0)
		{
			indexOfColon = gateway.length - 1;
		}
		
		gateway = gateway.substring(0, indexOfColon);
		
		return gateway;
	}
	
	public static function stripServerPort(gateway:String):String
	{
		if (Util.isBlank(gateway))
		{
			return "32400";
		}
		
		if (Util.startsWith(gateway, "http://"))
		{
			gateway = gateway.substring(7);
		}
		else if (Util.startsWith(gateway, "https://"))
		{
			gateway = gateway.substring(8);
		}
		
		if (Util.endsWith(gateway, "/"))
		{
			gateway = gateway.substring(0, gateway.length - 1);
		}
		
		var indexOfColon:Number = gateway.indexOf(":");
		
		if (indexOfColon < 0)
		{
			return "";
		}
		else
		{
			return gateway.substring(indexOfColon + 1);
		}
	}
	
	public static function alignIndicators(indicators:Array):Void
	{
		var config:Object =  Share.APP_SETTING.indicatorAlign;
		var align:String = config.align.toLowerCase();
		var hgap:Number = config.hgap;
		var xLimit:Number = config.xLimit;
		var startingX:Number = 0;
		var startingY:Number = indicators[0]._y;
		
		if (isNaN(new Number(hgap)))
		{
			hgap = 5;
		}
		
		if (isNaN(new Number(xLimit)))
		{
			xLimit = (align == "right" ? 1190 : 90);
		}
		
		if (align == "right")
		{
			indicators.reverse();
			
			var totalWidth:Number = 0;
			var len:Number = indicators.length;
			
			for (var i:Number = 0; i < len; i ++)
			{
				totalWidth += indicators[i]._width;
				
				if (i < len - 1)
				{
					totalWidth += hgap;
				}
			}
			
			startingX = xLimit - totalWidth;
		}
		else
		{
			startingX = xLimit;
		}
		
		ComponentUtils.alignComponents(indicators, { startingX:startingX, startingY:startingY, hgap:hgap, itemPerLine:indicators.length } );
	}
}
