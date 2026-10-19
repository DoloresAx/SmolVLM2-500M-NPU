# Rock 5B Hardware Summary

### ၁။ စက်အခြေအနေ (Specifications)
* **Board:** Radxa Rock 5B (RK3588 / RK3588S)
* **Architecture:** ARM64 (`aarch64`)
* **CPU:** 8 Cores (4x A76 + 4x A55)
* **NPU:** 6 TOPS (Tri-Core)
* **RAM:** 4 GB (လက်ရှိ လွတ်နေသော RAM: ~3.4 GB)

---

### ၂။ SmolVLM2-500M နှင့် ကိုက်ညီမှု (Compatibility)
* **အခြေအနေ:** **လုံးဝ သုံးလို့ ရပါသည် (100% OK)**
* **Memory:** Model က 0.8 GB ခန့်သာ သုံးသောကြောင့် RAM 2.5 GB ကျော် လွတ်လပ်စွာ ကျန်ရှိပါမည်။
* **Speed:** RK3588 NPU ပေါ်တွင် တစ်စက္ကန့်လျှင် **~31 tokens/s** ခန့် ထွက်ပါမည်။

---

### ၃။ Board ပေါ်တွင် Run ရန် အဆင့်များ (Quick Start)

```bash
# ၁။ လိုအပ်သော library များ ထည့်သွင်းခြင်း
sudo apt update && sudo apt install -y cmake g++ libopencv-dev
cd SmolVLM2-500M-NPU/aarch64/library && sudo cp ./*.so /usr/local/lib/
cd ../include && sudo cp ./*.h /usr/local/include/
sudo ldconfig

# ၂။ Build လုပ်ခြင်း
cd ../../
mkdir build && cd build
cmake ..
make -j8

# ၃။ Run စမ်းသပ်ခြင်း
./VLM_NPU ../Moon.jpg ../models/smolvlm2_500m_vision_fp16_rk3588.rknn ../models/smolvlm2_500m_llm_w8a8_rk3588.rkllm
```

---

### ၄။ မူရင်း System Info
* **Free RAM:** 3.46 GiB / 4 GiB
* **Used RAM:** 729 MiB
* **CPU Arch:** aarch64 (Cortex-A76 @ 2.35GHz + Cortex-A55 @ 1.8GHz)
