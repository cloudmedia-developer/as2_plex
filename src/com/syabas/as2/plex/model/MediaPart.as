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
* Class Description: Media Part
*
***************************************************/
import com.syabas.as2.plex.model.ModelBase;

class com.syabas.as2.plex.model.MediaPart extends ModelBase
{
	public var file:String = null;
	public var duration:Number = null;
	public var container:String = null;
	public var postURL:String = null;
	
	public function fromObject(dataObj:Object):Void
	{
		super.fromObject(dataObj);
		readMediaPartAttributes(dataObj);
	}
	
	public function fromXML(dataObj:XMLNode):Void
	{
		super.fromXML(dataObj);
		readMediaPartAttributes(dataObj.attributes);
	}
	
	private function readMediaPartAttributes(attributes:Object):Void
	{
		if (attributes.file != null && attributes.file != undefined)
		{
			file = attributes.file.toString();
		}
		
		if (attributes.duration != null && attributes.duration != undefined)
		{
			duration = parseInt(attributes.duration);
		}
		
		if (attributes.container != null && attributes.container != undefined)
		{
			container = attributes.container.toString();
		}
		
		if (attributes.postURL != null && attributes.postURL != undefined)
		{
			postURL = attributes.postURL.toString();
		}
	}
}