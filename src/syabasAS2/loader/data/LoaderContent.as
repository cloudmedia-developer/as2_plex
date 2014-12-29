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
import syabasAS2.loader.text.xml.XMLHunt;
/**
 * ...
 * @author Ng Tong Sheng
 */
class syabasAS2.loader.data.LoaderContent
{
	
	public var extra:Object;
	public var target;
	public var type:String;
	public var xmlParser:XMLHunt
	//----------------------------------------------------------------------------------------------------------
	public static var TYPE_IMAGE			:String = "image"			;
	public static var TYPE_XML				:String = "xml"				;
	public static var TYPE_BITMAP			:String = "bitmap"			;
	public static var TYPE_SYABAS_API		:String = "syabasApi"		;
	public static var TYPE_SYABAS_PHF		:String = "syabasPhf"		;
	public static var TYPE_SYABAS_KEY		:String = "syabasKey"		;
	public static var TYPE_JSON				:String = "json"			;
	public static var TYPE_TEXT				:String = "text"			;
	
	/**
	 * info data class to define loader infos
	 * @param	loaderContentType		choose type from the static var of LoaderContent
	 * @param	target					movieclip / bitmap / xml data							
	 * @param	extra					pass any value as object
	 * @param	xmlParser				only for loading XML and API
	 */
	public function LoaderContent(loaderContentType:String, target, extra:Object, xmlParser:XMLHunt) {
		this.type 		= loaderContentType;
		this.target 	= target;
		this.xmlParser	= xmlParser;
		this.extra		= extra;
	}
}