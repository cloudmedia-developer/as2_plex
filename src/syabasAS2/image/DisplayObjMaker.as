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
import syabasAS2.event.Caster;
class syabasAS2.image.DisplayObjMaker extends Caster{
	public function DisplayObjMaker() {
		
	}
	
	public function newMovieClip(path:String, depth:Number):MovieClip {
		var mcpathArray		:Array 		= path.split(".");
		var mcpathLength	:Number 	= mcpathArray.length;
		var mcpathMC		:MovieClip	= _root;
		for (var i:Number = 0; i < mcpathLength; i++) {
			if (mcpathMC[mcpathArray[i]]) {					mcpathMC = mcpathMC[mcpathArray[i]];	}
			else {
				if (depth && (i == mcpathLength - 1)) 		mcpathMC = mcpathMC.createEmptyMovieClip(mcpathArray[i], depth);
				else 										mcpathMC = mcpathMC.createEmptyMovieClip(mcpathArray[i], mcpathMC.getNextHighestDepth());
			}
		}
		return mcpathMC;
	}
	
	
	public function newTextField(path:String, depth:Number):TextField {
		var mcpathArray		:Array 		= path.split(".");
		var mcpathLength	:Number 	= mcpathArray.length;
		var mcpathMC		:MovieClip	= _root;
		var mcpathTXT		:TextField;
		for (var i:Number = 0; i < mcpathLength; i++) {
			if (mcpathMC[mcpathArray[i]]) {			mcpathMC 	= mcpathMC[mcpathArray[i]];	}
			else {
				if (i == mcpathLength - 1) {
					if (depth) 						mcpathTXT 	= mcpathMC.createTextField(mcpathArray[i], 		depth							, 0, 0, 0, 0);
					else 							mcpathTXT 	= mcpathMC.createTextField(mcpathArray[i], 		mcpathMC.getNextHighestDepth()	, 0, 0, 0, 0);		 	}
				else {								mcpathMC 	= mcpathMC.createEmptyMovieClip(mcpathArray[i], mcpathMC.getNextHighestDepth());						}						
			}
		}
		mcpathTXT.setNewTextFormat(new TextFormat());
		return mcpathTXT;
	}
}