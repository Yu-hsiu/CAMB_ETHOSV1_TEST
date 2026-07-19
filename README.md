## ETHOS-CAMB (CAMB_ETHOSV1_TEST) — debugged rebuild

A debugged rebuild of **ETHOS-CAMB** by Francis-Yan Cyr-Racine, the code that
computes cosmological perturbations for dark matter interacting with dark
radiation (ETHOS parametrization, [arXiv:1512.05344](http://arxiv.org/abs/1512.05344)),
built on CAMB (April 2014 version).

- Upstream: `bitbucket.org/franyancr/ethos_camb` @ commit `3f4c02cd3668`
  (unmodified mirror: [CAMB_ETHOS_From_FrancisYan-CyrRacine](https://github.com/Yu-hsiu/CAMB_ETHOS_From_FrancisYan-CyrRacine))
- This repository = upstream **+ 12 targeted code fixes across 3 files
  (11 fix IDs: #5–#12, #14–#16) + Makefile changes + new `ini/` configurations**.
  Every fix is marked in the source with an `ETHOSV1-FIX(#n)` comment.
  Full Chinese ledger: [VERSION.md](VERSION.md). Rebuilt 2026-07-14.

The physics is unchanged: same ETHOS parametrization, same CAMB 2014-04 base,
same usage (`./ethos_camb params.ini` with extra ETHOS parameters — see
`params.ini` for details).

### What this fork fixes

The upstream code crashes or silently produces NaN (e.g. σ₈) in the
zero/near-zero dark-opacity regime needed to reproduce ETHOS paper Fig. 1(left).
Root causes: uninitialized variables, divisions by zero, and `-ffast-math`
masking the failures.

| File | Location | Fix |
|---|---|---|
| modules.f90 | inithermo_dark (~2470) | **#5** seed `t_switch`/`a_switch`; zero/tiny dark heating no longer reads undefined values |
| modules.f90 | inithermo_dark (~2519) | **#6** take the analytic limit as `thomc→0`, avoiding `t_dark/0` |
| modules.f90 | inithermo_dark (~2543) | **#14** `cs2=0` when `tb≤0` (fully-decoupled cold-fluid limit); σ₈ no longer NaN |
| modules.f90 | epoch test (~2569) | **#7** rewrite `1/(tau·dotmu)` in multiplicative form; zero opacity now means "already decoupled" |
| equations_ppf.f90 | TC init (~997) | **#11** seed `EV%pig_dark`/`pigdot_dark`; early tight-coupling switch no longer reads garbage |
| equations_ppf.f90 | derivs (~2514) | **#8** `pb43_dark=0` when `opacity_dark≤0`, preventing 0/0 |
| equations_ppf.f90 | derivs (~2603) | **#8** tight-coupling branch falls back to free-streaming DM equations at zero dark opacity |
| equations_ppf.f90 | stiff-DM branch (~2632) | **#9** recompute `adotdota` inside the branch instead of relying on stale stack values |
| equations_ppf.f90 | derivs (~2757) | **#10** `qgdot_dark` uses the free-streaming form when `pb43_dark≤0` |
| cmbmain.f90 | (~826) | **#12** `min_i_DM_DR` defaults to 0; all-zero `a_n` no longer indexes out of bounds |
| equations_ppf.f90 | dark TC switch-off (~506) | **#15** tight-coupling closure hits 0/0 at zero opacity (exposed 2026-07-14 by honest floating-point flags; previously masked by fast-math); use the free-streaming initial value 0 |
| equations_ppf.f90 | stiff-DM branch (~2634) | **#16** `slip_dark` division by zero opacity unguarded (defensive, same family as #8); `slip=0` at zero opacity |

Fix **#13** is deliberately **not** fixed — see Known Issues.

### Makefile changes

- Modern gfortran compatibility: `-ffree-line-length-none`, `-fallow-argument-mismatch`
- **Removed `-ffast-math`** — it assumes no NaN/Inf exist and defeats the
  zero-opacity guards of #7/#8/#10
- `-O3` → `-O2`

### New: `ini/` Fig. 1(left) configurations

`ini/params_lcdm.ini` and `ini/params_n1..n4.ini` — five configurations for
reproducing ETHOS paper Fig. 1(left) (caption parameters + Sec. I cosmology;
`get_scalar_cls=F`, `do_lensing=F`, `do_nonlinear=0` to stay off the C_l path
affected by #13).

## Build & Run

```bash
make            # builds ethos_camb (gfortran)
mkdir -p outputs/{lcdm,n1,n2,n3,n4}
for m in lcdm n1 n2 n3 n4; do ./ethos_camb ini/params_$m.ini; done
# T(k) = P_n(k) / P_lcdm(k)
```

Acceptance criteria (Fig. 1 left): T(k) → 1 at small k; larger n departs from
CDM at larger k; n=1 shows broad suppression with almost no DAO, n=4 shows
multiple weakly-damped oscillations; z_drag consistent across the four
interacting runs (diagnostic file `kappadot_cs2.dat`).

## Known Issues

1. **#13 (deliberately unfixed):** the dark sector lacks an RSA high-k cutoff
   (switch commented out at `equations_ppf.f90:474`). Affects only the C_l
   path; the Fig. 1 configurations avoid it.
2. **DarkParams.f90 is dead code** (`cmbmain.f90:775` has `!use DarkParams`;
   not linked in the Makefile). Fig. 1 supplies `a_n` directly, so the
   micro-parameter conversion path is unused.
3. **Dark radiation self-interaction is not fully implemented**
   *(inherited from upstream Known Issue #1)* — Fig. 1 uses `b_n=0`.
4. **Compatibility with standard massive neutrinos is untested**
   *(inherited from upstream Known Issue #2)* — the ini files pin 3.046
   massless neutrinos.

## Citation

If you use this code, please cite the original CAMB
[references](http://camb.info/readme.html#refs) as well as the first ETHOS
[paper](http://arxiv.org/abs/1512.05344).

This code is provided with no guarantee. Use at your own risk.

---

## 中文摘要

本 repo 是針對 Cyr-Racine 原版 ETHOS-CAMB(暗物質–暗輻射交互作用宇宙學擾動程式,
CAMB 2014-04 基底)的**修復重建版**:物理模型不變,修掉原版在零/極低暗
opacity 下崩潰或悄悄產生 NaN 的問題。

- **12 處程式碼修復**(11 個修復編號 #5–#12、#14–#16,原始碼以
  `ETHOSV1-FIX(#n)` 註記),根因為未初始化變數、除以零、以及 `-ffast-math`
  掩蓋錯誤;#13 刻意未修(只影響 C_l 路徑)。
- **Makefile**:移除 `-ffast-math`(它假設無 NaN,會破壞零 opacity 保護)、
  `-O3` 改 `-O2`、加現代 gfortran 旗標。
- **新增 `ini/`**:重現 ETHOS 論文 Fig. 1(left) 的五組組態(lcdm、n1–n4)。
- **未修 4 項**見上方 Known Issues,其中 2 項承襲自上游。

詳細差異台帳(中文)見 [VERSION.md](VERSION.md)。

### Old message from CAMB_ETHOS_From_FrancisYan-CyrRacine

Code to compute the cosmological perturbation in the presence of dark
matter interacting with some sort of dark radiation. The parametrization is general enough to encompass a large array of dark matter/dark radiation models. It also allows for a mix of standard cold dark matter and interacting dark matter. 

The usage is similar to standard [CAMB](http://camb.info/) (April 2014 version) but with
extra ETHOS parameters passed to the code to parametrize the dark
matter and dark radiation physics. The details of the parametrization can be found in the first ETHOS 
[paper](http://arxiv.org/abs/1512.05344).

See params.ini file for details of the ETHOS parameters that can be
passed to the code.

If you use this code, please cite the original CAMB [references](http://camb.info/readme.html#refs), as well
as the first ETHOS [paper](http://arxiv.org/abs/1512.05344).

This code is provided with no guarantee. Use at your own risk.

# Known Issues #

1. The dark radiation self-interaction is not yet fully implemented.
2. The code might not work in the presence of standard massive neutrinos.

 
