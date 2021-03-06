
!------------------------------------------------------------------------!
!  The Community Multiscale Air Quality (CMAQ) system software is in     !
!  continuous development by various groups and is based on information  !
!  from these groups: Federal Government employees, contractors working  !
!  within a United States Government contract, and non-Federal sources   !
!  including research institutions.  These groups give the Government    !
!  permission to use, prepare derivative works of, and distribute copies !
!  of their work in the CMAQ system to the public and to permit others   !
!  to do so.  The United States Environmental Protection Agency          !
!  therefore grants similar permission to use the CMAQ system software,  !
!  but users are requested to provide copies of derivative works or      !
!  products designed to operate in the CMAQ system to the United States  !
!  Government without restrictions as to use by others.  Software        !
!  that is used with the CMAQ system but distributed under the GNU       !
!  General Public License or the GNU Lesser General Public License is    !
!  subject to their copyright restrictions.                              !
!------------------------------------------------------------------------!


C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /project/yoj/arc/ICON/src/common/gc_spc_map.F,v 1.2 2011/10/21 16:41:51 yoj Exp $ 

C what(1) key, module and SID; SCCS file; date and time of last delta:
C %W% %P% %G% %U%


      SUBROUTINE GC_SPC_MAP( LOGUNIT, NSPCS_IN, N_GC_OUT, SPMAP, 
     &                       INFL_SP_NAME, SPNAME_OUT )

C***********************************************************************
C
C  FUNCTION: map gas chem profile species to CGRID_SPCS
C             
C  PRECONDITIONS: None
C 
C  KEY SUBROUTINES/FUNCTIONS CALLED: None  
C
C  REVISION HISTORY: Prototype created by Jerry Gipson, January, 1998          
C    13 Jun 11 J.Young: Convert for Namelist redesign + UTILIO_DEFN
C
C***********************************************************************

      USE UTILIO_DEFN
      USE CGRID_SPCS     ! CGRID mechanism species

      IMPLICIT NONE

C Include Files: None

C Arguments:
      INTEGER :: LOGUNIT           ! Ouput log unit number
      INTEGER :: NSPCS_IN          ! Total no. of species in input file
      INTEGER :: N_GC_OUT          ! No. of GC species for IC's
      INTEGER :: SPMAP( * )        ! Map of output species to input species
      CHARACTER( 16 ) :: INFL_SP_NAME( * ) ! Species names on input file
      CHARACTER( 16 ) :: SPNAME_OUT( * )   ! Output file species names
      
C Parameters: None

C External Functions: 
      INTEGER FINDEX               ! Finds the index of a number in a list

C Local Variables:
      CHARACTER( 16 ) :: PNAME = 'GC_SPC_MAP'

      INTEGER ICBC_INDX            ! Index for ICBC NML surrogate name
      INTEGER INDX_SPC             ! Index for NML species name in input file
      INTEGER INDX_SUR             ! Index for NML surrogate name in input file
      INTEGER N                    ! Loop index
      INTEGER NSP                  ! Output species counter

C***********************************************************************

      WRITE( LOGUNIT, 92000 ) 

      NSP = 0

C set map for gas-phase species
      DO N = 1, N_GC_SPC

C find the location of the IC species name in the input file table
         INDX_SPC = INDEX1( GC_SPC( N ), NSPCS_IN, INFL_SP_NAME )

C find the location of the surrogate IC name in the Namelist table
         ICBC_INDX = FINDEX( N, N_GC_ICBC, GC_ICBC_MAP )
         IF ( ICBC_INDX .NE. 0 ) THEN
            INDX_SUR = INDEX1( GC_ICBC( ICBC_INDX ), NSPCS_IN, INFL_SP_NAME )
         ELSE
            INDX_SUR = 0
         END IF

C one or both found
         IF ( INDX_SPC .GT. 0 .OR. INDX_SUR .GT. 0 ) THEN
            NSP = NSP + 1
            IF ( INDX_SUR .GT. 0 ) THEN   ! surrogate name found
               SPMAP( NSP ) = INDX_SUR
            ELSE                          ! surrogate name not found, use species name
               SPMAP( NSP ) = INDX_SPC
            END IF
            SPNAME_OUT( NSP ) = INFL_SP_NAME( SPMAP( NSP ) )
         END IF

      END DO 

      N_GC_OUT = NSP   

      RETURN

C************************* FORMAT STATEMENTS ***************************

92000 FORMAT( /1X, 79 ( '#' ) 
     &        /1X, '#   Species map section'
     &        /1X, 79 ( '#' ) )

      END

