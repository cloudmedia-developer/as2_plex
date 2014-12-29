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
* Class Description: Media Element
*
***************************************************/

import com.syabas.as2.plex.model.MediaPart;

class com.syabas.as2.plex.model.MediaElement extends MediaPart
{
	public var audioCodec:String = null;
	public var audioChannel:String = null;
	public var videoCodec:String = null;
	public var videoResolution:String = null;
	public var aspectRatio:String = null;
	public var indirect:Boolean = false;
	public var parts:Array = null;
	
	public function fromObject(dataObj:Object):Void
	{
		super.fromObject(dataObj);
		readMediaElementAttributes(dataObj);
		
		if (dataObj._children != null && dataObj._children != undefined && dataObj._children.length > 0)
		{
			var _parts:Array = new Array();
			var size:Number = dataObj._children.length;
			var child:Object = null;
			var part:MediaPart = null;
			for (var i:Number = 0; i < size; i ++ )
			{
				child = dataObj._children[i];
				if (child._elementType == "Part")
				{
					part = new MediaPart();
					part.fromObject(child);
					
					_parts.push(part);
				}
			}
			
			if (_parts.length > 0)
			{
				parts = _parts;
			}
		}
	}
	
	public function fromXML(dataObj:XMLNode):Void
	{
		super.fromXML(dataObj);
		readMediaElementAttributes(dataObj.attributes);
		
		if (dataObj.childNodes != null && dataObj.childNodes != undefined && dataObj.childNodes.length > 0)
		{
			var _parts:Array = new Array();
			var size:Number = dataObj.childNodes.length;
			var child:XMLNode = null;
			var part:MediaPart = null;
			for (var i:Number = 0; i < size; i ++ )
			{
				child = dataObj.childNodes[i];
				if (child.nodeName == "Part")
				{
					part = new MediaPart();
					part.fromXML(child);
					
					_parts.push(part);
				}
			}
			
			if (_parts.length > 0)
			{
				parts = _parts;
			}
		}
	}
	
	private function readMediaElementAttributes(attributes:Object):Void
	{
		if (attributes.audioCodec != null && attributes.audioCodec != undefined)
		{
			audioCodec = attributes.audioCodec.toString();
		}
		
		if (attributes.aspectRatio != null && attributes.aspectRatio != undefined)
		{
			aspectRatio = attributes.aspectRatio.toString();
		}
		
		if (attributes.audioChannels != null && attributes.audioChannels != undefined)
		{
			audioChannel = attributes.audioChannels.toString();
		}
		
		if (attributes.videoCodec != null && attributes.videoCodec != undefined)
		{
			videoCodec = attributes.videoCodec.toString();
		}
		
		if (attributes.videoResolution != null && attributes.videoResolution != undefined)
		{
			videoResolution = attributes.videoResolution.toString();
		}
		
		if (attributes.indirect != null && attributes.indirect != undefined)
		{
			indirect = (attributes.indirect == "1") || (attributes.indirect == 1);
		}
	}
}