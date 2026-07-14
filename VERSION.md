# CAMB_ETHOSV1

Case A2 修復重建版 ETHOS_CAMB。建立日：2026-07-14。

## 出處

- 上游：Cyr-Racine 原版 `bitbucket.org/franyancr/ethos_camb`，commit `3f4c02cd3668`
  （2014-04 版 CAMB 基底）。使用者 GitHub 鏡像：
  `https://github.com/Yu-hsiu/CAMB_ETHOSV1_From_FrancisYan-CyrRacine`（內容 = 原版，未修改）。
- 本套件 = 原版 + 下列修復（全部在原始碼以 `ETHOSV1-FIX(#n)` 註記，編號對應
  `../docs/case_A2_A3_development_plan.md` §3.3 bug 台帳）。
- 根因分析：`../docs/fig1_left_root_cause_analysis.md`。

## 與原版的差異清單

| 檔案 | 位置 | 修復 |
|---|---|---|
| modules.f90 | inithermo_dark（~2470） | #5 播種 t_switch/a_switch，零/極小加熱不再讀未定義值 |
| modules.f90 | inithermo_dark（~2519） | #6 thomc→0 取解析極限，避免 t_dark/0 |
| modules.f90 | inithermo_dark（~2543） | #14 tb≤0 時 cs2=0（完全解耦冷流體極限），σ₈ 不再 NaN |
| modules.f90 | epoch 判斷（~2569） | #7 1/(tau·dotmu) 改乘法形式，零 opacity 語義=立即解耦 |
| equations_ppf.f90 | TC 初始化（~997） | #11 播種 EV%pig_dark/pigdot_dark，提前切換不讀垃圾 |
| equations_ppf.f90 | derivs（~2514） | #8 opacity_dark≤0 時 pb43_dark=0，防 0/0 |
| equations_ppf.f90 | derivs（~2603） | #8 零暗 opacity 時 tight 分支 fallback 自由 DM 方程 |
| equations_ppf.f90 | stiff-DM 分支（~2632） | #9 分支內補算 adotdota，不再依賴堆疊殘值 |
| equations_ppf.f90 | derivs（~2757） | #10 pb43_dark≤0 時 qgdot_dark 用自由流形式 |
| cmbmain.f90 | （~826） | #12 min_i_DM_DR 預設 0，全零 a_n 不再越界索引 |
| equations_ppf.f90 | 暗 TC 關閉切換（~506） | #15 零 opacity 時 TC 閉合式 0/0（2026-07-14 誠實旗標曝光；fast-math 曾掩蓋），改取自由流初值 0 |
| equations_ppf.f90 | stiff-DM 分支（~2634） | #16 slip_dark 除以零 opacity 無守衛（#8 同家族，防禦性），零 opacity 時 slip=0 |
| Makefile | FFLAGS | 現代 gfortran 相容（-ffree-line-length-none、-fallow-argument-mismatch）；**移除 -ffast-math**（它假設無 NaN，會破壞 #7/#8/#10 的零 opacity 保護）；-O3→-O2 |
| ini/（新增） | params_lcdm/n1..n4.ini | Fig.1(left) 五組組態（caption 參數 + Sec.I 宇宙學；get_scalar_cls=F、do_lensing=F、do_nonlinear=0 繞開台帳 #13 的 C_l 路徑） |

## 未修（已知、不擋 Fig.1）

- 台帳 #13 根因面：暗部門缺 RSA 高 k 截斷（equations_ppf.f90:474 開關被註解）——
  只影響 C_l 路徑；Fig.1 組態不進該路徑。
- DarkParams.f90 死代碼（cmbmain.f90:775 `!use DarkParams`、Makefile 無 DarkParams.o）——
  Fig.1 直接給定 a_n，不需要微觀參數換算路徑。
- DR 自交互作用未完整實作（上游 Known Issue #1）——Fig.1 的 b_n=0。
- massive neutrino 相容性（上游 Known Issue #2）——ini 已鎖 3.046 無質量微中子。

## 建置與執行

```bash
make            # 產出 ethos_camb 執行檔（gfortran）
mkdir -p outputs/{lcdm,n1,n2,n3,n4}
for m in lcdm n1 n2 n3 n4; do ./ethos_camb ini/params_$m.ini; done
# T(k) = P_n(k) / P_lcdm(k)，後處理見 ../notebooks/step2_camb_ethosv1_fig1.ipynb
```

驗收標準（Fig.1 left）：T(k) 小 k → 1；n 越大偏離 CDM 的 k 越大；n=1 寬幅抑制近無
DAO、n=4 多次弱阻尼振盪；四組 z_drag 一致（diagnostic 檔 kappadot_cs2.dat）。
