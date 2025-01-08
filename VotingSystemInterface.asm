.MODEL SMALL

.STACK 100H

.DATA
display db "WELCOME TO VOTING SYSTEM INTERFACE$", 0
voterNames db "nafiz", "tanni", "takib"   
voterPasswords db "ab2de", "qa&in", "sk@12"  
msgEnterName db "Enter Voter Name: $", 0
msgEnterPassword db "Enter Password: $", 0
msgAuthSuccessN db "Authentication successful. Proceeding...$", 0
msgAuthFailN db "Incorrect Name or password. Access Denied.$", 0
msgEnterYear db "Enter Your Birth Year: $", 0
msgEligible db "You are eligible to vote.$", 0
msgNotEligible db "You are NOT eligible to vote.$", 0

voterIDs db "1234", "5678", "9101"   
voterpins db "1111", "1234", "5678"  
msgEnterID db "Enter Voter ID: $"
msgEnterPIN db "Enter PIN: $"
msgAuthSuccess db "ID and PIN are valid. Access granted.$"
msgAuthFail db "Incorrect ID or PIN. Try Again.$"
incorrectpassword db "Your password is incorrect.Re-enter again.$"
incorrectpin db "Your pin is incorrect.Re-enter again.$"

msgVotePrompt db "Select a candidate to vote for (1-3): $"
msgVoteSuccess db ".Your vote has been recorded!$"
msgVoteFailure db "Invalid selection. Try again.$"

givenup db "This ID has already voted. Access Denied.$" 
nexttext db "Waiting for the next voter...$"

listprompt db "Showing candidates: $"

msgVoteGiven db "YOUR VOTE IS GIVEN TO CANDIDATE $"

newline db 0DH, 0AH, "$", 0  

votedIDs db 40 dup(0) 

inputName db 5 dup(?)                  
inputPassword db 5 dup(?)              
validPositionN db ?                     
inputYear db 4 dup(?)                  
currentYear dw 2024                   
age dw ?                               
voterCount db 3                        

inputID db 4 dup(?)                 
inputPIN db 4 dup(?)                
validPosition db ?                   
;voterCount db 3                      


candidates db "Candidate 1$","Candidate 2$","Candidate 3$" 
votes db 0, 0, 0
invalidAttemptsPass db 0
invalidAttemptsPin db 0 


MAIN PROC

; Initialize DS
MOV AX, @DATA
MOV DS, AX


; welcome message
LEA DX, display
MOV AH, 09H
INT 21H

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

;*************************************************Nafiz*******************************************

;Voter Name
LEA DX, msgEnterName
MOV AH, 09H
INT 21H


MOV CX, 5                
LEA SI, inputName        

InputNameLoop:
MOV AH, 1               
INT 21h                  
MOV [SI], AL            
INC SI                   
LOOP InputNameLoop       


MOV CX, 3                
LEA DI, voterNames       
MOV validPositionN, -1    

CheckVoterName:
    PUSH CX              
    MOV SI, OFFSET inputName 
    MOV BX, 0            

CompareDigitsN:
    MOV AL, [SI + BX]    
    MOV DL, [DI + BX]    
    CMP AL, DL           
    JNE NotMatchN         
    INC BX               
    CMP BX, 5            
    JNE CompareDigitsN    

    
    MOV AX, DI               
    SUB AX, OFFSET voterNames 
    MOV CL, 5                
    DIV CL                   
    MOV validPositionN, AL    

    POP CX               
    JMP DoneCheckingN     

NotMatchN:
    ADD DI, 5            
    POP CX              
    LOOP CheckVoterName  

DoneCheckingN:
    CMP validPositionN, -1 
    JE InvalidInputName  

;Password 
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

LEA DX, msgEnterPassword
MOV AH, 09H
INT 21H

MOV CX, 5                
LEA SI, inputPassword    

InputPasswordLoop:
MOV AH, 1                
INT 21h                  
MOV [SI], AL             
INC SI                   
LOOP InputPasswordLoop   


MOV AL, validPositionN     
MOV BL, AL                
MOV AX, BX               
MOV CL, 5                
MUL CL                   
LEA DI, voterPasswords    
ADD DI, AX                

MOV CX, 5                
LEA SI, inputPassword     

ComparePassword:
MOV AL, [SI]              
MOV DL, [DI]             
CMP AL, DL              
JNE InvalidInputPassword  
INC SI                    
INC DI                    
LOOP ComparePassword      


MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

LEA DX, msgAuthSuccessN
MOV AH, 09H
INT 21H

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

;Birth year
LEA DX, msgEnterYear
MOV AH, 09H
INT 21H


MOV CX, 4                
LEA SI, inputYear       

InputYearLoop:
MOV AH, 1                
INT 21h                 
MOV [SI], AL             
INC SI                   
LOOP InputYearLoop       


MOV AX, 0                
MOV BX, 10              

LEA SI, inputYear        


MOV CL, [SI]             
SUB CL, '0'              
MOV DX, AX               
MOV AX, BX               
IMUL DX                  
ADD AX, Cx               

INC SI                   

MOV CL, [SI]             
SUB CL, '0'              
MOV DX, AX              
MOV AX, BX               
IMUL DX                 
ADD AX, Cx              

INC SI                   

MOV CL, [SI]             
SUB CL, '0'              
MOV DX, AX               
MOV AX, BX               
IMUL DX                  
ADD AX, Cx               

INC SI                   

MOV CL, [SI]             
SUB CL, '0'             
MOV DX, AX               
MOV AX, BX               
IMUL DX                 
ADD AX, Cx              


MOV BX, currentYear      
SUB BX, AX               
MOV age, BX              


CMP BX, 18               
JL NotEligible          

; Eligible
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

LEA DX, msgEligible
MOV AH, 09H
INT 21H
;JMP EXIT                 

;*******************************Tanni****************************************


;welcome message
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

LEA DX, display
MOV AH, 09H
INT 21H

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

;Voter ID
LEA DX, msgEnterID
MOV AH, 09H
INT 21H


MOV CX, 4                
LEA SI, inputID           

InputIDLoop:
MOV AH, 1               
INT 21h                  
MOV [SI], AL             
INC SI                   
LOOP InputIDLoop         


MOV CX, 3                
LEA DI, voterIDs         
MOV validPosition, -1   

CheckVoterID:
    PUSH CX              
    MOV SI, OFFSET inputID 
    MOV BX, 0           

CompareDigits:
    MOV AL, [SI + BX]    
    MOV DL, [DI + BX]    
    CMP AL, DL          
    JNE NotMatch        
    INC BX              
    CMP BX, 4           
    JNE CompareDigits    

    
    MOV AX, DI          
    SUB AX, OFFSET voterIDs 
    SHR AX, 2            
    MOV validPosition, AL 
    POP CX               
    JMP DoneChecking     

NotMatch:
    ADD DI, 4            
    POP CX               
    LOOP CheckVoterID    

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

DoneChecking:
    CMP validPosition, -1 
    JE InvalidInputID    
    
Mov cl, validPositionN
mov dl, validposition
Cmp cl,dl
JNE InvalidInputID

;PIN
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 


LEA DX, msgEnterPIN
MOV AH, 09H
INT 21H

MOV CX, 4                
LEA SI, inputPIN       

InputPINLoop:
MOV AH, 1                
INT 21h                  
MOV [SI], AL             
INC SI                   
LOOP InputPINLoop        


MOV AL, validPosition    
MOV BL, AL                
MOV AX, BX                
SHL AX, 2                
LEA DI, voterpins         
ADD DI, AX                

MOV CX, 4                 
LEA SI, inputPIN          

ComparePIN:
MOV AL, [SI]              
MOV DL, [DI]              
CMP AL, DL                
JNE InvalidInputPIN       
INC SI                    
INC DI                    
LOOP ComparePIN           

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 


LEA DX, msgAuthSuccess
MOV AH, 09H
INT 21H   
JMP CheckIfIDExists  

;xxxxxx naile shafayet er jumpxxxxxxxxxx
naile:

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 


MOV CX, 3               
LEA SI, candidates       

LEA DX, listprompt
MOV AH, 09H
INT 21h

DisplayCandidatesLoop:
    
    
    MOV AH, 2
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H 
    
    MOV AH, 09H
    LEA DX, [SI]
    INT 21H               

   
    ADD SI, 12            
    
    LOOP DisplayCandidatesLoop


MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

LEA DX, msgVotePrompt
MOV AH, 09H
INT 21H


MOV AH, 1
INT 21h                  
SUB AL, '0'             
MOV BL, AL               


DEC BL                  
MOV SI, OFFSET votes     
ADD SI, BX               
INC BYTE PTR [SI]       





;xxxxxxxxxShafayet er store id and display votesxxxxxxxxxxxxxxxx

;candidate 
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 
LEA DX, msgVoteGiven
MOV AH, 09H
INT 21H


MOV AL, BL
ADD AL, '1'              
MOV DL, AL
MOV AH, 02H
INT 21H


LEA DX, msgVoteSuccess
MOV AH, 09H
INT 21H 

               

JMP StoreVoterID   

hoise:

JMP DisplayVotes 

InvalidInputID:

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H  

LEA DX, msgAuthFail
MOV AH, 09H
INT 21H
JMP EXIT

InvalidInputPIN:

MOV AL, [invalidAttemptsPin]

    
ADD AL, 1

    
MOV [invalidAttemptsPin], AL

   
CMP AL, 3
JGE TooManyInvalidAttempts
MOV AH, 2
MOV DL, 0DH
INT 21H 
MOV DL, 0AH
INT 21H 

LEA DX, incorrectpin
MOV AH, 09H
INT 21H

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H  

LEA DX, msgEnterPIN
MOV AH, 09H
INT 21H


MOV CX, 4                
LEA SI, inputPIN         
JMP InputPINLoop         






NotEligible:
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

LEA DX, msgNotEligible
MOV AH, 09H
INT 21H
JMP EXIT

InvalidInputName:
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

LEA DX, msgAuthFailN
MOV AH, 09H
INT 21H
JMP EXIT

InvalidInputPassword:

MOV AL, [invalidAttemptsPass]

    
ADD AL, 1

    
MOV [invalidAttemptsPass], AL

    
CMP AL, 3
JGE TooManyInvalidAttempts

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

CMP BL, 1
lea dx, incorrectpassword
MOV AH, 09H
INT 21H

MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 

LEA DX, msgEnterPassword
MOV AH, 09H
INT 21H

MOV CX, 5               
LEA SI, inputPassword                  
JE InvalidInputPassword  
INC BL                    
JMP InputPasswordLoop

TooManyInvalidAttempts:
MOV AH, 2
MOV DL, 0DH
INT 21H
MOV DL, 0AH
INT 21H 
   
MOV AH, 09H
LEA DX, msgAuthFailN
INT 21H
JMP EXIT         


LEA DX, msgAuthFailN
MOV AH, 09H
INT 21H
JMP EXIT  


;xxxxxxxxxxxxxxxxxShafayetxxxxxxxxxxxxxxxxxxxxxxx   



DisplayVotes:
  
    MOV AH, 2
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H

    
    

   
    MOV CX, 3               
    LEA SI, votes            
    LEA DI, candidates       

DisplayVoteLoop:
    
    MOV AH, 2
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H

    
    LEA DX, [DI]
    MOV AH, 09H
    INT 21H

   
    ADD DI, 12               

   
    MOV AL, [SI]            
    ADD AL, '0'              
    MOV DL, AL
    MOV AH, 2
    INT 21H

    
    INC SI                   
    LOOP DisplayVoteLoop    

    
    MOV AH, 2
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H   
    





    
    
CheckIfIDExists:
    LEA SI, votedIDs         
    LEA DI, inputID          
    MOV CX, 10               

MatchIDLoop:
    MOV AX, [SI]           
    CMP AX, 0              
    JE AllowVoting         

    CMP AX, [DI]             
    JNE NextID               

    MOV AX, [SI + 2]         
    CMP AX, [DI + 2]         
    JE IDExists             

NextID:
    ADD SI, 4                
    LOOP MatchIDLoop         

AllowVoting:
    JMP naile                     

IDExists:
   
    LEA DX,givenup 
    MOV AH, 09H
    INT 21H

   
    JMP RestartVoting

    
    
StoreVoterID:
    LEA SI, votedIDs         
FindEmptySlot:
    MOV AX, [SI]             
    CMP AX, 0               
    JE FoundSlot             
    ADD SI, 4               
    JMP FindEmptySlot        

FoundSlot:
    LEA DI, inputID          
    MOV AX, [DI]             
    MOV [SI], AX
    MOV AX, [DI + 2]        
    MOV [SI + 2], AX
    JMP hoise
        

RestartVoting:
    MOV AH, 2
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H 

    LEA DX, nexttext
    MOV AH, 09H
    INT 21H

    JMP MAIN              



EXIT:
MOV AX, 4C00H         
INT 21H

MAIN ENDP
END MAIN




