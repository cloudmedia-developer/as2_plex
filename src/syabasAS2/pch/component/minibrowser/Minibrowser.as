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
import syabasAS2.event.dispatcher.Caster;
import syabasAS2.event.Event;
import syabasAS2.loader.data.LoaderContent;
import syabasAS2.loader.event.LoaderErrorEvent;
import syabasAS2.loader.event.LoaderEvent;
import syabasAS2.loader.Loader;
import syabasAS2.utils.Destructor;
/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.pch.component.minibrowser.Minibrowser extends Caster
{
	private	var isSingleSelection	:Boolean = true;
	private	var isFolderOnly		:Boolean = true;
	private	var isLocalOnly			:Boolean = false;
	private var minibrowser			:MovieClip;
	private var type				:String;
	//----------------------------------------------------------------------------------------------------------
	public 	var EVENT_INIT			:String = "eventInit";
	public 	var EVENT_ACTIVATE		:String = "eventActivate";
	public 	var EVENT_DEACTIVATE	:String = "eventDeactivate";
	public 	var EVENT_ERROR			:String = "eventError";
	public 	var EVENT_NETWORK_ERROR	:String = "eventNetWorkError";
	public 	var EVENT_CANCEL		:String = "eventCancel";
	public 	var EVENT_DONE			:String = "eventDone";
	//----------------------------------------------------------------------------------------------------------
	public	var TYPE_COPY_TO		:String = "copyTo";
	public	var TYPE_MOVE_TO		:String = "moveTo";
	public	var TYPE_BROWSE			:String = "browse";
	
	private var popupId:Number;
	
	public function Minibrowser() {
	}
	
	public function load(url:String, container:MovieClip, isSingleSelection:Boolean, isFolderOnly:Boolean, type:String, isLocalOnly:Boolean):Void {
		if (isSingleSelection) 	this.isSingleSelection 	= isSingleSelection;
		
		if (isFolderOnly != null) {
			this.isFolderOnly = isFolderOnly;
		}
		
		if (isLocalOnly)		this.isLocalOnly		= isLocalOnly;
		
								this.type 				= type ? type : this.TYPE_COPY_TO;
		//----------------------------------------------------------------------------------------------------------
		this.minibrowser 								= container;
		var loader:Loader 								= new Loader();
			loader.addEventListener(LoaderEvent.COMPLETE	, this, "onComplete"	);
			loader.addEventListener(LoaderEvent.ERROR		, this, "onError"		);
			loader.load(url, new LoaderContent(LoaderContent.TYPE_IMAGE, this.minibrowser));
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		ACTIVATE AND DEACTIVATE				///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function activate():Void {
		this.minibrowser.main.activate();
		this.onActivation();
	}
	
	public function deactivate():Void {
		this.onDeactivation();
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		EVENT								///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	private function onComplete(event:LoaderEvent):Void {
		this.minibrowser.main.isSingleSelection = this.isSingleSelection;
		this.minibrowser.main.isFolderOnly		= this.isFolderOnly;
		this.minibrowser.main.isLocalOnly		= this.isLocalOnly;
		this.minibrowser.main.type				= this.type;
		this.minibrowser.main.addEventListener(this.minibrowser.main.EVENT_INIT		, this, "onBrowserInit"); 
		this.minibrowser.main.addEventListener(this.minibrowser.main.EVENT_CANCEL	, this, "onCancel"); 
		this.minibrowser.main.addEventListener(this.minibrowser.main.EVENT_DONE		, this, "onDone"); 
		this.minibrowser.main.init(this.minibrowser);
	}
	
	private function onCancel():Void {
		this.castEvent( new Event(null, this.EVENT_CANCEL) );
	}
	
	private function onDone(event:Object):Void {
		this.castEvent( event );
	}
	
	private function onError(event:LoaderErrorEvent):Void {
		this.castEvent( new Event(null, this.EVENT_ERROR) );
	}
	
	private function onBrowserInit():Void {
		this.castEvent( new Event(null, this.EVENT_INIT) );
	}
	
	private function onDeactivation():Void {
		this.castEvent( new Event(null, this.EVENT_DEACTIVATE) );
	}
	
	private function onActivation():Void {
		this.castEvent( new Event(null, this.EVENT_ACTIVATE) );
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////		KILL								///////////////////////////////////////
	///////////////////////////////////////											///////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	public function kill():Void {
		
		Destructor.kill(this);
	}
}