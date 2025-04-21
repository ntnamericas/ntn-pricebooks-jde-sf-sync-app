%dw 2.0
output application/json skipNullOn="everywhere"
---
payload map ((item, index) -> {
  srtxExternalIDLanded:
    if (item.IMSRTX != null and trim(item.IMSRTX) != "")
      if (["1801", "1802"] contains trim(item.IBMCU))
        trim(item.IMSRTX) ++ "-NTN-NBCC"
      else
        trim(item.IMSRTX) ++ "-NTN-NTN"
    else null,

  drawExternalIDLanded:
    if (
      trim(item.IMSRTX) != trim(item.IMDRAW) and
      item.IMDRAW  != null and trim(item.IMDRAW)  != "" and
      item.IBPRP1  != null and trim(item.IBPRP1)  != "" and
      item.IBSRP4  != null and trim(item.IBSRP4)  != ""
    )
      if (["1801", "1802"] contains trim(item.IBMCU))
        trim(item.IMDRAW) ++ "-" ++ trim(item.IBPRP1) ++ "-NBCC"
      else
        trim(item.IMDRAW) ++ "-" ++ trim(item.IBPRP1) ++ "-" ++ trim(item.IBSRP4)
    else null,

    unitPrice: item.BPUPRC/10000
}) distinctBy $