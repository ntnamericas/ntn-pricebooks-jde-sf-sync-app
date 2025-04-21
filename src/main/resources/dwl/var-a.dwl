%dw 2.0
output application/java
---
flatten(
    [payload] map ((item,index) ->
        item.PriceBookId.id map (priceBookId) -> {
            IsActive: item.IsActive,
            CurrencyIsoCode: item.CurrencyIsoCode,
            Product2Id: item.Product2Id,
            Pricebook2Id:  priceBookId,
            UnitPrice: item.UnitPrice
        }
))[0]