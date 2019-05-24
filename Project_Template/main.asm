INCLUDE Irvine32.inc


.data
; ---------- - display messages-------------- -

Did byte "ID|", 0
Dname byte "Names               |", 0
Dage byte "Ages ", 0
Ddec byte "Descriptions                  |", 0
Dgender byte "Gender    |", 0
Ddepart byte "Depart     |", 0
counter dword  0
tempmale byte " Male     ", 0
tempfemale byte " Female   ", 0
tempopd byte " O.P.D     ", 0
tempems byte " EM.S      ", 0
line byte "-------------------------------------------------------------------------------", 0
line2 byte "_______________________________________________________________________________", 0
NNF byte "The Name Not Found ,Press (y) To Try again Or Any Key To End : ", 0
ExistName byte "The Name You Entred Is Exist Press (y) To Try again Or (n) To End : ", 0
;---------------------------------senario section-----------------------------------------
SKeyChoose byte "- Did You Want To Load A previous Data ? Press (y) if yes And (n) if no : ",0
SKeyChoose2 byte "- Enter The Key :",0
Sadd byte "-1- For Add Patiant :",0
Sdelete byte "-2- For Delete Patiant :",0
Sedit byte "-3- For Edit Patiant :",0
Ssearch byte "-4- For Search For Patiant :",0 
Slist byte "-5- For List pataints :",0
SlistA byte "-a- List Alphabetical :",0
Slistopd byte "-b- List O.P.D patients :",0
Slistems byte "-c- List Emergency patients :",0
SLoad byte "-6- Load Data From File :",0
SSave byte "-7- Save Data To File :",0
SExit byte "-8- Exit Program :",0
SEnterKey byte "Please Enter The Key :",0
Stemp dword  0
Stemparr byte 21 dup(?)






;-------------------------------------------------------------------------------------------
BUFFER_SIZE = 2000
key byte "r",0
delim byte '@'
term byte '$'
SearchGeneralIndex dword 0
DeleteGeneralIndex dword 0
NameToSearch byte 21 dup(0)
IdToSearch dword 0

; ##################  original arrays ##################
Names byte 200 dup(0)

Ages dword 100 dup(0)
Genders byte 100 dup(0)
Departments byte 100 dup(0)
DeleteArr byte 200 dup(0)

Descriptions byte 300 dup(0)
NameCount dword 0
NameIndex dword - 21
IdIndex dword - 1



;################## insert values to Signle strings and insert these strings to the original arrays ##################
SingleName byte 21 dup(' ')
SingleDesc byte 31 dup(' ')
SingleGender byte 0
SingleDep byte 0
SingleAge dword 0

;########## offsets detremine the next position in the array to insert directly and stops the overrite ################
NameOffset dword 0
DepOffset dword 0
DepRef dword 0
AgeOffset dword 0
DescOffset dword 0 
GenderOffset dword 0
DeleteOffset dword 0
DeleteOffset2 dword 0
EncryptionOffset dword 0
TotalOffset dword 0

; ########## elements in the arrays ################
NameElem dword 0
DepElem dword 0
AgeElem dword 0
DescElem dword 0
GenderElem dword 0
EncryptionSize dword 0




buffer BYTE BUFFER_SIZE DUP(? )
filename BYTE "output.txt", 0
fileHandle HANDLE ?





enternamestr byte "Enter Name : ", 0
enteridstr byte "Enter ID  : ", 0
enteragestr byte "Enter Age  : ", 0
enterdeprstr byte "Enter '1' for OPD '2' for emergency : ",0
entergenderstr byte  "Enter Gender (m/f)  : ", 0
enterdescstr byte  "Enter Description : ", 0
searchnamestr byte  "Search By Name : ", 0
searchidstr byte  "Search By ID : ", 0





.code

MAIN proc

K1:
mov edx , offset Sadd
call writestring
call crlf
mov edx , offset Sdelete
call writestring
call crlf
mov edx , offset Sedit
call writestring
call crlf
mov edx , offset Ssearch
call writestring
call crlf
mov edx , offset Slist
call writestring
call crlf
mov edx , offset SLoad
call writestring
call crlf
mov edx , offset SSave
call writestring
call crlf
mov edx , offset SExit
call writestring
call crlf
call readdec
mov Stemp , eax
cmp eax , 1
je Padd
cmp eax , 2
je Pdelete
cmp eax , 3
je Pedit
cmp eax , 4
je Psearch
cmp eax , 5
je Plist
cmp eax , 6
je PLoad
cmp eax , 7
je PSave
cmp eax , 8
je PExit
jmp PExit
Padd:
	call addname
	call addage
	call adddesc
	call addgender
	call crlf
	call adddep
	call crlf
	jmp K1
Pdelete:
	call namesearch
	mov ebx , SearchGeneralIndex
	mov DeleteGeneralIndex, ebx
	call deletename
	call deleteage
	call deletedesc
	call deletegender
	call deletedep
	jmp K1
Pedit:
	call edit
	jmp K1

Plist:
	mov edx , offset SlistA
	call writestring
	call crlf
	mov edx , offset SlistOPD
	call writestring
	call crlf
	mov edx , offset SlistEMS
	call writestring
	call crlf
	call readchar
	call crlf
	cmp al ,'a'
	je PlistA
	cmp al ,'b'
	je PlistOPD
	cmp al ,'c'
	je PlistEMS
	jmp PExit
	PlistA:
		call SortName
		call display
		jmp K1
	PlistOPD:
		call display3
		jmp K1
	PlistEMS:
		call display2
		jmp K1


	Psearch:
		call searchrecored
		jmp K1

	PSave:
	mov edx , offset SEnterKey
	call writestring
	call crlf
	mov edx , offset Key
	mov ecx , 5
	call readstring

	call preparewritebuffer
	call sumoffset
	mov ebx,totaloffset
	mov EncryptionSize,ebx
	mov ebx ,offset buffer
	mov EncryptionOffset,ebx
	call encrypt_data
	call filewrite
	jmp K1



	Pload:
	mov edx , offset SEnterKey
	call writestring
	call crlf
	mov edx , offset Key
	mov ecx , 5
	call readstring

	 call fileread
	mov ebx, offset buffer
	mov encryptionoffset, ebx

	mov ebx, length buffer
	mov encryptionSize, ebx

	call encrypt_data
	call preparereadbuffer
	jmp K1












 jmp K1

 	PExit:



exit
MAIN ENDP


; ####### Search function uses{ { NameToSearch } } as the name we want to search for
; ####### Search function return{ { SearchGeneralIndex } } as the index of the name (in base 1)
; ####### Search function return{ { NameIndex } } as the index of the name(in bytes)

namesearch proc uses esi edi eax edx ecx ebx

mov NameCount, 0
mov edx, offset searchnamestr
call writestring
; ######### initialize the name with spaces ############

mov ax, ' '
mov edi, offset NameToSearch
mov ecx, length NameToSearch
rep stosb
; ####################################################


; ######### read the name ############

mov ecx, length NameToSearch
mov edx, offset NameToSearch
call readstring
; ###########################################
   

	mov esi, offset NameToSearch
	mov edi, offset Names

	mov ecx, length Names; ############## loop for only 100 Name ###################
    searchloop:


	mov esi, offset NameToSearch
	add NameIndex, length NameToSearch
	push ecx

; ######### check letter by letter for name ######
	mov ecx, length NameToSearch
checkloop :
	mov bl, [esi]
	mov al, [edi]
	cmp bl, al
	je inccount
	jmp checkcont


inccount :
	add NameCount, 1


checkcont :
	add esi, type NameToSearch
	add edi, type Names
	loop checkloop
	; ##############################################################

	pop ecx

	; ########check if we found the name########
	mov ebx, length NameToSearch
	cmp NameCount, ebx
	je namefound
	jmp searchcont


searchcont :
	mov NameCount, 0

	loop searchloop
	jmp notfound

namefound :
	mov eax, NameIndex				; ##############  divide name index
	mov edx, 0						; ##############  set reminder to 0
	mov ebx, length SingleName		; ##############  divide by single name length
	div ebx
	mov SearchGeneralIndex, eax		; ##############  put result to NameSearchElem
	jmp ex



notfound:
	mov NameIndex, -21

		ex :
		ret
namesearch endp






; ################## delete ##############################

; ####### delete function uses{ { DeleteGeneralIndex } } as the General Index that will be deleted from all arrays
deletename proc

	mov esi, offset Names
	mov edi, offset DeleteArr

		;################# get a copy of names array
	mov ecx, NameOffset
copyarr:
	mov bl, [esi]
	mov[edi], bl

	add esi, type Names
	add edi, type DeleteArr
loop copyarr

	mov eax, DeleteGeneralIndex		; ############### get offset of the old array to the (deleteElement)
	mov ebx, length SingleName
	mul ebx
	mov DeleteOffset, eax			; ###############  get the value of the offset


	mov eax, DeleteGeneralIndex		; ############### get offset of the new array to the element next to(deleteElement)
	add eax, 1						; ############### inrement index to get the next offset
	mov ebx,length SingleName
	mul ebx
	mov DeleteOffset2,eax			; ############### get the value of the offset


		; ############### set the offsets of the arrays
	mov esi, offset Names
	mov edi, offset DeleteArr
	add esi, DeleteOffset
	add edi, DeleteOffset2

		; ####### decrement NamesOffset by one name
		sub NameOffset, length SingleName

		; ####### decrement NameElem by one name
		sub NameElem, 1


		; ################# overrite the old array with elements in the new array
	mov ecx, NameOffset
overriteloop :
	mov bl, [edi]
		mov[esi], bl

		add esi, type Names
		add edi, type DeleteArr
		loop overriteloop



		ret


		deletename endp

		; --------------------------search2----------------------------------


		namesearch2 proc uses esi edi eax edx ecx ebx

		mov NameCount, 0

		; ######### initialize the name with spaces ############


		; ###########################################


		mov esi, offset NameToSearch
		mov edi, offset Names

		mov ecx, length Names; ############## loop for only 100 Name ###################
		searchloop:


	mov esi, offset NameToSearch
		add NameIndex, length NameToSearch
		push ecx

		; ######### check letter by letter for name ######
		mov ecx, length NameToSearch
		checkloop :
	mov bl, [esi]
		mov al, [edi]
		cmp bl, al
		je inccount
		jmp checkcont


		inccount :
	add NameCount, 1


		checkcont :
		add esi, type NameToSearch
		add edi, type Names
		loop checkloop
		; ##############################################################

		pop ecx

		; ########check if we found the name########
		mov ebx, length NameToSearch
		cmp NameCount, ebx
		je namefound
		jmp searchcont


		searchcont :
	mov NameCount, 0

		loop searchloop
		jmp notfound

		namefound :
	mov eax, NameIndex; ##############  divide name index
		mov edx, 0; ##############  set reminder to 0
		mov ebx, length SingleName; ##############  divide by single name length
		div ebx
		mov SearchGeneralIndex, eax; ##############  put result to NameSearchElem
		jmp ex



		notfound :
	mov NameIndex, -21

		ex :
		ret
		namesearch2 endp



	    ;####### delete function uses{ { DeleteGeneralIndex } } as the General Index that will be deleted from all arrays
		;####### delete description ##################
deletedesc proc

		mov esi, offset Descriptions
		mov edi, offset DeleteArr

		; ################# get a copy of descriptions array
		mov ecx, DescOffset
		copyarr :
	    mov bl, [esi]
		mov[edi], bl

		add esi, type Descriptions
		add edi, type DeleteArr
		loop copyarr

		mov eax, DeleteGeneralIndex; ############### get offset of the old array to the(deleteElement)
		mov ebx, length SingleDesc
		mul ebx
		mov DeleteOffset, eax      ; ###############  get the value of the offset


		mov eax, DeleteGeneralIndex; ############### get offset of the new array to the element next to(deleteElement)
		add eax, 1; ############### inrement index to get the next offset
		mov ebx, length SingleDesc
		mul ebx
		mov DeleteOffset2, eax; ############### get the value of the offset


		; ############### set the offsets of the arrays
		mov esi, offset Descriptions
		mov edi, offset DeleteArr
		add esi, DeleteOffset
		add edi, DeleteOffset2

		; ####### decrement DescOffset by one name
		sub DescOffset, length SingleDesc

		; ####### decrement DescElem by one name
		sub DescElem, 1


		; ################# overrite the old array with elements in the new array
		mov ecx, DescOffset
		overriteloop :
	mov bl, [edi]
		mov[esi], bl

		add esi, type Descriptions
		add edi, type DeleteArr
		loop overriteloop



		ret


		deletedesc endp


		; ########## delete selected age from array Ages
		; ####### delete function uses{ { DeleteGeneralIndex } } as the General Index that will be deleted from all arrays
deleteage proc

mov esi, offset Ages
mov edi, offset DeleteArr

; ################# get a copy of Ages array
mov ecx, AgeElem
copyarr :
	    mov ebx, [esi]
		mov[edi], ebx

		add esi, type Ages
		add edi, type Ages				 ; ############### mov the same size as Ages
loop copyarr

		mov eax, DeleteGeneralIndex		; ############### get offset of the old array to the(deleteElement)
		mov ebx, type SingleAge
		mul ebx
		mov DeleteOffset, ebx			; ###############  get the value of the offset (Address)


		mov eax, DeleteGeneralIndex		; ############### get offset of the new array to the element next to(deleteElement)
		add eax, 1						; ############### inrement index to get the next offset
		mov ebx, type SingleAge         ;
		mul ebx
		mov DeleteOffset2, eax			; ############### get the value of the offset


		; ############### set the offsets of the arrays
		mov esi, offset Ages
		mov edi, offset DeleteArr
		add esi, DeleteOffset
		add edi, DeleteOffset2

	
		; ####### decrement AgeElem by one Age
		sub AgeElem, 1


		; ################# overrite the old array with elements in the new array
		mov ecx, AgeElem
		overriteloop :
		mov ebx, [edi]
		mov[esi], ebx

		add esi, type Ages
		add edi, type Ages
		loop overriteloop


		ret


deleteage endp




; ########## delete selected gender from array Genders
; ####### delete function uses{ { DeleteGeneralIndex } } as the General Index that will be deleted from all arrays
deletegender proc

mov esi, offset Genders
mov edi, offset DeleteArr

; ################# get a copy of genders array
mov ecx, GenderElem
copyarr :
		    mov bl, [esi]
			mov[edi], bl

			add esi, type Genders
			add edi, type Genders; ############### mov the same size as Genders
			loop copyarr

			mov eax, DeleteGeneralIndex; ############### get offset of the old array to the(deleteElement)
			mov ebx, type SingleGender
			mul ebx
			mov DeleteOffset, eax; ###############  get the value of the offset(Address)


			mov eax, DeleteGeneralIndex; ############### get offset of the new array to the element next to(deleteElement)
			add eax, 1; ############### inrement index to get the next offset
			mov ebx, type SingleGender;
		    mul ebx
			mov DeleteOffset2, eax; ############### get the value of the offset


			; ############### set the offsets of the arrays
			mov esi, offset Genders
			mov edi, offset DeleteArr
			add esi, DeleteOffset
			add edi, DeleteOffset2


			; ####### decrement GenderElem by one Age
			sub GenderElem, 1


			; ################# overrite the old array with elements in the new array
			mov ecx, GenderElem
			overriteloop1 :
		    mov bl, [edi]
			mov[esi], bl

			add esi, type Genders
			add edi, type Genders
			loop overriteloop1


			ret

deletegender endp




				; ########## delete selected Department from array Departments
				; ####### delete function uses{ { DeleteGeneralIndex } } as the General Index that will be deleted from all arrays
				deletedep proc

				mov esi, offset Departments
				mov edi, offset DeleteArr

				; ################# get a copy of genders array
				mov ecx, DepElem
				copyarr :
			mov bl, [esi]
				mov[edi], bl

				add esi, type Departments
				add edi, type Departments; ############### mov the same size as Departments
				loop copyarr

				mov eax, DeleteGeneralIndex; ############### get offset of the old array to the(deleteElement)
				mov ebx, type SingleDep
				mul ebx
				mov DeleteOffset, eax; ###############  get the value of the offset(Address)


				mov eax, DeleteGeneralIndex; ############### get offset of the new array to the element next to(deleteElement)
				add eax, 1; ############### inrement index to get the next offset
				mov ebx, type SingleDep;
			mul ebx
				mov DeleteOffset2, eax; ############### get the value of the offset


				; ############### set the offsets of the arrays
				mov esi, offset Departments
				mov edi, offset DeleteArr
				add esi, DeleteOffset
				add edi, DeleteOffset2


				; ####### decrement DepElem by one Age
				sub DepElem, 1


				; ################# overrite the old array with elements in the new array
				mov ecx, DepElem
				overriteloop1 :
		    	mov bl, [edi]
				mov[esi], bl

				add esi, type Departments
				add edi, type Departments
				loop overriteloop1


				ret


				deletedep endp









; ################# addname #######################
addname proc uses esi edi eax edx ecx ebx

mov edx, offset enternamestr
call writestring

; ######### initialize the name with spaces ############


mov ax, ' '
mov edi, offset SingleName
mov ecx, length SingleName
rep stosb
;####################################################


;######### read the name ############


mov ecx, length SingleName
mov edx, offset SingleName
call readstring
; ###########################################


;####### enter name to signle string #########
mov esi, offset SingleName
mov edi, offset Names
add edi, NameOffset
rep movsb  ; ###### copy value from the string to the original array###########

add NameOffset, length SingleName




mov eax, NameOffset
mov edx,0
mov ebx,lengthof SingleName
div ebx

mov NameElem,eax





ret

addname endp


; ################# add Desciption #######################
adddesc proc uses esi edi eax edx ecx ebx

mov edx, offset enterdescstr
call writestring

; ######### initialize the description with spaces ############


mov ax, ' '
mov edi, offset SingleDesc
mov ecx, length SingleDesc
rep stosb
; ####################################################


; ######### read the description ############


mov ecx, length SingleDesc
mov edx, offset SingleDesc
call readstring
; ###########################################


; ####### enter desc to signle string #########
mov esi, offset SingleDesc
mov edi, offset Descriptions
add edi, DescOffset
rep movsb; ###### copy value from the string to the original array###########

add DescOffset, length SingleDesc




mov eax, DescOffset
mov edx, 0
mov ebx, lengthof SingleDesc
div ebx

mov DescElem, eax


ret

adddesc endp




; ######################################## add age procedure #################################
addage proc uses esi edi eax edx ecx ebx

mov edx, offset enteragestr
call writestring


call readint
mov SingleAge, eax

mov edi, offset Ages
add edi, AgeOffset

mov ebx, SingleAge

mov[edi], ebx

add AgeOffset, type SingleAge




mov eax, AgeOffset
mov edx, 0
mov ebx, type SingleAge
div ebx

mov AgeElem, eax

ret

addage endp

; ######################################## add gender procedure #################################
addgender proc  uses esi edi eax edx ecx ebx

mov edx, offset entergenderstr
call writestring


call readchar
mov SingleGender, al

mov edi, offset Genders
add edi, GenderOffset

mov bl, SingleGender

mov[edi], bl

add GenderOffset, type SingleGender

mov ebx, GenderOffset
mov GenderElem, ebx

ret

addgender endp


; ######################################## add departments procedure #################################
adddep proc  uses esi edi eax edx ecx ebx

mov edx, offset enterdeprstr
call writestring


call readchar
mov SingleDep, al

mov edi, offset Departments
add edi, DepOffset

mov bl, SingleDep

mov[edi], bl

add DepOffset, type SingleDep

mov ebx, DepOffset
mov DepElem, ebx

ret

adddep endp


; ################ Sort all user data according to Name ##########################################################################
; ------------------------------------------------------ -
; SortName
; Sort an array of n characters in ascending
; order, using the bubble sort algorithm.
; Receives: pointer to IdArray "esi", array size, pointer to NameArray "edi", pointer to describtion array "edx", pionter to genderArray "ebx"
; Returns: nothing
; ------------------------------------------------------ -

SortName proc USES eax ecx esi edi ebx edx
; pArray:PTR DWORD, ; pointer to array
; Count:DWORD; array size

mov ecx, NameElem
dec ecx; decrement count by 1
L1:
push ecx; save outer loop count
mov edi, offset Names; point to first value
mov esi, offset Ages
mov ebx, offset Descriptions
mov edx, offset Genders

push edx
mov edx, offset Departments
mov DepRef,edx
pop edx



L2 : mov al, [edi]; get array value
	cmp[edi + lengthof SingleName], al; compare a pair of values
	jg L3; if[ESI] <= [ESI + type SingleId], no exchange


	; ------------------------------------------------------------
	; exchange name
	; ------------------------------------------------------------
	push ecx
	push eax
	mov ecx, lengthof SingleName

	exchangeName :
mov al, [edi]
xchg al, [edi + lengthof SingleName]; exchange name
mov[edi], al
inc edi
loop exchangeName
pop eax
pop ecx

; ------------------------------------------------------------
; exchange discrebtion
; ------------------------------------------------------------
push ecx
push eax
mov ecx, lengthof SingleDesc
exchangediscrebtion :
mov al, [ebx]
xchg al, [ebx + lengthof SingleDesc]; exchange discribtion
mov[ebx], al
inc ebx
loop exchangediscrebtion
pop eax
pop ecx

; --------------------------------------------------
; exchange gender
; ------------------------------------------ -
push eax
mov eax, 0
mov al, [edx]
xchg al, [edx + type SingleGender]
mov[edx], al
inc edx
pop eax


; --------------------------------------------------
; exchange Departments
; ------------------------------------------ -
push ecx
mov ecx ,DepRef
push eax
mov eax, 0
mov al, [ecx]
xchg al, [ecx + type SingleDep]
mov[ecx], al
inc DepRef
pop eax
pop ecx


; -------------------------------------------- -
; exchange age
; ----------------------------------------------
push eax
mov eax, [esi]
xchg eax, [esi + type SingleAge]
mov[esi], eax
add esi, type SingleAge
pop eax



jmp l5





L3:
add esi, type SingleAge; move both pointers forward
add edi, lengthof SingleName
add ebx, length SingleDesc
add edx, lengthof SingleGender
add DepRef , lengthof SingleDep
l5 :
loop L2; inner loop
pop ecx			; retrieve outer loop count

dec ecx
cmp ecx,0
jne L1			; else repeat outer loop
	
L4 : ret
	SortName ENDP



; ################ Sort all user data according to age ##########################################################################
SortAge proc USES eax ecx esi edi ebx edx
mov ecx, NameElem
dec ecx; decrement count by 1
L1:
push ecx; save outer loop count
mov edi, offset Names; point to first value
mov esi, offset Ages
mov ebx, offset Descriptions
mov edx, offset Genders

L2 : mov al, [esi]; get array value
	cmp[esi + type SingleAge], al; compare a pair of values
	jg L3; if[ESI] <= [ESI + type SingleId], no exchange


	; ------------------------------------------------------------
	; exchange name
	; ------------------------------------------------------------
	push ecx
	push eax
	mov ecx, lengthof SingleName

	exchangeName :
mov al, [edi]
xchg al, [edi + lengthof SingleName]; exchange name
mov[edi], al
inc edi
loop exchangeName
pop eax
pop ecx

; ------------------------------------------------------------
; exchange discrebtion
; ------------------------------------------------------------
push ecx
push eax
mov ecx, lengthof SingleDesc
exchangediscrebtion :
mov al, [ebx]
xchg al, [ebx + lengthof SingleDesc]; exchange discribtion
mov[ebx], al
inc ebx
loop exchangediscrebtion
pop eax
pop ecx

; --------------------------------------------------
; exchange gender
; ------------------------------------------ -
push eax
mov eax, 0
mov al, [edx]
xchg al, [edx + type SingleGender]
mov[edx], al
inc edx
pop eax

; -------------------------------------------- -
; exchange age
; ----------------------------------------------
push eax
mov eax, [esi]
xchg eax, [esi + type SingleAge]
mov[esi], eax
add esi, type SingleAge
pop eax



jmp l5





L3:
add esi, type SingleAge; move both pointers forward
add edi, lengthof SingleName
add ebx, length SingleDesc
add edx, lengthof SingleGender
l5 :
loop L2				; inner loop
pop ecx	; retrieve outer loop count
loop L1				; else repeat outer loop
L4 : ret
SortAge ENDP



; ################ print array uses length of array in  ecx ##################################
	; ###################### print name array ######################
	; --------------------------------------
	; print array uses length of array in  ecx
	; and array offset in esi
	; and base "number of characters per line
	; --------------------------------------

	PrintNameArray proc uses ecx esi edi eax edx ebx
	mov ecx, NameElem
	mov esi, offset Names
	l1 :
push ecx
mov ecx, lengthof SingleName
l2 :
mov al, [esi]
call writechar
inc esi
loop l2
pop ecx
call crlf
loop l1

call crlf
ret
PrintNameArray endp



; ##################### encrypt arrays##############################
; ####### encrypt function uses{ {EncryptionOffset} } as the start of the array that will be encrypted
; ####### encrypt function uses{ {EncryptionSize} } as the Size of the array that will be encrypted
encrypt_data PROC uses eax ebx ecx esi edi edx
;
; encyrbt  the string by exclusive - ORing each
; byte with the encryption key byte.
; Receives: nothing
; Returns: nothing
; ----------------------------------------------------
pushad
mov ecx, EncryptionSize					; loop counter
mov esi, EncryptionOffset				; index 0 in buffer
mov edi, 0								; index 0 for key

L1 :
mov al, key[edi]
xor [esi], al; translate a byte
inc esi; point to next byte
inc edi; point to next byte
cmp edi, lengthof key			; if edi index gets to six, reset to zero
jne cont						; if not equal to 6, skip restting code
mov edi, 0						; reset edi / key to beginning

cont :
loop L1



popad
ret
encrypt_data ENDP





; ################ print array uses length of array in  ecx##################################
PrintDescArray proc uses ecx esi edi eax edx ebx
mov ecx, DescElem
mov esi, offset Descriptions
l1 :
push ecx
mov ecx, lengthof SingleDesc
l2 :
mov al, [esi]
call writechar
inc esi
loop l2
pop ecx
call crlf
loop l1

call crlf
ret
PrintDescArray endp


;################ print array uses length of array in  ecx##################################
; --------------------------------------
; print array uses length of array in  ecx
; and array offset in esi
; --------------------------------------
printAgeArray proc
mov ecx, AgeElem
mov esi, offset Ages
l02 :
mov eax, [esi]
call WriteInt
add esi, type SingleAge
call Crlf
loop l02



call Crlf

ret
printAgeArray endp



printGenderArray proc
mov ecx, GenderElem
mov esi, offset Genders
mov eax, 0
l02:
mov al, [esi]
call Writechar
add esi, type SingleGender
call crlf
loop l02

call crlf

ret
printGenderArray endp

printDepArray proc
mov ecx, DepElem
mov esi, offset Departments
mov eax, 0
l02:
mov al, [esi]
call Writechar
add esi, type SingleDep
call crlf
loop l02

call crlf

ret
printDepArray endp



; ####### filewrite function uses{ { filename } } as the file we want to write into
; ####### filewrite function uses{ { buffer } } as the data we want to write
filewrite proc uses esi edi ecx edx eax ebx

mov edx, OFFSET filename
call CreateOutputFile
mov fileHandle, eax; handle to object

; Write the buffer to the output file.
mov eax, fileHandle
mov edx, offset buffer
mov ecx, totaloffset
call WriteToFile
call CloseFile

ret

filewrite endp


; ####### fileread function uses{ { filename } } as the file we want to read from
; ####### fileread function uses{ { buffer } } as the data we read it
fileread proc uses esi edi ecx edx eax ebx


mov EDX, OFFSET fileName
call openInputFile
mov fileHandle, eax


mov EDX, OFFSET buffer
mov ECX, BUFFER_SIZE
call ReadFromFile


call crlf

; close file
mov eax, fileHandle
call CloseFile


quit :

ret

fileread endp


; ####### preparewritebuffer function uses{ { buffer } } as the data we want to write

; ################### set the buffer in the format to write it into the file 
preparewritebuffer proc uses eax ecx edi esi ebx edx

mov edi, offset buffer
mov esi ,offset Names
mov ebx , offset Ages
mov edx, offset Descriptions
mov eax, offset Genders
push eax
mov eax, offset Departments
mov DepRef,eax
pop eax

;########## loop on the all data and set it in desired format 
mov ecx, NameElem
bufferloop:
push ecx

;######### write the name 
push ebx
mov ecx,length SingleName
writename:
mov bl,[esi]
mov [edi],bl

add edi,type Names
add esi,type Names

loop writename
mov bl,delim
mov [edi],bl
add edi, 1
pop ebx


; ######### write the Age
push edx
mov edx,[ebx]
mov [edi],edx
add ebx , type Ages
add edi ,type Ages

mov dl, delim
mov[edi], dl
add edi, 1
pop edx


; ######### write the Desc
push eax
mov ecx, length SingleDesc
writeDesc :
mov  al, [edx]
mov[edi], al

add edi, type Descriptions
add edx, type Descriptions

loop writeDesc
mov al, delim
mov[edi], al
add edi, 1
pop eax


; ######### write the Gender
push edx
mov dl, [eax]
mov[edi], dl
add eax, type Genders
add edi, type Genders

mov dl, delim
mov[edi], dl
add edi, 1
pop edx

; ######### write the Department
push esi
mov esi,DepRef
push edx
mov dl, [esi]
mov[edi], dl
add DepRef, type Departments
add edi, type Departments


mov dl, delim
mov[edi], dl
add edi, 1
pop edx

pop esi




pop ecx
dec ecx
cmp ecx,0
jne bufferloop

; ################# adding terminator at the end to stop reading
mov dl, term
mov[edi], dl

ret

preparewritebuffer endp


; ####### preparereadbuffer function uses{ { buffer } } as the data we read
preparereadbuffer proc uses eax ecx edi esi ebx edx
mov edi, offset buffer
mov esi, offset Names
mov ebx, offset Ages
mov edx, offset Descriptions
mov eax, offset Genders

push eax
mov eax, offset Departments
mov DepRef,eax
pop eax

 


; ########## loop on the all data and set it in desired format
mov ecx, BUFFER_SIZE
bufferloop :
push ecx

push ebx
mov bl,[edi]
cmp bl, term  ;###### exit when reach the terminator
je ex

; ######### read the name

mov ecx, length SingleName
writename :
mov bl, [edi]
mov[esi], bl

add edi, type Names
add esi, type Names

loop writename

add NameOffset, length SingleName	; ######## increment name offset
add NameElem, 1						; ######## increment name Elements
add edi, 1 ; ######## skip the delimiter
pop ebx

; ######### write the Age
push edx
mov edx, [edi]
mov[ebx], edx
add ebx, type Ages
add edi, type Ages

add AgeOffset, type SingleAge			; ######## increment Age offset
add AgeElem, 1							; ######## increment Age Elements

add edi, 1
pop edx

; ######### write the Desc
push eax
mov ecx, length SingleDesc
writeDesc :
mov  al, [edi]
mov[edx], al

add edi, type Descriptions
add edx, type Descriptions

loop writeDesc

add DescOffset, length SingleDesc			; ######## increment Description offset
add DescElem, 1								; ######## increment Description Elements
add edi, 1									; ######## skip the delimiter
pop eax

; ######### write the Gender
push edx
mov dl, [edi]
mov[eax], dl
add eax, type Genders
add edi, type Genders

add GenderOffset, type SingleGender		; ######## increment Gender offset
add GenderElem, 1						; ######## increment Gender Elements
add edi, 1								; ######## skip the delimiter
pop edx



; ######### write the Departments
push esi
mov esi,DepRef
push edx
mov dl, [edi]
mov [esi], dl
add DepRef, type Departments
add edi, type Departments

add DepOffset, type SingleDep		; ######## increment Gender offset
add DepElem, 1						; ######## increment Gender Elements
add edi, 1							; ######## skip the delimiter
pop edx
pop esi
jmp cont



ex :
pop ebx
pop ecx
jmp breakloop

cont:
pop ecx
jmp bufferloop ;####### while true loop

breakloop:

ret 
preparereadbuffer endp



PrintBufferArray proc uses ecx esi edi eax edx ebx


mov ecx, NameElem
mov esi, offset buffer
l1 :
push ecx
mov ecx, lengthof SingleName
l2 :
mov al, [esi]
call writechar
inc esi
loop l2
pop ecx
call crlf
loop l1

call crlf
ret
PrintBufferArray endp

; **************************Edit****************************
Edit proc uses esi edi eax edx ecx ebx
; ------ - reading new data from user------

research:
mov NameIndex, -21
mov SearchGeneralIndex, -1
call namesearch
cmp SearchGeneralIndex, -1
jne continue
mov edx, offset NNf
call writestring
call crlf
call readchar
call crlf
cmp al, 'y'
je research
jne EndSearch



continue:
mov ecx, lengthof SingleName
mov edx, offset SingleName
L115 :
mov al, ' '
mov[edx], al
inc edx
loop L115
mov ecx, lengthof SingleDesc
mov edx, offset SingleDesc
L116 :
mov al, ' '
mov[edx], al
inc edx
loop L116


mov ebx, SearchGeneralIndex
push NameIndex
; -------- - to check if the name is exist or not.----------
reenter:
mov SearchGeneralIndex, -1
mov NameIndex, -21
mov ax, ' '
mov edi, offset NameToSearch
mov ecx, length NameToSearch
rep stosb
mov edx, offset enternamestr
call writestring
mov edx, offset SingleName
mov ecx, lengthof SingleName
call readstring

mov esi, offset SingleName
mov edi, offset NameToSearch
rep movsb
call namesearch2
cmp SearchGeneralIndex, -1
je continue2
mov edx, offset ExistName
call writestring
call crlf
call readchar
call crlf
cmp al, 'y'
je reenter
jne EndSearch




continue2 :
pop NameIndex
mov SearchGeneralIndex, ebx
mov edx, offset enteragestr
call writestring
call readdec
mov SingleAge, eax

mov edx, offset enterdescstr
call writestring
mov edx, offset SingleDesc
mov ecx, lengthof SingleDesc
call readstring

mov edx, offset entergenderstr
call writestring
call readchar
mov SingleGender, al

mov edx, offset enterdeprstr
call writestring
call readchar
mov SingleDep, al


call crlf
; ------replace the arrays------
mov edi, offset Names
mov esi, offset SingleName
mov edx, 0
mov eax, lengthof SingleName
mul SearchGeneralIndex
add edi, eax
mov ecx, lengthof SingleName
L100 :
mov al, [esi]
mov[edi], al
inc edi
inc esi
loop L100

; ----replace age----
mov edi, offset Ages
mov edx, 0
mov eax, type SingleAge
mul SearchGeneralIndex
add edi, eax
mov eax, SingleAge
mov[edi], eax

; ----replace gender----
mov edi, offset Genders
mov edx, 0
mov eax, type SingleGender
mul SearchGeneralIndex
add edi, eax
mov al, SingleGender
mov[edi], al

; ----replace dpertment----
mov edi, offset Departments
mov edx, 0
mov eax, type SingleDep
mul SearchGeneralIndex
add edi, eax
mov al, SingleDep
mov[edi], al

; ----replace dec----
mov edi, offset Descriptions
mov esi, offset SingleDesc
mov edx, 0
mov eax, lengthof SingleDesc
mul SearchGeneralIndex
add edi, eax
mov ecx, lengthof SingleDesc
L110 :
mov al, [esi]
mov[edi], al
inc edi
inc esi
loop L110
EndSearch :
ret
Edit Endp
; **************************Edit****************************

; **************************Display****************************
Display proc  uses esi edi eax edx ecx ebx

mov edx, offset line
call writestring
call crlf

mov edx, offset Dname
call writestring

mov edx, offset Ddec
call writestring

mov edx, offset Dgender
call writestring

mov edx, offset Ddepart
call writestring

mov edx, offset Dage
call writestring
call crlf

mov edx, offset line
call writestring
call crlf

mov counter, 0
mov ecx, NameElem
L120 :
push ecx
mov edi, offset Names
mov esi, offset SingleName
mov edx, 0
mov eax, lengthof SingleName
mul counter
add edi, eax
mov ecx, lengthof SingleName
L121 :
mov al, [edi]
mov[esi], al
cmp al, 10
je next23
call writechar
next23 :
inc edi
inc esi
loop L121
pop ecx
mov al, '|'
call writechar

push ecx
mov edi, offset Descriptions
mov esi, offset SingleDesc
mov edx, 0
mov eax, lengthof SingleDesc
mul counter
add edi, eax
mov ecx, lengthof SingleDesc
L122 :
mov al, [edi]
mov[esi], al
cmp al, 10
je next22
call writechar
next22 :
inc edi
inc esi
loop L122
pop ecx

mov al, '|'
call writechar

mov edi, offset Genders
mov edx, 0
mov eax, type SingleGender
mul counter
add edi, eax
mov al, [edi]
cmp al, 'm'
je female
mov edx, offset tempfemale
call writestring
jmp next120
female :
mov edx, offset tempmale
call writestring
next120 :

mov al, '|'
call writechar
mov edi, offset Departments
mov edx, 0
mov eax, type SingleDep
mul counter
add edi, eax
mov al, [edi]
cmp al, '1'
je OPD
mov edx, offset tempems
call writestring
jmp next121
OPD :
mov edx, offset tempopd
call writestring
next121 :


mov al, '|'
call writechar
mov edi, offset Ages
mov edx, 0
mov eax, type SingleAge
mul counter
add edi, eax
mov eax, [edi]
call writedec

call crlf
mov edx, offset line2
call writestring
call crlf
dec ecx
inc counter
cmp ecx, 0
jne L120





ret
Display endp
; **************************Display****************************


; **************************Display2****************************
Display2 proc  uses esi edi eax edx ecx ebx

mov edx, offset line
call writestring
call crlf

mov edx, offset Dname
call writestring

mov edx, offset Ddec
call writestring

mov edx, offset Dgender
call writestring

mov edx, offset Ddepart
call writestring

mov edx, offset Dage
call writestring
call crlf

mov edx, offset line
call writestring
call crlf

mov counter, 0
mov ecx, NameElem
L1200 :


mov edi, offset Departments
mov edx, 0
mov eax, type SingleDep
mul counter
add edi, eax
mov al, [edi]
cmp al, '1'
je skip



push ecx
mov edi, offset Names
mov esi, offset SingleName
mov edx, 0
mov eax, lengthof SingleName
mul counter
add edi, eax
mov ecx, lengthof SingleName
L1211 :
mov al, [edi]
mov[esi], al
cmp al, 10
je next231
call writechar
next231 :
inc edi
inc esi
loop L1211
pop ecx
mov al, '|'
call writechar

push ecx
mov edi, offset Descriptions
mov esi, offset SingleDesc
mov edx, 0
mov eax, lengthof SingleDesc
mul counter
add edi, eax
mov ecx, lengthof SingleDesc
L1220 :
mov al, [edi]
mov[esi], al
cmp al, 10
je next220
call writechar
next220 :
inc edi
inc esi
loop L1220
pop ecx


mov al, '|'
call writechar

mov edi, offset Genders
mov edx, 0
mov eax, type SingleGender
mul counter
add edi, eax
mov al, [edi]
cmp al, 'm'
je female2
mov edx, offset tempfemale
call writestring
jmp next1200
female2 :
mov edx, offset tempmale
call writestring
next1200 :

mov al, '|'
call writechar
mov edi, offset Departments
mov edx, 0
mov eax, type SingleDep
mul counter
add edi, eax
mov al, [edi]
cmp al, '1'
je OPD2
mov edx, offset tempems
call writestring
jmp next1211
OPD2 :
mov edx, offset tempopd
call writestring
next1211 :


mov al, '|'
call writechar
mov edi, offset Ages
mov edx, 0
mov eax, type SingleAge
mul counter
add edi, eax
mov eax, [edi]
call writedec

call crlf
mov edx, offset line2
call writestring
call crlf
skip:
dec ecx
inc counter
cmp ecx, 0
jne L1200





ret
Display2 endp
; **************************Display2****************************


; **************************Display2****************************
Display3 proc  uses esi edi eax edx ecx ebx

mov edx, offset line
call writestring
call crlf

mov edx, offset Dname
call writestring

mov edx, offset Ddec
call writestring

mov edx, offset Dgender
call writestring

mov edx, offset Ddepart
call writestring

mov edx, offset Dage
call writestring
call crlf

mov edx, offset line
call writestring
call crlf

mov counter, 0
mov ecx, NameElem
AL1200 :


mov edi, offset Departments
mov edx, 0
mov eax, type SingleDep
mul counter
add edi, eax
mov al, [edi]
cmp al, '2'
je Askip



push ecx
mov edi, offset Names
mov esi, offset SingleName
mov edx, 0
mov eax, lengthof SingleName
mul counter
add edi, eax
mov ecx, lengthof SingleName
AL1211 :
mov al, [edi]
mov[esi], al
cmp al, 10
je Anext231
call writechar
Anext231 :
inc edi
inc esi
loop AL1211
pop ecx
mov al, '|'
call writechar

push ecx
mov edi, offset Descriptions
mov esi, offset SingleDesc
mov edx, 0
mov eax, lengthof SingleDesc
mul counter
add edi, eax
mov ecx, lengthof SingleDesc
AL1220 :
mov al, [edi]
mov[esi], al
cmp al, 10
je Anext220
call writechar
Anext220 :
inc edi
inc esi
loop AL1220
pop ecx


mov al, '|'
call writechar

mov edi, offset Genders
mov edx, 0
mov eax, type SingleGender
mul counter
add edi, eax
mov al, [edi]
cmp al, 'm'
je Afemale2
mov edx, offset tempfemale
call writestring
jmp Anext1200
Afemale2 :
mov edx, offset tempmale
call writestring
Anext1200 :

mov al, '|'
call writechar
mov edi, offset Departments
mov edx, 0
mov eax, type SingleDep
mul counter
add edi, eax
mov al, [edi]
cmp al, '1'
je AOPD2
mov edx, offset tempems
call writestring
jmp Anext1211
AOPD2 :
mov edx, offset tempopd
call writestring
Anext1211 :


mov al, '|'
call writechar
mov edi, offset Ages
mov edx, 0
mov eax, type SingleAge
mul counter
add edi, eax
mov eax, [edi]
call writedec

call crlf
mov edx, offset line2
call writestring
call crlf
Askip:
dec ecx
inc counter
cmp ecx, 0
jne AL1200





ret
Display3 endp
; **************************Display3****************************

; **************************SearchRecored****************************
SearchRecored proc  uses esi edi eax edx ecx ebx
mov NameIndex, -21
mov SearchGeneralIndex, -1
call namesearch
mov ebx , SearchGeneralIndex
mov counter , ebx
mov edx, offset line
call writestring
call crlf

mov edx, offset Dname
call writestring

mov edx, offset Ddec
call writestring

mov edx, offset Dgender
call writestring

mov edx, offset Ddepart
call writestring

mov edx, offset Dage
call writestring
call crlf

mov edx, offset line
call writestring
call crlf


mov ecx, NameElem





push ecx
mov edi, offset Names
mov esi, offset SingleName
mov edx, 0
mov eax, lengthof SingleName
mul counter
add edi, eax
mov ecx, lengthof SingleName
L121 :
mov al, [edi]
mov[esi], al
cmp al, 10
je next23
call writechar
next23 :
inc edi
inc esi
loop L121
pop ecx
mov al, '|'
call writechar

push ecx
mov edi, offset Descriptions
mov esi, offset SingleDesc
mov edx, 0
mov eax, lengthof SingleDesc
mul counter
add edi, eax
mov ecx, lengthof SingleDesc
L122 :
mov al, [edi]
mov[esi], al
cmp al, 10
je next22
call writechar
next22 :
inc edi
inc esi
loop L122
pop ecx

mov al, '|'
call writechar

mov edi, offset Genders
mov edx, 0
mov eax, type SingleGender
mul counter
add edi, eax
mov al, [edi]
cmp al, 'm'
je female
mov edx, offset tempfemale
call writestring
jmp next120
female :
mov edx, offset tempmale
call writestring
next120 :

mov al, '|'
call writechar
mov edi, offset Departments
mov edx, 0
mov eax, type SingleDep
mul counter
add edi, eax
mov al, [edi]
cmp al, '1'
je OPD
mov edx, offset tempems
call writestring
jmp next121
OPD :
mov edx, offset tempopd
call writestring
next121 :


mov al, '|'
call writechar
mov edi, offset Ages
mov edx, 0
mov eax, type SingleAge
mul counter
add edi, eax
mov eax, [edi]
call writedec

call crlf
mov edx, offset line2
call writestring
call crlf

inc counter






ret
SearchRecored endp
; **************************SearchRecored****************************

sumoffset proc

mov ebx, 0
mov TotalOffset, ebx

mov ebx, length SingleName
add TotalOffset, ebx

mov ebx, type SingleGender
add TotalOffset, ebx

mov ebx, length SingleDep
add TotalOffset, ebx

mov ebx, length SingleDesc
add TotalOffset, ebx

mov ebx, type SingleGender
add TotalOffset, ebx
add TotalOffset,10








mov eax, NameElem
mov edx,0
mov ebx, TotalOffset
mul ebx
mov TotalOffset,eax


add TotalOffset, 1			;####### add one for the last delimiter (termination delimiter)



ret

sumoffset endp




END MAIN


