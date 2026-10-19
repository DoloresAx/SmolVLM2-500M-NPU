# SmolVLM2 Camera Integration & Deployment Todo List

Rock 5B ပေါ်တွင် Camera နှင့် SmolVLM2-500M ကို အောင်မြင်စွာ ချိတ်ဆက်မောင်းနှင်ရန် အဆင့်ဆင့် လုပ်ဆောင်ရမည့် လုပ်ငန်းစဉ်များ-

---

### Step 1: Camera စစ်ဆေးခြင်းနှင့် စမ်းသပ်ခြင်း (Camera Verification)
- [ ] **Camera Device ရှာဖွေခြင်း:**
  ```bash
  sudo apt install -y v4l-utils
  v4l2-ctl --list-devices
  ```
- [ ] **Camera Preview စမ်းသပ်ခြင်း:**
  ```bash
  sudo apt install -y ffmpeg
  # မိမိ camera device node (ဥပမာ- /dev/video5) ဖြင့် စမ်းသပ်ရန်
  ffplay -f v4l2 -video_size 640x480 /dev/video5
  ```

---

### Step 2: System Dependencies နှင့် Libraries သွင်းခြင်း (Environment Setup)
- [ ] **လိုအပ်သော Package များ သွင်းခြင်း:**
  ```bash
  sudo apt update
  sudo apt install -y cmake g++ libopencv-dev
  ```
- [ ] **RKNPU & RKLLM Shared Libraries များ ကူးယူခြင်း:**
  ```bash
  cd SmolVLM2-500M-NPU/aarch64/library
  sudo cp ./*.so /usr/local/lib/
  cd ../include
  sudo cp ./*.h /usr/local/include/
  sudo ldconfig
  ```
- [ ] **RKNPU Driver စစ်ဆေးခြင်း:**
  ```bash
  dmesg | grep -i rknpu
  ```

---

### Step 3: Model Weights များ ဒေါင်းလုဒ်ဆွဲခြင်း (Download Models)
- [ ] `models/` ဖိုဒါထဲသို့ `.rknn` နှင့် `.rkllm` ဖိုင် (၂) ခု ထည့်သွင်းခြင်း:
  * **Vision Model:** `smolvlm2_500m_vision_fp16_rk3588.rknn` (~200MB)
  * **LLM Model:** `smolvlm2_500m_llm_w8a8_rk3588.rkllm` (~500MB)
  ```bash
  cd SmolVLM2-500M-NPU/models
  # Hugging Face: https://huggingface.co/Qengineering/smolvlm2-500m-rk3588
  ```

---

### Step 4: Camera Support Code ပြင်ဆင်ခြင်း (Camera Implementation)
- [ ] Camera မှ Frame ယူပြီး `RKLLM.LoadImage(frame)` သို့ ပို့နိုင်မည့် code ရေးသားခြင်း (ဥပမာ- `src/main_camera.cpp` သို့မဟုတ် `src/main.cpp` တွင် OpenCV `cv::VideoCapture(5)` ဖြင့် ချိတ်ဆက်ခြင်း)။
- [ ] `CMakeLists.txt` တွင် executable အသစ် ထည့်သွင်းပေးခြင်း။

---

### Step 5: Build ပြုလုပ်ခြင်း (Build Project)
- [ ] CMake ဖြင့် C++ binary တည်ဆောက်ခြင်း:
  ```bash
  cd SmolVLM2-500M-NPU
  mkdir -p build && cd build
  cmake ..
  make -j8
  ```

---

### Step 6: စမ်းသပ် အသုံးပြုခြင်း (Testing & Verification)
- [ ] Camera မှတစ်ဆင့် VLM ကို စမ်းသပ်မေးမြန်းခြင်း:
  ```bash
  ./VLM_NPU /dev/video5 ../models/smolvlm2_500m_vision_fp16_rk3588.rknn ../models/smolvlm2_500m_llm_w8a8_rk3588.rkllm
  ```
- [ ] User prompt တွင် `<image>What do you see in the camera?` ဟု မေး၍ အဖြေမှန်ကန်မှု စစ်ဆေးခြင်း။