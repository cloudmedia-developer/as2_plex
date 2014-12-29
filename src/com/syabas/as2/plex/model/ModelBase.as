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
* Class Description: Base class of model
*
***************************************************/

class com.syabas.as2.plex.model.ModelBase
{
	public var _query:String = null;
	public var key:String = null;
	public var parentKey:String = null;
	public var title:String = null;
	public var id:String = null;
	public var identifier:String = null;
	public var file:String = null;
	
	public function fromObject(dataObj:Object):Void
	{
		this.readBaseAttributes(dataObj);
	}
	
	public function fromXML(dataObj:XMLNode):Void
	{
		this.readBaseAttributes(dataObj.attributes);
	}
	
	private function readBaseAttributes(attributes:Object):Void
	{
		if (attributes.key != null && attributes.key != undefined)
		{
			key = attributes.key.toString();
		}
		
		if (attributes.id != null && attributes.id != undefined)
		{
			id = attributes.id.toString();
		}
		
		if (attributes.parentKey != null && attributes.parentKey != undefined)
		{
			parentKey = attributes.parentKey.toString();
		}
		
		if (attributes.title != null && attributes.title != undefined)
		{
			title = attributes.title.toString();
		}
		else if (attributes.name != null && attributes.name != undefined)
		{
			title = attributes.name.toString();
		}
		else if (attributes.track != null && attributes.track != undefined)
		{
			title = attributes.track.toString();
		}
		else if (attributes.album != null && attributes.album != undefined)
		{
			title = attributes.album.toString();
		}
		else if (attributes.artist != null && attributes.artist != undefined)
		{
			title = attributes.artist.toString();
		}
		else if (attributes.genre != null && attributes.genre != undefined)
		{
			title = attributes.genre.toString();
		}
		
		if (attributes.identifier != null && attributes.identifier != undefined)
		{
			identifier = attributes.identifier.toString();
		}
		
		if (attributes.file != null && attributes.file != undefined)
		{
			file = attributes.file.toString();
		}
	}
	
}