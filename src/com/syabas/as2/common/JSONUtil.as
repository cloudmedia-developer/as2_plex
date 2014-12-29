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
* Version: 1.1.0
*
* Developer: Syabas Technology Sdn. Bhd.
*
* Class Description: JSON Utilities Class.
*
***************************************************/

import com.adobe.stagecraft.FastJSON;
import com.designvox.tranniec.JSON;

class com.syabas.as2.common.JSONUtil
{
	public static var AUTO_PARSER_TYPE:String = null;

	/*
	* Parse JSON Data.
	*
	* data:String   - Data to parse.
	* parser:String - Parser type. Available value: auto(Default), fastjson, designvox
	*
	* return JSON object.
	*/
	public static function parseJSON(data:String, parser:String):Object
	{
		if (parser == undefined || parser == null)
		{
			if (JSONUtil.AUTO_PARSER_TYPE == null)
			{
				var fastJSONTest:FastJSON = new FastJSON();
				if (fastJSONTest.turboParse != undefined)
					JSONUtil.AUTO_PARSER_TYPE = "fastjson";
				else
					JSONUtil.AUTO_PARSER_TYPE = "designvox";
			}

			parser = JSONUtil.AUTO_PARSER_TYPE;
		}

		if (parser == "fastjson")
		{
			var fastJSON:FastJSON = new FastJSON();
			return fastJSON.turboParse(data);
		}
		else
			return JSON.parse(data);
	}
}