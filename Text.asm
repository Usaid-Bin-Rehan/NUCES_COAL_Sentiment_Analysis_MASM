TITLE SENTIMENT ANALYSIS
INCLUDE Irvine32.inc

NoFile PROTO, fileName:PTR BYTE
Emotionless PROTO, noEmotionWord:PTR BYTE, noEmotionWordSize:DWORD
Counter PROTO,NoOfEmotions:DWORD
Search PROTO, src: ptr byte, key: ptr byte, strSize: dword, keySize: dword
Display PROTO, EmotionWord:PTR BYTE, EmotionWordSize:DWORD
Display_Word PROTO, foundWord:PTR BYTE
clear PROTO, textString:PTR BYTE, StringLength:DWORD
extracted_Word PROTO

.data

EmotionStringSize DWORD 10000
EmotionString BYTE 10000 dup(0)
EmotionCount BYTE 6 DUP(?)
EC BYTE ?
largest SBYTE -1
position DWORD ?

FileNames byte  "Happy.txt",0,0,0,0,0,0,0,0,0,0,0
		  byte  "Sad.txt",0,0,0,0,0,0,0,0,0,0,0,0,0
		  byte  "Anger.txt",0,0,0,0,0,0,0,0,0,0,0
		  byte  "Disgust.txt",0,0,0,0,0,0,0,0,0
		  byte  "Fear.txt",0,0,0,0,0,0,0,0,0,0,0,0
		  byte  "None.txt",0,0,0,0,0,0,0,0,0,0,0

EmotionNum DWORD 6
EmotionLength DWORD 400
TempFileNames DWORD  ?

EmotionfileHandler DWORD 0

inputFile BYTE "Input.txt",0
inputString BYTE 20000 dup(0)
inputFileHandler DWORD 0
currentInputIndex DWORD  inputString  
extractedWord BYTE 400 dup(0)
extractedWordSize DWORD 0

Detec_Emot_No BYTE  20000 dup(0)
IndexNoEmotionWords DWORD offset Detec_Emot_No

lineOut	BYTE 40 dup(?)
uword byte 40 dup(?)


;//loop counters
mainLoopCounter DWORD 20000
world_len byte ?


;//flags
inputFileEnded DWORD 0
fileEmotionWritten DWORD 0
lastWord DWORD 0


;//Strings to be used
semiColon BYTE ":",0
dot BYTE "."
bigSpace BYTE "       ",0
new_line byte 0Dh,0Ah


;//prompts
promptEnter byte "ENTER A SENTENCE",0
promptDisplay byte "ENTERED SENTENCE",0 
promptFile1 BYTE "File '",0
promptFile2 BYTE "' does not exist or cannot be opened.",0
promptNoDot BYTE "PROGRAM EXITED!!!!!!",0
promptHappy BYTE "HAPPY EMOTION DETECTED :)",0
promptSad BYTE "SAD EMOTION DETECTED :(",0
promptAnger BYTE "ANGER EMOTION DETECTED :(",0
promptDisgust BYTE "DISGUST EMOTION DETECTED:)(",0
promptFear BYTE "FEAR EMOTION DETECTED :|",0
promptMixed BYTE "MIXED EMOTION DETECTED :)",0
promptLove BYTE "LOVE EMOTION DETECTED :)",0
promptSurprise BYTE "SURPRISE EMOTION DETECTED!!",0
promptNone BYTE "YOU ENTERED AN EMOTIONLESS SENTENCE!!!{-",0
BlueTextOnMagenta = white + (red * 16)
DefaultColor = magenta + (Green * 16)


;--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-Emoji and Welcome Design Scenes
welcome BYTE "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@@@@@@&,,,.,,,,,,,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@@@@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@/.,,,.,,,.,,,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.,,,.,,,.,,,.,,,,,,,,,,,/@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,,,,.,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,,@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,,,,.,.,.,,,,,,,,,,,,@@@@@@@@", 13, 10
		BYTE "@@@@@@@,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,,,,,,,,.,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,,,@@@@@@", 13, 10
		BYTE "@@@@@/,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,,,,,,,,,,,,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,,,@@@@@", 13, 10
		BYTE "@@@@,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,,,,,,,,,.,,,,,,,.,,,,,.,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,.,,,,,@@@", 13, 10
		BYTE "@@@.....................................,.....,...........,,,,,,,.,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,..,,,@@@", 13, 10
		BYTE "@@,,,,,,.,.,.,.,.,.,.,.,.,.,,,,,,,.,,,,,,,.,,,,,,,.,,.,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,.,,,,,.,,,.,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,.,,,.,,,.,,,.,,,,,,,,,,,@@", 13, 10
		BYTE "@@,,.,,,..,.,.,.,.,.,.,.,..,,,.,,,.,,,.,,,.,,,..,,.WELCOME TO SENTIMENT ANALYSIS EXECUTION PROGRAM.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,.,.,,,.@@", 13, 10
		BYTE "@,,,,,,,.,,.,.,.,.,.,.,.,.,.,,,,,.,.,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,.,.,.,.,.,.,.,.,,,,,,.,,,.,,,.,,,.,,,,,.,,@", 13, 10
		BYTE "@,.,.,.,.,.,,,.,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,..,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,,.,.,.,.,.@", 13, 10
		BYTE "@*,,,,,,.,,,,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,,.,,,,,,,.,,,,,,,,,.,,,.,,,.,,,.,,,.,,,,,.,,,,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,@", 13, 10
		BYTE "@@,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,,.,,,.,,.,,,.,,,.,,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,,.,,,.,@@", 13, 10
		BYTE "@@,,,,,,.,,,,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,,,,.,.,.,,,,@@", 13, 10
		BYTE "@@@.........,,.,,,.,,,.,,,.,,,.,,,.,,..,,.,,,.,,,.,,,.,,,.,,,.,,....,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,..........@@", 13, 10
		BYTE "@@@@,,,,.,,,,,,,.,,,.,,,.,,,.,,,.,,,.,,,,,,.,,,.,,,.,,,.,,,.,,,.,,,,,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,,,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,.@@@", 13, 10
		BYTE "@@@@@/,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,.,,,.,,,,,,@@@@@", 13, 10
		BYTE "@@@@@@@,.,,,,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,.,,,.,,,.,,,.,,@@@@@@", 13, 10
		BYTE "@@@@@@@@@,.,.,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,.,,,,,.,,,.,,,.,,.,.,@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,,,.,,,.,,,.,,,.,,,.,,,.,,.,,,,,.,..,,,.,,,.,,,.,,,.,,@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", 13, 10,13, 10, 13, 10,0




semoji	BYTE "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@@@@@@&,,,.,,,,,,,.,,,,,,,%@@@@@@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@/.,,,.,,,.,,,.,,,.,,,.,,,.,,,./@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,@@@@@@@@", 13, 10
		BYTE "@@@@@@@,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,@@@@@@", 13, 10
		BYTE "@@@@@/,,.,,,.,,,.,,,.%%%.,,,.,,,.,,,.%%%.,,,.,,,.,,,.,,@@@@@", 13, 10
		BYTE "@@@@,,,,.,,,,,,,.,%%%%%,.,,,,,,,.,,,,,%%%%%,,,,,.,,,,,,,.@@@", 13, 10
		BYTE "@@@.........../%%%%%....................,%%%%%,...........@@", 13, 10
		BYTE "@@,,,,,,.,%%%%%%%,,,,,,,.,,,,,,,.,,,,,,,.,,,%%%%%%%,,,,,.,,@", 13, 10
		BYTE "@@,,.,,,.,/(.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.#*,.,,,.,,@", 13, 10
		BYTE "@,,,,,,,.,,%%%%%%%%%%%%%%%%,,,,,.,%%%%%%%%%%%%%%%#,,,,,,.,,/", 13, 10
		BYTE "@,.,.,.,.,.,,,*******,.,.,.,.,.,.,.,.,.,*******,,,.,.,.,.,./", 13, 10
		BYTE "@*,,,,,,.,,,,,*******,,,.,,,,,,,.,,,,,,,*******,.,,,,,,,.,,#", 13, 10
		BYTE "@@,,.,,,.,,,.,*******,,,.,,,.#%(.,,,.,,,*******,.,,,.,,,.,,@", 13, 10
		BYTE "@@,,,,,,.,,,,,*******,,,.,%%%%%%%%%,,,,,*******,.,,,,,,,.,,@", 13, 10
		BYTE "@@@...........*******....%%%%%%%%%%%....*******...........@@", 13, 10
		BYTE "@@@@,,,,.,,,,,*******,,,%%%///////%%%,,,*******,.,,,,,,,.@@@", 13, 10
		BYTE "@@@@@/,,.,,,.,*******,,,%%/////////%%,,,*******,.,,,.,,@@@@@", 13, 10
		BYTE "@@@@@@@,.,,,,,*******,,,.%%%#///%%%%,,,,*******,.,,,,,@@@@@@", 13, 10
		BYTE "@@@@@@@@@,.,.,*******,.,.,.,.,.,.,.,.,.,*******,.,.,@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@,,*******,,,.,,,,,,,.,,,,,,,*******,.@@@@@@@@@@@", 13, 10
		BYTE "@@*********************************************************@", 13, 10
		BYTE "@@@@@%*************************************************%@@@@", 13, 10, 13, 10, 13, 10,0
demoji  BYTE "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@@@@@@&,,,.,,,,,,,.,,,,,,,%@@@@@@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@/.,,,.,,,.,,,.,,,.,,,.,,,.,,,./@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,@@@@@@@@", 13, 10
		BYTE "@@@@@@@,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,@@@@@@", 13, 10
		BYTE "@@@@@/,,.,,,.,,,.,,,,,.,,,.,,,,,,.,,,.,,,,,,.,,,.,,,.,,@@@@@", 13, 10
		BYTE "@@@@,,,,.,,,,,,,.,%%%%%,.,,,,,,,.,,,,,%%%%%,,,,,.,,,,,,,.@@@", 13, 10
		BYTE "@@@.........../%%%%%....................,%%%%%,...........@@", 13, 10
		BYTE "@@,,,,,,.,%%%%%%%,,,,,,,.,,,,,,,.,,,,,,,.,,,%%%%%%%,,,,,.,,@", 13, 10
		BYTE "@@,,.,,,.,/(.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.#*,.,,,.,,@", 13, 10
		BYTE "@,,,,,,,.,,%%%%%%%%%%%%%%%%,,,,,.,%%%%%%%%%%%%%%%#,,,,,,.,,/", 13, 10
		BYTE "@,.,.,.,.,,,,.,,,.,,,,,,,.,,,,.,.,.,.,.,,,,.,,,.,,,,,,.,.,./", 13, 10
		BYTE "@*,,,,,,.,,,,,,.,,,.,,,,,.,,,,,,,.,,,,,,,,,.,,,.,,,,,.,.,.,,#", 13, 10
		BYTE "@@,,.,,,.,,,.,,,,.,,,.,,,,,.,.,,,.,,,,,,.,,,.,,,,.,,,.,,,.,,@", 13, 10
		BYTE "@@,,,,,,.,,,,,,.,,,.,,,,.,%%%%%%%%%,,,,,,,.,,,,,,.,,,,,,,.,,@", 13, 10
		BYTE "@@@.........,,,.,,,.,....%%%%%%%%%%%...,,,.,,,.,...........@@", 13, 10
		BYTE "@@@@,,,,.,,,,,,.,,,.,,,,%%%///////%%%,,,,,,.,,,,,,,,,,,,,.@@@", 13, 10
		BYTE "@@@@@/,,.,,,.,,,.,,,,,,,%%/////////%%,,,,,.,,,.,,,,,,.,,@@@@@", 13, 10
		BYTE "@@@@@@@,.,,,,,,,.,,,.,,,.***********,.,.,.,.,.,.,,.,,,,@@@@@@", 13, 10
		BYTE "@@@@@@@@@,.,.,,,.,,,.,,,.***********.,,,.,,,.,,,,.,.,@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@,,.,.,.,.,.***************.,,,,,.,.,,.@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@.,.**************************.,.@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@%@@@@@@@@@@@@@************************@@@@@@@@@@@@@%@@@@", 13, 10, 13, 10, 13, 10,0

aemoji  BYTE "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", 13, 10
	    BYTE "@@@@@@@@@@@@@@@@@@@@&,,,.,,,,,,,.,,,,,,,%@@@@@@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@/.,,,.,,,.,,,.,,,.,,,.,,,.,,,./@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,@@@@@@@@", 13, 10
		BYTE "@@@@@@@,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,@@@@@@", 13, 10
		BYTE "@@@@@/,,.,,,.,,,.,,.,.,,.,.,.,.,,,.,,.,,..,.,,,.,,,,.,,@@@@@", 13, 10
		BYTE "@@@@,,,,.,,,,,,,.,,,,,,,.,,,,.,.,,,,,.,,,.,.,.,.,.,.,.,,.@@@", 13, 10
		BYTE "@@@...........,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,...........@@", 13, 10
		BYTE "@@,,,,,,.,.,..,.,.,,,,,,.,,,,,,,.,,,,,,,.,,,,.,.,.,,,,,,.,,@", 13, 10
		BYTE "@,,,,,,,.,,%%%%%%%%%%%%%%%%,,,,,.,%%%%%%%%%%%%%%%#,,,,,,.,,@", 13, 10
		BYTE "@,,,.,,,.,,..,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,..,,.,,,.,,@", 13, 10
		BYTE "@,.,.,.,.,.,,,.%%%%%%%.,.,.,.,.,.,.,.,.%%%%%%,,.,.,,.,.,.,.@", 13, 10
		BYTE "@*,,,,,,.,,,,,..,.,.,,,,.,,,,,,,.,,,,,,,.,.,.,.,.,,,,,,,.,,#", 13, 10
		BYTE "@@,,.,,,.,,,.,.,.,.,,,,,.,,,..,..,,,.,,.,.,.,.,,.,,,.,,,.,,@", 13, 10
		BYTE "@@,,,,,,.,,,,,.,.,.,.,,,..,.,.,.,,,,,,.,.,.,.,,,,,.,.,.,.,,@", 13, 10
		BYTE "@@@............,.,..,....%%%%%%%%%%%....,.,.,.,.,.........@@", 13, 10
		BYTE "@@@@,,,,.,,,,.,.,,.,..,,%%%///////%%%,,,,.,.,.,,.,,,,,,,.@@@", 13, 10
		BYTE "@@@@@/,,.,,,.,.,.,..,,,.,.,.,.,.,.,.,.,,.,.,.,.,.,,,.,,@@@@@", 13, 10
		BYTE "@@@@@@@,.,,,,.,.,.,.,.,,.,.,.,.,.,.,,,,.,.,.,.,,.,,,,,@@@@@@", 13, 10
		BYTE "@@@@@@@@@,.,.,..,.,.,,.,.,.,.,.,.,.,.,..,.,.,.,..,.,@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@,,,..,.,.,.,.,,,,,,,.,,,,,,.,.,.,.,,.@@@@@@@@@@@", 13, 10
	    BYTE "@@@@@@@@@@@@@@@@@@@@&,,,.,,,,,,,.,,,,,,,%@@@@@@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", 13, 10, 13, 10, 13, 10,0

		
hemoji  BYTE "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@@@@@@&,,,.,,,,,,,.,,,,,,,%@@@@@@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@/.,,,.,,,.,,,.,,,.,,,.,,,.,,,./@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,@@@@@@@@", 13, 10
		BYTE "@@@@@@@,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,,,.,,,,,@@@@@@", 13, 10
		BYTE "@@@@@/,,.,,,.,,,.,,,,.,.,.,.,.,.,.,.,.,.,,,,.,,,.,,,.,,@@@@@", 13, 10
		BYTE "@@@@,,,,.,,,,,,,.,%%%%%,.,,,,,,,.,,,,,%%%%%,,,,,.,,,,,,,.@@@", 13, 10
		BYTE "@@@.........../%%%%%....................,%%%%%,...........@@", 13, 10
		BYTE "@@,,,,,,.,,.,.,.,.,.,.,.,.,.,.,.,.,.,,.,.,.,.,.,.,.,.,,..,,@", 13, 10
		BYTE "@@,,.,,,.,.,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,.,,,..,,.,,,.,,@", 13, 10
		BYTE "@,,,,,,,.,,%%%%%%%%%%%%%%%%,,,,,.,%%%%%%%%%%%%%%%#,,,,,,.,,/", 13, 10
		BYTE "@,.,.,.,.,.,,,.,.,.,.,.,.,.,.,.,.,.,.,.,,.,,.,.,,,.,.,.,.,./", 13, 10
		BYTE "@*,,,,,,.,,,,,.,.,.,.,.,.,.,.,.,.,.,.,.,,.,.,....,,,,,,,.,,#", 13, 10
		BYTE "@@,,.,,,.,,,,.,.,.,.,.,.,.,.,.,.,.,.,.,,.,.,.,.,.,,,.,,,.,,@", 13, 10
		BYTE "@@,,,.,.,.,.,.,.,.,.,,.,.,.,.,.,.,.,.,.,.,.,.,.,.,,,,,,,.,,@", 13, 10
		BYTE "@@@..................,.,.,.,.,.,.,.,.,.,.,.,.,.,,.,,......@@", 13, 10
		BYTE "@@@@,,,,.,,,,,,.,.,,.,.,.,.,.,.,.,.,.,.,.,.,.,,,.,,,,,,,.@@@", 13, 10
		BYTE "@@@@@/,,.,,,.,.,..,.,,,,%%/////////%%,,,,,.,,.,,.,,,.,,@@@@@", 13, 10
		BYTE "@@@@@@@,.,,,,,,.,.,.,,,,.%%%#%%%%%%,,.,,..,.,.,..,,,,,@@@@@@", 13, 10
		BYTE "@@@@@@@@@,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,.,@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@,.,.,.,.,,,,.,,,,,,,.,,,,,,,,.,.,.,,.@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@@@@@@&,,,.,,,,,,,.,,,,,,,%@@@@@@@@@@@@@@@@@@@", 13, 10
		BYTE "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", 13, 10, 13, 10, 13, 10,0

femoji BYTE "		      ,.-------.,                ",13,10
BYTE "         ,:'             ':,			 ",13,10
BYTE "      ,:                     :,		 ",13,10
BYTE "	   :                         :		 ",13,10
BYTE "     ,'                         ',	 ",13,10
BYTE "	 ,:                           :,	 ",13,10
BYTE "	 : :      .           .      : :	 ",13,10
BYTE "     	| :   __       __   : |			 ",13,10
BYTE "	  |  `/'     ~' . '     '~\'  |		 ",13,10
BYTE "	    |  ~  ,-~^, | ,^~-,  ~  |		 ",13,10
BYTE "	  |   |        }:{        |   |		 ",13,10
BYTE "	  |   l       / | \       !   |		 ",13,10
BYTE "	   .~  (_,.--' .^. '--.,_)  ~.		 ",13,10
BYTE "	  |     ---:' / | \ `:---     |		 ",13,10
BYTE "	    \_.       \/^\/       ._/		 ",13,10
BYTE "		V| \                 / |V		 ",13,10
BYTE "		  | |T~\__!_!__/~T| |			 ",13,10
BYTE "		 | |`IIII_I_I_I_IIII'| |		 ",13,10
BYTE "		 |  \,III I I I III,/ |		     ",13,10
BYTE "		     \   `~~~~'     /			 ",13,10
BYTE "		   \   .       .   /			 ",13,10
BYTE "            \.    ^    ./				 ",13,10
BYTE "               ^~  ^ ~^				 ", 13, 10, 13, 10, 13, 10,0





.code

main PROC
;--------------------------------------------------------------------------------------------------------- DISPLAY -----------------------------------------------------------------------------------------------------------
call clrscr
mov eax, BlueTextOnMagenta
call SetTextColor
call clrscr
LEA edx, welcome
call writeString
call crlf
;----------------------------------------------------------------------------------------------- PROMPTS TO TAKE USER'S INPUT -----------------------------------------------------------------------------------------------

call crlf
LEA edx, promptEnter
call writestring
call crlf
mov edx,0
LEA edx, inputString
mov ecx,lengthof inputString
call readstring
call crlf

;----------------------------------------------------------------------------------------- CONVERTING UPPERCASE STRING TO LOWERCASE -----------------------------------------------------------------------------------------

LEA esi,inputString
mov ecx,lengthof inputString
lop:
	mov al,[esi]
	cmp al,65
	jb nx
	cmp al,0
	je comp
	cmp al,90
	ja nx
	add al,32
	mov [esi],al
	nx:	
		inc esi
		loop lop

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

mov edx,0
LEA edx, promptDisplay
call writestring
call crlf
comp:
LEA edx, inputString
call writestring
call crlf
call crlf

;------------------------------------------------------------------------------------------------- WRITING INPUT TO THE FILE ------------------------------------------------------------------------------------------------

mov edx,0
mov eax,0
LEA edx, inputFile
call CreateOutputFile
mov lineout, al
LEA esi,inputString
mov ecx,lengthof inputString
LEA edi, uword
call crlf
l1:
	lodsb
	cmp al,0
	je q
	cmp al," "
	je done
	stosb
	loop l1
done:
	mov world_len,0
	LEA edx, uword
	call writestring
	
	mov bl,cl
	mov ecx,lengthof uword
	LEA edi, uword
	x:
		mov bh,[edi]
		cmp bh,0
		je d
		inc world_len
		inc edi
		loop x
	d:
		movzx eax,lineout
		LEA edx,  uword
		movzx ecx,world_len
		call WriteToFile
		lea edx,new_line
		movzx eax,lineout
		mov ecx, 2
		call WriteToFile
		movzx ecx,world_len
		LEA edi, uword
	y:
		mov bh,0
		mov [edi],bh
		inc edi
		loop y
	mov cl,bl
	mov edi,offset uword
	call crlf
	jmp l1
q:
	mov world_len,0
	mov edx,offset uword
	call writestring
	call crlf
	mov bl,cl
	mov ecx,lengthof uword
	mov edi,offset uword
	a:
		mov bh,[edi]
		cmp bh,0
		je b
		inc world_len
		inc edi
		loop a
	b:
		movzx eax,lineout
		movzx ecx,world_len
		mov edx, OFFSET uword
		call WriteToFile
		lea edx,new_line
		movzx eax,lineout
		mov ecx, 2
		call WriteToFile
		movzx eax,lineout
		mov edx, OFFSET dot
		mov ecx,1
		call WriteToFile
		mov edi,offset uword
		movzx ecx,world_len
	z:
		mov bh,0
		mov [edi],bh
		inc edi
		loop z
movzx eax, lineout
call CloseFile

;-------------------------------------------------------------------------------------- READING FROM THE FILE "input.txt" TO inputString ------------------------------------------------------------------------------------- 

mov eax, offset Detec_Emot_No
mov IndexNoEmotionWords, eax      

mov edx, offset inputFile

call openInputFile
mov inputFilehandler, eax

cmp eax, INVALID_HANDLE_VALUE
je InputFileNotExist


mov ecx, lengthOf inputString
mov edx, offset inputString
mov eax, inputfilehandler
call readFromFile


;------------------------------------------------------------------------------------------- FILE TEXT MOVED TO inputString---------------------------------------------------------------------------------------------------


;----------------------------------------------------------------------------------------------- CHECKING FILE'S FORMAT ------------------------------------------------------------------------------------------------------


INVOKE Search, addr inputString, addr dot, lengthof inputString, lengthof dot

;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
cmp ebx,-1
je noInputFormat
mov ebx,0


mov TempFileNames, offset FileNames
mov ecx,EmotionNum
OuterLoop:

			mov EmotionNum, ecx

			;Setting flags to zero
			mov eax, 0
			mov fileEmotionWritten, eax
			mov lastWord, eax
			mov inputFileEnded, eax

			;Resetting currentInputIndex
			mov esi, offset inputString
			mov currentInputIndex, esi 

 
			INVOKE clear, offset EmotionString, EmotionStringSize

			mov edx, TempFileNames
			call openInputFile
			mov EmotionfileHandler, eax

			cmp eax, INVALID_HANDLE_VALUE
			je FileNotExist


			mov ecx, lengthOf EmotionString
			mov edx, offset EmotionString
			mov eax, EmotionfileHandler
			call readFromFile
			;reading completed, text moved to categoryString
		


			mov ecx, mainLoopCounter
			innerLoop:
					mov mainLoopCounter, ecx
					mov eax, inputFileEnded
					cmp eax, 0
					jne breakLoopCateg2

					call extracted_Word

					INVOKE Search, addr EmotionString, addr extractedWord, EmotionStringSize, extractedWordSize
	
					cmp ebx, -1
					je loopEnd
					
					mov eax, fileEmotionWritten
					cmp eax, 0
					jne alreadyPrintedCateg2
					INVOKE Display, TempFileNames, EmotionLength	

			alreadyPrintedCateg2:
					 INVOKE Display_Word, offset extractedWord
					 mov EC,cl
					 INVOKE Counter,EmotionNum

			jmp loopEnd
					
loopEnd:
					;//restoring ecx after a function call
					mov ecx, mainLoopCounter
			loop Innerloop

			breakLoopCateg2:
			call crlf
			
	

			
			jmp skipThis
FileNotExist:
			INVOKE NoFile, tempFileNames
skipThis:

			add TempFileNames,20
			mov ecx,EmotionNum
			dec ecx
			cmp ecx, 0
jnz outerLoop



;-------------------------------------------------------------------------------------------------- PROMPTS REGARDING INPUT --------------------------------------------------------------------------------------------------
jmp skipDownStatement
noInputFormat:
	call crlf
	mov edx, offset promptNoDot
	call writeString
	call crlf

jmp skipDownStatement

InputFileNotExist:
	INVOKE NoFile, addr inputFile

skipDownStatement:

mov al, Detec_Emot_No[0]
cmp al, 0
;je exitTheProgram

;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

mov ecx,lengthOf EmotionCount
mov esi,0
LEC:
	mov al,EmotionCount[esi]
	cmp al,largest
	jg storeLargest
	jmp next

	storeLargest:
				mov largest,al
				mov position,esi
				jmp next

	next:
		 inc esi
Loop LEC

mov eax,0


mov eax,position
;   Comparing emotion type


cmp eax,5
je pHappy
cmp eax,4
je pSad
cmp eax,3
je pAnger
cmp eax,2
je pDisgust
cmp eax,1
je pFear
cmp eax,0
je pNone

pHappy:
		mov edx,OFFSET promptHappy
		call writeString
		call crlf
	    call crlf
        lea edx,hemoji
	    call WriteString
	    call crlf
		jmp conclude

pSad:
      mov edx,OFFSET promptSad
	  call writeString
	  call crlf
	  
       call crlf
       lea edx,semoji
	   call WriteString
	   call crlf

	  jmp conclude

pAnger:
        mov edx,OFFSET promptAnger
	    call writeString
	    call crlf

		call crlf
        lea edx,aemoji
	    call WriteString
	    call crlf

	    jmp conclude

pDisgust:
         mov edx,OFFSET promptDisgust
	     call writeString
	     call crlf
		 
		 call crlf
		 lea edx,demoji
	     call WriteString
	     call crlf

	     jmp conclude

pFear:
	   mov edx,OFFSET promptFear
	   call writeString
	   call crlf
	   
	   call crlf
	   lea edx,femoji
	   call WriteString
	   call crlf

	   jmp conclude

pNone:
	   mov edx,OFFSET promptNone
	   call writeString
	   call crlf
	   jmp conclude	   

conclude:


exit
main ENDP 
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

NoFile PROC, fileName:PTR BYTE

call crlf
call crlf
mov edx, offset promptFile1
call writeString
mov edx, fileName
call writeString
mov edx, offset promptFile2
call writeString

ret
NoFile ENDP


; ****************************

clear PROC, textString:PTR BYTE, StringLength:DWORD

	mov edi, textString
	mov eax, 0
	mov ecx, stringLength
	rep stosb

ret
clear ENDP

Display_Word PROC, foundWord:PTR BYTE

	inc foundword
	mov edx, foundword
	call writeString

ret
Display_Word ENDP


; **************** Procedure to display emotion Word Extracted from files ************

Display PROC, EmotionWord:PTR BYTE, EmotionWordSize:DWORD

	mov esi, EmotionWord
	mov ecx, EmotionWordSize
	mov eax,0
	mov fileEmotionWritten, eax

loopPrintCategName:
				mov al, [esi]
				cmp al, '.'
				je breakPrintCategName
				mov al, [esi]
				call writeChar
			
				inc esi
loop loopPrintCategName

breakPrintCategName:
	mov edx, offset semiColon
	call writeString
	call crlf

	mov eax, 0fh
	mov fileEmotionWritten, eax


	mov edx, offset bigSpace
	call writeString

ret
Display ENDP

; **************** Word Extration from files ************


extracted_Word PROC

INVOKE clear, addr extractedWord, extractedWordSize 
	
	mov ecx, lengthOf inputString
	mov eax, 0
	mov ebx, 0
	mov extractedWordSize, eax
	mov esi, currentInputIndex
	lea edi, extractedWord

	mov al, 0ah
	stosb
	inc extractedWordSize

	cmp al, '.'
	je return

noComma:
copy:
		 mov al, [esi]
		 cmp al, 0ah
		 je addComma
		 				 
		 mov bl, [esi]
		 cmp bl, '.'
		 je FileEnded

		 movsb
		 inc extractedWordSize
		loop copy

FileEnded:
	mov eax, 0fh
	mov inputFileEnded, eax

addComma:
	mov al, 0ah
	stosb
	inc esi
	inc extractedWordSize



return:		  

    ;find size of the word here	
	mov currentInputIndex, esi 		        
ret
extracted_Word ENDP

; **************** Searcing Procedure ************

Search proc uses ecx esi edi eax, src: ptr byte, key: ptr byte, strSize: dword, keySize: dword

  	mov ecx, strSize
  	mov esi, src
  	mov edi, key
  	mov eax, 0
  	
  ;dec keySize -> no null character
  
  L2:
  
    cmp eax, keySize
    jz L5

    cmpsb
    jz L3
    mov edi, key
    cmp eax, 1
    jb L4
    dec esi
    mov eax, 0
    jmp L4

    L3: 
    inc eax
   
  L4: 
  loop L2
 
; **************** If Not Found ************

  	mov ebx, -1
  ret

  L5: 
  

; **************** If Found ************

      mov ebx, esi
      sub ebx, src
      sub ebx, eax
  ret
Search endp

; **************** Emotion Counting ************

Counter PROC,NoOfEmotions:DWORD

	mov eax,NoOfEmotions
	dec eax
	
	cmp al,5
	je inHappy
	cmp al,4
	je inSad
	cmp al,3
	je inAnger
	cmp al,2
	je inDisgust
	cmp al,1
	je inFear
	cmp al,0
	je inNone
	


inHappy:
		mov esi,eax
		add EmotionCount[si],1
		jmp last
inSad:
	  mov esi,eax
	  add EmotionCount[si],1
	  jmp last
inAnger:
	    mov esi,eax
	    add EmotionCount[si],1
		jmp last
inDisgust:
	     mov esi,eax
	     add EmotionCount[si],1
		 jmp last
inFear:
	   mov esi,eax
	   add EmotionCount[si],1
	   jmp last
inNone:
		mov esi,eax
		add EmotionCount[si],1
		jmp last

last:
ret
Counter ENDP

END main