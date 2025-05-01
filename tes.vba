Private Sub CariDokumen()
On Error GoTo Salah
Dim iRow As Long
Dim CARI_DATA As Object
Set CARI_DATA = Sheet2
Sheet5.Range("Q5").Value = Me.CMBBERDASARKAN.Value
Sheet5.Range("Q6").Value = Me.TXTKATAKUNCI.Value
Me.TABELSURAT.Value = ""
CARI_DATA.Range("A5").CurrentRegion.AdvancedFilter Action:=xlFilterCopy, CriteriaRange:= _
Sheet5.Range("Q5:Q6"), CopyToRange:=Sheet5.Range("A5:O5"), Unique:=False
iRow = Sheet5.Range("A" & Rows.Count).End(xlUp).Row
If iRow > 1 Then
Me.TABELSURAT.RowSource = "CARIMASUK!A6:I" & iRow
Else
Call MsgBox("Data tidak ditemukan", vbInformation, "Cari Data")
End If
Me.TXTTOTALDATA.Value = Me.TABELSURAT.ListCount
Exit Sub
Salah:
Call MsgBox("Maaf Data tidak ditemukan", vbInformation, "Cari Data")
End Sub

.AddItem "Nomor Surat"
.AddItem "Pengirim"
.AddItem "Perihal"
.AddItem "Ditujukan"
.AddItem "Tanggal Surat"


.AddItem "Purchase Order"
.AddItem "Buyer PO"
.AddItem "Brand	PO"
.AddItem "Season"
.AddItem "Category"
.AddItem "Sub Categor"
.AddItem "Vendor"
.AddItem "Factory"
.AddItem "Origin Country"
.AddItem "Ship To"
.AddItem "Shipment Type"
.AddItem "FOB Cost"
.AddItem "Tanggal"



Private Sub CetakSuratMasuk()
If Me.TABELDOKUMEN.RowSource = "" Then
Call MsgBox("Harap tampilkan data yang akan dicetak", vbInformation, "Cetak Surat Masuk")
Else
Select Case MsgBox("Anda akan mencetak surat masuk" _
& vbCrLf & "Apakah anda yakin?" _
, vbYesNo Or vbQuestion Or vbDefaultButton1, "Cetak Surat Masuk")
Case vbNo
Exit Sub
Case vbYes
End Select
Unload Me
Sheet5.PrintPreview
FORMUTAMA.Show
End If
End Sub
