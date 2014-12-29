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
* Class Description: Container
*
***************************************************/
import com.syabas.as2.plex.model.MediaModel;
import com.syabas.as2.plex.model.SettingModel;

class com.syabas.as2.plex.model.ContainerModel extends MediaModel
{
	public static var VIEW_GROUP_MOVIE:String = "movie";
	public static var VIEW_GROUP_ARTIST:String = "artist";
	public static var VIEW_GROUP_ALBUM:String = "album";
	public static var VIEW_GROUP_TRACK:String = "track";
	public static var VIEW_GROUP_SONG:String = "songs";
	public static var VIEW_GROUP_TV_SHOW:String = "show";
	public static var VIEW_GROUP_TV_SEASON:String = "season";
	public static var VIEW_GROUP_TV_EPISODE:String = "episode";
	public static var VIEW_GROUP_PHOTO:String = "photo";
	
	public static var CONTENT_PLUGIN:String = "plugins";
	
	public var viewGroup:String = null;
	public var contentType:String = null;
	public var content:String = null;
	public var title1:String = null;
	public var title2:String = null;
	
	public var mediaTagPrefix:String = null;
	public var mediaTagVersion:String = null;
	
	public var items:Array = null;
	public var header:String = null;
	public var message:String = null;
	
	public var identifier:String = null;
	public var offset:Number = 0;
	public var mixedParents:Boolean = false;
	
	public var externalTitle:String = null;
	
	public function fromObject(dataObj:Object):Void
	{
		super.fromObject(dataObj);
		this.readContainerAttributes(dataObj);
		
		var _items:Array = new Array();
		
		if (dataObj._children != null && dataObj._children != undefined && dataObj._children.length > 0)
		{
			var size:Number = dataObj._children.length;
			var child:Object = null;
			var item:MediaModel = null;
			var setting:SettingModel = null;
			for (var i:Number = 0; i < size; i ++ )
			{
				child = dataObj._children[i];
				if (child._elementType == "Setting")
				{
					setting = new SettingModel();
					setting.fromObject(child);
					
					_items.push(setting);
				}
				else
				{
					item = new MediaModel();
					item.fromObject(child);
				
					_items.push(item);
				}
			}
			
			/*if (_items.length > 0)
			{
				items = _items;
			}*/
		}
		items = _items;
	}
	
	public function fromXML(dataObj:XMLNode):Void
	{
		super.fromXML(dataObj);
		
		
		this.readContainerAttributes(dataObj.attributes);
		
		var _items:Array = new Array();
		
		if (dataObj.childNodes != null && dataObj.childNodes != undefined && dataObj.childNodes.length > 0)
		{
			var size:Number = dataObj.childNodes.length;
			var child:XMLNode = null;
			var item:MediaModel = null;
			var setting:SettingModel = null;
			for (var i:Number = 0; i < size; i ++ )
			{
				child = dataObj.childNodes[i];
				if (child.nodeType == 1)
				{
					if (child.nodeName == "Setting")
					{
						setting = new SettingModel();
						setting.fromXML(child);
						
						_items.push(setting);
					}
					else
					{
						item = new MediaModel();
						item.fromXML(child);
					
						_items.push(item);
					}
				}
			}
			
			/*if (_items.length > 0)
			{
				items = _items;
			}*/
		}
		items = _items;
	}
	
	private function readContainerAttributes(attributes:Object):Void
	{
		if (attributes.viewGroup != null && attributes.viewGroup != undefined)
		{
			viewGroup = attributes.viewGroup.toString();
		}
		
		if (attributes.title1 != null && attributes.title1 != undefined)
		{
			title1 = attributes.title1.toString();
		}
		
		if (attributes.title2 != null && attributes.title2 != undefined)
		{
			title2 = attributes.title2.toString();
		}
		
		if (attributes.contenttype != null && attributes.contenttype != undefined)
		{
			contentType = attributes.contenttype.toString();
		}
		
		if (attributes.content != null && attributes.content != undefined)
		{
			content = attributes.content.toString();
		}
		
		if (attributes.mediaTagPrefix != null && attributes.mediaTagPrefix != undefined)
		{
			mediaTagPrefix = attributes.mediaTagPrefix.toString();
		}
		
		if (attributes.mediaTagVersion != null && attributes.mediaTagVersion != undefined)
		{
			mediaTagVersion = attributes.mediaTagVersion.toString();
		}
		
		if (attributes.header != null && attributes.header != undefined)
		{
			header = attributes.header.toString();
		}
		
		if (attributes.message != null && attributes.message != undefined)
		{
			message = attributes.message.toString();
		}
		
		if (attributes.identifier != null && attributes.identifier != undefined)
		{
			identifier = attributes.identifier.toString();
		}
		
		if (attributes.offset != null && attributes.offset != undefined)
		{
			offset = parseInt(attributes.offset);
		}
		
		if (attributes.mixedParents != null && attributes.mixedParents != undefined)
		{
			mixedParents = (attributes.mixedParents == "1");
		}
	}
	
}