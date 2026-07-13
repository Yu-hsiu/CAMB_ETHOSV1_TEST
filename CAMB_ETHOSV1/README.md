# ETHOS-CAMB #

Code to compute the cosmological perturbation in the presence of dark
matter interacting with some sort of dark radiation. The parametrization is general enough to encompass a large array of dark matter/dark radiation models. It also allows for a mix of standard cold dark matter and interacting dark matter. 

The usage is similar to standard [CAMB](http://camb.info/) (April 2014 version) but with
extra ETHOS parameters passed to the code to parametrize the dark
matter and dark radiation physics. The details of the parametrization can be found in the first ETHOS [paper](http://arxiv.org/abs/1512.05344).

See params.ini file for details of the ETHOS parameters that can be
passed to the code.

If you use this code, please cite the original CAMB [references](http://camb.info/readme.html#refs), as well
as the first ETHOS [paper](http://arxiv.org/abs/1512.05344).

This code is provided with no guarantee. Use at your own risk.

# Known Issues #

1. The dark radiation self-interaction is not yet fully implemented.
2. The code might not work in the presence of standard massive neutrinos.



 