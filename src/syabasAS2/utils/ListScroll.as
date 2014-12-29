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
import syabasAS2.utils.Marquee;


class syabasAS2.utils.ListScroll{
	private var index:Number;
	private var hlRow:Number;
	private var total:Number;
	
	public function ListScroll(vIndex:Number,hlrow:Number){
		index = vIndex;
		hlRow = hlrow;
	}
	
	public function scrollUp(target:MovieClip, lineSpace:Number, txt:TextField):Number
	{
		if (index > 0)
		{
			Marquee.self.stop();
			index--;
			if (hlRow > 0)
			{
				hlRow--;
			}
			else
			{
				var pos:Number = index * -lineSpace;
				tweenMc(target,pos - lineSpace,pos);
			}
			Marquee.self.start(txt);
		}
		return hlRow;
	}
	
	public function scrollDown(target:MovieClip, lineSpace:Number, txt:TextField, total:Number, rowPerPage:Number):Number
	{
		if (index < (total - 1))
		{
			Marquee.self.stop();
			index++;
			if (hlRow < (rowPerPage - 1))
			{
				hlRow++;
			}
			else
			{
				var pos:Number = (index - (rowPerPage - 1)) * -lineSpace;
				tweenMc(target,pos + lineSpace,pos);
			}
			Marquee.self.start(txt);
		}
		return hlRow;
	}
	
	private function tweenMc(target:MovieClip, stopValue:Number, y:Number) {
		target.stopTween();
		target._y = stopValue;
		target.tween("_y", y, 0.5, "easeInOutQuart");
	}
}
