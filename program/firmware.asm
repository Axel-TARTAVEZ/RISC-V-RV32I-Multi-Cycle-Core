00000000 <_start>:
# --- 1. INITIALISATION DU SYSTÈME (Bootloader) ---
 0:  auipc sp, 0x10       # Initialise le pointeur de pile (Stack Pointer)
 4:  mv    sp, sp         
 8:  auipc a0, 0x8        # Prépare l'adresse de début de la section RAM (.data) à 0x8000
 c:  addi  a0, a0, -8     
10:  auipc a1, 0x8        # Prépare l'adresse de fin de la section RAM
14:  addi  a1, a1, -16    
18:  li    a2, 204        
1c:  beq   a0, a1, 34     # Si la RAM est vide de variables pré-initialisées, on passe.
# ... boucle ignorée car la section de données est vide ...
34:  auipc a0, 0x8        
38:  addi  a0, a0, -48    # Prépare l'adresse 0x8004 (section .bss)
3c:  auipc a1, 0x8        
40:  addi  a1, a1, -56    
44:  li    t0, 0          
48:  beq   a0, a1, 58     # (bug corrigé) Si tout est propre, on passe.
# ... nettoyage ignoré ...
58:  jal   60 <main>      # INITIALISATION TERMINÉE : On appelle le code C principal
5c:  j     5c             # Sécurité : Si le main plante, il s'arrête ici.

00000060 <main>:
# --- 2. PRÉPARATION DE LA FONCTION C (Prologue) ---
60:  addi  sp, sp, -32    # Alloue 32 octets sur la pile pour stocker nos variables
64:  sw    ra, 28(sp)     # Sauvegarde l'adresse de retour
68:  sw    s0, 24(sp)     # Sauvegarde le Frame Pointer
6c:  addi  s0, sp, 32     
70:  lui   a5, 0xa        # a5 = 0xA000 (C'EST L'ADRESSE MMIO DE TES AFFICHEURS 7-SEG)
74:  sw    a5, -24(s0)    # On la garde au chaud sur la pile
78:  sw    zero, -20(s0)  # On initialise notre variable "compteur" (i = 0) sur la pile
7c:  j     a4             # On saute à la ligne A4 pour tester la condition de la boucle

# --- 3. LE CORPS DE LA BOUCLE C (Fait la somme) ---
80:  lui   a5, 0x8        # a5 = 0x8000 (Adresse en RAM où on stocke la somme globale)
84:  lw    a4, 0(a5)      # Lit la somme actuelle en RAM
88:  lw    a5, -20(s0)    # Lit le compteur 'i' depuis la pile
8c:  add   a4, a4, a5     # ALU : a4 = somme_actuelle + i
90:  lui   a5, 0x8        
94:  sw    a4, 0(a5)      # RAM : Écrit la nouvelle somme à l'adresse 0x8000
98:  lw    a5, -20(s0)    # Relit 'i'
9c:  addi  a5, a5, 1      # ALU : Incrémente i (i++)
a0:  sw    a5, -20(s0)    # Sauvegarde le nouveau 'i' sur la pile

# --- 4. LA CONDITION DE LA BOUCLE ---
a4:  lw    a4, -20(s0)    # Charge la valeur de 'i'
a8:  li    a5, 99         # a5 = 99
ac:  bge   a5, a4, 80     # Si 99 >= i, la boucle continue (saute à la ligne 80)

# --- 5. FIN DU PROGRAMME ET AFFICHAGE SUR LES LEDS ---
# Quand i vaut 100, on sort de la boucle et on atterrit ici :
b0:  lui   a5, 0x8        
b4:  lw    a5, 0(a5)      # Charge la somme finale calculée depuis 0x8000 (Valeur : 4950)
b8:  mv    a4, a5         
bc:  lw    a5, -24(s0)    # Récupère l'adresse 0xA000 (stockée au tout début)
c0:  sw    a4, 0(a5)      # !!! ECRITURE MMIO !!! Envoie la valeur 4950 (0x1356) vers tes 7 segments !
c4:  nop                  # Temps mort
c8:  j     c4             # BOUCLE INFINIE : Le PC reste piégé entre C4 et C8. Fin du bal.