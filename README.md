# PS3HEN Offset Tool

### Usage: .\hen_offset_tool.ps1 [filename] [[filename2] -compare] [-fwver [version]] -debug -text
     
### Examples<br>
#### View Results. Ask For FW Version: ./hen_offset_tool.ps1 PS3HEN.BIN

#### View Results. Specify FW Version: ./hen_offset_tool.ps1 PS3HEN.BIN -fwver 490C

#### Compare 2 Bins: ./hen_offset_tool.ps1 PS3HEN_482C.BIN PS3HEN_490C.BIN -compare

#### Swap/Replace Offsets: ./hen_offset_tool.ps1 PS3HEN_482C PS3HEN_490 -replace -fwver 482C -newfw 490C -debug

#### Dump Offsets To Text: ./hen_offset_tool.ps1 PS3HEN.BIN -text

#### Show All Debug Output: ./hen_offset_tool.ps1 PS3HEN.BIN -debug