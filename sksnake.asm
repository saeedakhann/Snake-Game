[org 0x0100]
jmp start

str1: db 'ONE LIFE LOST! TWO LIVES LEFT. RESTARTING GAME.', 0
str2: db 'TWO LIVES LOST! ONE LIFE LEFT. RESTARTING GAME.', 0
str3: db 'GAME OVER!! YOU LOST!!', 0
str4: db 'CONGRATULATIONS!! YOU WON!! ^_^', 0
str5: db 'YOUR SCORE: ', 0
prevkey: db 0
index: db 0
snake_body_next: times 220 db 'X'
won: dw 0
snake_body: db 'XXXXXXXXXXXXXXXXXXXO'
snake_position: times 240 dw 0
snake_size: dw 20 ; cmp max_size game win
lives: dw 3
score: dw 0
time: dw 0
milliseconds: dw 0
seconds: dw 59
mins: dw 3
speed: dw 0
gameover: dw 0
max_size: dw 240
prevcommand: dw 0 ; 1 for up, 2 for down, 3 for left, 4 for right
pos_num: dw 0

Food: dw 340,550,870,900,3000,1080,1500,3700,1900,2500,820,450,360,3400,3820,2900,1200,2650,1190,2100, ;border only
Food2: dw 3700,600,2950,1700,350,430,3250,2800,1200,3760,590,3600,1150,340,2750,750,1780,2100,2980,650   ;hurdle1
Food3: dw 1350,2090,550,570,1380,3800,1670,360,2000,3250,1900,750,1100,1800,450,2200,950,3650,1100,650  ;hurdle2

FoodPtr: dw 0     ;which position
shapetype: dw 0
Fruitposition: dw 0          ;present fruit position


GameOverCall:
pusha

push cs
pop ds

dec word[cs:lives]
mov word[cs:gameover], 1
call clrscr

twolivesleft:
cmp word[cs:lives], 2
jne onelifeleft
push 0 
push 12
push 7
push str1
call printstr
jmp endscore

onelifeleft:
cmp word[cs:lives], 1
jne nolifeleft
push 0 
push 12
push 7
push str2
call printstr
jmp endscore

nolifeleft:
push 0 
push 12
push 7
push str3

call printstr
push 0
push 13
push 7
push str5
call printstr

mov word[cs:pos_num], 2106
push word[cs:score]
call printnum
call delayprint
jmp endofgame

endscore:
push 0
push 13
push 7
push str5
call printstr
mov word[cs:pos_num], 2106
push word[cs:score]
call printnum
call delayprint

mov byte[cs:prevkey], 0
mov word[cs:score], 0
mov word[cs:time], 0 ; reset timer
mov word[cs:seconds], 59
mov word[cs:mins], 3
mov word[cs:snake_size], 20

mov word[cs:gameover], 0

popa
ret
; popa
; pop ax ; ret address
; jmp restart

endofgame:
popa
pop ax ; ret address
jmp exitmain

GameWon:
pusha
mov word[cs:gameover], 1
call clrscr

push 0 
push 12
push 7
push str4
call printstr

push 0
push 13
push 7
push str5
call printstr
mov word[cs:pos_num], 2106
push word[cs:score]
call printnum

mov byte[cs:prevkey], 0
mov word[cs:score], 0
mov word[cs:time], 0 ; reset timer
mov word[cs:seconds], 59
mov word[cs:mins], 3
mov word[cs:snake_size], 20
mov word[cs:gameover], 0

popa
pop ax
jmp main

hurdle1:
pusha
push 0xb800
pop es
mov cx, 40
mov si, 1800
hurdle:
mov byte[es:si], ' '
mov byte[es:si+1], 00110000b
add si, 2
loop hurdle
popa
ret

hurdle1collision:
pusha
push 0xb800
pop es

mov cx, 40
mov si, 1800
hcollision:
cmp si, [cs:snake_position]
je hurdlecollision
add si, 2
loop hcollision
jmp leave1
hurdlecollision:

call GameOverCall
popa
pop ax
jmp restart

leave1:
popa
ret

hurdle2:
pusha
push 0xb800
pop es

mov cx, 40
mov si, 1470
hurdleloop1:
mov byte[es:si], ' '
mov byte[es:si+1], 00110000b
add si,2
loop hurdleloop1

mov cx, 40
mov si, 2300
hurdleloop2:
mov byte[es:si], ' '
mov byte[es:si+1], 00110111b
add si,2
loop hurdleloop2

popa
ret

hurdle2collision:
pusha
push 0xb800
pop es

mov cx,40
mov si,1470
hcollision1:
cmp si,[cs:snake_position]    ;head
je hurdlecollision2
add si,2
loop hcollision1

mov cx, 40
mov si, 2300

hcollision2:
cmp si, [cs:snake_position]
je hurdlecollision2
add si, 2
loop hcollision2

jmp leave2
hurdlecollision2:

call GameOverCall
popa
pop ax
jmp restart
leave2:
popa
ret


printstr: 
push bp
mov bp, sp
push es
push ax
push cx
push si
push di
push ds
pop es ; load ds in es
mov di, [bp+4] ; point di to string
mov cx, 0xffff ; load maximum number in cx
xor al, al ; load a zero in al
repne scasb ; find zero in the string
mov ax, 0xffff ; load maximum number in ax
sub ax, cx ; find change in cx
dec ax ; exclude null from length
jz exit ; no printing if string is empty
mov cx, ax ; load string length in cx
mov ax, 0xb800
mov es, ax ; point es to video base
mov al, 80 ; load al with columns per row
mul byte [bp+8] ; multiply with y position
add ax, [bp+10] ; add x position
shl ax, 1 ; turn into byte offset
mov di,ax ; point di to required location
mov si, [bp+4] ; point si to string
mov ah, [bp+6] ; load attribute in ah
cld ; auto increment mode
nextchar: lodsb ; load next char in al
stosw ; print char/attribute pair
loop nextchar ; repeat for the whole string
exit: pop di
pop si
pop cx
pop ax
pop es
pop bp
ret 8

SelfCollision:
pusha
mov cx, [cs:snake_size]
mov si, [cs:snake_position]
mov di, 2
selfcheck:
cmp si, [cs:snake_position+di]
je found
add di, 2
loop selfcheck

cmp cx, 0
je exitselfcollision

found:

call GameOverCall
popa
pop ax
jmp restart

exitselfcollision:
popa
ret


Collisioncheck:
pusha
mov ax, [cs:snake_position]
cmp ax, [cs:Fruitposition]
jne var1

cmp word[cs:shapetype], 0    ;&
jne no1
add word[cs:score], 2
jmp found1

no1:
cmp word[cs:shapetype], 1    ;*
jne no2
add word[cs:score], 4
jmp found1

no2:
cmp word[cs:shapetype], 2    ;$
jne no3
add word[cs:score], 6
jmp found1

no3:
cmp word[cs:shapetype], 3    ;@
jne no4
add word[cs:score], 8
jmp found1

var1:
jmp notfound
no4:
cmp word[cs:shapetype], 4    ;?
jne no5
add word[cs:score], 10
jmp found1

no5:
cmp word[cs:shapetype], 5   ;%
jne found1
add word[cs:score], 12

found1:
add word[cs:snake_size], 4   ;compare snake size with max size and print time and say user won

cmp word[cs:lives], 3
jne printfoodcheck
call printfood
jmp notfound

printfoodcheck:
cmp word[cs:lives], 2
jne printfoodcheck2
call printfood1
jmp notfound

printfoodcheck2:
call printfood2

notfound:
popa
ret

printfood:
pusha
mov ax, 0xb800
mov es, ax ; point es to video base

recheck:
mov bx, [cs:FoodPtr]
mov di, [cs:Food+bx]
mov dx, [cs:shapetype]

mov si, 0
mov cx, [cs:snake_size]

check:
cmp [cs:snake_position+si], di
je changelocation
add si, 2
loop check
jmp continue

changelocation:
add word[cs:FoodPtr], 2
cmp word[cs:FoodPtr], 40
jne recheck
mov word[cs:FoodPtr], 0    ;all positions food is printed reset to 1st position
jmp recheck

continue:
mov bx, [cs:FoodPtr]
mov di, [cs:Food+bx]

cmp dx, 0
jne n1
mov byte[es:di], '*'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip

n1:
cmp dx,1
jne n2
mov byte[es:di], '$'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip

n2:
cmp dx,2
jne n3
mov byte[es:di], '@'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip

n3:
cmp dx,3
jne n4
mov byte[es:di], '?'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip

n4:
cmp dx,4
jne n5
mov byte[es:di], '%'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip

n5:
cmp dx,5
jne n6
mov byte[es:di], 'o'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip

n6:
cmp dx,6
jne skip
mov byte[es:di],'&'
mov word[cs:shapetype], 0
mov word[cs:Fruitposition], di   ;set fruit position

skip:
add word[cs:FoodPtr], 2
cmp word[cs:FoodPtr], 40
jne ext
mov word[cs:FoodPtr], 0    ;all positions food is printed reset to 1st position

ext:
popa
ret


printfood1:
pusha
mov ax, 0xb800
mov es, ax ; point es to video base

recheck1:
mov bx, [cs:FoodPtr]
mov di, [cs:Food2+bx]
mov dx, [cs:shapetype]

mov si, 0
mov cx, [cs:snake_size]

check1:
cmp [cs:snake_position+si], di
je changelocation1
add si, 2
loop check1
jmp continue1

changelocation1:
add word[cs:FoodPtr], 2
cmp word[cs:FoodPtr], 40
jne recheck1
mov word[cs:FoodPtr], 0    ;all positions food is printed reset to 1st position
jmp recheck1

continue1:
mov bx, [cs:FoodPtr]
mov di, [cs:Food2+bx]

cmp dx, 0
jne n11
mov byte[es:di], '*'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip1

n11:
cmp dx, 1
jne n21
mov byte[es:di], '$'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip1

n21:
cmp dx, 2
jne n31
mov byte[es:di], '@'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip1

n31:
cmp dx, 3
jne n41
mov byte[es:di], '?'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip1

n41:
cmp dx, 4
jne n51
mov byte[es:di], '%'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip1

n51:
cmp dx, 5
jne n61
mov byte[es:di], 'o'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip1

n61:
cmp dx, 6
jne skip1
mov byte[es:di],'&'
mov word[cs:shapetype], 0
mov word[cs:Fruitposition], di   ;set fruit position

skip1:
add word[cs:FoodPtr], 2
cmp word[cs:FoodPtr], 40
jne ext1
mov word[cs:FoodPtr], 0    ;all positions food is printed reset to 1st position

ext1:
popa
ret


printfood2:
pusha
mov ax, 0xb800
mov es, ax ; point es to video base

recheck2:
mov bx, [cs:FoodPtr]
mov di, [cs:Food3+bx]
mov dx, [cs:shapetype]

mov si, 0
mov cx, [cs:snake_size]

check2:
cmp [cs:snake_position+si], di
je changelocation2
add si, 2
loop check2
jmp continue2

changelocation2:
add word[cs:FoodPtr], 2
cmp word[cs:FoodPtr], 40
jne recheck2
mov word[cs:FoodPtr], 0    ;all positions food is printed reset to 1st position
jmp recheck2

continue2:
mov bx, [cs:FoodPtr]
mov di, [cs:Food3+bx]

cmp dx, 0
jne n12
mov byte[es:di], '*'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip2

n12:
cmp dx, 1
jne n22
mov byte[es:di], '$'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip2

n22:
cmp dx, 2
jne n32
mov byte[es:di], '@'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip2

n32:
cmp dx, 3
jne n42
mov byte[es:di], '?'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip2

n42:
cmp dx, 4
jne n52
mov byte[es:di], '%'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip2

n52:
cmp dx, 5
jne n62
mov byte[es:di], 'o'
inc word[cs:shapetype]
mov word[cs:Fruitposition], di   ;set fruit position
jmp skip2

n62:
cmp dx, 6
jne skip2
mov byte[es:di],'&'
mov word[cs:shapetype], 0
mov word[cs:Fruitposition], di   ;set fruit position

skip2:
add word[cs:FoodPtr], 2
cmp word[cs:FoodPtr], 40
jne ext2
mov word[cs:FoodPtr], 0    ;all positions food is printed reset to 1st position

ext2:
popa
ret


delayprint:

pusha
mov bx, 10
dp2:
mov cx, 65000
dp:
shl ax, 0xff
shr ax, 0xff
shl ax, 0xff
shr ax, 0xff

shl ax, 0xff
shr ax, 0xff
shl ax, 0xff
shr ax, 0xff

shl ax, 0xff
shr ax, 0xff
shl ax, 0xff
shr ax, 0xff

shl ax, 0xff
shr ax, 0xff
shl ax, 0xff
shr ax, 0xff

shl ax, 0xff
shr ax, 0xff
shl ax, 0xff
shr ax, 0xff

shl ax, 0xff
shr ax, 0xff
shl ax, 0xff
shr ax, 0xff

shl ax, 0xff
shr ax, 0xff
shl ax, 0xff
shr ax, 0xff

shl ax, 0xff
shr ax, 0xff
shl ax, 0xff
shr ax, 0xff

shl ax, 0xff
shr ax, 0xff
shl ax, 0xff
shr ax, 0xff

loop dp

dec bx
cmp bx, 0
jne dp2

popa
ret

delay:
push cx
push ax
mov cx, word[cs:speed]
d:

shl ax, 0xff
shr ax, 0xff
shl ax, 0xff
shr ax, 0xff

shl ax, 0xff
shr ax, 0xff
shl ax, 0xff
shr ax, 0xff

loop d
pop ax
pop cx
ret


print_time_lives:
pusha
push 0xb800
pop es

;Time print
mov byte[es:0], 'T'
mov byte[es:1], 7
mov byte[es:2], 'i'
mov byte[es:3], 7
mov byte[es:4], 'm'
mov byte[es:5], 7
mov byte[es:6], 'e'
mov byte[es:7], 7
mov byte[es:8], ':'
mov byte[es:9], 7
mov byte[es:10], ' '
mov byte[es:11], 7

cmp word[cs:milliseconds], 1000
jb secondcheck
dec word[cs:seconds]
mov word[cs:milliseconds], 0

secondcheck:
cmp word[cs:seconds], 10
ja nextcheck
mov word[cs:pos_num], 18
push 0
call printnum

nextcheck:
cmp word[cs:seconds], 0
ja printtime
mov word[cs:seconds], 59
dec word[cs:mins]

printtime:
mov word[cs:pos_num], 12
push 0
call printnum

mov word[cs:pos_num], 14
push word[cs:mins]
call printnum

mov byte[es:16], ':'
mov byte[es:17], 7

cmp word[cs:seconds], 10
jae printsecs
mov word[cs:pos_num], 20
push word[cs:seconds]
call printnum
mov word[es:22], 0x0720
jmp printlives

printsecs:
mov word[cs:pos_num], 18
push word[cs:seconds]
call printnum


printscore:
mov byte[es:30], 'S'
mov byte[es:31], 7
mov byte[es:32], 'c'
mov byte[es:33], 7
mov byte[es:34], 'o'
mov byte[es:35], 7
mov byte[es:36], 'r'
mov byte[es:37], 7
mov byte[es:38], 'e'
mov byte[es:39], 7
mov byte[es:40], ':'
mov byte[es:41], 7

mov word[cs:pos_num], 42
push word[cs:score]
call printnum


printlives:
mov byte[es:68], 'T'
mov byte[es:69], 7
mov byte[es:70], 'o'
mov byte[es:71], 7
mov byte[es:72], 't'
mov byte[es:73], 7
mov byte[es:74], 'a'
mov byte[es:75], 7
mov byte[es:76], 'l'
mov byte[es:77], 7
mov byte[es:78], ' '
mov byte[es:79], 7

mov byte[es:80], 'L'
mov byte[es:81], 7
mov byte[es:82], 'i'
mov byte[es:83], 7
mov byte[es:84], 'v'
mov byte[es:85], 7
mov byte[es:86], 'e'
mov byte[es:87], 7
mov byte[es:88], 's'
mov byte[es:89], 7
mov byte[es:90], ':'
mov byte[es:91], 7
mov byte[es:92], ' '
mov byte[es:93], 7

mov word[cs:pos_num], 94
push 3
call printnum


mov byte[es:100], 'R'
mov byte[es:101], 7
mov byte[es:102], 'e'
mov byte[es:103], 7
mov byte[es:104], 'm'
mov byte[es:105], 7
mov byte[es:106], 'a'
mov byte[es:107], 7
mov byte[es:108], 'i'
mov byte[es:109], 7
mov byte[es:110], 'n'
mov byte[es:111], 7
mov byte[es:112], 'i'
mov byte[es:113], 7
mov byte[es:114], 'n'
mov byte[es:115], 7
mov byte[es:116], 'g'
mov byte[es:117], 7
mov byte[es:118], ' '
mov byte[es:119], 7

mov byte[es:120], 'L'
mov byte[es:121], 7
mov byte[es:122], 'i'
mov byte[es:123], 7
mov byte[es:124], 'v'
mov byte[es:125], 7
mov byte[es:126], 'e'
mov byte[es:127], 7
mov byte[es:128], 's'
mov byte[es:129], 7
mov byte[es:130], ':'
mov byte[es:131], 7
mov byte[es:132], ' '
mov byte[es:133], 7

mov word[cs:pos_num], 134
push word[cs:lives]
call printnum

cmp word[cs:mins], 0
jne exitprintime
cmp word[cs:seconds], 1
ja exitprintime

call GameOverCall
popa
pop ax
jmp restart
exitprintime:
popa
ret

bordercollision:
pusha
push 0xb800
pop es

mov si, 160
firstrowcheck:
cmp si, [cs:snake_position]
jne checked1

call GameOverCall
popa
pop ax
jmp restart

jmp exitcheck
checked1:
add si, 2
cmp si, 320
jb firstrowcheck


mov si, 3840
lastrowcheck:
cmp si, [cs:snake_position]
jne checked2

call GameOverCall
popa 
pop ax
jmp restart
checked2:
add si, 2
cmp si, 4000
jb lastrowcheck


mov si, 322
firstcolcheck:
cmp si, [cs:snake_position]
jne checked3

call GameOverCall
popa
pop ax
jmp restart

checked3:
add si, 160
cmp si, 4000
jb firstcolcheck

mov si, 318
lastcolcheck:
cmp si, [cs:snake_position]
jne checked4

call GameOverCall
popa
pop ax
jmp restart

checked4:
add si, 160
cmp si, 4000
jb lastcolcheck

exitcheck:
popa
ret

border:
pusha
push 0xb800
pop es

mov si, 160

firstrow:
mov byte[es:si], ' '
mov byte[es:si+1], 00110111b
add si, 2
cmp si, 320
jb firstrow

mov si, 3840
lastrow:
mov byte[es:si], ' '
mov byte[es:si+1], 00110111b
add si, 2
cmp si, 4000
jb lastrow

mov si, 320
firstcol:
mov byte[es:si], ' '
mov byte[es:si+1], 00110111b
mov byte[es:si+2], ' '
mov byte[es:si+3], 00110111b
add si, 160
cmp si, 4000
jb firstcol

mov si, 316
lastcol:
mov byte[es:si], ' '
mov byte[es:si+1], 00110111b
mov byte[es:si+2], ' '
mov byte[es:si+3], 00110111b
add si, 160
cmp si, 4000
jb lastcol
popa
ret


clrscr: 
push es
push ax
push cx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
xor di, di ; point di to top left column
mov ax, 0x0720 ; space char in normal attribute
mov cx, 2000 ; number of screen locations
cld ; auto increment mode
rep stosw ; clear the whole screen
pop di
pop cx
pop ax
pop es
ret

; subroutine to print a number at top left of screen
; takes the number to be printed as its parameter
printnum: 
push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit: 
mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigit ; if no divide it again
mov di, [cs:pos_num] ; point di to top left column
nextposition:
pop dx ; remove a digit from the stack
mov dh, 0x07 ; use normal attribute
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextposition ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 2

clrarea: 
push es
push ax
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov di, 324 ; point di to top left column
mov si, 476
nextpos: 
mov byte [es:di], ' '
mov byte [es:di+1], 00000000b ; background base color
add di, 2 ; move to next screen location
cmp di, si ; has the whole screen cleared
jb nextpos
add si, 160
add di, 8
cmp si, 3836
jb nextpos
pop di
pop ax
pop es
ret

snakestart:
pusha
push 0xb800
pop es
mov di, 1924 ; mid screen
mov cx, 20

mov si, 240
sub si, [cs:snake_size]

mov ah, 00110111b

snakeprint:
mov al, [cs:snake_body_next+si]
mov [es:di], ax
add di, 2
inc si
loop snakeprint

sub di, 2
mov si, 0
mov cx, [cs:snake_size]

position:
mov word[cs:snake_position+si], di
sub di, 2
add si, 2
loop position

mov word[cs:prevcommand], 4 ; right 
popa
ret

playright:
pusha
push 0xb800
pop es

cmp word[cs:prevcommand], 3; prev command cannot be left
je endright

mov si, word[cs:snake_size]
shl si, 1
sub si, 2

mov di, word[cs:snake_position+si]
mov word[es:di], 0x720


mov cx, [cs:snake_size]
rightloop:
sub si, 2
mov di, word[cs:snake_position+si]
mov word[cs:snake_position+si+2], di
loop rightloop

mov di, word[cs:snake_position + 2]
mov ah, 00110111b
mov al,'X'
mov word[es:di], ax

add di, 2
mov al,'O'
mov word[es:di], ax
mov word[cs:snake_position], di


mov word[cs:prevcommand], 4

endright:

cmp word[cs:lives], 2
jne nexthurdle2
call hurdle1collision
jmp calls1

nexthurdle2:
cmp word[cs:lives], 1
jne calls1
call hurdle2collision

calls1:
call Collisioncheck
call bordercollision
call SelfCollision
popa
ret

playleft:
pusha
push 0xb800
pop es
cmp word[cs:prevcommand], 4 ; prev command cannot be right
je endleft

mov si, word[snake_size]
shl si, 1
sub si, 2

mov di, word[cs:snake_position+si]
mov word[es:di],0x720

mov cx, [cs:snake_size]

leftloop:
sub si, 2
mov di, word[cs:snake_position+si]
mov word[cs:snake_position+si+2], di
loop leftloop

mov di, word[cs:snake_position+2]
mov ah, 00100111B
mov al,'X'
mov word[es:di], ax

sub di, 2
mov al,'O'
mov word[es:di], ax
mov word[cs:snake_position], di

mov word[cs:prevcommand], 3
endleft:

cmp word[cs:lives], 2
jne nexthurdle1
call hurdle1collision
jmp calls

nexthurdle1:
cmp word[cs:lives], 1
jne calls
call hurdle2collision


calls:
call Collisioncheck
call bordercollision
call SelfCollision
cmp word[cs:lives], 3

popa
ret


playup:
pusha
push 0xb800
pop es
cmp word[cs:prevcommand], 2 ; prev command cannot be down
je endup

mov si, word[snake_size]
shl si, 1
sub si, 2

mov di, word[snake_position+si]
mov word[es:di],0x720

mov cx, [cs:snake_size]

uploop:
sub si, 2
mov di, word[snake_position+si]
mov word[snake_position+si+2], di
loop uploop

mov di, word[snake_position+2]
mov ah, 00010111b
mov al,'X'
mov word[es:di], ax

sub di, 160
mov al,'O'
mov word[es:di], ax
mov word[cs:snake_position],di

mov word[cs:prevcommand], 1
endup:

cmp word[cs:lives], 2
jne nexthurdle3
call hurdle1collision
jmp calls2

nexthurdle3:
cmp word[cs:lives], 1
jne calls2
call hurdle2collision

calls2:
call Collisioncheck
call bordercollision
call SelfCollision
popa
ret


playdown:
pusha
push 0xb800
pop es
cmp word[cs:prevcommand], 1 ; prev command cannot be up
je endup

mov si, word[snake_size]
shl si, 1
sub si, 2

mov di, word[snake_position+si]
mov word[es:di],0x720

mov cx, [cs:snake_size]

downloop:
sub si, 2
mov di, word[snake_position+si]
mov word[snake_position+si+2], di
loop downloop

mov di, word[snake_position+2]
mov ah, 01000111b
mov al,'X'
mov word[es:di], ax

add di, 160
mov al,'O'
mov word[es:di], ax
mov word[cs:snake_position],di

mov word[cs:prevcommand], 2
enddown:

cmp word[cs:lives], 2
jne nexthurdle4
call hurdle1collision
jmp calls3

nexthurdle4:
cmp word[cs:lives], 1
jne calls3
call hurdle2collision


calls3:
call Collisioncheck
call bordercollision
call SelfCollision
popa
ret

KeyboardIsr:
pusha

in al, 0x60

cmp word[cs:gameover], 1
je nomatchkey
; push cs
; pop ds

cmp al, byte[cs:prevkey]
je nomatchkey

cmp al, 11001000b ; UP ARROW release scancode
jne next1
call playup
jmp exitisr

next1:
cmp al, 11010000b ; DOWN ARROW release scancode
jne next2
call playdown
jmp exitisr

next2:
cmp al, 11001101b; RIGHT ARROW release scancode
jne next3
call playright
jmp exitisr

next3:
cmp al, 11001011b ; LEFT ARROW release scancode
jne nomatchkey
call playleft

exitisr:
mov byte[cs:prevkey], al

nomatchkey:
mov al, 0x20
out 0x20, al

popa
iret

TimeIsr:
pusha
cmp word[cs:snake_size], 240
jb play
mov word[cs:won], 1
call GameWon
jmp exittime

play:
cmp word[cs:gameover], 1
je var2

add word[cs:time], 1
add word[cs:milliseconds], 55

call SelfCollision
call bordercollision
call Collisioncheck
call print_time_lives

cmp word[cs:lives], 2
jne nexthurdle
call hurdle1collision
jmp checktime

nexthurdle:
cmp word[cs:lives], 1
jne checktime
call hurdle2collision

checktime:
cmp word[cs:time], 364 ; first 20 seconds
ja nextcmp
mov word[cs:speed], 65000; reduce delay
jmp timeover
var2:
jmp exittime
nextcmp:
cmp word[cs:time], 728
ja nextcmp2
mov word[cs:speed], 60000;
jmp timeover

nextcmp2:
cmp word[cs:time], 1092
ja nextcmp3
mov word[cs:speed], 55000
jmp timeover

nextcmp3:
cmp word[cs:time], 1456
ja nextcmp4
mov word[cs:speed], 50000
jmp timeover

nextcmp4:
cmp word[cs:time], 1820
ja nextcmp5
mov word[cs:speed], 45000
jmp timeover

nextcmp5:
cmp word[cs:time], 2184
ja nextcmp6
mov word[cs:speed], 40000;
jmp timeover

nextcmp6:
cmp word[cs:time], 2548
ja nextcmp7
mov word[cs:speed], 35000;
jmp timeover

nextcmp7:
cmp word[cs:time], 2912
ja nextcmp8
mov word[cs:speed], 30000;
jmp timeover

nextcmp8:
cmp word[cs:time], 3276
ja nextcmp9
mov word[cs:speed], 25000;
jmp timeover

nextcmp9:
cmp word[cs:time], 3640
ja nextcmp10
mov word[cs:speed], 20000;
jmp timeover

nextcmp10:
cmp word[cs:time], 4004
ja nextcmp11
mov word[cs:speed], 15000;
jmp timeover

nextcmp11:
cmp word[cs:time], 4368
ja timeover
mov word[cs:speed], 10000;
jmp timeover

timeover:
cmp word[cs:gameover], 1
jne exittime
mov word[cs:time], 0

exittime:
mov al, 0x20
out 0x20, al
popa
iret

start: 
push 0xb800
pop es

xor ax, ax
mov es, ax

cli
mov word[es:9*4], KeyboardIsr
mov [es:9*4+2], cs
mov word [es:8*4], TimeIsr; store offset at n*4
mov [es:8*4+2], cs
sti

restart:
call clrscr
call border
call snakestart
cmp word[cs:lives], 3
jne secondstage
call printfood
jmp upcheck

secondstage:
cmp word[cs:lives], 2
jne thirdstage
call printfood1
call hurdle1
jmp upcheck

thirdstage:
call printfood2
call hurdle2

upcheck:
cmp word[cs:prevcommand], 1
jne downcheck
call playup
call delay
call Collisioncheck

downcheck:
cmp word[cs:prevcommand], 2
jne leftcheck
call playdown
call delay
call Collisioncheck

leftcheck:
cmp word[cs:prevcommand], 3
jne rightcheck
call playleft
call delay
call Collisioncheck

rightcheck:
cmp word[cs:prevcommand], 4
jne exitmain
call playright
call delay

call Collisioncheck
call bordercollision
call SelfCollision

exitmain:
cmp word[cs:gameover], 1
je out1
jmp upcheck

out1:
cmp word[cs:lives], 0
ja restart

main:
mov ax, 0x4c00 ; terminate and stay resident
int 0x21