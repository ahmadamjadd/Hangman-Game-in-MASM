display_str MACRO str

    
    mov ah, 09h
    mov dx, offset nl
    INT 21h

    
    mov ah, 09h
    mov dx, offset str
    INT 21h

    mov ah, 09h
    mov dx, offset nl
    INT 21h


ENDM

delay MACRO 

    mov cx, 10000
    RUN:
    LOOP RUN
ENDM

get_len MACRO str

    mov si, offset str
    mov bl, len_wrd
    get:
        mov al, [si]
        cmp al, "$"
        je got_it
        add len_wrd, 1
        inc si
        jmp get
        
        got_it:
ENDM

add_null MACRO
    
    mov si, offset guesses_wrd
    mov dh, 0
    mov dl, len_wrd
    mov cx, dl

    add_end_char:
        inc si
    LOOP add_end_char

    mov BYTE PTR [si], '$'
ENDM

print_guess_word MACRO

    display_str nl

    mov si, offset guesses_wrd

    print_loop:
        mov dl, [si]

        cmp dl, '$'
        je completed
        mov ah, 02h
        INT 21h

        ; display_str space

        inc si
        jmp print_loop
    completed:
        display_str nl

ENDM


print_var MACRO var
    LOCAL skip_tens
    push ax
    push bx
    push dx

    mov al, var
    mov ah, 0

    mov bl, 10
    div bl  ; AL = quotient (tens), AH = remainder (ones) 

    mov bl, ah ;save ah

    cmp al, 0
    je skip_tens

    add al, 48    
    mov dl, al
    mov ah, 02h    
    int 21h

    skip_tens:

        add bl, 48
        mov dl, bl
        mov ah, 02h
        int 21h

    pop dx
    pop bx
    pop ax
ENDM


cls MACRO
    mov ah, 0      
    mov al, 3      
    int 10h       
ENDM

.model small
.stack 100h
.data
    space db " ", "$"
    selected db 10 dup('$')
    enter db "Enter a letter: ", "$"
    nl db 0Ah, "$"
    guesses_wrd db 10 dup("-")
    not_str db "Wrong guess! You lost a point", "$"
    yes_str db "Thats right! You got it", "$"
    lost db "You lost!! Another game?", "$"
    len_wrd db 0
    entered_words db 26 dup("-"), "$"
    bf db "Change entered_words size", "$"
    exp db "!!!!!!!!!!!!!!!!!!!!!!!!!!!", "$"
    won db "Congrats! You won the game", "$"
    ; words    db "apple", 0, "mango", 0, "grape", 0, "banana", 0, "cherry", 0
    ; wordPtrs dw offset words, offset words+6, offset words+12, offset words+18, offset words+25
    chances db 10
    score db 0
    left db "Chances left: ", "$"
    scr db "Score: ", "$"
    chars db "Here's a Hint for you: ", "$"

    choose_difficulty db "What do you want you difficulty to be? { e(Easy)\{m(medium)\h(hard) }", "$"
    rim db "Focus! e OR m OR h", "$"

    final_score db "Final Score: ", "$"
    final_ch db "Mistakes to spare: ", "$"

    fs db 0
    
    ; ASCII Art for hangman stages
    stage0 db "  +---+", 0Ah
           db "  |   |", 0Ah
           db "      |", 0Ah
           db "      |", 0Ah
           db "      |", 0Ah
           db "      |", 0Ah
           db "=========", "$"
           
    stage1 db "  +---+", 0Ah
           db "  |   |", 0Ah
           db "  O   |", 0Ah
           db "      |", 0Ah
           db "      |", 0Ah
           db "      |", 0Ah
           db "=========", "$"
           
    stage2 db "  +---+", 0Ah
           db "  |   |", 0Ah
           db "  O   |", 0Ah
           db "  |   |", 0Ah
           db "      |", 0Ah
           db "      |", 0Ah
           db "=========", "$"
           
    stage3 db "  +---+", 0Ah
           db "  |   |", 0Ah
           db "  O   |", 0Ah
           db " /|   |", 0Ah
           db "      |", 0Ah
           db "      |", 0Ah
           db "=========", "$"
           
    stage4 db "  +---+", 0Ah
           db "  |   |", 0Ah
           db "  O   |", 0Ah
           db " /|\  |", 0Ah
           db "      |", 0Ah
           db "      |", 0Ah
           db "=========", "$"
           
    stage5 db "  +---+", 0Ah
           db "  |   |", 0Ah
           db "  O   |", 0Ah
           db " /|\  |", 0Ah
           db " /    |", 0Ah
           db "      |", 0Ah
           db "=========", "$"
           
    stage6 db "  +---+", 0Ah
           db "  |   |", 0Ah
           db "  O   |", 0Ah
           db " /|\  |", 0Ah
           db " / \  |", 0Ah
           db "      |", 0Ah
           db "=========", "$"
           
    TIL db "HANGMAN GAME", "$"
    welcome db "Welcome to Hangman! Try to guess the word.", "$"

    easyWords db "apple",0, "cat",0, "india",0, "dog",0
    easyPtrs  dw offset easyWords, offset easyWords+6, offset easyWords+10, offset easyWords+16


    mediumWords db "banana",0, "tiger",0, "france",0, "lion",0
    mediumPtrs dw offset mediumWords, offset mediumWords+7, offset mediumWords+13, offset mediumWords+20


    hardWords db "cherry",0, "elephant",0, "australia",0, "rhinoceros",0
    hardPtrs dw offset hardWords, offset hardWords+7, offset hardWords+16, offset hardWords+26


.code
    mov ax, @data
    mov ds, ax
    
    cls 
    display_str TIL
    display_str welcome
    cls

    call get_string 

    get_len selected
    add_null

    display_str chars
    display_str guesses_wrd

    mov bx, chances
    
    gameloop:

        try_again:
            
            ; Display ASCII Art
            cmp chances, 10
            je show_stage0
            cmp chances, 8
            jae show_stage1
            cmp chances, 6
            jae show_stage2
            cmp chances, 5
            je show_stage3
            cmp chances, 4
            je show_stage4
            cmp chances, 2
            jae show_stage5
            jmp show_stage6
            
            show_stage0:
                display_str stage0
                jmp after_art
            show_stage1:
                display_str stage1
                jmp after_art
            show_stage2:
                display_str stage2
                jmp after_art
            show_stage3:
                display_str stage3
                jmp after_art
            show_stage4:
                display_str stage4
                jmp after_art
            show_stage5:
                display_str stage5
                jmp after_art
            show_stage6:
                display_str stage6
                
            after_art:
            
            display_str left
            print_var chances

            display_str scr
            print_var score

            display_str enter
            ;Take user input
            mov ah, 01h
            int 21h
            push ax ;Store al as is_entered returns values in it
            ;cmp al, 'h'
            ;je HINT -> if difficulty is e then print 'THe first letter is x' else if med then tell 
        
            call is_entered
            cmp al, 1 ;Duplicate was found
            jne ll
            jmp try_again
            ll:
            cmp al, 2
            je warning 
            jmp continue
    
        warning:
            display_str bf

        continue:
            pop ax

            call compare_and_store_word
            push dx ;Below uses dx also. So I have save dx
            print_guess_word 
            pop dx

            cmp dx , 1
            jne skip_gameloop
            jmp gameloop
            skip_gameloop:
    
            jne WRONG
    WRONG:
        ; print_var score
        ; I don't know why score is getting changed here. From print statements 
        ;I identified where score reset to 0 and made sure to load it into a dl to temporary store it and later restore it
        display_str not_str
        push dx
        mov dl, score
        sub bx, 1 ;Mistakes
        ; print_var score
        mov chances, bx
        ; print_var score
        mov score, dl
        pop dx
        cmp bx, 0
        jne ff
        jmp game_end ;if 0 then game over
        ff:
        jmp gameloop

    game_over:
        cls ; Clear screen before showing game result
        mov al, len_wrd
        cmp al, 0
        je game_win
        cmp bx, 0
        jne tt
        jmp game_end
        
        tt:
        game_win:
            mov   al, score   
            mov   bl, chances   
            mul   bl               
            mov   bl, 2
            div   bl               
            cmp al, 100
            jb keep_it
            mov al, 99
            keep_it:
                mov fs, al

            display_str final_score
            print_var fs
            
            
            display_str exp
            display_str won
            display_str exp


            jmp game_over_actually

        game_end:
            display_str stage6 ; Show complete hangman
            display_str lost

        game_over_actually:
            mov ah, 04ch
            INT 21h

compare_and_store_word PROC 
    xor dx, dx
    ;display_str selected
    
    ; Get index of word
    mov si, offset selected
    mov di, offset guesses_wrd


    COMPARE:
        ;compare entered letter with letters in chosen word
        mov cl, [si]
        cmp al, cl
        je EQUAL

        RETURN:
            inc si
            inc di
            cmp cl, "$"
            je finish
            
            jmp COMPARE
    EQUAL:
        display_str yes_str
        mov [di], al
        mov dx, 1 ;return true
        call end_game

        jmp RETURN
        finish:
            RET
compare_and_store_word ENDP

end_game PROC

    add score, 2
    sub len_wrd, 1
    cmp len_wrd, 0
    jne skip
    jmp game_over
    skip:


    RET
end_game ENDP

is_entered PROC
    mov si, offset entered_words

    search_loop:
        mov cl, [si]
        cmp cl, al
        je duplicate_found
        cmp cl, '$'
        je not_found
        inc si
        jmp search_loop

    duplicate_found:
        mov al, 1      ; flag = 1 means duplicate found
        ret

    not_found:
        mov si, offset entered_words

    find_empty:
        mov cl, [si]
        cmp cl, '-'
        je store_letter
        cmp cl, '$'
        je buffer_full
        inc si
        jmp find_empty

    store_letter:
        mov [si], al
        mov al, 0      ; flag = 0 means stored successfully
        ret

    buffer_full:
        mov al, 2      ; flag = 2 means buffer full
        ret

is_entered ENDP


get_string PROC
    
    ag:
    display_str choose_difficulty
    mov ah, 01h
    INT 21h

    mov ah, 0
    push ax

    ; Get clk ticks
    mov ah, 00h
    int 1Ah   
    mov al, dl              
    and al, 00000111b       ; Mask to have only 7 possibilies
    cmp al, 04              
    jbe ok_index ;If selected index < 4
    mov al, 03              ; Fallback
    
ok_index: 
    mov bl, al
    xor bh, bh              
    shl bx, 1 ; Mul by 2 to get actual offset 

    pop ax
    cmp al, 'e'
    je Easy
    cmp al, 'm'
    je MED
    cmp al, 'h'
    je HARD
    display_str rim
    jmp ag

    EASY: 
        mov si, easyPtrs[bx]   ; Get offset of the chosen word
        jmp CONT
    MED:
        mov si, mediumPtrs[bx]   ; Get offset of the chosen word
        jmp CONT
    HARD: 
        mov si, hardPtrs[bx]   ; Get offset of the chosen word
    CONT: 
    lea di, selected ; Get address of selected

;Copy from array to selected
copy_loop:
    mov al, [si]            
    cmp al, 0              
    je done_copy
    mov [di], al          
    inc si
    inc di
    jmp copy_loop

done_copy:
    mov byte ptr [di], '$'  ; Null terminate the string
    RET
get_string ENDP

END