   !FYCR-DM-DR
   !Module to compute simple scattering rates and convert masses/energies
   !from eV to SI units used in the code.
   module DarkParams
       use precision
       
       implicit none
      
       ! Masses in SI units for use in the code
       real(dl) :: m_DM, m_phi, alpha_DM, alpha_DR
       real(dl) :: sigma_DM_DR 
       real(dl) :: Compton_CT_dark
       real(dl) :: zdec
       real(dl) :: stat_fact
       real(dl) :: stat_fact2
       real(dl) :: dark_dec_const
       
       type dark_params
          real(dl) :: m_DM_GeV 
          real(dl) :: m_phi_MeV
          real(dl) :: alpha_DM
          real(dl) :: alpha_DR
       end type dark_params

       contains

         subroutine calculate_dark_rate(DPP)
           use constants
           implicit none
           type(dark_params) DPP

           !Factors that account for the thermal integral over Fermi-Dirac Statistics
           stat_fact = 310.0d0/147.0d0
           stat_fact2 = 31.0d0/252.0d0
              
           !Define the values for the masses of the dark elements (in SI)
           m_DM = DPP%m_DM_GeV*1.0d9*eV/c**2.d0
           m_phi = DPP%m_phi_MeV*1.0d6*eV/c**2.d0

           !Pass the values of the coupling constants
           alpha_DM = DPP%alpha_DM
           alpha_DR = DPP%alpha_DR
           
           !DM-DR cross section
           !In m^2/J^2, since we need to multiplty by (k_B*T_dark)**2 in order to get the actual cross section
           sigma_DM_DR = 16.0d0*const_pi*alpha_DM*alpha_DR*h_P*h_P*c*c/((m_phi*c**2)**4)

           !Constant used to estimate the epoch of DM decoupling (Gamma_DM_DR = H)
           !(2*sqrt(8*pi**3/90)*m_phi**4*m_DM/(64*pi**3*m_planck*rho_crit*alpha_DM*alpha_DR*stat_fact))**(1/3)
           dark_dec_const = (1.66015d16*(DPP%m_phi_MeV)**4*DPP%m_DM_GeV/ &
                 (32.0d0*const_pi**3*stat_fact*alpha_DM*alpha_DR*1.2209*8.098))**(1.0d0/3.0d0)
            
           !Compton_CT_dark is CT in Mpc/K^6 units
           !Used to get evolution of dark matter temperature
           Compton_CT_dark = MPC_in_sec*254.0d0*const_pi**6*stat_fact2*alpha_DM*alpha_DR &
                *k_B**6/(h_P*(m_phi*c**2)**4*m_DM*c**2)
          
         end subroutine calculate_dark_rate

   end module DarkParams



