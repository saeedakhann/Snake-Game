
    [org 100h]
    ; Adjust the delay subroutine accordingly, the first subroutine
    jmp start
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    strlen: db  3   ;;;(GIVE THE LENGTH OF THE SNAKE HERE)initial length should not be more than 12...  

    string: dw 0x0204,0x0304,0x0404,0x0504,0x0604,0x0704,0x0804,0x0904,0x0a04,0x0b04,0x0c04,0x0d04,0x0b04,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0   ; contains the x-coordinate followed by y-quardinate    ;;
    Food: dw 2000,3000,1000,1500,3700,1694,2500,28,3900                   ;;
    FoodPtr: dw 0                            ;;
    DiscardedTail: dw 0        ; not for the user, it is to lengthen the snake             ;;
                                            ;;
    StrPosition: db 0           ; not for the user                    ;;
    direction: db 2             ; up, down, left or right direction needed for proper head selection       ;;
    SubDirection: db 0     ; for every individual byte, up, down, left or right for appropriate previous byte printing  ;;
    gameover: db 'Game Over! Snake collided with its body.'                  ;;
    newthing: db 0x4d                           ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    start:        ;;;;
             ;;;;
     call AssignASCII     ;;;;
     call cls      ;;;;
      repeatit:     ;;;;
       call PrintSnake   ;;;;
       call KeyOperation  ;;;;
       call FoodCheck   ;;;;
       call CollisionCheck  ;;;;
       call cls    ;;;;
      jmp repeatit    ;;;;
             ;;;;
     exit:       ;;;; 
    mov ax,0x4c00      ;;;;
    int 0x21       ;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



    ;;;;;;;;;;;;;;;;; Subroutines;;;;;;;;;;;;;;;;;;;;;
       
       ;;
       ;;
    ;;;;;;;
     ;;;;;
      ;;;
       ;
       
     
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Delay subroutine needs to be modifed according to dosbox and NASM clockcycles.....
    delay:            ;;;;;;
    push ax            ;;;;;;
    push bx            ;;;;;;
      mov bx,0         ;;;;;
      outerdelay:         ;;;;;
       mov ax,0        ;
       innerdelay:        ;;
        add ax,1       ;
        cmp ax,100  ;;;;;;!!!!!!<<<<<  ;;;
       jne innerdelay       ;;;
                 ;;;
       add bx,1        ;;;
       cmp bx,400  ;;;;!!!!!!!<<<<<  ;;;
      jne outerdelay        ;;;
                 ;;;
    pop bx            ;;;
    pop ax            ;;;
    ret             ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



     
       
       
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GetKey:       ;;
        mov ah,1    ;;
      int 0x16    ;;
            ;;
      jz leavethis   ;;
      mov [newthing],ah  ;;
            ;;
      mov ax,0    ;;
      int 0x16    ;;
      jmp leave1    ;;
            ;;
      leavethis:    ;;
      mov ah,[newthing]  ;;
      leave1:     ;;
      call delay    ;;
      call delay    ;;
      call delay    ;;
      call delay    ;;
     ret    ;;   ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    terminate:           ;;
    call cls           ;;

    mov ah,0x13           ;;
    mov al,1             ;;;;;;;;;;;;;;;;;;
    mov bh,0     ;;      ;;
    mov bl,7     ;;
    mov dx,0x0c08    ;; erminate    ;;
    mov cx,40     ;;
    push cs      ;;
    pop es      ;;      ;;
    mov bp,gameover
    int 0x10


    call delay           ;;
    call delay
    call delay

    jmp exit           ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    blink:       ;
            ;
    ;call blue      ;
    ;call delay      ;
    ;call red       ;
    ;call delay      ;
    ;call blue       ;
    ;call delay      ;
    ;call normal      ;
    jmp keyagain     ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    blue:       ;
    push di       ;
    push ax       ;
    mov di,0      ;
    mov al,0x17      ;
     blueagain:     ;
      mov byte[es:di+1],al ;
      add di,2    ;
      cmp di,4000    ;
     jne blueagain    ;
    pop ax ;      ;
    pop di       ;
    ret        ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    red:       ;
    push di       ; 
    push ax       ;
    mov di,0      ;
    mov al,0x47      ;
     redagain:     ;
      mov byte[es:di+1],al ;
      add di,2    ;
      cmp di,4000    ;
     jne redagain    ;
    pop ax ;      ;
    pop di       ;
    ret        ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    normal:       ;
    push di       ;
    push ax       ;
    mov di,0      ;
    mov al,0x07      ;
     normalagain:    ;
      mov byte[es:di+1],al ;
      add di,2    ;
      cmp di,4000    ;
     jne normalagain    ;
    pop ax       ;
    pop di       ;
    ret        ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    CollisionCheck:    ;
    push bx 
    push ax
     mov bh,0
     mov bl,[strlen]
     shl bx,1
     sub bx,2
     mov ax,[string+bx]
     againCollisionCheck:
     sub bx,2
     cmp ax,[string+bx]
     je terminate
     cmp bx,0
     je exitCollisionCheck
     jmp againCollisionCheck
     
     exitCollisionCheck:
    pop ax 
    pop bx
    ret       ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    KeyOperation:
     push bx
      call GetKey
      
      

      
      mov bh,0
      mov bl,[strlen]
      sub bl,1
      shl bx,1     ; multiply by 2
      mov dx,[string+bx]
      
       cmp ah,0x48
        jne NextKeyOperation2
       cmp dl,0   ; give new head position
        je exit
       
       cmp byte[direction],3
        je blink
        
        
       sub dl,1
       mov byte[newthing],0x48 ;;;;;;;;;;;;;;;;;;;;
       mov [string+bx],dx
       mov byte[direction],1
        jmp exitKeyOperation
      
       NextKeyOperation2:
       cmp ah,0x4d
        jne NextKeyOperation3
       cmp dh,79     ; give new head position
        je exit
       cmp byte[direction],4
        je blink
       add dh,1
       
       mov byte[newthing],0x4d ;;;;;;;;;;;;;;;;;;;;;
       mov [string+bx],dx
       mov byte[direction],2
        jmp exitKeyOperation
       
       NextKeyOperation3:
       cmp ah,0x50
        jne NextKeyOperation4
       cmp dl,24     ; give new head position
        je exit
       cmp byte[direction],1
        je blink
       add dl,1
       
       mov byte[newthing],0x50             ;;;;;;;;;;;;;;
       mov [string+bx],dx
       mov byte[direction],3
        jmp exitKeyOperation
       
       NextKeyOperation4:
       cmp ah,0x4b
        jne keyagain
       cmp dh,0     ; give new head position
        je exit
       cmp byte[direction],2
        je blink
       sub dh,1
       
       mov byte[newthing],0x4b            ;;;;;;;;;;;;;;;
       mov [string+bx],dx
       mov byte[direction],4
        jmp exitKeyOperation
       
       
       keyagain:
        
        call KeyOperation
       
      exitKeyOperation:
      
      
      
      
      pop bx
      
    ret
      
      
      
     


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    AssignASCII:               ;
    ; DESCRIPRION (first 4 asciis contain heads followed by 4 tails, vertical and horizonals straight bodies and then four curved bodies, so total is 14)
     push ax
     push bx
     push cx
     push dx
     
      push ds     ;
      pop es     ; make sure ES = DS
       mov bp, OurFont  ;
       mov cx,15   ; we'll change just 14 of them (read the description of the sub-routine)
       mov dx,1   ; STARTING ASCII NUMBER
       mov bh,16   ; 16 bytes per char
       xor bl,bl   ; RAM block
       mov ax,1100h  ; change font to our font
       int 10h    ; video interrupt
      push 0xb800
      pop es
     pop dx ;;; 2 times down also!!!!!!
     pop cx
     pop bx
     pop ax
    ret  
     mov byte[es:00],1
     mov byte[es:4],2
     mov byte[es:8],3
     mov byte[es:12],4
     mov byte[es:16],5
     mov byte[es:20],6
     mov byte[es:24],7
     mov byte[es:28],8
     mov byte[es:32],9
     mov byte[es:36],10
     mov byte[es:00],14
     mov byte[es:02],11
     mov byte[es:160],13
     mov byte[es:162],12
     
     pop dx
     pop cx
     pop bx
     pop ax
     
     
    ret                  ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    PrintSnake:   ; calls body printing functions one by one   ;;
                      ;;
     call PrintHead              ;;
     call PrintTrunk              ;;
     call PrintTail              ;;
     call ShiftLeft 
     call PrintFood
    ret                  ;;
                      ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    PrintFood:               ;

    push bx
    push di
     mov bx,[FoodPtr]
     mov di,[Food+bx]
     mov byte[es:di],15
     
    pop di
    pop bx

    ret                ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;               ;
    FoodCheck:              ;
    push ax               ;
    push bx
    push cx               ;
    push dx
    push si
    push di
                    ;
      mov al,[strlen]
      call Position
      mov si,ax       ; copy position of the head
      
      mov bx,[FoodPtr]
      mov di,[Food+bx]
      
      cmp si,di
      jne exitFoodCheck
      
      mov bh,0
      mov bl,[strlen]
      shl bx,1
      sub bx,2
      againFoodloop:
      mov ax,[string+bx]          ; shiftig right loop to increase length
      mov [string+bx+2],ax
      sub bx,2
      cmp bx,-2
      jne againFoodloop

      mov ax,[DiscardedTail]
      mov [string],ax
      
      add byte[strlen],1
      add word[FoodPtr],2
      cmp word[FoodPtr],12
      jna exitFoodCheck
      mov word[FoodPtr],0
    exitFoodCheck:  
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax               ;
                    ;
    ret                ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;       ;


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    PrintHead:                ;
     push ax
     push bx
      push 0xb800
      pop es
      mov al,[strlen]        ; requirement of the function
      mov [StrPosition],al
      call Position                                       ; this function returns postion in ax (so for safety ax is pushed in stack at the start!)
      mov bx,ax           ; copy position is pc
      
       cmp byte[direction],0x1
       jne nextcmp2
       mov al,1           ; the ascii of head directed upwards
       mov [es:bx],al
       
        mov [SubDirection],al      ; update 'subdirection' memory place
        jmp headexit
      
       nextcmp2:
       cmp byte[direction],0x2
       jne nextcmp3
       mov al,2          ; the ascii of head directed rightwards
       mov [es:bx],al
        
        mov [SubDirection],al      ; update 'subdirection' memory place
        jmp headexit
       
       nextcmp3:
       cmp byte[direction],0x3
       jne nextcmp4
       mov al,3          ; the ascii of head directed downwards
       mov [es:bx],al
       
        mov [SubDirection],al      ; update 'subdirection' memory place
        jmp headexit
       
       nextcmp4:

       mov al,4          ; the ascii of head directed leftwards
       mov [es:bx],al
       
        mov [SubDirection],al      ; update 'subdirection' memory place
      
     headexit:
     pop bx
     pop ax
      
    ret                  ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    PrintTrunk:                ;
     ;Description (this prints the whole body of the snake)     ;
     againPrintTrunk:
      cmp byte[StrPosition],2
      je exitPrintTrunk
      sub byte[StrPosition],1           ;
      call TrunkOrganPrint           ;
     jmp againPrintTrunk             ;
    exitPrintTrunk:              
    ret                  ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    TrunkOrganPrint:              ;
    ;Description (this function ptints organs relative to body position)
    mov al,[StrPosition]
    call Position
    mov bx,ax                                       ; copy first position position in bx

    mov al,[StrPosition]
    sub al,1
    call Position

      cmp byte[SubDirection],1
      jne OrganCmp2       ; this is main comparison
        sub ax,2
        cmp ax,bx
        jne sub1num2     ; this is sub comparison
        mov al,13
        mov [es:bx],al
         mov byte[SubDirection],4
         jmp exitTrunkOrganPrit
        
        sub1num2:
        sub ax,158
        cmp ax,bx
        jne sub1num3
        mov al,9
        mov [es:bx],al
         jmp exitTrunkOrganPrit
        
        sub1num3:
        mov al,12
        mov [es:bx],al
         mov byte[SubDirection],2
         jmp exitTrunkOrganPrit
      
      OrganCmp2:
      
      cmp byte[SubDirection],2
      jne OrganCmp3       ; this is main comparison
        add ax,160
        cmp ax,bx
        jne sub2num2     ; this is sub comparison
        mov al,13
        mov [es:bx],al
         mov byte[SubDirection],3
         jmp exitTrunkOrganPrit
        
        sub2num2:
        sub ax,158
        cmp ax,bx
        jne sub2num3
        mov al,10
        mov [es:bx],al
         jmp exitTrunkOrganPrit
        
        sub2num3:
        mov al,14
        mov [es:bx],al
         mov byte[SubDirection],1
         jmp exitTrunkOrganPrit
         
       OrganCmp3:
       
       cmp byte[SubDirection],3
       jne OrganCmp4       ; this is main comparison
        sub ax,2
        cmp ax,bx
        jne sub3num2     ; this is sub comparison
        mov al,14
        mov [es:bx],al
         mov byte[SubDirection],4
         jmp exitTrunkOrganPrit
        
        sub3num2:
        add ax,162
        cmp ax,bx
        jne sub3num3
        mov al,9
        mov [es:bx],al
         jmp exitTrunkOrganPrit
        
        sub3num3:
        mov al,11
        mov [es:bx],al
         mov byte[SubDirection],2
         jmp exitTrunkOrganPrit
       
       OrganCmp4:
        ; SubDirection is obviously 4
        add ax,160
        cmp ax,bx
        jne sub4num2     ; this is sub comparison
        mov al,12
        mov [es:bx],al
         mov byte[SubDirection],3
         jmp exitTrunkOrganPrit
        
        sub4num2:
        sub ax,162
        cmp ax,bx
        jne sub4num3
        mov al,10
        mov [es:bx],al
         jmp exitTrunkOrganPrit
        
        sub4num3:
        mov al,11
        mov [es:bx],al
         mov byte[SubDirection],1
    exitTrunkOrganPrit:    
    ret                 ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    PrintTail:                ;
     push ax
     push bx                ;
     ;Description (prints the tail of the snake according to 'SubDirection')    ;
      mov al,1
      call Position ; function returns position in ax
      mov bx,ax         ; copy  
       
       cmp byte[SubDirection],1
       jne NextTailCmp2
       mov al,5 
       mov [es:bx],al
        jmp exitPrintTail
       
       NextTailCmp2:
       cmp byte[SubDirection],2
       jne NextTailCmp3
       mov al,6
       mov [es:bx],al
        jmp exitPrintTail
       
       NextTailCmp3:
       cmp byte[SubDirection],3
       jne NextTailCmp4
       mov al,7
       mov [es:bx],al
        jmp exitPrintTail
       
       NextTailCmp4:
       mov al,8
       mov [es:bx],al
       
    exitPrintTail:  
     pop bx                ;
     pop ax                ;
    ret                  ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                      ;
    ; Description (takes the coordinates from memory poition given by 'al' in al returns position in ax)
    Position:
     push bx
      mov bh,0
      mov bl,al            ; moves the length of the string in bx
      mov ax,0     ; make sure that ah has 0 in it
      shl bx,1                    ; multiply by two as we are dealing with word
      sub bx,2     ; start direction the head position
      
      
      mov al,80
      push bx
       mov bl,[string+bx] ;load y-coordinate from the memore
       mul bl
      pop bx
      mov bl,[string+bx+1] ;multiplication algo (leading x-coordinate)
      mov bh,0     ; make sure that bh shas 0 for proper addition with ax
      add ax,bx
      shl ax,1
     pop bx
    ret

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
    ShiftLeft:                  ;    
    push ax
    push bx
    push cx
     mov bx,[string]
     mov [DiscardedTail],bx
     mov ch,0             ;make sure there is nothing else in ch
     mov cl,[strlen]
     mov bx,0
     sub cx,1
     
      ShiftLeftAgain:
       mov ax,[string+bx+2]
       mov [string+bx],ax
       add bx,2
       sub cx,1
       cmp cx,0
      jne ShiftLeftAgain
    pop cx
    pop bx
    pop ax
    ret                     ;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;
    cls:
     push es
     push di

      mov di,0
      push 0xb800
      pop es
      mov ax,0x0720
      mov cx,2000
      rep stosw 

    pop di
    pop es

    ret
    ;;;;;;;;;;;;;;;;;;;;;;;;



    ; for my own sake I have made it not to word with any background attribute as horizontal characters are different from verticle ones!!!
    ; ascii code 1
    OurFont db 10000001b
        db 10000001b
     db 10000001b
        db 11000011b
     db 11000011b
     db 11100111b
     db 10100111b
     db 10011111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
    ; ascii code 2
     db 00000000b
        db 00000000b
     db 11111111b
     db 11110010b
     db 11110100b
     db 11111000b
     db 11110000b
     db 11100000b
     db 11100000b
     db 11110000b
     db 11111000b
     db 11111100b
     db 11111110b
     db 11111111b
     db 00000000b
     db 00000000b
     
    ; ascii code 3 
     db 11111111b
        db 11111111b
     db 11111111b
        db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 10011111b
     db 10100111b
     db 11100111b
     db 11000011b
     db 11000011b
     db 10000001b
     db 10000001b
     db 10000001b
     
    ; ascii code 4 
     db 00000000b
        db 00000000b
     db 11111111b
     db 01110011b
     db 00110111b
     db 00011111b
     db 00001111b
     db 00000111b
     db 00000111b
     db 00001111b
     db 00011111b
     db 00111111b
     db 01111111b
     db 11111111b
     db 00000000b
     db 00000000b
     ;;;;;;;;;;;;;;;;;;;;;;;;
     ;tail
    ; ascii code 5 
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 01111110b
        db 01111110b
     db 01111110b
     db 00111100b
        db 00111100b
     db 00111100b
     db 00011000b
     db 00011000b
     db 00011000b
     
     
    ; ascii code 6 
     db 00000000b
        db 00000000b
     db 00000000b
     db 00000011b
     db 00001111b
     db 00011111b
     db 01111111b
     db 11111111b
     db 11111111b
     db 01111111b
     db 00011111b
     db 00001111b
     db 00000011b
     db 00000000b
     db 00000000b
     db 00000000b
     
    ; ascii code 7 
     db 00011000b
     db 00011000b
     db 00011000b
     db 00111100b
        db 00111100b
     db 00111100b
     db 01111110b
     db 01111110b
        db 01111110b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     
    ; ascii code 8 
     db 00000000b
        db 00000000b
     db 00000000b
     db 11000000b
     db 11110000b
     db 11111000b
     db 11111110b
     db 11111111b
     db 11111111b
     db 11111110b
     db 11111000b
     db 11110000b
     db 11000000b
     db 00000000b
     db 00000000b
     db 00000000b
     ;;;;;;;;;;;;;; vartical followed by horizontal
    ; ascii code 9 
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     
    ; ascii code 10
     db 00000000b
     db 00000000b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 00000000b
     db 00000000b
     
     ;;;;;;;;;;;;;;;;;;;;;;; turns
     ;opens on left and dows
    ; ascii code 11
     db 00000000b
     db 00000000b
     db 11110000b
     db 11111000b
     db 11111100b
     db 11111110b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
        db 11111111b
     db 11111111b
     
     ; opens from up and left
    ; ascii code 12
        db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111110b
     db 11111100b
     db 11111000b
     db 11110000b
     db 00000000b
     db 00000000b
     
     ;opens from right and top
    ; ascii code 13 
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 0111111b
     db 00111111b
     db 00011111b
     db 00001111b
     db 00000000b
     db 00000000b
     
     ; opens from bottom and right
    ; ascii code 14 
     db 00000000b
     db 00000000b
     db 00001111b
     db 00011111b
     db 00111111b
     db 01111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
        db 11111111b
     db 11111111b
    ;;;;;;;;;;;;;;
    ; Food (apple) ascii 15 decimal
     db 00000000b
        db 00000000b
     db 00000000b
     db 00100000b
     db 00010000b
     db 01101010b
     db 11111111b
     db 11111111b
     db 11111111b
     db 01111110b
     db 00111100b
     db 00011000b
     db 00000000b
     db 00000000b
     db 00000000b
     db 00000000b
