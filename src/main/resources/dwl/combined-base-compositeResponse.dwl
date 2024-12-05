%dw 2.0
output application/json
var compositeResponse = vars.compositeResponsePB34.compositeResponse ++ vars.compositeResponsePB1415.compositeResponse
---
{
	//"Id":((((((compositeResponse filter ($."referenceId" == "refPBE30" or $."referenceId" == "refPBE40" or $."referenceId" == "refPBE140" or $."referenceId" == "refPBE150" )) map ($.body.records)) filter ($ !=[] ))[0]) map ((item, index) -> if(item."CurrencyIsoCode" == "CAD") item.Id else "" )) filter ($ != ""))[0],
	"Id":((((((compositeResponse filter ($."referenceId" == "refPBE30" or $."referenceId" == "refPBE40")) map ($.body.records)) filter ($ !=[] ))[0]) map ((item, index) -> if(item."CurrencyIsoCode" == "CAD") item.Id else "" )) filter ($ != ""))[0],
	"UnitPrice": payload."0"."payload".unitPrice
}