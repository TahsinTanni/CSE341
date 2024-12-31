.MODEL SMALL

.STACK 100H

.DATA
display db "WELCOME TO VOTING SYSTEM INTERFACE$", 0
voterNames db "nafiz", "tanni", "takib"   ; Predefined Voter Names (3)
voterPasswords db "ab2de", "qa&in", "sk@12"  ; Corresponding Passwords for each Voter Name
msgEnterName db "Enter Voter Name: $", 0
msgEnterPassword db "Enter Password: $", 0
msgAuthSuccessN db "Authentication successful. Proceeding...$", 0
msgAuthFailN db "Incorrect Name or Password. Access Denied.$", 0
msgEnterYear db "Enter Your Birth Year: $", 0
msgEligible db "You are eligible to vote.$", 0
msgNotEligible db "You are NOT eligible to vote.$", 0

voterIDs db "1234", "5678", "9101"   ; Predefined Voter IDs (3)
voterpins db "1111", "1234", "5678"  ; Corresponding PINs for each Voter ID
msgEnterID db "Enter Voter ID: $"
msgEnterPIN db "Enter PIN: $"
msgAuthSuccess db "ID and PIN are valid. Access granted.$"
msgAuthFail db "Incorrect ID or PIN. Try Again.$"
;newline db 0DH, 0AH, "$"             ; New line for output

msgVotePrompt db "Select a candidate to vote for (1-3): $"
msgVoteSuccess db ".Your vote has been recorded!$"
msgVoteFailure db "Invalid selection. Try again.$"

listprompt db "Showing candidates: $"

msgVoteGiven db "YOUR VOTE IS GIVEN TO CANDIDATE $"

newline db 0DH, 0AH, "$", 0

inputName db 5 dup(?)                  ; Buffer for input (voter name)
inputPassword db 5 dup(?)              ; Buffer for input (password)
validPositionN db ?                     ; Stores the matched name position (offset)
inputYear db 4 dup(?)                  ; Buffer for input (birth year)
currentYear dw 2024                   ; Current year for age calculation
age dw ?                               ; Calculated age
voterCount db 3                        ; Number of voters

inputID db 4 dup(?)                  ; Buffer for input (voter ID)
inputPIN db 4 dup(?)                 ; Buffer for input (PIN)
validPosition db ?                   ; Stores the matched ID position (offset)
;voterCount db 3                      ; Number of voters

; Candidate list and vote storage
candidates db "Candidate 1$","Candidate 2$","Candidate 3$" ; List of candidates
votes db 0, 0, 0                      ; Votes for each candidate (indexed 0 to 2)


MAIN PROC

; Initialize DS
MOV AX, @DATA
MOV DS, AX

; Display welcome message
LEA DX, display
MOV AH, 09H
INT 21H

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

; Prompt user to enter Voter Name
LEA DX, msgEnterName
MOV AH, 09H
INT 21H

; Get Voter Name input
MOV CX, 5                ; Max length of voter name (4 characters)
LEA SI, inputName        ; SI points to buffer

InputNameLoop:
MOV AH, 1                ; DOS function to read a single character
INT 21h                  ; Read input character
MOV [SI], AL             ; Store the character in the buffer
INC SI                   ; Move buffer pointer to next position
LOOP InputNameLoop       ; Loop for 4 characters

; Check the input name against predefined voter names
MOV CX, 3                ; Number of predefined voter names
LEA DI, voterNames       ; DI points to voterNames array
MOV validPositionN, -1    ; Initialize to -1 (no match yet)

CheckVoterName:
    PUSH CX              ; Save loop counter
    MOV SI, OFFSET inputName ; SI points to input buffer
    MOV BX, 0            ; Index for current digit

CompareDigitsN:
    MOV AL, [SI + BX]    ; Load input digit
    MOV DL, [DI + BX]    ; Load current name digit
    CMP AL, DL           ; Compare digits
    JNE NotMatchN         ; If mismatch, go to NotMatch
    INC BX               ; Increment index
    CMP BX, 5            ; Check if all 4 digits are compared
    JNE CompareDigitsN    ; Loop if not

    ; If match found, calculate position
    MOV AX, DI               ; Save the pointer to the matched name
    SUB AX, OFFSET voterNames ; Calculate offset from base
    MOV CL, 5                ; Correct element size (each name is 5 bytes)
    DIV CL                   ; Divide by 5 to get the correct index
    MOV validPositionN, AL    ; Store position in validPosition

    POP CX               ; Restore loop counter
    JMP DoneCheckingN     ; Skip further checks

NotMatchN:
    ADD DI, 5            ; Move to next name
    POP CX               ; Restore loop counter
    LOOP CheckVoterName  ; Continue loop

DoneCheckingN:
    CMP validPositionN, -1 ; Check if no name matched
    JE InvalidInputName  ; If no match, display error

; Prompt for Password input
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break
LEA DX, msgEnterPassword
MOV AH, 09H
INT 21H

MOV CX, 5                ; Max length of password (4 characters)
LEA SI, inputPassword    ; SI points to buffer for password

InputPasswordLoop:
MOV AH, 1                ; DOS function to read a single character
INT 21h                  ; Read input character
MOV [SI], AL             ; Store the character in the buffer
INC SI                   ; Move buffer pointer to next position
LOOP InputPasswordLoop   ; Loop for 4 characters

; Match Password using the stored offset
MOV AL, validPositionN     ; Get the matched name position
MOV BL, AL                ; Copy position to BL
MOV AX, BX                ; Load position into AX
MOV CL, 5                 ; Correct element size (each name/password is 5 bytes)
MUL CL                    ; Multiply by 5 to get the correct offset
LEA DI, voterPasswords    ; DI points to voterPasswords array
ADD DI, AX                ; Adjust DI to matched password position

MOV CX, 5                 ; Compare 4 password digits
LEA SI, inputPassword     ; SI points to input password buffer

ComparePassword:
MOV AL, [SI]              ; Load input password digit
MOV DL, [DI]              ; Load corresponding password digit
CMP AL, DL                ; Compare digits
JNE InvalidInputPassword  ; If mismatch, go to error
INC SI                    ; Move to next digit
INC DI                    ; Move to next password digit
LOOP ComparePassword      ; Loop through all digits

; If password matches, prompt for birth year
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break
LEA DX, msgAuthSuccessN
MOV AH, 09H
INT 21H

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

; Prompt for birth year
LEA DX, msgEnterYear
MOV AH, 09H
INT 21H

; Get Birth Year input (4 digits)
MOV CX, 4                ; Expect 4 digits for year
LEA SI, inputYear        ; SI points to the buffer

InputYearLoop:
MOV AH, 1                ; DOS function to read a single character
INT 21h                  ; Read input character
MOV [SI], AL             ; Store the character in the buffer
INC SI                   ; Move to the next position in the buffer
LOOP InputYearLoop       ; Repeat until all 4 digits are read

; Convert input birth year from ASCII to integer
MOV AX, 0                ; Clear AX to accumulate the year value
MOV BX, 10               ; Base 10 for decimal conversion

LEA SI, inputYear        ; SI points to input year buffer

; Convert each digit from ASCII to integer and calculate the year
MOV CL, [SI]             ; Load the first digit
SUB CL, '0'              ; Convert ASCII to integer
MOV DX, AX               ; Save AX into DX to preserve it
MOV AX, BX               ; Move 10 into AX (for multiplication)
IMUL DX                  ; Multiply AX by 10 (AX = AX * 10)
ADD AX, Cx               ; Add the current digit to AX

INC SI                   ; Move to second digit

MOV CL, [SI]             ; Load the second digit
SUB CL, '0'              ; Convert ASCII to integer
MOV DX, AX               ; Save AX into DX to preserve it
MOV AX, BX               ; Move 10 into AX (for multiplication)
IMUL DX                  ; Multiply AX by 10
ADD AX, Cx               ; Add the second digit

INC SI                   ; Move to third digit

MOV CL, [SI]             ; Load the third digit
SUB CL, '0'              ; Convert ASCII to integer
MOV DX, AX               ; Save AX into DX to preserve it
MOV AX, BX               ; Move 10 into AX (for multiplication)
IMUL DX                  ; Multiply AX by 10
ADD AX, Cx               ; Add the third digit

INC SI                   ; Move to fourth digit

MOV CL, [SI]             ; Load the fourth digit
SUB CL, '0'              ; Convert ASCII to integer
MOV DX, AX               ; Save AX into DX to preserve it
MOV AX, BX               ; Move 10 into AX (for multiplication)
IMUL DX                  ; Multiply AX by 10
ADD AX, Cx               ; Add the fourth digit

; At this point, AX contains the converted year value
MOV BX, currentYear      ; Load the current year (2024)
SUB BX, AX               ; Subtract the entered year from the current year (calculate age)
MOV age, BX              ; Store the calculated age in the 'age' variable

; Compare age to 18 and check eligibility
CMP BX, 18               ; Compare age with 18
JL NotEligible           ; If age is less than 18, jump to not eligible message

; Eligible
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

LEA DX, msgEligible
MOV AH, 09H
INT 21H
;JMP EXIT
;*******************************Tanni****************************************


; Display welcome message
LEA DX, display
MOV AH, 09H
INT 21H

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

; Prompt user to enter Voter ID
LEA DX, msgEnterID
MOV AH, 09H
INT 21H

; Get Voter ID input
MOV CX, 4                ; Max length of voter ID (4 characters)
LEA SI, inputID           ; SI points to buffer

InputIDLoop:
MOV AH, 1                ; DOS function to read a single character
INT 21h                   ; Read input character
MOV [SI], AL             ; Store the character in the buffer
INC SI                   ; Move buffer pointer to next position
LOOP InputIDLoop         ; Loop for 4 characters

; Check the input ID against predefined voter IDs
MOV CX, 3                ; Number of predefined voter IDs
LEA DI, voterIDs         ; DI points to voterIDs array
MOV validPosition, -1    ; Initialize to -1 (no match yet)

CheckVoterID:
    PUSH CX              ; Save loop counter
    MOV SI, OFFSET inputID ; SI points to input buffer
    MOV BX, 0            ; Index for current digit

CompareDigits:
    MOV AL, [SI + BX]    ; Load input digit
    MOV DL, [DI + BX]    ; Load current ID digit
    CMP AL, DL           ; Compare digits
    JNE NotMatch         ; If mismatch, go to NotMatch
    INC BX               ; Increment index
    CMP BX, 4            ; Check if all 4 digits are compared
    JNE CompareDigits    ; Loop if not

    ; If match found, calculate position
    MOV AX, DI           ; Save the pointer to the matched ID
    SUB AX, OFFSET voterIDs ; Calculate offset from base
    SHR AX, 2            ; Divide by 4 (ID length) to get index
    MOV validPosition, AL ; Store position in validPosition
    POP CX               ; Restore loop counter
    JMP DoneChecking     ; Skip further checks

NotMatch:
    ADD DI, 4            ; Move to next ID
    POP CX               ; Restore loop counter
    LOOP CheckVoterID    ; Continue loop

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

DoneChecking:
    CMP validPosition, -1 ; Check if no ID matched
    JE InvalidInputID    ; If no match, display error 
    
Mov cl, validPositionN
mov dl, validposition
Cmp cl,dl
JNE InvalidInputID

; Display message about PIN
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

; Prompt for PIN input
LEA DX, msgEnterPIN
MOV AH, 09H
INT 21H

MOV CX, 4                ; Max length of PIN (4 characters)
LEA SI, inputPIN         ; SI points to buffer for PIN

InputPINLoop:
MOV AH, 1                ; DOS function to read a single character
INT 21h                   ; Read input character
MOV [SI], AL             ; Store the character in the buffer
INC SI                   ; Move buffer pointer to next position
LOOP InputPINLoop        ; Loop for 4 characters

; Match PIN using the stored offset
MOV AL, validPosition     ; Get the matched ID position
MOV BL, AL                ; Copy position to BL
MOV AX, BX                ; Load position into AX
SHL AX, 2                 ; Multiply by 4 (shift left by 2 bits)
LEA DI, voterpins         ; DI points to voterpins array
ADD DI, AX                ; Adjust DI to matched PIN position

MOV CX, 4                 ; Compare 4 PIN digits
LEA SI, inputPIN          ; SI points to input PIN buffer

ComparePIN:
MOV AL, [SI]              ; Load input PIN digit
MOV DL, [DI]              ; Load corresponding PIN digit
CMP AL, DL                ; Compare digits
JNE InvalidInputPIN       ; If mismatch, go to error
INC SI                    ; Move to next digit
INC DI                    ; Move to next PIN digit
LOOP ComparePIN           ; Loop through all digits

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

; If PIN matches, grant access
LEA DX, msgAuthSuccess
MOV AH, 09H
INT 21H

; Voting Section
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

; Display candidates
MOV CX, 3                ; Number of candidates
LEA SI, candidates       ; SI points to the first candidate's name 

LEA DX, listprompt
MOV AH, 09H
INT 21h

DisplayCandidatesLoop:
    ; Display current candidate
    
    MOV AH, 2
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H ; Line break
    MOV AH, 09H
    LEA DX, [SI]
    INT 21H               ; Print the candidate's name

    ; Move to the next candidate in the array
    ADD SI, 12            ; Move SI by 12 to the next candidate name (since each name ends with '$' and is 12 bytes)
    
    LOOP DisplayCandidatesLoop


; Prompt user to select a candidate
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break
LEA DX, msgVotePrompt
MOV AH, 09H
INT 21H

; Get the candidate choice (1-3)
MOV AH, 1
INT 21h                  ; Read user input
SUB AL, '0'              ; Convert ASCII to number (1, 2, or 3)
MOV BL, AL               ; Store the selected candidate number in BL

; Update the vote array
DEC BL                   ; Convert to zero-indexed (1 -> 0, 2 -> 1, 3 -> 2)
MOV SI, OFFSET votes     ; Point to the votes array
ADD SI, BX               ; Move to the selected candidate's position
INC BYTE PTR [SI]        ; Increment the vote for the selected candidate

; Show message with candidate name
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break
LEA DX, msgVoteGiven
MOV AH, 09H
INT 21H

; Show the name of the candidate
MOV AL, BL
ADD AL, '1'              ; Convert index back to 1, 2, or 3
MOV DL, AL
MOV AH, 02H
INT 21H

; Confirm vote has been recorded
LEA DX, msgVoteSuccess
MOV AH, 09H
INT 21H
JMP EXIT                  ; Exit successfully



InvalidInputID:

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break
LEA DX, msgAuthFail
MOV AH, 09H
INT 21H
JMP EXIT

InvalidInputPIN:
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

LEA DX, msgAuthFail
MOV AH, 09H
INT 21H





NotEligible:
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

LEA DX, msgNotEligible
MOV AH, 09H
INT 21H
JMP EXIT

InvalidInputName:
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

LEA DX, msgAuthFailN
MOV AH, 09H
INT 21H
JMP EXIT

InvalidInputPassword:
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H ; Line break

LEA DX, msgAuthFailN
MOV AH, 09H
INT 21H
JMP EXIT

EXIT:
MOV AX, 4C00H         ; Exit to DOS
INT 21H

MAIN ENDP
END MAIN
