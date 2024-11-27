%dw 2.0
output application/json
---
{
  "compositeRequest": flatten(
    [payload] map ((item, index) -> [
      {
        "method": "GET",
        "referenceId": "refProduct2" ++ index as String,
        "url": "/services/data/v57.0/query/?q=SELECT id from Product2 where External_ID__c = '" ++ item.srtxExternalID ++ "'"
      },
      {
        "method": "GET",
        "referenceId": "refPricebook14" ++ index as String,
        "url": "/services/data/v57.0/query/?q=SELECT id from Pricebook2 where JDE_Price_Book__c = '14'"
      },
      {
        "method": "GET",
        "referenceId": "refPricebook15" ++ index as String,
        "url": "/services/data/v57.0/query/?q=SELECT id from Pricebook2 where JDE_Price_Book__c = '15'"
      },
	  {
        "method": "GET",
        "referenceId": "refPBE14" ++ index as String,
        "url": "/services/data/v57.0/query/?q=SELECT id from PricebookEntry where (Pricebook2Id = '@{refPricebook14" ++ index as String ++ ".records[0].Id}' and Product2Id = '@{refProduct2" ++ index as String ++ ".records[0].Id}')"
      },
      {
        "method": "GET",
        "referenceId": "refPBE15" ++ index as String,
        "url": "/services/data/v57.0/query/?q=SELECT id,CurrencyIsoCode from PricebookEntry where (Pricebook2Id = '@{refPricebook15" ++ index as String ++ ".records[0].Id}' and Product2Id = '@{refProduct2" ++ index as String ++ ".records[0].Id}')"
      }
	  ])
	  )
	}