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
import darien.debug.Tracer;
import syabasAS2.event.LoadEvent;
import syabasAS2.image.DisplayObjMaker;
import syabasAS2.image.QueueLoader;
import syabasAS2.text.StringConverter;
import syabasAS2.utils.Destructor;

class syabasAS2.image.XMLMc extends DisplayObjMaker{
	public var EVENT_ALL_COMPLETE :String = "eventAllComplete";
	private var queueloader			:QueueLoader;
	private var strconverter		:StringConverter;
	
	public function XMLMc() {
		this.strconverter 		= new StringConverter();
		this.queueloader 		= new QueueLoader();
		this.queueloader.addEvent(this.queueloader.EVENT_ALL_COMPLETE, this, "all_loaded");
	}
	
	public function load_all():Void {
		this.queueloader.start();
	}
	
	private function all_loaded(event:LoadEvent):Void {
		this.castEvent( { type: this.EVENT_ALL_COMPLETE } );
		Destructor.kill(this);
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		CREATE ALL MCs/TFs FROM XML			///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public function create_all_mc(nodes:Array):Void {
		var length:Number = nodes.length;
		for (var i:Number = 0; i < length; i++) {
			this.create_single_mc(nodes, null, i);
		}
	}
	
	public function create_all_txt(nodes:Array):Void {
		var length:Number = nodes.length;
		for (var i:Number = 0; i < length; i++) {
			this.create_single_txt(nodes, null, i);
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public function create_single_mc(nodes:Array, nodeName:String, index:Number):MovieClip {
		var target		:Object;
		var value		:String;
		var match		:Boolean 	= false;
		if (nodeName != null && nodeName != undefined) {
			var length:Number 		= nodes.length;
			for (var i:Number = 0; i < length; i++) {
				if (nodes[i].nodeName == nodeName) {
					match 			= true;
					target			= nodes[i];
					value			= target.firstChild.toString();
					break;
				}
			}
		}
		else if (index != null && index != undefined) {
			if (nodes[index]) {
				match 			= true;
				target			= nodes[index];
				value			= target.firstChild.toString();
			}
		}
		if (!match) {
			trace("||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
			trace("||   XMLMc ERROR: no name match the nodeName in target node   ||");
			trace("||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
			return undefined;
		}
		else {
			if (target.attributes.mc) {
				var mcpath				:String		= target.attributes.mc;
				var mcdepth				:Number		= parseInt(target.attributes.depth);
				if (mcpath.indexOf(".") != -1) {
					var mcpathMC		:MovieClip	= this.newMovieClip(mcpath, mcdepth);
					for (var name:String in target.attributes) {
						if (mcpathMC[name] != undefined && (name != "_visible" || value == undefined)) {
							mcpathMC[name] 			= this.strconverter.toType(typeof(mcpathMC[name]), target.attributes[name].toString());
						}
					}
					if (value) {
						this.queueloader.queue(value, mcpathMC);
					}
					return mcpathMC;
				}
				else {
					trace("||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
					trace("||   XMLMc ERROR: target.attributes.mc format is wrong        ||");
					trace("||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
					return undefined;
				}
			}
			else {
				trace("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
				trace("||   XMLMc ERROR: target.attributes.mc is undefined        ||");
				trace("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
				return undefined;
			}
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public function create_single_txt(nodes:Array, nodeName:String, index:Number):TextField {
		var target		:Object;
		var value		:String;
		var match		:Boolean 	= false;
		if (nodeName != null && nodeName != undefined) {
			var length:Number 		= nodes.length;
			for (var i:Number = 0; i < length; i++) {
				if (nodes[i].nodeName == nodeName) {
					match 			= true;
					target			= nodes[i];
					value			= target.firstChild.toString();
					break;
				}
			}
		}
		else if (index != null && index != undefined) {
			if (nodes[index]) {
				match 			= true;
				target			= nodes[index];
				value			= target.firstChild.toString();
			}
		}
		if (!match) {
			trace("||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
			trace("||   XMLMc ERROR: no name match the nodeName in target node   ||");
			trace("||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
			return undefined;
		}
		else {
			if (target.attributes.mc) {
				var mcpath				:String			= target.attributes.mc;
				var mcdepth				:Number			= parseInt(target.attributes.depth);
				if (mcpath.indexOf(".") != -1) {
					var mcpathTXT		:TextField		= this.newTextField(mcpath, mcdepth);
					var newTextFormat	:TextFormat 	= mcpathTXT.getNewTextFormat();
					for (var name:String in target.attributes) {
						var valuestr	:String 		= target.attributes[name].toString();
						if 		(mcpathTXT[name] 		!= undefined) 	mcpathTXT[name] 		= this.strconverter.toType(typeof(mcpathTXT[name]), 	valuestr);
						else if (newTextFormat[name] 	!= undefined) 	newTextFormat[name] 	= this.strconverter.toType(typeof(newTextFormat[name]), valuestr);
					}
					mcpathTXT.setNewTextFormat(newTextFormat)
					if (value) {
						mcpathTXT.text = value;
					}
					trace("==================================================================")
					trace(mcpathTXT)
					return mcpathTXT;
				}
				else {
					trace("||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
					trace("||   XMLMc ERROR: target.attributes.mc format is wrong        ||");
					trace("||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
					return undefined;
				}
			}
			else {
				trace("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
				trace("||   XMLMc ERROR: target.attributes.mc is undefined        ||");
				trace("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
				return undefined;
			}
		}
	}
}