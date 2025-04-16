%dw 2.0
output application/json
var compositeResponse = vars.compositeResponsePB34.compositeResponse 
//++ vars.compositeResponsePB1415.compositeResponse
---
(compositeResponse 
      filter ($.referenceId == "refPBE30" or $.referenceId == "refPBE40") 
      map ((item) -> 
        {
          "Id": 
            (item.body.records filter ($.CurrencyIsoCode == "CAD") map $.Id)[0],
            "UnitPrice": payload.unitPrice
        }
      )
    )

