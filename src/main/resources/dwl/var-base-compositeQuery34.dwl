%dw 2.0
output application/json
---
{
  "compositeRequest": flatten(
    [payload] map ((item, index) -> [
      {
        "method": "GET",
        "referenceId": "refProduct2" ++ index as String,
        "url": "/services/data/v57.0/query/?q=SELECT id from Product2 where External_ID__c = '" ++ item.drawExternalID ++ "'"
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