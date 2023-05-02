# Define script parameters
param (
    [string]$filename,   # The name of the binary file to search
    [string]$fwver,      # The firmware version to search for offsets in
    [switch]$debug,      # Debug mode switch
    [switch]$text,       # Text output switch
    [switch]$js          # Javascript output switch
)

# Check if filename parameter is provided
if (-not $filename) {
	# Show help and about info
    Write-Host ""
    Write-Host "==========================================================================="
    Write-Host "PS3HEN Offset Tool v1.0 [TEST VERSION]"
    Write-Host ""
    Write-Host "esc0rtd3w / PS3Xploit Team 2023"
    Write-Host "http://www.ps3xploit.me"
    Write-Host ""
    Write-Host ""
    Write-Host "Usage: .\hen_offset_tool.ps1 [filename] -fwver [version] -debug -text"
    Write-Host ""
    Write-Host ""
    Write-Host "Examples"
    Write-Host "--------"
    Write-Host "View Results. Ask For FW Version: ./hen_offset_tool.ps1 PS3HEN.BIN"
    Write-Host ""
    Write-Host "View Results. Specify FW Version: ./hen_offset_tool.ps1 PS3HEN.BIN -fwver 490C"
    Write-Host ""
    Write-Host "Dump Offsets To Text: ./hen_offset_tool.ps1 PS3HEN.BIN -fwver 490C -text"
    Write-Host ""
    Write-Host "Show All Debug Output: ./hen_offset_tool.ps1 PS3HEN.BIN -fwver 490C -debug"
    Write-Host "==========================================================================="
    Write-Host ""
    exit 1
}

# Check if the file exists
if (-not (Test-Path $filename)) {
    Write-Host "Error: File not found"
    exit 1
}

# Title and Info
Write-Host ""
Write-Host "PS3HEN Offset Tool v1.0 [TEST VERSION]"
Write-Host ""

# Check if the fwver parameter is provided, and prompt the user for it if it isn't
if (-not $fwver) {
    do {
        $fwver = Read-Host -Prompt "Please select firmware version (Available versions: 480C, 481C, 482C, 482D, 484C, 484D, 490C)"
    } while (-not ($fwver -eq "480C" -or $fwver -eq "481C" -or $fwver -eq "482C" -or $fwver -eq "482D" -or $fwver -eq "483C" -or $fwver -eq "484C" -or $fwver -eq "484D" -or $fwver -eq "490C"))
}

Write-Host ""
Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Loading offsets dictionary..."

# Load offsets dictionary for the selected firmware version
$offsetsDictionary = @{
	"480C" = @{
        "unk0_mr_r4_r29"  = "0057CD64"
        "gadget_mod2_addr"  = "00013B74"
        "unk4_ld_r0_r1"  = "00019D44"
        "gadget_mod7_addr"  = "0001A6AC"
        "unk3_sys_ppu_thread_create"  = "0001DCB0"
        "unk2_stw_r3_r31"  = "00075480"
        "gadget_mod3_addr"  = "000B8E00"
        "gadget_mod4a_addr"  = "000D9684"
        "gadget_mod8_addr"  = "002BACB0"
        "gadget_mod4b_addr" = "0042C780"
        "unk1_ld_r0_r1" = "00582F18"
        "gadget_mod1_addr" = "0060E588"
        "unk6" = "006D9714"
        "unk7_li_r3_0" = "006D9754"
        "unk8" = "006D975C"
        "unk9_set_r29" = "006EAA18"
        "unk10_28b_sc" = "006EC900"
        "unk11" = "007072F4"
        "vsh_ps3hen_key_toc" = "00707314"
        "vsh_opd_patch+0x4" = "00096D60"
        "unk12_lwz_r11_r3" = "00474758"
        "TOC" = "006F5520"
        "lv2_unk1"  = "00003F80"
        "lv2_unk2"  = "0000BB78"
        "lv2_unk3"  = "000137D4"
        "lv2_unk4"  = "00020E94"
        "lv2_unk5"  = "00025A30"
        "lv2_unk6"  = "00040608"
        "lv2_unk7"  = "00050288"
        "lv2_unk8"  = "0007B40C"
        "lv2_unk9"  = "0012EF50"
        "lv2_unk10" = "001648B0"
        "lv2_unk11" = "00198460"
        "lv2_unk12" = "001D4AFC"
        "lv2_unk13" = "001D4C50"
        "lv2_unk14" = "0029481C"
        "lv2_unk15" = "00670040"
        "lv2_unk16" = "00670000"
        "lv2_unk17" = "00670090"
        "lv2_unk18" = "00672000"
        "lv2_unk19" = "007E0000"
        "lv2_unk20" = "007F0190"
    }
	"481C" = @{
        "unk0_mr_r4_r29"  = "0057CD74"
        "gadget_mod2_addr"  = "00013B74"
        "unk4_ld_r0_r1"  = "00019D44"
        "gadget_mod7_addr"  = "0001A6AC"
        "unk3_sys_ppu_thread_create"  = "0001DCB0"
        "unk2_stw_r3_r31"  = "00075480"
        "gadget_mod3_addr"  = "000B8E00"
        "gadget_mod4a_addr"  = "000D9684"
        "gadget_mod8_addr"  = "002BACB4"
        "gadget_mod4b_addr" = "0042C774"
        "unk1_ld_r0_r1" = "00582F28"
        "gadget_mod1_addr" = "0060E59C"
        "unk6" = "006D9714"
        "unk7_li_r3_0" = "006D9754"
        "unk8" = "006D975C"
        "unk9_set_r29" = "006EAA18"
        "unk10_28b_sc" = "006EC900"
        "unk11" = "0070731C"
        "vsh_ps3hen_key_toc" = "0070733C"
        "vsh_opd_patch+0x4" = "00096D60"
        "unk12_lwz_r11_r3" = "0047474C"
        "TOC" = "006F5520"
        "lv2_unk1"  = "00003F80"
        "lv2_unk2"  = "0000BB78"
        "lv2_unk3"  = "000137D8"
        "lv2_unk4"  = "00020E98"
        "lv2_unk5"  = "00025A34"
        "lv2_unk6"  = "0004060C"
        "lv2_unk7"  = "0005028C"
        "lv2_unk8"  = "0007B410"
        "lv2_unk9"  = "0012EF58"
        "lv2_unk10" = "001648B8"
        "lv2_unk11" = "00198468"
        "lv2_unk12" = "001D4B04"
        "lv2_unk13" = "001D4C58"
        "lv2_unk14" = "00294828"
        "lv2_unk15" = "00670040"
        "lv2_unk16" = "00670000"
        "lv2_unk17" = "00670090"
        "lv2_unk18" = "00672000"
        "lv2_unk19" = "007E0000"
        "lv2_unk20" = "007F0190"
    }
	"482C" = @{
        "unk0_mr_r4_r29"  = "0057CE48"
        "gadget_mod2_addr"  = "00013B74"
        "unk4_ld_r0_r1"  = "00019D44"
        "gadget_mod7_addr"  = "0001A6AC"
        "unk3_sys_ppu_thread_create"  = "0001DCB0"
        "unk2_stw_r3_r31"  = "00075480"
        "gadget_mod3_addr"  = "000B8E00"
        "gadget_mod4a_addr"  = "000D9684"
        "gadget_mod8_addr"  = "002BACB8"
        "gadget_mod4b_addr" = "0042C778"
        "unk1_ld_r0_r1" = "00583044"
        "gadget_mod1_addr" = "0060EF38"
        "unk6" = "006D9714"
        "unk7_li_r3_0" = "006D9754"
        "unk8" = "006D975C"
        "unk9_set_r29" = "006EAA48"
        "unk10_28b_sc" = "006EC930"
        "unk11" = "00707754"
        "vsh_ps3hen_key_toc" = "00707774"
        "vsh_opd_patch+0x4" = "00096D60"
        "unk12_lwz_r11_r3" = "00474750"
        "TOC" = "006F5550"
        "lv2_unk1"  = "00003F80"
        "lv2_unk2"  = "0000BB78"
        "lv2_unk3"  = "000137D8"
        "lv2_unk4"  = "00020E98"
        "lv2_unk5"  = "00025A34"
        "lv2_unk6"  = "0004060C"
        "lv2_unk7"  = "0005028C"
        "lv2_unk8"  = "0007B410"
        "lv2_unk9"  = "0012EF58"
        "lv2_unk10" = "001648B8"
        "lv2_unk11" = "00198468"
        "lv2_unk12" = "001D4B04"
        "lv2_unk13" = "001D4C58"
        "lv2_unk14" = "00294828"
        "lv2_unk15" = "00670040"
        "lv2_unk16" = "00670000"
        "lv2_unk17" = "00670090"
        "lv2_unk18" = "00672000"
        "lv2_unk19" = "007E0000"
        "lv2_unk20" = "007F0190"
    }
    "482D" = @{
        "unk0_mr_r4_r29"  = "00584A3C"
        "gadget_mod2_addr"  = "00013B74"
        "unk4_ld_r0_r1"  = "00019D44"
        "gadget_mod7_addr"  = "0001A6AC"
        "unk3_sys_ppu_thread_create"  = "0001DD64"
        "unk2_stw_r3_r31"  = "00075538"
        "gadget_mod3_addr"  = "000B8EB8"
        "gadget_mod4a_addr"  = "000DEBD8"
        "gadget_mod8_addr"  = "002C24E0"
        "gadget_mod4b_addr" = "0043436C"
        "unk1_ld_r0_r1" = "0058AC38"
        "gadget_mod1_addr" = "00616B54"
        "unk6" = "006E97FC"
        "unk7_li_r3_0" = "006E983C"
        "unk8" = "006E9844"
        "unk9_set_r29" = "006FAB38"
        "unk10_28b_sc" = "006FCA20"
        "unk11" = "007180BC"
        "vsh_ps3hen_key_toc" = "007180DC"
        "vsh_opd_patch+0x4" = "00096E18"
        "unk12_lwz_r11_r3" = "0047C334"
        "TOC" = "00705640"
        "lv2_unk1" = "00003F80"
        "lv2_unk2" = "0000BBF8"
        "lv2_unk3" = "00013E28"
        "lv2_unk4" = "00022948"
        "lv2_unk5" = "000276E4"
        "lv2_unk6" = "00043F70"
        "lv2_unk7" = "00053C34"
        "lv2_unk8" = "0007F4EC"
        "lv2_unk9" = "001352E4"
        "lv2_unk10" = "0016AC44"
        "lv2_unk11" = "0019E7F4"
        "lv2_unk12" = "001DAFB4"
        "lv2_unk13" = "001DB108"
        "lv2_unk14" = "002AF710"
        "lv2_unk15" = "006B0040"
        "lv2_unk16" = "006B0000"
        "lv2_unk17" = "006B0090"
        "lv2_unk18" = "006B2000"
        "lv2_unk19" = "007E0000"
        "lv2_unk20" = "007F0190"
    }
	"483C" = @{
        "unk0_mr_r4_r29"  = "0057CE48"
        "gadget_mod2_addr"  = "00013B74"
        "unk4_ld_r0_r1"  = "00019D44"
        "gadget_mod7_addr"  = "0001A6AC"
        "unk3_sys_ppu_thread_create"  = "0001DCB0"
        "unk2_stw_r3_r31"  = "00075480"
        "gadget_mod3_addr"  = "000B8E00"
        "gadget_mod4a_addr"  = "000D9684"
        "gadget_mod8_addr"  = "002BACB8"
        "gadget_mod4b_addr" = "0042C778"
        "unk1_ld_r0_r1" = "00583044"
        "gadget_mod1_addr" = "0060EFD8"
        "unk6" = "006D9714"
        "unk7_li_r3_0" = "006D9754"
        "unk8" = "006D975C"
        "unk9_set_r29" = "006EAA54"
        "unk10_28b_sc" = "006EC938"
        "unk11" = "0070784C"
        "vsh_ps3hen_key_toc" = "0070786C"
        "vsh_opd_patch+0x4" = "00096D60"
        "unk12_lwz_r11_r3" = "00474750"
        "TOC" = "006F5558"
        "lv2_unk1"  = "00003F80"
        "lv2_unk2"  = "0000BB78"
        "lv2_unk3"  = "000137D8"
        "lv2_unk4"  = "00020E98"
        "lv2_unk5"  = "00025A34"
        "lv2_unk6"  = "0004060C"
        "lv2_unk7"  = "0005028C"
        "lv2_unk8"  = "0007B410"
        "lv2_unk9"  = "0012EF58"
        "lv2_unk10" = "001648B8"
        "lv2_unk11" = "00198468"
        "lv2_unk12" = "001D4B04"
        "lv2_unk13" = "001D4C58"
        "lv2_unk14" = "00294828"
        "lv2_unk15" = "00670040"
        "lv2_unk16" = "00670000"
        "lv2_unk17" = "00670090"
        "lv2_unk18" = "00672000"
        "lv2_unk19" = "007E0000"
        "lv2_unk20" = "007F0190"
    }
	"484C" = @{
        "unk0_mr_r4_r29"  = "0057CE48"
        "gadget_mod2_addr"  = "00013B74"
        "unk4_ld_r0_r1"  = "00019D44"
        "gadget_mod7_addr"  = "0001A6AC"
        "unk3_sys_ppu_thread_create"  = "0001DCB0"
        "unk2_stw_r3_r31"  = "00075480"
        "gadget_mod3_addr"  = "000B8E00"
        "gadget_mod4a_addr"  = "000D9684"
        "gadget_mod8_addr"  = "002BACB8"
        "gadget_mod4b_addr" = "0042C778"
        "unk1_ld_r0_r1" = "00583044"
        "gadget_mod1_addr" = "0060EFD8"
        "unk6" = "006D9714"
        "unk7_li_r3_0" = "006D9754"
        "unk8" = "006D975C"
        "unk9_set_r29" = "006EAA54"
        "unk10_28b_sc" = "006EC938"
        "unk11" = "0070784C"
        "vsh_ps3hen_key_toc" = "0070786C"
        "vsh_opd_patch+0x4" = "00096D60"
        "unk12_lwz_r11_r3" = "00474750"
        "TOC" = "006F5558"
        "lv2_unk1"  = "00003F80"
        "lv2_unk2"  = "0000BB78"
        "lv2_unk3"  = "000137D8"
        "lv2_unk4"  = "00020E98"
        "lv2_unk5"  = "00025A34"
        "lv2_unk6"  = "0004060C"
        "lv2_unk7"  = "0005028C"
        "lv2_unk8"  = "0007B410"
        "lv2_unk9"  = "0012EF58"
        "lv2_unk10" = "001648B8"
        "lv2_unk11" = "00198468"
        "lv2_unk12" = "001D4B04"
        "lv2_unk13" = "001D4C58"
        "lv2_unk14" = "00294828"
        "lv2_unk15" = "00670040"
        "lv2_unk16" = "00670000"
        "lv2_unk17" = "00670090"
        "lv2_unk18" = "00672000"
        "lv2_unk19" = "007E0000"
        "lv2_unk20" = "007F0190"
    }
    "484D" = @{
        "unk0_mr_r4_r29" = "00584A3C"
        "gadget_mod2_addr" = "00013B74"
        "unk4_ld_r0_r1" = "00019D44"
        "gadget_mod7_addr" = "0001A6AC"
        "unk3_sys_ppu_thread_create" = "0001DD64"
        "unk2_stw_r3_r31" = "00075538"
        "gadget_mod3_addr" = "000B8EB8"
        "gadget_mod4a_addr" = "000DEBD8"
        "gadget_mod8_addr" = "002C24E0"
        "gadget_mod4b_addr" = "0043436C"
        "unk1_ld_r0_r1" = "0058AC38"
        "gadget_mod1_addr" = "00616BF4"
        "unk6" = "006E97FC"
        "unk7_li_r3_0" = "006E983C"
        "unk8" = "006E9844"
        "unk9_set_r29" = "006FAB44"
        "unk10_28b_sc" = "006FCA28"
        "unk11" = "007181B4"
        "vsh_ps3hen_key_toc" = "007181D4"
        "vsh_opd_patch+0x4" = "00096E18"
        "unk12_lwz_r11_r3" = "0047C334"
        "TOC" = "00705648"
        "lv2_unk1"  = "00003F80"
        "lv2_unk2"  = "0000BBF8"
        "lv2_unk3"  = "00013E28"
        "lv2_unk4"  = "00022948"
        "lv2_unk5"  = "000276E4"
        "lv2_unk6"  = "00043F70"
        "lv2_unk7"  = "00053C34"
        "lv2_unk8"  = "0007F4EC"
        "lv2_unk9"  = "001352E4"
        "lv2_unk10" = "0016AC44"
        "lv2_unk11" = "0019E7F4"
        "lv2_unk12" = "001DAFB4"
        "lv2_unk13" = "001DB108"
        "lv2_unk14" = "002AF710"
        "lv2_unk15" = "006B0040"
        "lv2_unk16" = "006B0000"
        "lv2_unk17" = "006B0090"
        "lv2_unk18" = "006B2000"
		"lv2_unk19" = "007E0000"
        "lv2_unk20" = "007F0190"
    }
	"490C" = @{
        "unk0_mr_r4_r29"  = "0057CE44"
        "gadget_mod2_addr"  = "00013B74"
        "unk4_ld_r0_r1"  = "00019D44"
        "gadget_mod7_addr"  = "0001A6AC"
        "unk3_sys_ppu_thread_create"  = "0001DCB0"
        "unk2_stw_r3_r31"  = "00075480"
        "gadget_mod3_addr"  = "000B8E00"
        "gadget_mod4a_addr"  = "000D9684"
        "gadget_mod8_addr"  = "002BACB4"
        "gadget_mod4b_addr" = "0042C774"
        "unk1_ld_r0_r1" = "00583040"
        "gadget_mod1_addr" = "0060EFD0"
        "unk6" = "006D9714"
        "unk7_li_r3_0" = "006D9754"
        "unk8" = "006D975C"
        "unk9_set_r29" = "006EAA54"
        "unk10_28b_sc" = "006EC938"
        "unk11" = "007079FC"
        "vsh_ps3hen_key_toc" = "00707A1C"
        "vsh_opd_patch+0x4" = "00096D60"
        "unk12_lwz_r11_r3" = "0047474C"
        "TOC" = "006F5558"
        "lv2_unk1"  = "00003F80"
        "lv2_unk2"  = "0000BB78"
        "lv2_unk3"  = "000137D4"
        "lv2_unk4"  = "00020E94"
        "lv2_unk5"  = "00025A30"
        "lv2_unk6"  = "00040608"
        "lv2_unk7"  = "00050288"
        "lv2_unk8"  = "0007B40C"
        "lv2_unk9"  = "0012EF50"
        "lv2_unk10" = "001648B0"
        "lv2_unk11" = "00198460"
        "lv2_unk12" = "001D4AFC"
        "lv2_unk13" = "001D4C50"
        "lv2_unk14" = "0029481C"
        "lv2_unk15" = "00670040"
        "lv2_unk16" = "00670000"
        "lv2_unk17" = "00670090"
        "lv2_unk18" = "00672000"
        "lv2_unk19" = "007E0000"
        "lv2_unk20" = "007F0190"
    }
}
Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Loading offsets dictionary...done"
Write-Host ""

# Define memory ranges for each section of the binary file
Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Loading offset ranges..."
$ranges = @(
    @{
        Name = "webkit_vsh_gadgets_1"
        Start = 0x00000000
        End = 0x0006FFFF
    },
    @{
        Name = "sprx"
        Start = 0x00070000
        End = 0x0007FFF7
    },
    @{
        Name = "size_of_stage2"
        Start = 0x0007FFF8
        End = 0x0007FFFF
    },
    @{
        Name = "stage2"
        Start = 0x00080000
        End = 0x0009FFF7
    },
    @{
        Name = "webkit_vsh_gadgets_2"
        Start = 0x0009FFF8
        End = 0x000A0387
    },
    @{
        Name = "padding1"
        Start = 0x000A0388
        End = 0x000A4FAF
    },
    @{
        Name = "socket_lv2_value"
        Start = 0x000A4FB0
        End = 0x000A5EEF
    },
    @{
        Name = "padding2"
        Start = 0x000A5EF0
        End = 0x000FFFDF
    },
    @{
        Name = "stackframe_lv2_vsh_offsets"
        Start = 0x000FFFE0
        End = 0x00101FFF
    },
    @{
        Name = "stage0"
        Start = 0x00102000
        End = 0x0010EFFF
    },
    @{
        Name = "padding3"
        Start = 0x0010F000
        End = 0x0010FFFF
    }
)
Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Loading offset ranges...done"
Write-Host ""

# Check if the selected firmware version is valid
if (-not $offsetsDictionary.ContainsKey($fwver)) {
    Write-Host "Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Error: Invalid firmware version. Available versions: $($offsetsDictionary.Keys -join ', ')"
    exit 1
}

# Select the offsets dictionary for the selected firmware version
$currentDictionary = $offsetsDictionary.$fwver

# Read binary file content into memory
Write-Host "*** THIS STEP MAY TAKE A WHILE DEPENDING ON THE SPEED OF YOUR COMPUTER ***"
Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Reading binary file content into 0x4 byte chunks..."
$fileContent = [System.IO.File]::ReadAllBytes($filename)

# Search for gadget offsets in the binary file
$foundOffsets = @()
function ByteSequenceEqual($a, $b) {
	
	# Check if the count of elements in arrays $a and $b are not equal
    if ($a.Count -ne $b.Count) {
        return $false
    }
	
	# Loop through each element in arrays $a and $b
    for ($i = 0; $i -lt $a.Count; $i++) {
		
		# Check if the elements at index $i are not equal
        if ($a[$i] -ne $b[$i]) {
            return $false
        }
    }
	
	# Return true if all elements in the arrays are equal
    return $true
}

# Divide the file content into 4-byte chunks
$chunkIndex = 0
$chunkedFileContent = -join ($fileContent | % { '{0:X2}' -f $_ }) -split '(?<=\G.{8})' | Where-Object { $_ } | % { 
	# Calculate the current offset based on the chunk index
    $currentOffset = $chunkIndex * 4
	# Format the offset in hexadecimal format with leading zeros
    $offset = '0x{0:X8}' -f $currentOffset
	# Get the range that the current offset falls within
    $range = $ranges | Where-Object { $currentOffset -ge [UInt32]($_.Start) -and $currentOffset -lt [UInt32]($_.End) } | Select-Object -First 1
	# Write debug information if debug mode is enabled
    if ($debug) { Write-Host "Processing chunk: $_     Offset: $offset     Range: $($range.Name)" }
	# Increment the chunk index
    $chunkIndex++
	# Convert the hexadecimal string to an unsigned 32-bit integer
    [UInt32]("0x" + $_) 
}

# Search for each offset value in the offsets dictionary
$summaryTable = @()
Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Reading binary file content in 0x4 byte chunks...done"
Write-Host ""
Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Searching for gadgets..."
Write-Host ""

# Loop through each offset in the dictionary
foreach ($offset in $currentDictionary.GetEnumerator()) {
	
	# Convert the offset value to UInt32 and display a search message
    $searchValue = [UInt32]("0x" + $offset.Value)
    Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Searching for $($offset.Name) with value 0x$($offset.Value)..."

	# Initialize a counter for number of instances found
    $count = 0

	# Loop through each element in the file content array
    for ($i = 0; $i -lt $chunkedFileContent.Length; $i++) {
		
		# Check if the element matches the search value
        if ($chunkedFileContent[$i] -eq $searchValue) {
			
			# Calculate the file offset and display the match information
            $foundAtOffset = '0x{0:X8}' -f (($i * 4) + 0x4)
            $formattedBytes = '{0:X8}' -f $searchValue
            if ($debug) { Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Found at offset: 0x$('{0:X8}' -f $foundAtOffset) -> $formattedBytes" }

			# Increment the instance counter and check if the match already exists in the results array
            $count++
            $existingOffset = $foundOffsets | Where-Object { $_.Name -eq $offset.Name -and $_.FileOffset -eq $foundAtOffset }

			# Add a new match to the results array if it doesn't already exist
            if ($null -eq $existingOffset) {
                $foundOffsets += [PSCustomObject]@{
                    GadgetName = $offset.Name
                    FileOffset = $foundAtOffset
                    Value = '0x{0:X8}' -f $searchValue
                }
				# Display the message for a new match found
                if ($debug) { Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  New match found for $($offset.Name) at offset $($foundAtOffset): $count instance(s) found." }
            } else {
				# Update the count if the match already exists in the results array
                if ($debug) { Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Additional match found for $($existingOffset.Name) at offset $($existingOffset.FileOffset): $count instance(s) found." }
            }
        }
    }

	# Display the total number of instances found for the current offset
    $formattedCount = '{0:d}' -f $count
    Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Found $formattedCount matches for $($offset.Name)."
	Write-Host ""

	# Add a summary of the results to the summary table
    $summaryTable += [PSCustomObject]@{
        GadgetName = $offset.Name
        Instances = $count
    }
}

# Output results
	Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Searching for gadgets...done"
	Write-Host ""
	Write-Host ""

# Check if any gadget offsets were found
if ($foundOffsets.Count -gt 0) {
	# Output summary of found gadget offsets and their values
	Write-Host "Found gadget offsets and values summary"
	Write-Host ""
	
    # Display input file path and firmware version
	Write-Host "Input file: $filename | Firmware version: ${fwver}"
	Write-Host ""

	# Format and display the list of found gadget offsets and their values
    $foundOffsets | Format-Table -Property GadgetName, FileOffset, Value -AutoSize | Out-Host

	# Output summary table of gadget values and their counts
    Write-Host "Summary of instances for each gadget value:"
	Write-Host ""
    $summaryTable | Format-Table -AutoSize | Out-Host

	$jsOutput = ""

	if ($js) {
		foreach ($offsetGroup in $offsetsDictionary.GetEnumerator()) {
			$groupKey = $offsetGroup.Name
			$offsets = $offsetGroup.Value

			foreach ($offset in $offsets.GetEnumerator()) {
				$jsOutput += "const $($offset.Name)_$($groupKey) = [`n`t$($offset.Value)`n];`n`n"
			}
		}

    # Save the $jsOutput to a .js file
    Set-Content -Path "output.js" -Value $jsOutput
	}

	# If the text output switch is enabled, save the results to a file
    if ($text) {
        $outputFilename = "offsets_output.txt"
        Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Saving results to $outputFilename..."
        $foundOffsets | Format-Table -Property GadgetName, FileOffset, Value -AutoSize | Out-File $outputFilename
        Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Saving results to $outputFilename...done"
        Write-Host ""
    }

	# Output the total count of found gadget offsets
    $totalCount = ($foundOffsets | Measure-Object).Count
    Write-Host "Total gadgets count: $totalCount"
} else {
	# Output message indicating that no matching offsets were found
    Write-Host "No matching offsets found for $fwver."
}
