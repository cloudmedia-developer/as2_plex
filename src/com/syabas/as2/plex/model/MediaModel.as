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
* Class Description: Media
*
***************************************************/

import com.syabas.as2.plex.model.ModelBase;
import com.syabas.as2.plex.model.MediaElement;

class com.syabas.as2.plex.model.MediaModel extends ModelBase
{
	public static var CONTENT_TYPE_MOVIE:String = "movie";
	public static var CONTENT_TYPE_ARTIST:String = "artist";
	public static var CONTENT_TYPE_ALBUM:String = "album";
	public static var CONTENT_TYPE_PHOTO:String = "photo";
	public static var CONTENT_TYPE_SHOW:String = "show";
	public static var CONTENT_TYPE_SEASON:String = "season";
	public static var CONTENT_TYPE_EPISODE:String = "episode";
	public static var CONTENT_TYPE_PLUGIN:String = "plugin";
	public static var CONTENT_TYPE_TRACK:String = "track";
	public static var CONTENT_TYPE_PERSON:String = "person";
	
	public static var TYPE_VIDEO:Number = 0;
	public static var TYPE_TRACK:Number = 1;
	public static var TYPE_PHOTO:Number = 2;
	public static var TYPE_DIRECTORY:Number = 3;
	public static var TYPE_OTHER:Number = 99;
	
	public var parentTitle:String = null;
	public var grandParentTitle:String = null;
	
	public var art:String = null;
	public var thumbnail:String = null;
	public var banner:String = null;
	public var parentThumbnail:String = null;
	public var grandParentThumbnail:String = null;
	public var summary:String = null;
	public var type:String = null;
	
	public var studio:String = null;
	public var contentRating:String = null;
	public var rating:Number = null;
	public var year:Number = null;
	public var index:Number = 0;
	public var parentIndex:Number = 0;
	public var childCount:Number = null;
	public var viewedChildCount:Number = null;
	
	public var media:Array = null;
	public var genre:Array = null;
	public var writer:Array = null;
	public var director:Array = null;
	public var role:Array = null;
	public var country:Array = null;
	
	public var itemType:Number = null;
	
	public var isPopup:Boolean = false;
	public var isSetting:Boolean = false;
	public var isSearch:Boolean = false;
	
	public var size:Number = null;
	
	public var duration:Number = null;
	public var viewOffset:Number = 0;
	public var originalAirDate:String = null;
	public var viewCount:Number = 0;
	public var prompt:String = null;
	
	public var ratingKey:String = null;
	
	public var album:String = null;
	public var artist:String = null;
	public var track:String = null;
	
	public function fromObject(dataObj:Object):Void
	{
		super.fromObject(dataObj);
		
		if (dataObj._elementType == "Video")
		{
			this.itemType = TYPE_VIDEO;
		}
		else if (dataObj._elementType == "Track")
		{
			this.itemType = TYPE_TRACK;
		}
		else if (dataObj._elementType == "Photo")
		{
			this.itemType = TYPE_PHOTO;
		}
		else if (dataObj._elementType == "Directory" || dataObj._elementType == "Artist" || dataObj._elementType == "Album" || dataObj._elementType == "Genre" || dataObj._elementType == "Playlist" || dataObj._elementType == "Podcast")
		{
			this.itemType = TYPE_DIRECTORY;
		}
		else
		{
			this.itemType = TYPE_OTHER;
		}
		
		this.readMediaAttributes(dataObj);
		
		if (dataObj._children != null && dataObj._children != undefined && dataObj._children.length > 0)
		{
			var mediaArray:Array = new Array();
			var genreArray:Array = new Array();
			var writerArray:Array = new Array();
			var countryArray:Array = new Array();
			var directorArray:Array = new Array();
			var roleArray:Array = new Array();
			
			var size:Number = dataObj._children.length;
			var child:Object = null;
			var _media:MediaElement = null;
			for (var i:Number = 0; i < size; i ++ )
			{
				child = dataObj._children[i];
				if (child._elementType == "Media")
				{
					_media = new MediaElement();
					_media.fromObject(child);
					
					mediaArray.push(_media);
				}
				if (child._elementType == "Genre")
				{
					genreArray.push(child.tag.toString());
				}
				if (child._elementType == "Writer")
				{
					writerArray.push(child.tag.toString());
				}
				if (child._elementType == "Country")
				{
					countryArray.push(child.tag.toString());
				}
				if (child._elementType == "Director")
				{
					directorArray.push(child.tag.toString());
				}
				if (child._elementType == "Role")
				{
					roleArray.push(child.tag.toString());
				}
			}
			
			if (mediaArray.length > 0)
			{
				media = mediaArray;
			}
			if (genreArray.length > 0)
			{
				genre = genreArray;
			}
			if (writerArray.length > 0)
			{
				writer = writerArray;
			}
			if (countryArray.length > 0)
			{
				country = countryArray;
			}
			if (directorArray.length > 0)
			{
				director = directorArray;
			}
			if (roleArray.length > 0)
			{
				role = roleArray;
			}
		}
	}
	
	public function fromXML(dataObj:XMLNode):Void
	{
		super.fromXML(dataObj);
		
		if (dataObj.nodeName == "Video")
		{
			this.itemType = TYPE_VIDEO;
		}
		else if (dataObj.nodeName == "Track")
		{
			this.itemType = TYPE_TRACK;
		}
		else if (dataObj.nodeName == "Photo")
		{
			this.itemType = TYPE_PHOTO;
		}
		else if (dataObj.nodeName == "Directory"  || dataObj.nodeName == "Artist" || dataObj.nodeName == "Album" || dataObj.nodeName == "Genre" || dataObj.nodeName == "Playlist" || dataObj.nodeName == "Podcast")
		{
			this.itemType = TYPE_DIRECTORY;
		}
		else
		{
			this.itemType = TYPE_OTHER;
		}
		
		this.readMediaAttributes(dataObj.attributes);
		
		if (dataObj.childNodes != null && dataObj.childNodes != undefined && dataObj.childNodes.length > 0)
		{
			var mediaArray:Array = new Array();
			var genreArray:Array = new Array();
			var writerArray:Array = new Array();
			var countryArray:Array = new Array();
			var directorArray:Array = new Array();
			var roleArray:Array = new Array();
			
			var size:Number = dataObj.childNodes.length;
			var child:XMLNode = null;
			var _media:MediaElement = null;
			for (var i:Number = 0; i < size; i ++ )
			{
				child = dataObj.childNodes[i];
				if (child.nodeName == "Media")
				{
					_media = new MediaElement();
					_media.fromXML(child);
					
					mediaArray.push(_media);
				}
				if (child.nodeName == "Genre")
				{
					genreArray.push(child.attributes.tag.toString());
				}
				if (child.nodeName == "Writer")
				{
					writerArray.push(child.attributes.tag.toString());
				}
				if (child.nodeName == "Country")
				{
					countryArray.push(child.attributes.tag.toString());
				}
				if (child.nodeName == "Director")
				{
					directorArray.push(child.attributes.tag.toString());
				}
				if (child.nodeName == "Role")
				{
					roleArray.push(child.attributes.tag.toString());
				}
			}
			
			if (mediaArray.length > 0)
			{
				media = mediaArray;
			}
			if (genreArray.length > 0)
			{
				genre = genreArray;
			}
			if (writerArray.length > 0)
			{
				writer = writerArray;
			}
			if (countryArray.length > 0)
			{
				country = countryArray;
			}
			if (directorArray.length > 0)
			{
				director = directorArray;
			}
			if (roleArray.length > 0)
			{
				role = roleArray;
			}
		}
	}
	
	private function readMediaAttributes(attributes:Object):Void
	{
		if (attributes.popup == "1" || attributes.popup == 1 )
		{
			isPopup = true;
		}
		
		if (attributes.settings == "1" || attributes.settings == 1)
		{
			isSetting = true;
		}
		
		if (attributes.search == "1" || attributes.search == 1)
		{
			isSearch = true;
		}
		
		if (attributes.type != null && attributes.type != undefined)
		{
			type = attributes.type.toString();
		}
		
		if (attributes.art != null && attributes.art != undefined)
		{
			art = attributes.art.toString();
		}
		
		if (attributes.thumb != null && attributes.thumb != undefined)
		{
			thumbnail = attributes.thumb.toString();
		}
		else if (attributes.sourceIcon != null && attributes.sourceIcon != undefined)
		{
			thumbnail = attributes.sourceIcon.toString();
		}
		
		if (attributes.banner != null && attributes.banner != undefined)
		{
			banner = attributes.banner.toString();
		}
		
		if (attributes.parentThumb != null && attributes.parentThumb != undefined)
		{
			parentThumbnail = attributes.parentThumb.toString();
		}
		
		if (attributes.grandparentThumb != null && attributes.grandparentThumb != undefined)
		{
			grandParentThumbnail = attributes.grandparentThumb.toString();
		}
		
		if (attributes.summary != null && attributes.summary != undefined)
		{
			summary = attributes.summary.toString();
		}
		
		if (attributes.index != null && attributes.index != undefined)
		{
			index = attributes.index.toString();
		}
		
		if (attributes.parentIndex != null && attributes.parentIndex != undefined)
		{
			parentIndex = attributes.parentIndex.toString();
		}
		
		if (attributes.studio != null && attributes.studio != undefined)
		{
			studio = attributes.studio.toString();
		}
		
		if (attributes.contentRating != null && attributes.contentRating != undefined)
		{
			contentRating = attributes.contentRating.toString();
		}
		
		if (attributes.summary != null && attributes.summary != undefined)
		{
			summary = attributes.summary.toString();
		}
		
		if (attributes.parentTitle != null && attributes.parentTitle != undefined)
		{
			parentTitle = attributes.parentTitle.toString();
		}
		
		if (attributes.grandparentTitle != null && attributes.grandparentTitle != undefined)
		{
			grandParentTitle = attributes.grandparentTitle.toString();
		}
		
		if (attributes.originallyAvailableAt != null && attributes.originallyAvailableAt != undefined)
		{
			originalAirDate = attributes.originallyAvailableAt.toString();
		}
		
		if (attributes.rating != null && attributes.rating != undefined)
		{
			rating = parseFloat(attributes.rating);
		}
		
		if (attributes.year != null && attributes.year != undefined)
		{
			year = parseInt(attributes.year);
		}
		
		if (attributes.leafCount != null && attributes.leafCount != undefined)
		{
			childCount = parseInt(attributes.leafCount);
		}
		
		if (attributes.totalSize != null && attributes.totalSize != undefined)
		{
			size = parseInt(attributes.totalSize);
		}
		else if (attributes.size != null && attributes.size != undefined)
		{
			size = parseInt(attributes.size);
		}
		
		if (attributes.duration != null && attributes.duration != undefined)
		{
			duration = parseInt(attributes.duration);
		}
		else if (attributes.totalTime != null && attributes.totalTime != undefined)
		{
			duration = parseInt(attributes.totalTime);
		}
		
		if (attributes.viewOffset != null && attributes.viewOffset != undefined)
		{
			viewOffset = parseInt(attributes.viewOffset);
		}
		
		if (attributes.viewCount != null && attributes.viewCount != undefined)
		{
			viewCount = parseInt(attributes.viewCount);
		}
		
		if (attributes.viewedLeafCount != null && attributes.viewedLeafCount != undefined)
		{
			viewedChildCount = parseInt(attributes.viewedLeafCount);
		}
		
		if (attributes.prompt != null && attributes.prompt != undefined)
		{
			prompt = attributes.prompt.toString();
		}
		
		if (attributes.ratingKey != null && attributes.ratingKey != undefined)
		{
			ratingKey = attributes.ratingKey.toString();
		}
		else if (attributes.key != null && attributes.key != undefined)
		{
			ratingKey = attributes.key.toString();
		}
	}
}