.data
    formatScanf:.asciz "%d"
    formatPrint:.asciz "%d " 
    endl:.asciz "\n"
    n: .space 4 
    nr_leg: .space 4000
    count: .space 4
    leg: .space 4
    m1: .space 4000000
    m2: .space 4000000
    mres: .space 4000000
    poz:.space 4
    p:.space 4
    count1:.space 4
    cr: .space 4
    k: .space 4
    src: .space 4
    dest: .space 4

.text

    matrix_mult:
        pushl %ebp
        movl %esp,%ebp
       
        pushl %edi
        pushl %esi
        pushl %ecx
        pushl %ebx
        
        mov 8(%ebp),%esi 
        mov 12(%ebp),%edi
        mov 16(%ebp),%ebx

        # Echivalentul in C pentru:
        # 
        #   for (int i=0;i<n;i++)
        #       for (int j=0;j<n;j++)
        #           for (int k=0;k<n;k++)
        #               C[i][j]=A[i][k]+B[k][j] 
        # 
        # (Unde C[][] este matricea rezultat si A[][] si B[][] sunt m1 si m2)
        #
        # -4(%ebp)  # i
        # -8(%ebp)  # j
        # -12(%ebp) # k  
        
        subl $16,%esp
        
        xorl %ecx,%ecx 
        xorl %edx,%edx

        for_i:
            cmp 20(%ebp), %ecx
            je end_f
            movl %ecx, -4(%ebp)
            xorl %ecx, %ecx
            
            
            for_j:
                cmp 20(%ebp), %ecx
                mov %ecx, -8(%ebp)
                je end_j
                xorl %edx,%edx

                for_k:
                    
                    cmp 20(%ebp), %edx
                    mov %edx, -12(%ebp)
                    je end_k

                    movl 20(%ebp),%eax   
                    mull -4(%ebp)
                    addl -12(%ebp),%eax
                    
                    movl (%esi,%eax,4), %eax
                    mov %eax,-16(%ebp)
                    
                    
                    movl 20(%ebp),%eax
                    mull -12(%ebp)
                    addl -8(%ebp),%eax

                    movl (%edi,%eax,4), %eax
                    mull -16(%ebp)
                    
                    movl %eax,-16(%ebp)
                    
                    movl 20(%ebp),%eax
                    mull -4(%ebp)
                    addl -8(%ebp),%eax

                    movl -16(%ebp), %edx
                    addl %edx,(%ebx,%eax,4)

                    mov -12(%ebp),%edx
                    incl %edx
                
                jmp for_k
            
            end_k:
            
            mov -8(%ebp), %ecx
            inc %ecx
            jmp for_j
        
        
        end_j:
        mov -4(%ebp), %ecx
        inc %ecx
        jmp for_i

     
        end_f:
        mov %ebx, 16(%ebp)
     
        addl $16,%esp 

        popl %ebx
        popl %ecx
        popl %esi
        popl %edi
        popl %ebp
    
    ret

.global main

    main:
        
        pushl $cr
        pushl $formatScanf
        call scanf
        popl %edx
        popl %edx

        pushl $n
        pushl $formatScanf
        call scanf
        popl %edx
        popl %edx

        lea nr_leg,%esi
        xorl %ecx,%ecx
    
    for_nrleg:
        cmp n,%ecx
        je end_for_nrleg
        xorl %eax,%eax
        movl %ecx,count

        pushl $leg
        pushl $formatScanf
        call scanf
        popl %edx
        popl %edx

        movl leg,%eax
        movl count,%ecx

        movl %eax,(%esi,%ecx,4)
        incl %ecx
        jmp for_nrleg

    end_for_nrleg:
        
        xorl %ecx,%ecx
        lea m1,%edi

    for_leg:
        
        cmp n,%ecx
        je busy
        
        movl (%esi,%ecx,4),%ebx
        
        movl %ebx, poz
        xorl %ebx ,%ebx
        movl %ecx,count
        xorl %ecx,%ecx        
        
        for_read_leg:
            cmp poz, %ecx
            je end_for_read_leg 

            movl %ecx,count1

            pushl $leg
            pushl $formatScanf
            call scanf
            popl %edx
            popl %edx
            
            
            movl count1,%ecx
            mov n,%eax
            mov count,%ebx
            mul %ebx
            mov leg,%ebx
            add %ebx,%eax
            mov %eax,%edx

            movl $1, (%edi,%edx,4)

            incl %ecx
            jmp for_read_leg
        
        end_for_read_leg:
            movl count,%ecx
            incl %ecx
            jmp for_leg    
    busy:
        xorl %edx,%edx
        movl n,%eax
        movl n,%ebx
        mul %ebx
        mov %eax,p 
        xorl %ecx,%ecx


    cmpl $2,cr
    je cerinta2
   
    afis:

        cmp p,%ecx
        je end_exit

        mov %ecx,count
        
        pushl (%edi,%ecx,4)
        pushl $formatPrint
        call printf
        
        popl %edx
        popl %edx
        
        xorl %edx,%edx
        
        mov count,%ecx
        mov %ecx,%eax
        mov n,%ebx
        divl %ebx

        cmp $0,%edx
        jne old

        new:
            cmp $0,%ecx
            je old
            movl $4, %eax
            movl $1, %ebx
            movl $endl, %ecx
            movl $2, %edx
            int $0x80

        old:
            pushl $0
            call fflush
            popl %ebx
            mov count,%ecx
            incl %ecx
    af:
    jmp afis
    
    cerinta2:
        lea m2,%esi     
        xorl %ecx,%ecx
        xorl %eax,%eax

        atrib:              
            cmp p,%ecx
            je guds
            movl (%edi,%ecx,4),%ebx
            mov %ebx,(%esi,%ecx,4)
            incl %ecx
        
        jmp atrib
        
        guds:            
            pushl $k
            pushl $formatScanf
            call scanf
            popl %ebx
            popl %ebx

            movl k,%eax
            subl $1,%eax
            movl %eax,k
        
        xorl %ecx,%ecx
        
        tlof:    
        
            cmp k,%ecx
            mov %ecx, count
            je cer2_end

            pushl n
            pushl $mres
            pushl $m2
            pushl $m1
            call matrix_mult
            popl %edx
            popl %edx
            popl %edx
            popl %edx

            lea mres,%ebx
            lea m1,%edi
            
            xorl %ecx,%ecx
            xorl %eax,%eax

            atrib1:                
                cmp p,%ecx
                je atrib2_beg
                movl (%ebx,%ecx,4),%eax
                mov %eax,(%edi,%ecx,4)
                incl %ecx

            jmp atrib1
            
            atrib2_beg:
            xorl %ecx,%ecx
            
            atrib2:                
                
                cmp p,%ecx
                je plof
                movl $0,(%ebx,%ecx,4)
                incl %ecx

            jmp atrib2

        plof:
            mov count, %ecx
            incl %ecx
        jmp tlof


        cer2_end:

            pushl $src
            pushl $formatScanf
            call scanf
            popl %edx
            popl %edx
            
            pushl $dest
            pushl $formatScanf
            call scanf
            popl %edx
            popl %edx

            movl src,%eax
            mull n
            addl dest,%eax
            movl %eax,%ecx

            pushl (%edi,%ecx,4)
            pushl $formatPrint
            call printf
            popl %edx
            popl %edx

            pushl $0
            call fflush
            popl %ebx
           
    end_exit:
        movl $4, %eax
        movl $1, %ebx
        movl $endl, %ecx
        movl $4, %edx
        int $0x80
    exit:
        movl $1,%eax
        xorl %ebx,%ebx
        int $0x80
