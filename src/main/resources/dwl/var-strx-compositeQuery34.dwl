%dw 2.0
import * from dw::core::Strings
output application/json
fun urlEncode(str: String): String =
  str replace " " with "%20"
      replace "'" with "%27"
      replace "#" with "%23"
      replace "(" with "%28"
      replace ")" with "%29"
      replace "," with "%2C"
      replace "=" with "%3D"
      replace "@" with "%40"
---
{
  "compositeRequest": flatten(
    [payload] map ((item, index) -> [
      {
        "method": "GET",
        "referenceId": "refProduct2" ++ index as String,
        "url": "/services/data/v57.0/query/?q=" ++ urlEncode("SELECT id from Product2 where External_ID__c = '" ++ item.srtxExternalID ++ "'")
        //"url": "/services/data/v57.0/query/?q=SELECT id from Product2 where External_ID__c = '" ++ (item.srtxExternalID as String) ++ "'"
      },
      {
        "method": "GET",
        "referenceId": "refPricebook3" ++ index as String,
        "url": "/services/data/v57.0/query/?q=SELECT id from Pricebook2 where JDE_Price_Book__c = '3'"
      },
      {
        "method": "GET",
        "referenceId": "refPricebook4" ++ index as String,
        "url": "/services/data/v57.0/query/?q=SELECT id from Pricebook2 where JDE_Price_Book__c = '4'"
      },
	  {
        "method": "GET",
        "referenceId": "refPBE3" ++ index as String,
        "url": "/services/data/v57.0/query/?q=SELECT id, CurrencyIsoCode from PricebookEntry where (Pricebook2Id = '@{refPricebook3" ++ index as String ++ ".records[0].Id}' and Product2Id = '@{refProduct2" ++ index as String ++ ".records[0].Id}')"
      },
      {
        "method": "GET",
        "referenceId": "refPBE4" ++ index as String,
        "url": "/services/data/v57.0/query/?q=SELECT id,CurrencyIsoCode from PricebookEntry where (Pricebook2Id = '@{refPricebook4" ++ index as String ++ ".records[0].Id}' and Product2Id = '@{refProduct2" ++ index as String ++ ".records[0].Id}')"
      }
	  ])
	  )
	}