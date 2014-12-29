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
class syabasAS2.image.Centralizer {
	public static function moveXY(target, ref) {
		if (ref == _root || ref == undefined)
		{
			var refW:Number = Stage.width;
			var refH:Number = Stage.height;
			var refX:Number = 0;
			var refY:Number = 0;
		}
		else
		{
			var refW:Number = ref._width;
			var refH:Number = ref._height;
			var refX:Number = ref._x;
			var refY:Number = ref._y;
		}
		if (target._width == 0 || target._height == 0)
		{
			if (target.w != undefined && target.h != undefined)
			{
				var targetW:Number = target.w;
				var targetH:Number = target.h;
			}
			else
			{
				var targetW:Number = target._width;
				var targetH:Number = target._height;
			}
		}
		else
		{
			var targetW:Number = target._width;
			var targetH:Number = target._height;
		}
		target._x = refX + ((refW - targetW) / 2);
		target._y = refY + ((refH - targetH) / 2);
	}

	public static function moveX(target, ref) {
		if (ref == _root || ref == undefined)
		{
			var refW:Number = Stage.width;
			var refX:Number = 0;
		}
		else
		{
			var refW:Number = ref._width;
			var refX:Number = ref._x;
		}
		if (target._width == 0)
		{
			if (target.w != undefined)
			{
				var targetW:Number = target.w;
			}
			else
			{
				var targetW:Number = target._width;
			}
		}
		else
		{
			var targetW:Number = target._width;
		}
		target._x = refX + ((refW - targetW) / 2);
	}

	public static function moveY(target, ref) {
		if (ref == _root || ref == undefined)
		{
			var refH:Number = Stage.height;
			var refY:Number = 0;
		}
		else
		{
			var refH:Number = ref._height;
			var refY:Number = ref._y;
		}
		if (target._height == 0)
		{
			if (target.h != undefined)
			{
				var targetH:Number = target.h;
			}
			else
			{
				var targetH:Number = target._height;
			}
		}
		else
		{
			var targetH:Number = target._height;
		}
		target._y = refY + ((refH - targetH) / 2);
	}
}