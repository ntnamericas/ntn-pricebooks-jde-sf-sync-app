%dw 2.0
output application/json
---
payload map (item, index) -> (
{
    drawExternalID: if ((trim(item.IMDRAW) != "") and trim(item.IBPRP1 != "") and trim(item.IBSRP4 != "")) ( trim(item.IMDRAW) ++ "-" ++ trim(item.IBPRP1) ++ "-" ++ trim(item.IBSRP4)) else "",
	srtxExternalID : if (trim(item.IMSRTX) != "") (if ((["1801","1802"] contains (trim(item.IBMCU)))) ((trim(item.IMSRTX) ++ "-NTN-NBCC"))  else ((trim(item.IMSRTX) ++ "-NTN-NTN"))) else "",
    "unitPrice": item.BPUPRC
	
}) distinctBy $