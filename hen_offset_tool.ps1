# Define script parameters
param (
    [string]$filename,   # The name of the binary file to search
    [string]$filename2,  # The name of the binary file to compare
    [string]$fwver,      # The firmware version to search for offsets in
    [switch]$debug,      # Debug mode switch
    [switch]$compare,    # Compare 2 bins and output diffs switch
    [switch]$text,       # Text output switch
    [switch]$opcode,     # Text output matching gadgets with PPC code output
    [switch]$replace,    # Replace current offset values with values from another firmware
    #[switch]$newfw,      # Only used with -replace switch to specify new fw version
	[string]$newfw = $null,
    [switch]$js          # Javascript output switch
)

$logFile = "hen_offset_tool.log"

# Check if filename parameter is provided
if (-not $filename) {
	# Show help and about info
    Write-Host ""
    Write-Host "=============================================================================================="
    Write-Host "PS3HEN Offset Tool v1.0"
    Write-Host ""
    Write-Host "esc0rtd3w / PS3Xploit Team 2023"
    Write-Host "http://www.ps3xploit.me"
    Write-Host ""
    Write-Host ""
    Write-Host "Usage: .\hen_offset_tool.ps1 [filename] [[filename2] -compare] [-fwver [version]] -debug -text"
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "Examples"
    Write-Host "--------"
    Write-Host "View Results. Ask For FW Version: ./hen_offset_tool.ps1 PS3HEN.BIN"
    Write-Host ""
    Write-Host "View Results. Specify FW Version: ./hen_offset_tool.ps1 PS3HEN.BIN -fwver 490C"
    Write-Host ""
    Write-Host "Dump Offsets To Text: ./hen_offset_tool.ps1 PS3HEN.BIN -text"
    Write-Host ""
    Write-Host "Dump Offsets To Javascript: ./hen_offset_tool.ps1 PS3HEN.BIN -js"
    Write-Host ""
    Write-Host "Show All Debug Output: ./hen_offset_tool.ps1 PS3HEN.BIN -fwver 490C -debug"
    Write-Host ""
    Write-Host "Compare Two Bins: ./hen_offset_tool.ps1 PS3HEN_482C.BIN PS3HEN_490C.BIN -compare"
    Write-Host ""
    Write-Host "Swap/Replace Offsets: ./hen_offset_tool.ps1 482C.BIN 490C.BIN -replace -fwver 482C -newfw 490C"
    Write-Host "=============================================================================================="
    Write-Host ""
    exit 1
}

# Check if the file exists
if (-not (Test-Path $filename)) {
    Write-Host "Error: File not found"
    exit 1
}

# Get the current script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Get PPC OP Code as hexadecimal value
function Get_PPC_OP_Code {
    param (
        [string]$hexValue
    )

    # Dictionary of PPC OP Codes
    $ppcOpCodes = @{
        # Arithmetic
        'add'   = '7C000214';   # Add
		'addc'  = '7C000215';   # Add carrying
		'adde'  = '7C000216';   # Add extended
		'addme' = '7C000217';   # Add minus one extended
		'addze' = '7C000218';   # Add to zero extended
		'addo'  = '7C0001D4';   # Add (with overflow)
		'addco' = '7C0001D5';   # Add carrying (with overflow)
		'addeo' = '7C0001D6';   # Add extended (with overflow)
		'addmeo'= '7C0001D7';   # Add minus one extended (with overflow)
		'addzeo'= '7C0001D8';   # Add to zero extended (with overflow)
		'divw'  = '7C000219';   # Divide word
		'divwu' = '7C00021A';   # Divide word unsigned
		'mulhw' = '7C00021B';   # Multiply high word
		'mulhwu'= '7C00021C';   # Multiply high word unsigned
		'mullw' = '7C00021D';   # Multiply low word
		'mulli' = '7C00021E';   # Multiply low immediate
		'neg'   = '7C00021F';   # Negate
		'subf'  = '7C000220';   # Subtract from
		'subfc' = '7C000221';   # Subtract from carrying
		'subfe' = '7C000222';   # Subtract from extended
		'subfme'= '7C000223';   # Subtract from minus one extended
		'subfze'= '7C000224';   # Subtract from zero extended
		'divwo' = '7C0001E0';   # Divide word (with overflow)
		'divwuo'= '7C0001E1';   # Divide word unsigned (with overflow)
		'mulhwo'= '7C0001E2';   # Multiply high word (with overflow)
		'mulhwuo'= '7C0001E3';  # Multiply high word unsigned (with overflow)
		'mullwo'= '7C0001E4';   # Multiply low word (with overflow)

        # Logical
        'and'   = '7C000038';   # AND
		'andi'  = '7C000039';   # AND Immediate
		'andis' = '7C00003A';   # AND Immediate Shifted
		'nand'  = '7C00003B';   # NAND
		'nor'   = '7C00003C';   # NOR
		'or'    = '7C00003D';   # OR
		'ori'   = '7C00003E';   # OR Immediate
		'oris'  = '7C00003F';   # OR Immediate Shifted
		'xor'   = '7C000040';   # XOR (Exclusive OR)
		'xori'  = '7C000041';   # XOR Immediate
		'xoris' = '7C000042';   # XOR Immediate Shifted
		'eqv'   = '7C000043';   # Equivalent (XOR Inverted)
		'extsb' = '7C000044';   # Extend Sign Byte
		'extsh' = '7C000045';   # Extend Sign Halfword
		'extsw' = '7C000046';   # Extend Sign Word
		'cntlzw'= '7C000047';   # Count Leading Zeros Word
		'cntlzd'= '7C000048';   # Count Leading Zeros Doubleword
		'popcntw' = '7C000049'; # Population Count Word
		'popcntd' = '7C00004A'; # Population Count Doubleword
		'clrldi' = '7C00004B';  # Clear Left Doubleword Immediate
		'clrlwi' = '7C00004C';  # Clear Left Word Immediate
		'clrrdi' = '7C00004D';  # Clear Right Doubleword Immediate
		'clrrwi' = '7C00004E';  # Clear Right Word Immediate
		'insrdi' = '7C00004F';  # Insert from Right Doubleword Immediate
		'insrwi' = '7C000050';  # Insert from Right Word Immediate
		'slwi'   = '7C000051';  # Shift Left Word Immediate
		'sldi'   = '7C000052';  # Shift Left Doubleword Immediate
		'srwi'   = '7C000053';  # Shift Right Word Immediate
		'srdi'   = '7C000054';  # Shift Right Doubleword Immediate

        # Branch
        'b' = '48000000'; # Branch
		'bl' = '4C000020'; # Branch and Link
		'blr' = '4C000021'; # Branch and Link Register
		'bctr' = '4C000022'; # Branch to Count Register
		'bctrl' = '4C000023'; # Branch to Count Register and Link
		'bc' = '4C000024'; # Branch Conditional
		'bca' = '4C000025'; # Branch Conditional Absolute
		'bcl' = '4C000026'; # Branch Conditional and Link
		'bcla' = '4C000027'; # Branch Conditional and Link Absolute
		'bcctr' = '4C000028'; # Branch Conditional to Count Register
		'bcctrl' = '4C000029'; # Branch Conditional to Count Register and Link
		'bclr' = '4C00002A'; # Branch Conditional to Link Register
		'bclrl' = '4C00002B'; # Branch Conditional to Link Register and Link
		'bcx' = '4C00002C'; # Branch Conditional Extended
		'bcxl' = '4C00002D'; # Branch Conditional Extended and Link
		'bcxx' = '4C00002E'; # Branch Conditional Extended Extended
		'bcxxl' = '4C00002F'; # Branch Conditional Extended Extended and Link

        # Load
        'lwz'  = '80000000'; # Load Word and Zero
		'lwzu' = '80200000'; # Load Word and Zero with Update
		'lwzux'= '81200000'; # Load Word and Zero with Update Indexed
		'lwzx' = '81000000'; # Load Word and Zero Indexed
		'lhz'  = 'A0000000'; # Load Halfword and Zero
		'lhzu' = 'A0200000'; # Load Halfword and Zero with Update
		'lhzux'= 'A1200000'; # Load Halfword and Zero with Update Indexed
		'lhzx' = 'A1000000'; # Load Halfword and Zero Indexed
		'lha'  = 'A8000000'; # Load Halfword Algebraic
		'lhau' = 'A8200000'; # Load Halfword Algebraic with Update
		'lhaux'= 'A9200000'; # Load Halfword Algebraic with Update Indexed
		'lhax' = 'A9000000'; # Load Halfword Algebraic Indexed
		'lbz'  = 'A4000000'; # Load Byte and Zero
		'lbzu' = 'A4200000'; # Load Byte and Zero with Update
		'lbzux'= 'A5200000'; # Load Byte and Zero with Update Indexed
		'lbzx' = 'A5000000'; # Load Byte and Zero Indexed
		'lfs'  = 'C0000000'; # Load Floating-Point Single
		'lfsu' = 'C0200000'; # Load Floating-Point Single with Update
		'lfsux'= 'C2200000'; # Load Floating-Point Single with Update Indexed
		'lfsx' = 'C2000000'; # Load Floating-Point Single Indexed
		'lfd'  = 'E0000000'; # Load Floating-Point Double
		'lfdu' = 'E0200000'; # Load Floating-Point Double with Update
		'lfdux'= 'E2200000'; # Load Floating-Point Double with Update Indexed
		'lfdx' = 'E2000000'; # Load Floating-Point Double Indexed

        # Store
		'stw'   = '90000000'; # Store Word
		'stwu'  = '90200000'; # Store Word with Update
		'stwux' = '91200000'; # Store Word with Update Indexed
		'stwx'  = '91000000'; # Store Word Indexed
		'sth'   = 'B0000000'; # Store Halfword
		'sthu'  = 'B0200000'; # Store Halfword with Update
		'sthux' = 'B1200000'; # Store Halfword with Update Indexed
		'sthx'  = 'B1000000'; # Store Halfword Indexed
		'stb'   = 'B4000000'; # Store Byte
		'stbu'  = 'B4200000'; # Store Byte with Update
		'stbux' = 'B5200000'; # Store Byte with Update Indexed
		'stbx'  = 'B5000000'; # Store Byte Indexed
		'stfs'  = 'D0000000'; # Store Floating-Point Single
		'stfsu' = 'D0200000'; # Store Floating-Point Single with Update
		'stfsux'= 'D2200000'; # Store Floating-Point Single with Update Indexed
		'stfsx' = 'D2000000'; # Store Floating-Point Single Indexed
		'stfd'  = 'F0000000'; # Store Floating-Point Double
		'stfdu' = 'F0200000'; # Store Floating-Point Double with Update
		'stfdux'= 'F2200000'; # Store Floating-Point Double with Update Indexed
		'stfdx' = 'F2000000'; # Store Floating-Point Double Indexed
		'stfiwx'= 'DC000000'; # Store Floating-Point Immediate Word Indexed

        # Pseudo-OP Codes
		
		# nop (No Operation)
		# Instruction: ori r0, r0, 0
        'nop' = '60000000';
		
		# li Rx, IMM (Load Immediate)
		# Instruction: addi Rx, r0, IMM
		# where XX is the register number and YYYY is the immediate value)
        #'li' = '38XXYYYY';
		
		# mr Rx, Ry (Move Register)
		# Instruction: or Rx, Ry, Ry
		# where XX is the destination register number and YY is the source register number
        #'mr' = '7CXXYY78';
		
		# not Rx, Ry (Not)
		# Instruction: nor Rx, Ry, Ry
		# where XX is the destination register number and YY is the source register number
        #'not' = '7CXXYYF8';
		
		# blr (Branch to Link Register)
		# Instruction: mtlr rX; blr
		# 4E800020 (where XX is the register number)
        #'blr' = '7C08XXXA';
    }

    if ($ppcOpCodes.ContainsKey($hexValue)) {
        Write-Host ("$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Input Value: $hexValue, PPC OP Code: $($ppcOpCodes[$hexValue])")
    } else {
        Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  No matching PPC OP Code found for input value: $hexValue"
    }
}


# Unused
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

# Title and Info
Write-Host ""
Write-Host "PS3HEN Offset Tool v1.0 [TEST VERSION 3]"
Write-Host ""

# Check switch to see if files should be compared
if ($compare) {
    try {
		# Read the first file
		Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Reading $($filename)..."
        $content1 = [System.IO.File]::ReadAllBytes($filename)
		Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Reading $($filename)...done"
		Write-Host ""
		
		# Read the second file
		Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Reading $($filename2)..."
        $content2 = [System.IO.File]::ReadAllBytes($filename2)
		Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Reading $($filename2)...done"
		Write-Host ""

		# Initialize an array to store the differences
        $differences = @()
		
        Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Comparing files..."

		# Iterate through the files comparing 4-byte chunks
        $chunkSize = 4
        for ($i = 0; $i -lt $content1.Count; $i += $chunkSize) {
			# Convert the 4-byte chunks to strings for comparison
            $chunk1 = [BitConverter]::ToString($content1, $i, $chunkSize).Replace("-", "")
            $chunk2 = [BitConverter]::ToString($content2, $i, $chunkSize).Replace("-", "")

			# Compare the chunks and store the differences
            if ($chunk1 -ne $chunk2) {
                $differences += "Difference at byte 0x{0:X8}: 0x{1} - 0x{2}`r`n" -f $i, $chunk1, $chunk2
                if ($debug) { Write-Host ("Difference at byte 0x{0:X8}: 0x{1} - 0x{2}" -f $i, $chunk1, $chunk2) }
            }
        }
		
        Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Comparing files...done"

		# Save the differences to a file or print a message if no differences are found
        if ($differences.Count -gt 0) {
            $differences | Set-Content -Path (Join-Path $scriptPath "changes.txt")
            Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Differences saved to changes.txt."
			exit 1
        } else {
            Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  No differences found between the files."
			exit 1
        }
    } catch {
        Write-Error "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  An error occurred while comparing the files: $_"
		exit 1
    }
}

# Check if the fwver parameter is provided, and prompt the user for it if it isn't
if (-not $fwver) {
    do {
        $fwver = Read-Host -Prompt "Please select firmware version (Available versions: 480C, 481C, 482C, 482D, 483C, 484C, 484D, 490C)"
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

function ReplaceBytes ($chunkedContent, $searchValue, $replacementValue) {
    for ($i = 0; $i -lt $chunkedContent.Length; $i++) {
        if ($chunkedContent[$i] -eq $searchValue) {
            $chunkedContent[$i] = $replacementValue
        }
    }
    return $chunkedContent
}

function WriteNewBytes ($chunkedContent, $inputFile) {
    # Convert the chunked content array back to bytes
    $byteContent = New-Object 'Byte[]' ($chunkedContent.Length * 4)
    for ($i = 0; $i -lt $chunkedContent.Length; $i++) {
        $bytes = [BitConverter]::GetBytes($chunkedContent[$i])
        if ([BitConverter]::IsLittleEndian) {
            [Array]::Reverse($bytes)
        }
        $bytes.CopyTo($byteContent, $i * 4)
    }

    # Write the byte array to the input file
    Set-Content -Path $inputFile -Value $byteContent -Encoding Byte -Force
}

# Select the offsets dictionary for the selected firmware version
$currentDictionary = $offsetsDictionary.$fwver

# Read binary file content into memory
Write-Host "*** THIS STEP MAY TAKE A WHILE DEPENDING ON THE SPEED OF YOUR COMPUTER ***"
Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Reading binary file content into 0x4 byte chunks..."
$fileContent = [System.IO.File]::ReadAllBytes($filename)

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
    #if ($debug) { Write-Host "Processing chunk: $_     Offset: $offset     Range: $($range.Name)" }
	# Increment the chunk index
    $chunkIndex++
	# Convert the hexadecimal string to an unsigned 32-bit integer
    [UInt32]("0x" + $_) 
}

Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Reading binary file content in 0x4 byte chunks...done"
Write-Host ""
Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Searching for gadgets..."
Write-Host ""

# Search for each offset value in the offsets dictionary
$summaryTable = @()
$foundOffsets = @()

# Loop through each offset in the dictionary
foreach ($offset in $currentDictionary.GetEnumerator()) {
	
	# Convert the offset value to UInt32 and display a search message
    $searchValue = [UInt32]("0x" + $offset.Value)
    Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Searching for $($offset.Name) with value 0x$($offset.Value)..."

	# Initialize a counter for number of instances found
    $count = 0
    $offsetFound = $false
	
	# Initialize a hashtable to store the count of matches for each gadget
	$gadgetMatchesCount = @{}

	# Loop through each element in the file content array
    for ($i = 0; $i -lt $chunkedFileContent.Length; $i++) {
		
		# Check if the element matches the search value
        if ($chunkedFileContent[$i] -eq $searchValue) {
			
			# Calculate the file offset and display the match information
            $offsetFound = $true

            $foundAtOffset = '0x{0:X8}' -f (($i * 4) + 0x4)
            $formattedBytes = '{0:X8}' -f $searchValue
            if ($debug) { 
				Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Found at offset: $foundAtOffset -> $formattedBytes (Search Value: 0x$('{0:X8}' -f $searchValue))"
			}

            # Increment the instance counter and check if the match already exists in the results array
            $count++
            $existingOffset = $foundOffsets | Where-Object { $_.Name -eq $offset.Name -and $_.FileOffset -eq $foundAtOffset }

			# Add a new match to the results array if it doesn't already exist
            if ($null -eq $existingOffset)
			{
				$foundOffsets += [PSCustomObject]@{
					GadgetName = $offset.Name
					FileOffset = $foundAtOffset
					Value = '0x{0:X8}' -f $searchValue
					Instances = $count
				}
				# Display the message for a new match found
				if ($debug)
				{ 
					Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  New match found for $($offset.Name) at offset $($foundAtOffset): $count instance(s) found."
				}
			} 
			else
			{
				# Update the count if the match already exists in the results array
				$existingOffset.Instances = $count
				if ($debug)
				{ 
					Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Additional match found for $($existingOffset.Name) at offset $($existingOffset.FileOffset): $count instance(s) found."
				}
			}
        }
    }

	# Replace the current fw value with the new fw value if -replace and -newfw switch are provided
	if ($replace -and $newfw) {
		# Get the new firmware offsets from the offsets dictionary
		$newFirmwareOffsets = $offsetsDictionary.$newfw
		# Get the replacement value for the current offset from the new firmware offsets dictionary
		$replacementValue = [UInt32]("0x" + $newFirmwareOffsets[$offset.Name])

		# Check if the new firmware offsets dictionary contains the current offset name
		if ($newFirmwareOffsets.ContainsKey($offset.Name)) {
			# Loop through the chunked file content
			for ($i = 0; $i -lt $chunkedFileContent.Length; $i++) {
				# If the current value in the chunked file content matches the search value
				if ($chunkedFileContent[$i] -eq $searchValue -and $i -gt 0) {
					# Replace the current value with the new replacement value in the chunked file content
					$chunkedFileContent[$i] = $replacementValue
					if ($debug) {
						Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Replaced at offset: 0x$('{0:X8}' -f ($i * 4)) with 0x$('{0:X8}' -f $replacementValue) for $($offset.Name)."
					}
				}
			}
		} else {
			# Output debug information if no replacement value is found for the current offset in the new firmware offsets
			if ($debug) { Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  No replacement value found for $($offset.Name) in new firmware offsets." }
		}

		# Display the total number of instances found for the current offset
		if ($offsetFound) {
			$formattedCount = '{0:d}' -f $count
			Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Found $formattedCount matches for $($offset.Name)."
			Write-Host ""

			# Add a summary of the results to the summary table
			$summaryTable += [PSCustomObject]@{
				GadgetName = $offset.Name
				Instances = $count
			}
		} else {
			Write-Host "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  No matches found for $($offset.Name)."
			Write-Host ""
		}
	}
}

# Call the WriteNewBytes function to update the input file with the replaced values
if ($replace -and $newfw)
{
	#Add-Content -Path $logFile -Value "$(Get-Date -Format '[yyyy-MM-dd HH:mm:ss]')  Writing $([string]::Join(', ', ($chunkedFileContent | ForEach-Object { '0x{0:X8}' -f $_ }))) to $($filename)."
	#Write-Host ""
	WriteNewBytes -chunkedContent $chunkedFileContent -inputFile $filename
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
	$tableOutput = $foundOffsets | Format-Table -Property GadgetName, FileOffset, Value -AutoSize | Out-String
	Add-Content -Path $logFile -Value $tableOutput
	Write-Host $tableOutput

    # Output summary table of gadget values and their counts
    Write-Host "Summary of instances for each gadget value:"
    Write-Host ""
    $summaryTable | Format-Table -AutoSize | Out-Host

    if ($js) {
        $jsOutput = @()
        $uniqueGadgets = $foundOffsets.GadgetName | Select-Object -Unique
        foreach ($gadgetName in $uniqueGadgets) {
            $offsetsForGadget = $foundOffsets | Where-Object { $_.GadgetName -eq $gadgetName } | ForEach-Object { $_.FileOffset }
            $offsetsString = ($offsetsForGadget -join ",`n`t")
            $jsOutput += "const $gadgetName = [`n`t$offsetsString`n];`n"
        }

        $jsOutput -join "`n" | Out-File -FilePath (Join-Path $scriptPath "gadget_offsets_${fwver}.js")
        Write-Host "JavaScript output saved to gadget_offsets_${fwver}.js"
    }
	
	if ($opcode) {
		$opcodeOutput = @()
		$uniqueGadgets = $foundOffsets.GadgetName | Select-Object -Unique
		foreach ($gadgetName in $uniqueGadgets) {
			$offsetsForGadget = $foundOffsets | Where-Object { $_.GadgetName -eq $gadgetName } | ForEach-Object { $_.FileOffset }
			$offsetsString = ($offsetsForGadget -join ",`n`t")
			$opcodeOutput += "GadgetName: $gadgetName`n"
			foreach ($offset in $offsetsForGadget) {
				$ppcOpCode = Get_PPC_OP_Code $offset
				$opcodeOutput += "Offset: $offset, OpCode: $ppcOpCode`n"
			}
			$opcodeOutput += "`n"
		}

		$opcodeOutput -join "`n" | Out-File -FilePath (Join-Path $scriptPath "gadget_opcodes_${fwver}.txt")
		Write-Host "OpCode output saved to gadget_opcodes_${fwver}.txt"
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
	
	# Write Log
	if ($debug) { Set-Content -Path $logFile -Value $summaryString -Encoding utf8 -Force }
} else {
	# Output message indicating that no matching offsets were found
    Write-Host "No matching offsets found for $fwver."
	
	# Write Log
	if ($debug) { Set-Content -Path $logFile -Value $summaryString -Encoding utf8 -Force }
}