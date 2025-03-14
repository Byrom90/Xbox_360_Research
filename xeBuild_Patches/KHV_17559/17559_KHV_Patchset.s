# This is a complete decompile of the HV & Kernel patches applied by xeBuild when building a nand for RGH systems
# They will compile 1:1 identical to the patches found in the kernel/hv section of the .bin files provided with xeBuild (& JRunner)
# I've tried to name and note what each patch is doing but be warned they may not be entirely accurate.
# - Byrom -

# Credits:
#			RGLoader - 17489 Devkit patches with labels
#			AndThePickles - Filling in some of the blanks

# TODO: Clean this up a bit
#		Complete names & notes

.include "../macros.S"

# HV & KERNEL VERSION: 17559

## Stock HV function & addresses ##
# Start of the syscall table. This is where the address of the real HvxGetVersions (Syscall0) function is found
.set Syscall_Table, 0x15FD0
# The real HvxGetVersions function address found above
.set HV_HvxGetVersions,0x1cc8
.set HV_memcpy, 0xa880
.set HV_Unk1, 0x2d8
.set HV_XeCryptAesKey, 0x200f8

# Custom function used to set the protection state. Created in empty space
.set HV_setmemprot, 0x154c

# Custom function to fix HV flags. Created in empty space. Is followed by HV PeekPoke syscall0 backdoor in the same set of patches
.set HV_FlagFixer, 0xB510
.set HV_PP_Syscall0, 0xB564

#=============================================================================
		.globl _start
_start:
#=============================================================================

#============================================================================
#
#		HV PATCHES
#
#============================================================================

# ============================================================================
#	Branch to HV flag fix function???
# ============================================================================
# 00 00 18 80 00 00 00 01 48 00 B5 13
	MAKEPATCH 0x1880
0:
	bla HV_FlagFixer
9:

# ============================================================================
#	Devkit XEX2 AES key
# ============================================================================
# 00 00 00 F0 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
	MAKEPATCH 0xF0
0:
	.long 0
	.long 0
	.long 0
	.long 0
9:
# ============================================================================	
# Disable memory protection
#	ExceptionVectorDSI
# ============================================================================
# 00 00 11 BC 00 00 00 01 48 00 15 4E
	MAKEPATCH 0x11BC
0:
	ba HV_setmemprot
9:

# ============================================================================
#	The li %r4, 7 in this is modified by the syscall0 backdoor 
#	to toggle the memory protection state.
#	ENABLED = 0x38800000 (li r4, 0) || DISABLED = 0x38800007 (li r4, 7)
# ============================================================================
# 00 00 15 4C 00 00 00 04 38 80 00 07 7C 21 20 78 7C 35 EB A6 48 00 11 C2
	MAKEPATCH HV_setmemprot
0:
	li %r4, 7		# DISABLED by default
	andc %r1, %r1, %r4
	mtspr 0x3B5, %r1 # .long 0x7C35EBA6
	ba 0x11C0
9:

# ============================================================================
#	???
# ============================================================================
# 00 00 31 20 00 00 00 01 60 00 00 00
	MAKEPATCH 0x3120
0:
	nop
9:
# ============================================================================
# 	Disable fuse blowing ???
# ============================================================================
# 00 00 A5 60 00 00 00 02 38 60 00 01 4E 80 00 20
	MAKEPATCH 0xA560
0:
	li	  %r3, 1
	blr
9:
# ============================================================================
#	HvxLoadImageData
# ============================================================================
# 00 02 A3 0C 00 00 00 02 60 00 00 00 60 00 00 00
	MAKEPATCH 0x2A30C
0:
	nop
	nop
9:
# ============================================================================
#	HvxResolveImports
#	Bypass STATUS_REVISION_MISMATCH - C0000059
# ============================================================================
# 00 02 AA 80 00 00 00 01 60 00 00 00
	MAKEPATCH 0x2AA80
0:
	nop
9:
# ============================================================================
#	HvxResolveImports
#	Bypass STATUS_REVISION_MISMATCH - C0000059
# ============================================================================
# 00 02 AA 8C 00 00 00 01 60 00 00 00
	MAKEPATCH 0x2AA8C
0:
	nop
9:

# ============================================================================
#	HV Flag Fixer??? branched from 0x1880
#	Followed by HV Syscall0 PeekPoke backdoor starting at 0xB564
# ============================================================================
# 00 00 B5 10 00 00 00 48 7D 08 02 A6 A0 60 00 06 38 80 00 21 7C 63 20 78 
# B0 60 00 06 38 60 00 21 48 00 B5 3F 38 60 00 0A 48 00 B5 3F 7D 08 03 A6 
# 48 00 02 DA 3C 80 80 00 60 84 02 00 78 84 07 C6 64 84 EA 00 54 63 C0 0E 
# 90 64 10 14 80 64 10 18 54 63 01 8D 41 82 FF F8 4E 80 00 20 3D 60 72 62 
# 61 6B 74 72 7F 03 58 40 41 9A 00 08 48 00 1C CA 2B 04 00 04 41 99 00 94 
# 41 9A 00 44 38 A0 15 4C 3C C0 38 80 2B 04 00 02 40 9A 00 0C 60 C6 00 07 
# 48 00 00 0C 2B 04 00 03 40 9A 00 1C 38 00 00 00 90 C5 00 00 7C 00 28 6C 
# 7C 00 2F AC 7C 00 04 AC 4C 00 01 2C 38 60 00 01 4E 80 00 20 7D 88 02 A6 
# F9 81 FF F8 F8 21 FF F1 7C A8 03 A6 7C E9 03 A6 80 86 00 00 90 85 00 00 
# 7C 00 28 6C 7C 00 2F AC 7C 00 04 AC 4C 00 01 2C 38 A5 00 04 38 C6 00 04 
# 42 00 FF E0 4E 80 00 20 38 21 00 10 E9 81 FF F8 7D 88 03 A6 4E 80 00 20 
# 2B 04 00 05 40 9A 00 14 7C C3 33 78 7C A4 2B 78 7C E5 3B 78 48 00 A8 82 
# 38 60 00 02 4E 80 00 20

	MAKEPATCH HV_FlagFixer
0:
	# Not sure about this yet
	mflr %r8
	lhz %r3, 6(0)
	li %r4, 0x21
	andc %r3, %r3, %r4
	sth %r3, 6(0)
	li %r3, 0x21
	bla 0xb53c
	li %r3, 0xa
	bla 0xb53c
	mtlr %r8
	ba HV_Unk1

	lis %r4, 0x8000
	ori %r4, %r4, 0x200
	sldi %r4, %r4, 0x20
	oris %r4, %r4, 0xea00
	slwi %r3, %r3, 0x18
	stw %r3, 0x1014(%r4)
loc_b554:
	lwz %r3, 0x1018(%r4)
	rlwinm. %r3, %r3, 0, 6, 6
	beq loc_b554			# 0xb554
	blr 

# HV peek poke by replacing HvxGetVersions syscall - 0xB564
	lis %r11, 0x7262				# Freeboot syscall key - 0x72627472 "rbtr" 1st half
	ori %r11, %r11, 0x7472			# 2nd half
	# Check for the key
	cmplw cr6, %r3, %r11			# Check for Freeboot key
	beq cr6, checkOpType			# Branch to checkOpType if matches - 0xb578
	ba 	HV_HvxGetVersions			# If not, branch back to the real HvxGetVersions

checkOpType: # 0xb578
	cmplwi cr6, %r4, 4				# Check for 4 aka hvxExecute
	bgt cr6, doMemCpy				# If it's greter than 4 it must be MemCpy - 0xb610
	beq cr6, hvxExecuteCode			# If it matches then it's hvxExecute - 0xb5c4
	li %r5, HV_setmemprot			# Memory protections function address added in an earlier patch
	lis %r6, 0x3880					# Sets r6 to 0x38800000 - Remains like this if protections are to be ENABLED
	cmplwi cr6, %r4, 2				# Check for 2 aka set mem protections DISABLED
	bne cr6, checkforMemProtectOn	# If not, branch to check for mem protections ENABLED - 0xb59c
	ori %r6, %r6, 7					# Updates r6 to 0x38800007 - Indicating protections are to be DISABLED
	b setMemProtections				# Branch to set memory protections setup - 0xb5a4

checkforMemProtectOn: # 0xb59c
	cmplwi cr6, %r4, 3				# Check for 3 aka set mem protections ENABLED
	bne cr6, returnOne				# If not, branch to returnOne to exit - 0xb5bc

setMemProtections: # 0xb5a4
	li %r0, 0
	stw %r6, 0(%r5)					# Sets the start of the set mem function based on what was set in r6 earlier - ENABLED = 0x38800000 (li r4, 0) || DISABLED = 0x38800007 (li r4, 7)
	dcbst 0, %r5
	icbi 0, %r5
	sync 0
	isync 

returnOne: # 0xb5bc
	li %r3, 1
	blr 

hvxExecuteCode: # 0xb5c4
	mflr %r12
	std %r12, -8(%r1)
	stdu %r1, -0x10(%r1)
	mtlr %r5
	mtctr %r7

cpyLoop: # 0xb5d8
	lwz %r4, 0(%r6)
	stw %r4, 0(%r5)
	dcbst 0, %r5
	icbi 0, %r5
	sync 0
	isync 
	addi %r5, %r5, 4
	addi %r6, %r6, 4
	bdnz cpyLoop	# 0xb5d8
	blr 
	addi %r1, %r1, 0x10
	ld %r12, -8(%r1)
	mtlr %r12
	blr 

doMemCpy: # 0xb610
	cmplwi cr6, %r4, 5
	bne cr6, returnTwo	# Branch to returnTwo - 0xb628
	mr %r3, %r6
	mr %r4, %r5
	mr %r5, %r7
	ba HV_memcpy		# Branch to the HV MemCpy function

returnTwo: # 0xb628
	li %r3, 2
	blr 
9:
# ============================================================================
# HvxGetVersions address in syscall table
# Replace the address with custom hv peek poke function
# ============================================================================
# 00 01 5F D0 00 00 00 01 00 00 B5 64
	MAKEPATCH Syscall_Table
0:
	.long HV_PP_Syscall0
9:
# ============================================================================
#       HvxSecurity Functions  (sets machine acct flags)
# ============================================================================
# 00 00 6B B0 00 00 00 02 38 60 00 00 4E 80 00 20
	MAKEPATCH 0x6BB0 #;//HvxSecuritySetDetected
0:
	li	  %r3, 0
	blr
9:

# 00 00 6C 48 00 00 00 02 38 60 00 00 4E 80 00 20
	MAKEPATCH 0x6C48 #;//HvxSecurityGetDetected
0:
	li	  %r3, 0
	blr
9:

# 00 00 6C 98 00 00 00 02 38 60 00 00 4E 80 00 20
	MAKEPATCH 0x6C98 #;//HvxSecuritySetActivated
0:
	li	  %r3, 0
	blr
9:

# 00 00 6D 08 00 00 00 02 38 60 00 00 4E 80 00 20
	MAKEPATCH 0x6D08 #;//HvxSecurityGetActivated
0:
	li	  %r3, 0
	blr
9:

# 00 00 6D 58 00 00 00 02 38 60 00 00 4E 80 00 20
	MAKEPATCH 0x6D58 #;//HvxSecuritySetStat
0:
	li	  %r3, 0
	blr
9:
# ============================================================================
#	HvxKeysGetKey - Allow access to all XeKeys properties
# ============================================================================
# 00 00 81 3C 00 00 00 01 48 00 00 30
	MAKEPATCH 0x813C
0:
	b	  0x30
9:
# ============================================================================
# 	Bypass CB sig check - Replaces call to XeCryptBnQwBeSigVerify
# ============================================================================
# 00 00 70 BC 00 00 00 01 38 60 00 01
	MAKEPATCH 0x70BC
0:
	li	  %r3, 1
9:
# ============================================================================
# 	Bypass CD check
# ============================================================================
# 00 00 72 68 00 00 00 01 38 60 00 00
	MAKEPATCH 0x7268
0:
	li	  %r3, 0
9:
# ============================================================================
# 	NOP MachineCheck
# ============================================================================
# 00 00 72 B4 00 00 00 01 60 00 00 00
	MAKEPATCH 0x72B4
0:
	nop
9:
# ============================================================================
#	NOP MachineCheck
# ============================================================================
# 00 00 72 C4 00 00 00 01 60 00 00 00
	MAKEPATCH 0x72C4
0:
	nop
9:
# ============================================================================
#	NOP MachineCheck
# ============================================================================
# 00 00 72 EC 00 00 00 02 60 00 00 00 39 60 00 01
	MAKEPATCH 0x72EC
0:
	nop
	li %r11, 1
9:
# ============================================================================
#	HvpCompareXGD2MediaID - Always return true
# ============================================================================
# 00 02 4D 58 00 00 00 02 38 60 00 01 4E 80 00 20
	MAKEPATCH 0x24D58
0:
	li	  %r3, 1
	blr
9:
# ============================================================================
# 	HvpDvdDecryptFcrt - Disable check
#	Replaces HvpPkcs1Verify branch
# ============================================================================
# 00 02 64 F0 00 00 00 01 38 60 00 01
	MAKEPATCH 0x264F0
0:
	li	  %r3, 1
9:
# ============================================================================
# 	Something related to xex aes key for dev signed support???
# 	Fixes bad signature
#	Overwrites the status STATUS_IMAGE_CHECKSUM_MISMATCH - C0000221
# ============================================================================
# 00 02 9B 08 00 00 00 0E 2B 3C 00 00 41 9A 00 30 2F 03 00 00 40 9A 00 10
# 38 80 00 F0 48 00 00 18 60 00 00 00 2B 1D 00 00 38 9F 04 40 40 9A 00 08 
# 38 80 00 54 7F 83 E3 78 4B FF 65 C1 3B E0 00 00
	MAKEPATCH 0x29B08
0:
	# This section overwrites a check on the return value of XeCryptBnQwBeSigVerify disabling STATUS_IMAGE_CHECKSUM_MISMATCH - C0000221
	cmpldi	  cr6, %r28, 0		# Value set from r4 being passed to main function being patched
	beq	  cr6, loc_29B3C 		# Branch if zero. This is how it's handled by the function normally when XeCryptBnQwBeSigVerify returns non-zero
	cmpwi	  cr6, %r3, 0		# Check the return value of XeCryptBnQwBeSigVerify performed just before these patches
	bne	  cr6, loc_29B24		# Branch when non-zero
	li	  %r4, 0xF0 			# Address of Devkit XEX2 AES key that has been set to all zero.
	b	  loc_29B34
	nop
	
	# Everything below remains unchanged??? Maybe it's just here to make it easier to create branches when compiling???
loc_29B24:	# At 0x29B24 here. This section is normally performed here just after the r28 check
	cmplwi	  cr6, %r29, 0
	addi	  %r4, %r31, 0x440
	bne	  cr6, loc_29B34
	li	  %r4, 0x54 			# Address of Retail XEX2 AES key - 20 B1 85 A5 9D 28 FD C3 40 58 3F BB 08 96 BF 91

loc_29B34:	# At 0x29B34 here

	mr	  %r3, %r28
	bl 0xffffffffffff65c0		# Branch to 0x200f8 XeCryptAesKey

loc_29B3C:	# At 0x29B3C here
	li	  %r31, 0
9:
# ============================================================================
# 	HvxImageTransformImageKey - Disables a conditional branch
# ============================================================================
# 00 02 B7 78 00 00 00 01 60 00 00 00
	MAKEPATCH 0x2B778
0:
	nop
9:
# ============================================================================
# 	HvxCreateImageMapping hash check
# ============================================================================
# 00 02 CA E8 00 00 00 01 38 60 00 00
	MAKEPATCH 0x2CAE8
0:
	li	  %r3, 0
9:
# ============================================================================
# 	HvxCreateImageMapping HV XEX region check 
# ============================================================================
# 00 02 CD D8 00 00 00 01 60 00 00 00
	MAKEPATCH 0x2CDD8
0:
	nop
9:
# ============================================================================
# 	HvxExpansionInstall - Disable conditional branch after XeCryptBnQwBeSigVerify
# ============================================================================	
# 00 03 08 9C 00 00 00 04 40 9A 00 08 3B A0 00 00 60 00 00 00 60 00 00 00
MAKEPATCH 0x3089C
0:
	bne	  cr6, loc_2B8
	li	  %r29, 0

loc_2B8:
	nop
	nop
9:
# ============================================================================
#	HvpInstallExpansion - Disable XeKeysStatus check
# ============================================================================
# 00 03 04 E8 00 00 00 01 60 00 00 00
	MAKEPATCH 0x304E8
0:
	nop
9:
# ============================================================================
#	HvpInstallExpansion - Disable KV Restricted Privs check
# ============================================================================
# 00 03 04 FC 00 00 00 01 60 00 00 00
	MAKEPATCH 0x304FC
0:
	nop
9:

#============================================================================
#
#		KERNEL PATCHES
#
#============================================================================

#============================================================================
# Patches XexpConvertError
#============================================================================
# 00 07 B9 20 00 00 00 02 38 60 00 00 4E 80 00 20

    KMAKEPATCH 0x8007B920
0:
    li %r3, 0
    blr 
9:

#=============================================================================
# Patches branch to XexpVerifyMediaType within XexpLoadXexHeaders
#=============================================================================
# 00 07 C4 B8 00 00 00 01 38 60 00 01

    KMAKEPATCH 0x8007C4B8
0:
    li %r3, 1
9:

#=============================================================================
# Patches branch to RtlImageXexHeaderString within XexpLoadFile
#=============================================================================
# 00 07 C5 E8 00 00 00 01 38 60 00 00

    KMAKEPATCH 0x8007C5E8
0:
    li %r3, 0
9:

#=============================================================================
# Patch within XexpLoadFile
#=============================================================================
# 00 07 C6 34 00 00 00 01 39 60 00 00

    KMAKEPATCH 0x8007C634
0:
    li %r11, 0
9:

#=============================================================================
# Patch within XexpLoadFile
#=============================================================================
# 00 07 C6 84 00 00 00 01 39 60 00 00

    KMAKEPATCH 0x8007C684
0:
    li %r11, 0
9:

#=============================================================================
# Patches XexpVerifyMinimumVersion
#=============================================================================
# 00 07 AF 08 00 00 00 02 38 60 00 00 4E 80 00 20

    KMAKEPATCH 0x8007AF08
0:
    li %r3, 0
    blr 
9:

#=============================================================================
# Patch within SfcxInspectLargeDataBlock
#=============================================================================
# 00 09 4F 78 00 00 00 01 3A E0 00 10

    KMAKEPATCH 0x80094F78
0:
    li %r23, 0x10
9:

#=============================================================================
# Patch within SataCdRomAuthenticationExInitialize
#=============================================================================
# 00 09 98 D0 00 00 00 01 2B 0B 00 FF

    KMAKEPATCH 0x800998D0
0:
    cmplwi cr6, %r11, 0xff
9:

#=============================================================================
# Patches to disable fatal error screen E66 (VdDisplayFatalError)
# Caused by DVD drive (ERROR_XSS_CDROM_COULD_NOT_CREATE_DEVICE)
#=============================================================================
# 00 09 92 B4 00 00 00 05 38 60 00 00 60 00 00 00 60 00 00 00 60 00 00 00 60 00 00 00

    KMAKEPATCH 0x800992B4
0:
    li %r3, 0
    nop 
    nop 
    nop 
    nop 
9:

#=============================================================================
# Patches XeKeysVerifyRSASignature
#=============================================================================
# 00 10 9C 90 00 00 00 02 38 60 00 01 4E 80 00 20

    KMAKEPATCH 0x80109C90
0:
    li %r3, 1
    blr 
9:

#=============================================================================
# Patches XeKeysSecurityConvertError
#=============================================================================
# 00 10 A7 88 00 00 00 02 38 60 00 00 4E 80 00 20

    KMAKEPATCH 0x8010A788
0:
    li %r3, 0
    blr 
9:

#=============================================================================
# Patches XeKeysDvdAuthExConvertError
#=============================================================================
# 00 10 AA 68 00 00 00 02 38 60 00 00 4E 80 00 20 

    KMAKEPATCH 0x8010AA68
0:
    li %r3, 0
    blr 
9:

#=============================================================================
# Patches _XeKeysRevokeIsValid
#=============================================================================
# 00 10 AF 30 00 00 00 02 38 60 00 01 4E 80 00 20 

    KMAKEPATCH 0x8010AF30
0:
    li %r3, 1
    blr 
9:

#=============================================================================
# Patches XeKeysRevokeIsRevoked
#=============================================================================
# 00 10 B1 38 00 00 00 02 38 60 00 00 4E 80 00 20 

    KMAKEPATCH 0x8010B138
0:
    li %r3, 0
    blr 
9:

#=============================================================================
# Patches _XeKeysRevokeIsRevoked
#=============================================================================
# 00 10 B0 E8 00 00 00 02 38 60 00 00 4E 80 00 20 

    KMAKEPATCH 0x8010B0E8
0:
    li %r3, 0
    blr 
9:

#=============================================================================
# Patches XeKeysRevokeIsDeviceRevoked
#=============================================================================
# 00 10 B2 78 00 00 00 02 38 60 00 00 4E 80 00 20 

    KMAKEPATCH 0x8010B278
0:
    li %r3, 0
    blr 
9:

#=============================================================================
# Patches XeKeysRevokeConvertError
#=============================================================================
# 00 10 B3 F8 00 00 00 02 38 60 00 00 4E 80 00 20

    KMAKEPATCH 0x8010B3F8
0:
    li %r3, 0
    blr 
9:

#=============================================================================
# Patches XeKeysConsoleSignatureVerification
#=============================================================================
# 00 10 BF 20 00 00 00 05 2B 05 00 00 38 60 00 01 41 9A 00 08 90 65 00 00 4E 80 00 20

    KMAKEPATCH 0x8010BF20
0:
    cmplwi cr6, %r5, 0
    li %r3, 1
    beq cr6, 0x8   # 0x8010bf30
    stw %r3, 0(%r5)
    blr
9:

#=============================================================================
# Patches XeCryptBnQwBeSigVerify
#=============================================================================
# 00 11 19 90 00 00 00 02 38 60 00 01 4E 80 00 20

    KMAKEPATCH 0x80111990
0:
    li %r3, 1
    blr 
9:

#=============================================================================
# Patch within MassConfigureTransferCable (Skips hdd security sector verification???)
#=============================================================================
# 00 0E 17 54 00 00 00 01 48 00 00 54

    KMAKEPATCH 0x800E1754
0:
    b 0x54  # 0x800e17a8
9:

#=============================================================================
# Patch within MassConfigureTransferCable
#=============================================================================
# 00 0E 17 CC 00 00 00 03 83 5C 00 98 60 00 00 00 60 00 00 00

    KMAKEPATCH 0x800E17CC
0:
    lwz %r26, 0x98(%r28)
    nop 
    nop 
9:

#=============================================================================
# Patches SataDiskAuthenticateDevice (Disables hdd security sector verification???)
#============================================================================
# 00 15 D9 D8 00 00 00 02 38 60 00 01 4E 80 00 20

    KMAKEPATCH 0x8015D9D8
0:
    li %r3, 1
    blr 
9:

#=============================================================================
# Patches here use the space available within XeKeysConsoleSignatureVerification
# due to it being patched out earlier and no longer used.
#============================================================================
# 00 10 BF 40 00 00 00 2C 40 98 00 08 4E 80 00 20 3C 60 80 10 3C A0 00 00
# 38 80 00 00 60 84 00 08 60 63 BF D0 38 C0 00 00 4B F7 18 61 38 60 00 00
# 3C 80 80 10 60 84 BF EC 4C 00 01 2C 90 64 00 00 4B F5 54 64 38 A1 00 54
# 3C E0 80 10 60 E7 BF EC 81 07 00 00 4C 00 01 2C 2B 08 00 00 41 9A 00 0C
# 7F FF FB 78 4B FF FF EC 4E 80 00 20 2B 03 00 14 40 9A 00 24 3C E0 80 10
# 60 E7 BF EC 81 07 00 00 4C 00 01 2C 2B 08 00 00 41 9A 00 0C 7F FF FB 78
# 4B FF FF EC 4B FF C4 44 5C 44 65 76 69 63 65 5C 46 6C 61 73 68 5C 6C 61
# 75 6E 63 68 2E 78 65 78 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
# 12 34 56 78

    KMAKEPATCH 0x8010BF40
0:
    #=============================================================================
    # Branched here from a patch in Phase1Initialization
    # Checks if xam was loaded successfully.
    # Branches to launch.xex loader if successful
    #=============================================================================
    bge cr6, 0x8    		# If xam was loaded successfully branch to the function that loads launch.xex at 0x8010bf48 below
    blr 					# If not, branch back to init to display fatal error E79 if xam wasn't loaded  
  
    #=============================================================================
    # Branched here from patch above
    # launch.xex loader
    # we're at 0x8010bf48 at this point
    #=============================================================================
# XexLoadImage Setup
    lis %r3, 0x8010			# Set r3 to address of launch.xex path string 0x8010bfd0 - 1st half
    lis %r5, 0				# Set r5 (MinimumVersion)
    li %r4, 0				# Set r4 (ModuleTypeFlags) - 1st half
    ori %r4, %r4, 8			# Set r4 (ModuleTypeFlags) - 2nd half
    ori %r3, %r3, 0xbfd0	# Set r3 to address of launch.xex path string 0x8010bfd0 - 2nd half
    li %r6, 0				# Set r6 (pHandle)
# Run XexLoadImage 
    bl 0xfffffffffff71860   # 0x8007d7c0 - XexLoadImage - Attempt to load launch.xex. Note there is no check for whether this was successful
# Signify this has completed
    li %r3, 0				# Set r3 to zero
    lis %r4, 0x8010			# Set r4 to the address other functions check for completion (0x8010bfec) - 1st half - (The 0x12345678 after the launch.xex path)
    ori %r4, %r4, 0xbfec	# Set r4 to the address other functions check for completion (0x8010bfec) - 2nd half
    isync 
    stw %r3, 0(%r4)			# Sets value at the address to zero so signify completion to allow other functions to act accordingly
# Complete - Return back
    b 0xfffffffffff55464 	# 0x800613dc - Branches back to Phase1Initialization to continue. This is where it would have branched to originally if xam was loaded without these patches

    #=============================================================================
    # Branched here from a patch in XexLoadExecutable
    # we're at 0x8010BF7C at this point
    #=============================================================================
    addi %r5, %r1, 0x54
# Set the address to check
    lis %r7, 0x8010			# Set r7 to the address to check for completion (0x8010bfec) - 1st half - (The 0x12345678 after the launch.xex path)
    ori %r7, %r7, 0xbfec	# Set r7 to the address to check for completion (0x8010bfec) - 2nd half
# Check value is zero loop - We're at 0x8010bf88
    lwz %r8, 0(%r7)			# Stores the current value at the address in r8 - Jumps back here until the value is zero
    isync 
    cmplwi cr6, %r8, 0		# Checks if value is zero - This would signify the launch.xex loader has ran and therefore set the value to zero
    beq cr6, 0xC    		# If true branch to the blr at 0x8010bfa0  
    mr %r31, %r31
    b 0xffffffffffffffec   	# Branches back to the storing the value for rechecking 0x8010bf88
# Check has completed successfully
    blr						# Check returned true so return

    #=============================================================================
    # Branched here from a patch in XeKeysGetKeyProperties
    # we're at 0x8010BFA4 at this point
    #=============================================================================
    cmplwi cr6, %r3, 0x14
    bne cr6, 0x24   		# If false, skip everything and branch to the complete branch at 0x8010bfcc
# Set the address to check
    lis %r7, 0x8010			# Set r7 to the address to check for completion (0x8010bfec) - 1st half - (The 0x12345678 after the launch.xex path)
    ori %r7, %r7, 0xbfec	# Set r7 to the address to check for completion (0x8010bfec) - 2nd half
# Check value is zero loop - We're at 0x8010bfb4
    lwz %r8, 0(%r7)			# Stores the current value at the address in r8 - Jumps back here until the value is zero
    isync 
    cmplwi cr6, %r8, 0		# Checks if value is zero - This would signify the launch.xex loader has ran and therefore set the value to zero
    beq cr6, 0xC    		# If true branch to the complete branch at 0x8010bfcc
    mr %r31, %r31
    b 0xffffffffffffffec    # Branches back to the storing the value for rechecking at 0x8010bfb4
# Check has completed successfully
    b 0xffffffffffffc444    # 0x80108410 - HvxKeysGetKeyProperties (not _HvxKeysGenerateRandomKey. naming by script outdated ????)

    #=============================================================================
    # launch.xex path string - \Device\Flash\launch.xex
    # we're at 0x8010bfd0 at this point
    #=============================================================================
    .long 0x5C446576    
    .long 0x6963655C    
    .long 0x466C6173    
    .long 0x685C6C61    
    .long 0x756E6368    
    .long 0x2E786578
    .long 0

    #=============================================================================
    # Functions above will loop until this is set to zero when loading launch.xex
    # we're at 0x8010bfec at this point
    #=============================================================================
    .long 0x12345678
9:

#=============================================================================
# Patch within Phase1Initialization
# Branch to check if xam was loaded
# This is the first part of the launch.xex loader
#============================================================================
# 00 06 13 CC 00 00 00 01 48 0A AB 75

    KMAKEPATCH 0x800613CC
0:
    bl 0xaab74  # 0x8010bf40
9:

#=============================================================================
# Patch within XexLoadExecutable
#============================================================================
# 00 07 D7 F8 00 00 00 01 48 08 E7 85

    KMAKEPATCH 0x8007D7F8
0:
    bl 0x8e784  # 0x8010bf7c
9:

#=============================================================================
# Patches XeKeysGetKeyProperties to branch to a custom function
#============================================================================
# 00 10 8E 70 00 00 00 01 48 00 31 34

    KMAKEPATCH 0x80108E70 
0:
    b 0x3134    # 0x8010bfa4
9:

#============================================================================
	.long 0xffffffff
	.end
#============================================================================
