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
import syabasAS2.utils.Destructor;
class syabasAS2.loader.text.xml.XMLHunt {
	
	private var rootHasChildNodes:Boolean 	= false;
	private var rootObject	:Object;
	private var nodes		:Array;
	private var input		:Array;
	private var output		:Array;
	private var level		:Array;
	
	public function XMLHunt(object:Object) {
		if (object.hasChildNodes() != 0) {
			rootHasChildNodes 	= true;
			rootObject			= object;
		}
	}
	
	public function get mainChildNodes():Array {
		return rootObject.childNodes;
	}
	
	public function kill():Void {
		Destructor.kill(this.rootObject);
		Destructor.kill(this);
	}
	////////////////////////////////////////////////////////////////////////////////////////
	public function hunt_childNodes(childnodesPath:String):Array {
		if (rootHasChildNodes) {
			var pathlist:Array 						= childnodesPath.split("/");
			var pathlistLength:Number 				= pathlist.length;
			if( pathlistLength != 0) {
				this.nodes 							= rootObject.childNodes;
				for (var i:Number = 0; i < pathlistLength; i++) { 
					var searchTerm:String 			= pathlist[i];
					var nodesLength:Number			= this.nodes.length;
					var isMatchFound:Boolean		= false;
					for (var j:Number = 0; j < nodesLength; j++) {
						if (this.nodes[j].nodeName == pathlist[i]) {
							isMatchFound			= true
							if (this.nodes[j].hasChildNodes()) {
								this.nodes 			= this.nodes[j].childNodes;
							}
							else {
								trace("ERROR: ===================================================================");
								trace("XMLHunt: the target path ( " + childnodesPath + " ) do not have childNodes");
								trace("ERROR: ===================================================================");
								return undefined;
							}
							break;
						}
					}
					if (!isMatchFound) {
						trace("ERROR: ==================================================");
						trace("XMLHunt: no childNodes found in " + childnodesPath);
						trace("ERROR: ==================================================");
						return undefined;
					}
				}
				return this.nodes;
			}
			else {
				trace("ERROR: ======================================");
				trace("XMLHunt: nothing found in childnodesPath");
				trace("- make sure you using \"/\" as the delimiter");
				trace("ERROR: ======================================");
				return undefined;
			}
		}
		else {
			return undefined;
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////
	public function hunt_value(inputArg, valuePath:String):String {
		if (typeof(inputArg) == "string") 	{ 
			if (inputArg == "") {
				this.input = this.mainChildNodes;
			}
			else {
				this.input = hunt_childNodes(inputArg); 
			}
		}
		else if (!inputArg) {
			this.input = this.mainChildNodes;
		}
		else { 
			this.input = inputArg; 
		}
		var inputLength:Number 				= this.input.length;
		var valuePathList:Array				= valuePath.split("/");
		var valuePathListLength:Number 		= valuePathList.length;
		if (valuePathListLength == 1) {
			var isMatchFound:Boolean 		= false;
			for (var i:Number = 0; i < inputLength; i++ ) { 
				if (this.input[i].nodeName == valuePath) {
					isMatchFound 			= true;
					if (!this.input[i].firstChild.hasChildNodes()) {
						return this.input[i].firstChild.toString();
					}
					else {
						return this.input[i];
					}
					break;
				}
			}
			if (!isMatchFound) {
				trace("ERROR: ==================================================");
				trace("XMLHunt: no value found in " + valuePath);
				trace("ERROR: ==================================================");
				return undefined;
			}
		}
		else if (valuePathListLength == 0) { 
			trace("ERROR: ======================================");
			trace("XMLHunt: nothing found in valuePath");
			trace("- make sure you using \"/\" as the delimiter");
			trace("ERROR: ======================================");
			return undefined;
		}
		else {
			for (var j:Number = 0; j < valuePathListLength; j++) {
				var isMatchFound:Boolean 	= false;
				for (var i:Number = 0; i < inputLength; i++ ) { 
					if (input[i].nodeName == valuePathList[j]) {
						isMatchFound 		= true;
						if (j == valuePathListLength - 1) {
							if (!this.input[i].firstChild.hasChildNodes()) {
								return this.input[i].firstChild.toString();
							}
							else {
								return this.input[i];
							}
							break;
						}
						else {
							this.input = this.input[i].childNodes;
							break;
						}
					}
				}
				if (!isMatchFound) {
					trace("ERROR: ==================================================");
					trace("XMLHunt: no value found in " + valuePath);
					trace("ERROR: ==================================================");
					return undefined;
				}
			}
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////
	public function hunt_multi_value(inputArg, valuePath:Array):Array {
		if (typeof(inputArg) == "string") 	{ 
			if (inputArg == "") {
				this.input = this.mainChildNodes;
			}
			else {
				this.input = hunt_childNodes(inputArg); 
			}
		}
		else if (!inputArg) {
			this.input = this.mainChildNodes;
		}
		else { 
			this.input = inputArg; 
		}
		if (this.input) {
			if (!valuePath) {
				valuePath = [];
			}
			var valuePathLength:Number 			= valuePath.length;
			if (valuePathLength != 0) {
				var object:Array				= new Array();
				for (var a:Number = 0; a < valuePathLength; a++) {
					object[a]					= hunt_value(this.input, valuePath[a]);
				}
				return object;
			}
			else {
				var output:Array				= new Array();
				var inputLength:Number 			= this.input.length;
				for (var i:Number = 0; i < inputLength; i++ ) { 
					if (!this.input[i].firstChild.hasChildNodes()) {
						output[i] 				= this.input[i].firstChild.toString();
					}
					else {
						output[i] 				= this.input[i];
					}
				}
				return output;
			}
		}
		else {
			return undefined;
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////
	public function hunt_node_list(inputArg, nodeName:String):Array {
		if (typeof(inputArg) == "string") 	{ 
			if (inputArg == "") {
				this.input = this.mainChildNodes;
			}
			else {
				this.input = hunt_childNodes(inputArg); 
			}
		}
		else if (!inputArg) {
			this.input = this.mainChildNodes;
		}
		else { 
			this.input = inputArg; 
		}
		this.output					= new Array();
		var inputLength:Number 		= this.input.length;
		var isMatchFound:Boolean 	= false;
		for (var i:Number = 0; i < inputLength; i++ ) { 
			if (this.input[i].nodeName == nodeName) {
				isMatchFound 			= true;
				this.output.push(this.input[i]);
			}
		}
		if (!isMatchFound) {
			trace("ERROR: ==================================================");
			trace("XMLHunt: no nodeName found in " + nodeName);
			trace("ERROR: ==================================================");
			return undefined;
		}
		else {
			return this.output;
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////
	public function hunt_list(inputArg, listPath:String, toString:Boolean):Array {
		if (typeof(inputArg) == "string") 	{ 
			if (inputArg == "") {
				this.input = this.mainChildNodes;
			}
			else {
				this.input = hunt_childNodes(inputArg); 
			}
		}
		else if (!inputArg) {
			this.input = this.mainChildNodes;
		}
		else { 
			this.input = inputArg; 
		}
		var listPathList:Array				= listPath.split("/");
		var listPathListLength:Number		= listPathList.length;
		if (listPathListLength == 0) {
			trace("ERROR: ======================================");
			trace("XMLHunt: nothing found in listPath");
			trace("- make sure you using \"/\" as the delimiter");
			trace("ERROR: ======================================");
			return undefined;
		}
		else {
			this.level 						= new Array();
			for (var a:Number = 0; a < listPathListLength; a++ ) {
				this.level[a]				= new Array();
				if (a == 0) {
					var inputLength:Number 		= this.input.length;
					var isMatchFound:Boolean 	= false;
					for (var i:Number = 0; i < inputLength; i++ ) { 
						if (this.input[i].nodeName == listPathList[a]) {
							isMatchFound 		= true;
							this.level[a].push(this.input[i]);
						}
					}
					if (!isMatchFound) {
						trace("ERROR: ==================================================");
						trace("XMLHunt: no nodeName found in " + listPathList[a]);
						trace("ERROR: ==================================================");
						return undefined;
					}
				}
				else {
					var target:Array  				= this.level[a - 1];
					var length:Number 				= target.length;
					for (var b:Number = 0; b < length; b++ ) {
						var scan:Array 				= target[b].childNodes;
						var scanLength:Number 		= scan.length;
						var isMatchFound:Boolean 	= false;
						for (var c:Number = 0; c < scanLength; c++ ) {
							if (scan[c].nodeName == listPathList[a]) {
								isMatchFound 		= true;
								this.level[a].push(scan[c]);
							}
						}
						if (!isMatchFound) {
							trace("ERROR: ==================================================");
							trace("XMLHunt: no item found in " + listPath);
							trace("ERROR: ==================================================");
							this.level[a].push(null);
						}
					}
				}
			}
			this.output		 			= this.level[this.level.length - 1];
			var outputLength:Number 	= this.output.length;
			if (toString) {
				for (var i:Number = 0; i < outputLength; i++ ) {
					if (!this.output[i].firstChild.hasChildNodes()) {
						this.output[i] 	= this.output[i].firstChild.toString();
					}
				}
			}
			if (this.output.length != 0) {
				return this.output;
			}
			else {
				trace("ERROR: ==================================================");
				trace("XMLHunt: no list found in " + listPath);
				trace("ERROR: ==================================================");
				return undefined;
			}
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////
}	